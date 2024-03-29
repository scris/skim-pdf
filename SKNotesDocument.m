//
//  SKNotesDocument.m
//  Skim
//
//  Created by Christiaan Hofman on 4/10/07.
/*
 This software is Copyright (c) 2007
 Christiaan Hofman. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 - Neither the name of Christiaan Hofman nor the names of any
    contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SKNotesDocument.h"
#import "SKNoteOutlineView.h"
#import "SKDocumentController.h"
#import "SKTemplateParser.h"
#import "SKApplicationController.h"
#import "NSValue_SKExtensions.h"
#import "NSURL_SKExtensions.h"
#import "SKTypeSelectHelper.h"
#import <SkimNotes/SkimNotes.h>
#import "SKNotesPage.h"
#import "SKPDFDocument.h"
#import "SKNoteText.h"
#import "PDFAnnotation_SKExtensions.h"
#import "SKStringConstants.h"
#import "SKFDFParser.h"
#import "SKStatusBar.h"
#import "NSWindowController_SKExtensions.h"
#import "NSDocument_SKExtensions.h"
#import "NSMenu_SKExtensions.h"
#import "NSView_SKExtensions.h"
#import "NSFileManager_SKExtensions.h"
#import "SKToolbarItem.h"
#import "NSToolbarItem_SKExtensions.h"
#import "SKPrintableView.h"
#import "SKPDFView.h"
#import "NSPointerArray_SKExtensions.h"
#import "SKScrollView.h"
#import "NSColor_SKExtensions.h"
#import "NSString_SKExtensions.h"
#import "NSError_SKExtensions.h"
#import "SKTemplateManager.h"
#import "NSArray_SKExtensions.h"
#import "NSScreen_SKExtensions.h"
#import "NSInvocation_SKExtensions.h"
#import "PDFDocument_SKExtensions.h"
#import "SKNoteTableRowView.h"
#import "NSObject_SKExtensions.h"

#define SKNotesDocumentWindowFrameAutosaveName @"SKNotesDocumentWindow"

#define SKNotesDocumentToolbarIdentifier @"SKNotesDocumentToolbarIdentifier"
#define SKNotesDocumentSearchToolbarItemIdentifier @"SKNotesDocumentSearchToolbarItemIdentifier"
#define SKNotesDocumentOpenPDFToolbarItemIdentifier @"SKNotesDocumentOpenPDFToolbarItemIdentifier"

#define SKLastExportedNotesTypeKey @"SKLastExportedNotesType"

#define NOTES_KEY @"notes"
#define PAGES_KEY @"pages"

#define NOTE_COLUMNID   @"note"
#define TYPE_COLUMNID   @"type"
#define COLOR_COLUMNID  @"color"
#define PAGE_COLUMNID   @"page"
#define AUTHOR_COLUMNID @"author"
#define DATE_COLUMNID   @"date"

#define ROWVIEW_IDENTIFIER @"row"

#define STATUSBAR_HEIGHT 22.0

#define EXTRA_ROW_HEIGHT 2.0
#define DEFAULT_TEXT_ROW_HEIGHT 85.0

@implementation SKNotesDocument

@synthesize outlineView, statusBar, arrayController, searchField, notes, pdfDocument, sourceFileURL;
@dynamic window, interactionMode;

- (instancetype)init {
    self = [super init];
    if (self) {
        notes = [[NSArray alloc] init];
        pdfDocument = nil;
        rowHeights = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality valueOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsIntegerPersonality capacity:0];
        windowRect = NSZeroRect;
        memset(&ndFlags, 0, sizeof(ndFlags));
        ndFlags.caseInsensitiveSearch = [[NSUserDefaults standardUserDefaults] boolForKey:SKCaseInsensitiveNoteSearchKey];
    }
    return self;
}

- (void)dealloc {
    [outlineView setDelegate:nil];
    [outlineView setDataSource:nil];
}

- (NSString *)windowNibName {
    return @"NotesDocument";
}

- (NSWindow *)window {
    NSArray *wcs = [self windowControllers];
    return [wcs count] > 0 ? [[wcs objectAtIndex:0] window] : nil;
}

- (void)showWindows{
    NSWindowController *wc = [[self windowControllers] lastObject];
    BOOL wasVisible = [wc isWindowLoaded] && [[wc window] isVisible];
    
    [super showWindows];
    
    if (wasVisible == NO)
        [[NSNotificationCenter defaultCenter] postNotificationName:SKDocumentDidShowNotification object:self];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    ndFlags.settingUpWindow = YES;
    
    [aController setShouldCloseDocument:YES];
    
    [self setupToolbarForWindow:[aController window]];
    
    [aController setWindowFrameAutosaveNameOrCascade:SKNotesDocumentWindowFrameAutosaveName];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKShowNotesStatusBarKey] == NO)
        [self toggleStatusBar:nil];
    
    if (NSEqualRects(windowRect, NSZeroRect) == NO)
        [[aController window] setFrame:windowRect display:NO];
    
    NSMenu *menu = [NSMenu menu];
    [menu addItemWithTitle:NSLocalizedString(@"Ignore Case", @"Menu item title") action:@selector(toggleCaseInsensitiveSearch:) target:self];
    [[searchField cell] setSearchMenuTemplate:menu];
    [[searchField cell] setPlaceholderString:NSLocalizedString(@"Search", @"placeholder")];
    
    [outlineView setAutoresizesOutlineColumn: NO];
    [outlineView setIndentationPerLevel:1.0];
    [outlineView setStronglyReferencesItems:YES];

    NSSortDescriptor *indexSortDescriptor = [[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationPageIndexKey ascending:YES];
    NSSortDescriptor *stringSortDescriptor = [[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationStringKey ascending:YES selector:@selector(localizedCaseInsensitiveNumericCompare:)];
    [arrayController setSortDescriptors:@[indexSortDescriptor, stringSortDescriptor]];
    [outlineView reloadData];
    
    [outlineView setTypeSelectHelper:[SKTypeSelectHelper typeSelectHelperWithMatchOption:SKSubstringMatch]];
    
    noteTypeSheetController = [[SKNoteTypeSheetController alloc] initIncludingWidgets:YES];
    [noteTypeSheetController setDelegate:self];
    
    menu = [[outlineView headerView] menu];
    [menu addItem:[NSMenuItem separatorItem]];
    [[menu addItemWithTitle:NSLocalizedString(@"Note Type", @"Menu item title") action:NULL keyEquivalent:@""] setSubmenu:[noteTypeSheetController noteTypeMenu]];
    
    ndFlags.settingUpWindow = NO;
}

- (void)windowWillClose:(NSNotification *)notification {
    [pdfDocument setContainingDocument:nil];
}

- (void)windowDidResize:(NSNotification *)notification {
    if (ndFlags.autoResizeRows) {
        [rowHeights removeAllObjects];
        [outlineView noteHeightOfRowsChangedAnimating:NO];
    }
}

- (NSArray *)writableTypesForSaveOperation:(NSSaveOperationType)saveOperation {
    NSArray *writableTypes = [super writableTypesForSaveOperation:saveOperation];
    if (saveOperation == NSSaveToOperation) {
        NSMutableArray *tmpArray = [writableTypes mutableCopy];
        [[SKTemplateManager sharedManager] resetCustomTemplateTypes];
        [tmpArray addObjectsFromArray:[[SKTemplateManager sharedManager] customTemplateTypes]];
        writableTypes = tmpArray;
    }
    return writableTypes;
}

- (NSString *)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation {
    return [super fileNameExtensionForType:typeName saveOperation:saveOperation] ?: [[SKTemplateManager sharedManager] fileNameExtensionForTemplateType:typeName];
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel {
    BOOL success = [super prepareSavePanel:savePanel];
    if (success && ndFlags.exportUsingPanel) {
        NSPopUpButton *formatPopup = [[savePanel accessoryView] descendantOfClass:[NSPopUpButton class]];
        if (formatPopup) {
            NSString *lastExportedType = [[NSUserDefaults standardUserDefaults] stringForKey:SKLastExportedNotesTypeKey];
            if (lastExportedType) {
                NSInteger idx = [formatPopup indexOfItemWithRepresentedObject:lastExportedType];
                if (idx != -1 && idx != [formatPopup indexOfSelectedItem]) {
                    [formatPopup selectItemAtIndex:idx];
                    [formatPopup sendAction:[formatPopup action] to:[formatPopup target]];
                    [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:[self fileNameExtensionForType:lastExportedType saveOperation:NSSaveToOperation], nil]];
                }
            }
        }
    }
    return success;
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)contextInfo {
    ndFlags.exportUsingPanel = NO;
    if (contextInfo) {
        NSInvocation *invocation = (NSInvocation *)CFBridgingRelease(contextInfo);
        __unsafe_unretained NSDocument *theDoc = doc;
        [invocation setArgument:&theDoc atIndex:2];
        [invocation setArgument:&didSave atIndex:3];
        [invocation invoke];
    }
}

- (void)runModalSavePanelForSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
    // Override so we can determine if this is a save, saveAs or export operation, so we can prepare the correct accessory view
    void *newContextInfo = NULL;
    if (delegate && didSaveSelector) {
        NSInvocation *invocation = [NSInvocation invocationWithTarget:delegate selector:didSaveSelector];
        [invocation setArgument:&contextInfo atIndex:4];
        newContextInfo = (void *)CFBridgingRetain(invocation);
    }
    ndFlags.exportUsingPanel = (saveOperation == NSSaveToOperation);
    [super runModalSavePanelForSaveOperation:saveOperation delegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:newContextInfo];
}

// This method is not used for autosave, but that does not matter because we don't need to do anything special there
- (void)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
    if (saveOperation == NSSaveToOperation && ndFlags.exportUsingPanel)
        [[NSUserDefaults standardUserDefaults] setObject:typeName forKey:SKLastExportedNotesTypeKey];
    [super saveToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
    NSFileWrapper *fileWrapper = nil;
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
    if ([ws type:SKNotesDocumentType conformsToType:typeName] ||
        [ws type:SKNotesTextDocumentType conformsToType:typeName] ||
        [ws type:SKNotesRTFDocumentType conformsToType:typeName] ||
        [ws type:SKNotesFDFDocumentType conformsToType:typeName] ||
        [[SKTemplateManager sharedManager] isRichTextBundleTemplateType:typeName] == NO)
        fileWrapper = [super fileWrapperOfType:typeName error:outError];
    else
        fileWrapper = [self notesFileWrapperForTemplateType:typeName];
    
    if (fileWrapper == nil && outError != NULL)
        *outError = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write notes", @"Error description")];
    
    return fileWrapper;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    NSData *data = nil;
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
    if ([ws type:SKNotesDocumentType conformsToType:typeName]) {
        data = [self notesData];
    } else if ([ws type:SKNotesTextDocumentType conformsToType:typeName]) {
        data = [[self notesString] dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([ws type:SKNotesRTFDocumentType conformsToType:typeName]) {
        data = [self notesRTFData];
    } else if ([ws type:SKNotesFDFDocumentType conformsToType:typeName]) {
        NSString *filename = nil;
        NSURL *pdfURL = [[self fileURL] URLReplacingPathExtension:@"pdf"];
        if ([pdfURL checkResourceIsReachableAndReturnError:NULL])
            filename = [pdfURL lastPathComponent];
        data = [self notesFDFDataForFile:filename fileIDStrings:nil];
    } else {
        data = [self notesDataForTemplateType:typeName];
    }
    
    if (data == nil && outError != NULL)
        *outError = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write notes", @"Error description")];
    
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    BOOL didRead = NO;
    NSArray *array = nil;
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
    if ([ws type:typeName conformsToType:SKNotesDocumentType]) {
        array = SKNSkimNotesFromData(data);
    } else if ([ws type:typeName conformsToType:SKNotesFDFDocumentType]) {
        array = [SKFDFParser noteDictionariesFromFDFData:data];
    }
    
    if (array) {
        NSMutableArray *newNotes = [NSMutableArray arrayWithCapacity:[array count]];
        NSMutableArray *newUnsupportedNotes = [NSMutableArray arrayWithCapacity:[array count]];

        [self willChangeValueForKey:PAGES_KEY];
        pdfDocument = [[SKPDFDocument alloc] init];
        
        [pdfDocument setContainingDocument:self];
        
        for (NSDictionary *dict in array) {
            PDFAnnotation *note = [PDFAnnotation newSkimNoteWithProperties:dict];
            if (note == nil && [[dict objectForKey:SKNPDFAnnotationTypeKey] isEqualToString:SKNWidgetString]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                switch ([[dict objectForKey:SKNPDFAnnotationWidgetTypeKey] integerValue]) {
                    case kSKNPDFWidgetTypeText: note = [PDFAnnotationTextWidget alloc]; break;
                    case kSKNPDFWidgetTypeButton: note = [PDFAnnotationButtonWidget alloc]; break;
                    case kSKNPDFWidgetTypeChoice: note = [PDFAnnotationChoiceWidget alloc]; break;
                    default: break;
                }
#pragma clang diagnostic pop
                note = [note initSkimNoteWithProperties:dict];
            }
            if (note) {
                PDFPage *page;
                NSUInteger pageIndex = [[dict objectForKey:SKNPDFAnnotationPageIndexKey] unsignedIntegerValue];
                NSUInteger pageCount = [pdfDocument pageCount];
                
                while (pageIndex >= pageCount) {
                    page = [[SKNotesPage alloc] init];
                    [pdfDocument insertPage:page atIndex:pageCount++];
                }
                [[pdfDocument pageAtIndex:pageIndex] addAnnotation:note];
                [newNotes addObject:note];
            } else {
                [newUnsupportedNotes addObject:dict];
            }
        }
        [self didChangeValueForKey:PAGES_KEY];
        
        [rowHeights removeAllObjects];
        
        [self willChangeValueForKey:NOTES_KEY];
        notes = [newNotes copy];
        [self didChangeValueForKey:NOTES_KEY];
        
        unsupportedNotes = [newUnsupportedNotes count] ? [newUnsupportedNotes copy] : nil;
        
        [outlineView reloadData];
        didRead = YES;
    }
    
    if (didRead == NO && outError != NULL)
        *outError = [NSError readFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to load file", @"Error description")];
    
    return didRead;
}

- (NSDictionary *)fileAttributesToWriteToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError **)outError {
    NSMutableDictionary *dict = [[super fileAttributesToWriteToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation originalContentsURL:absoluteOriginalContentsURL error:outError] mutableCopy];
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
    // only set the creator code for our native types
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKShouldSetCreatorCodeKey] && [ws type:typeName conformsToType:SKNotesDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'SKim'] forKey:NSFileHFSCreatorCode];
    
    if ([ws type:typeName conformsToType:SKNotesDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'SKNT'] forKey:NSFileHFSTypeCode];
    else if ([[absoluteURL pathExtension] isEqualToString:@"rtf"] || [ws type:typeName conformsToType:SKNotesRTFDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'RTF '] forKey:NSFileHFSTypeCode];
    else if ([[absoluteURL pathExtension] isEqualToString:@"txt"] || [ws type:typeName conformsToType:SKNotesTextDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'TEXT'] forKey:NSFileHFSTypeCode];
    
    return dict;
}

- (void)updateNoteFilterPredicate {
    [arrayController setFilterPredicate:[noteTypeSheetController filterPredicateForSearchString:[searchField stringValue] caseInsensitive:ndFlags.caseInsensitiveSearch]];
    [outlineView reloadData];
}

- (void)applySetup:(NSDictionary *)setup {
    NSString *rectString = [setup objectForKey:SKDocumentSetupWindowFrameKey];
    NSWindowController *wc = [[self windowControllers] lastObject];
    if (wc == nil) {
        [self makeWindowControllers];
        wc = [[self windowControllers] lastObject];
    }
    if (rectString) {
        if ([wc isWindowLoaded] == NO) {
            windowRect = NSRectFromString(rectString);
        } else {
            [[wc window] setFrame:NSRectFromString(rectString) display:YES];
        }
    }
}

- (void)applyOptions:(NSDictionary *)options {
    NSString *searchString = [options objectForKey:@"search"];
    if ([searchString length] > 0 && [searchField window]) {
        [searchField setStringValue:searchString];
        [self performSelector:@selector(searchNotes:) withObject:searchField afterDelay:0.0];
    }
}

- (void)setFileURL:(NSURL *)absoluteURL {
    if (absoluteURL)
        [self setSourceFileURL:nil];
    [super setFileURL:absoluteURL];
    [[NSNotificationCenter defaultCenter] postNotificationName:SKDocumentFileURLDidChangeNotification object:self];
}

- (NSString *)displayName {
    if (sourceFileURL)
        return [[sourceFileURL lastPathComponent] stringByDeletingPathExtension];
    return [super displayName];
}

- (SKInteractionMode)interactionMode  {
    return ([[self window] styleMask] & NSWindowStyleMaskFullScreen) == 0 ? SKNormalMode : SKFullScreenMode;
}

- (SKInteractionMode)systemInteractionMode  {
    if ([NSScreen screenForWindowHasMenuBar:[self window]])
        return [self interactionMode];
    return SKNormalMode;
}

- (NSArray *)SkimNoteProperties {
    NSArray *array = [super SkimNoteProperties];
    if ([unsupportedNotes count])
        array = [array arrayByAddingObjectsFromArray:unsupportedNotes];
    return array;
}

- (NSMenu *)notesMenu {
    return [[outlineView headerView] menu];
}

#pragma mark Printing

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError {
    NSPrintInfo *printInfo = [[self printInfo] copy];
    [[printInfo dictionary] addEntriesFromDictionary:printSettings];
    [printInfo setHorizontalPagination:NSFitPagination];
    [printInfo setHorizontallyCentered:NO];
    [printInfo setVerticallyCentered:NO];
    
    SKPrintableView *printableView = [[SKPrintableView alloc] initWithFrame:[printInfo imageablePageBounds]];
    [printableView setVerticallyResizable:YES];
    [printableView setHorizontallyResizable:NO];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithRTF:[self notesRTFData] documentAttributes:NULL];
    NSTextStorage *textStorage = [printableView textStorage];
    [textStorage beginEditing];
    [textStorage setAttributedString:attrString];
    [textStorage endEditing];
    
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:printableView printInfo:printInfo];
    
    [[printOperation printPanel] setOptions:NSPrintPanelShowsCopies | NSPrintPanelShowsPageRange | NSPrintPanelShowsPaperSize | NSPrintPanelShowsOrientation | NSPrintPanelShowsScaling | NSPrintPanelShowsPreview];
    
    [printOperation setJobTitle:[self displayName]];
    
    if (printOperation == nil && outError)
        *outError = [NSError printDocumentErrorWithLocalizedDescription:nil];
    
    return printOperation;
}

#pragma mark Actions

- (IBAction)openPDF:(id)sender {
    NSURL *url = sourceFileURL ?: [[self fileURL] URLReplacingPathExtension:@"pdf"];
    if ([url checkResourceIsReachableAndReturnError:NULL]) {
        // resolve symlinks and aliases
        NSNumber *isAlias = nil;
        url = [url URLByResolvingSymlinksInPath];
        while ([url getResourceValue:&isAlias forKey:NSURLIsAliasFileKey error:NULL] && [isAlias boolValue]) {
            NSData *data = [NSURL bookmarkDataWithContentsOfURL:url error:NULL];
            if (data)
                url = [NSURL URLByResolvingBookmarkData:data options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:NULL] ?: url;
        }
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error){
            if (document == nil && [error isUserCancelledError] == NO)
                [self presentError:error];
        }];
    } else NSBeep();
}

- (IBAction)searchNotes:(id)sender {
    [self updateNoteFilterPredicate];
}

- (IBAction)toggleStatusBar:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(NO == [statusBar isVisible]) forKey:SKShowNotesStatusBarKey];
    [statusBar toggleBelowView:[outlineView enclosingScrollView] animate:sender != nil];
}

- (void)copyNotes:(id)sender {
    [self outlineView:outlineView copyItems:[sender representedObject]];
}

- (void)autoSizeNoteRows:(id)sender {
    CGFloat height,rowHeight = [outlineView rowHeight];
    NSTableColumn *tableColumn = [outlineView outlineTableColumn];
    NSUInteger column = [[outlineView tableColumns] indexOfObject:tableColumn];
    id cell = [tableColumn dataCell];
    NSRect rect = NSMakeRect(0.0, 0.0, NSWidth([outlineView frameOfCellAtColumn:column row:0]), CGFLOAT_MAX);
    NSRect fullRect = NSMakeRect(0.0, 0.0, NSWidth([outlineView frameOfCellAtColumn:-1 row:0]), CGFLOAT_MAX);
    NSMutableIndexSet *rowIndexes = nil;
    NSArray *items = [sender representedObject];
    NSInteger row;
    
    if (items == nil) {
        NSMutableArray *tmpItems = [NSMutableArray array];
        for (PDFAnnotation *note in notes) {
            [tmpItems addObject:note];
            if ([note hasNoteText])
                [tmpItems addObject:[note noteText]];
        }
        items = tmpItems;
    } else {
        rowIndexes = [NSMutableIndexSet indexSet];
    }
    
    for (id item in items) {
        [cell setObjectValue:[item objectValue]];
        if ([(PDFAnnotation *)item type])
            height = [cell cellSizeForBounds:rect].height;
        else if ([tableColumn isHidden] == NO)
            height = [cell cellSizeForBounds:fullRect].height;
        else
            height = 0.0;
        NSMapInsert(rowHeights, (__bridge void *)item, (void *)(NSInteger)round(fmax(height, rowHeight) + EXTRA_ROW_HEIGHT));
        if (rowIndexes) {
            row = [outlineView rowForItem:item];
            if (row != -1)
                [rowIndexes addIndex:row];
        }
    }
    [outlineView noteHeightOfRowsWithIndexesChanged:rowIndexes ?: [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [outlineView numberOfRows])]];
}

- (void)resetRowHeights {
    [rowHeights removeAllObjects];
    [outlineView noteHeightOfRowsChangedAnimating:YES];
}

- (void)resetHeightOfNoteRows:(id)sender {
    NSArray *items = [sender representedObject];
    if (items == nil) {
        [self  resetRowHeights];
    } else {
        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
        for (id item in items) {
            NSMapRemove(rowHeights, (__bridge void *)item);
            NSInteger row = [outlineView rowForItem:item];
            if (row != -1)
                [indexes addIndex:row];
        }
        [outlineView noteHeightOfRowsWithIndexesChanged:indexes];
    }
}

- (void)toggleAutoResizeNoteRows:(id)sender {
    ndFlags.autoResizeRows = (0 == ndFlags.autoResizeRows);
    if (ndFlags.autoResizeRows)
        [self  resetRowHeights];
    else
        [self autoSizeNoteRows:nil];
}

- (IBAction)toggleCaseInsensitiveSearch:(id)sender {
    ndFlags.caseInsensitiveSearch = NO == ndFlags.caseInsensitiveSearch;
    if ([[searchField stringValue] length])
        [self searchNotes:searchField];
    [[NSUserDefaults standardUserDefaults] setBool:ndFlags.caseInsensitiveSearch forKey:SKCaseInsensitiveNoteSearchKey];
}

- (IBAction)toggleFullscreen:(id)sender {
    [[self window] toggleFullScreen:sender];
}

- (void)performFindPanelAction:(id)sender {
    if ([sender tag] == NSFindPanelActionShowFindPanel) {
        NSToolbar *toolbar = [[self window] toolbar];
        if ([[[toolbar items] valueForKey:@"itemIdentifier"] containsObject:SKNotesDocumentSearchToolbarItemIdentifier] == NO)
            [toolbar insertItemWithItemIdentifier:SKNotesDocumentSearchToolbarItemIdentifier atIndex:0];
        if ([toolbar displayMode] == NSToolbarDisplayModeLabelOnly)
            [toolbar setDisplayMode:NSToolbarDisplayModeDefault];
        [toolbar setVisible:YES];
        [searchField selectText:nil];
    } else {
        NSBeep();
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    SEL action = [menuItem action];
    if (action == @selector(toggleStatusBar:)) {
        if ([statusBar isVisible])
            [menuItem setTitle:NSLocalizedString(@"Hide Status Bar", @"Menu item title")];
        else
            [menuItem setTitle:NSLocalizedString(@"Show Status Bar", @"Menu item title")];
        return YES;
    } else if (action == @selector(toggleCaseInsensitiveSearch:)) {
        [menuItem setState:ndFlags.caseInsensitiveSearch ? NSOnState : NSOffState];
        return YES;
    } else if (action == @selector(toggleAutoResizeNoteRows:)) {
        [menuItem setState:ndFlags.autoResizeRows ? NSOnState : NSOffState];
        return YES;
    } else if (action == @selector(toggleFullscreen:)) {
        if ([self interactionMode] == SKFullScreenMode)
            [menuItem setTitle:NSLocalizedString(@"Remove Full Screen", @"Menu item title")];
        else
            [menuItem setTitle:NSLocalizedString(@"Full Screen", @"Menu item title")];
        return YES;
    } else if (action == @selector(performFindPanelAction:)) {
        switch ([menuItem tag]) {
            case NSFindPanelActionShowFindPanel:
                return YES;
            default:
                return NO;
        }
    }
    return YES;
}

#pragma mark NSOutlineView datasource and delegate methods

- (NSInteger)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item {
    if (item == nil)
        return [[arrayController arrangedObjects] count];
    else
        return [item hasNoteText] ? 1 : 0;
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item {
    return [item hasNoteText];
}

- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)anIndex ofItem:(id)item {
    if (item == nil) {
        return [[arrayController arrangedObjects] objectAtIndex:anIndex];
    } else {
        return [item noteText];
    }
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return item;
}

- (NSView *)outlineView:(NSOutlineView *)ov viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([(PDFAnnotation *)item type] || tableColumn == [ov outlineTableColumn]) {
        return [ov makeViewWithIdentifier:[tableColumn identifier] owner:self];
    }
    return nil;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)ov rowViewForItem:(id)item {
    return [ov makeViewWithIdentifier:ROWVIEW_IDENTIFIER owner:self];
}

- (void)outlineView:(NSOutlineView *)ov didClickTableColumn:(NSTableColumn *)tableColumn {
    NSTableColumn *oldTableColumn = [ov highlightedTableColumn];
    NSTableColumn *newTableColumn = ([NSEvent modifierFlags] & NSEventModifierFlagCommand) ? nil : [ov highlightedTableColumn];
    NSMutableArray *sortDescriptors = nil;
    BOOL ascending = YES;
    if ([oldTableColumn isEqual:newTableColumn]) {
        sortDescriptors = [[arrayController sortDescriptors] mutableCopy];
        [sortDescriptors replaceObjectAtIndex:0 withObject:[[sortDescriptors firstObject] reversedSortDescriptor]];
        ascending = [[sortDescriptors firstObject] ascending];
    } else {
        NSString *tcID = [newTableColumn identifier];
        NSSortDescriptor *pageIndexSortDescriptor = [[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationPageIndexKey ascending:ascending];
        NSSortDescriptor *boundsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:SKPDFAnnotationBoundsOrderKey ascending:ascending selector:@selector(compare:)];
        sortDescriptors = [NSMutableArray arrayWithObjects:pageIndexSortDescriptor, boundsSortDescriptor, nil];
        if ([tcID isEqualToString:TYPE_COLUMNID]) {
            [sortDescriptors insertObject:[[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationTypeKey ascending:YES selector:@selector(noteTypeCompare:)] atIndex:0];
        } else if ([tcID isEqualToString:COLOR_COLUMNID]) {
            [sortDescriptors insertObject:[[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationColorKey ascending:YES selector:@selector(colorCompare:)] atIndex:0];
        } else if ([tcID isEqualToString:NOTE_COLUMNID]) {
            [sortDescriptors insertObject:[[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationStringKey ascending:YES selector:@selector(localizedCaseInsensitiveNumericCompare:)] atIndex:0];
        } else if ([tcID isEqualToString:AUTHOR_COLUMNID]) {
            [sortDescriptors insertObject:[[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationUserNameKey ascending:YES selector:@selector(localizedCaseInsensitiveNumericCompare:)] atIndex:0];
        } else if ([tcID isEqualToString:DATE_COLUMNID]) {
            [sortDescriptors insertObject:[[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationModificationDateKey ascending:YES] atIndex:0];
        } else if ([tcID isEqualToString:PAGE_COLUMNID]) {
            if (oldTableColumn == nil)
                ascending = NO;
        }
        if (oldTableColumn)
            [ov setIndicatorImage:nil inTableColumn:oldTableColumn];
        [ov setHighlightedTableColumn:newTableColumn];
    }
    [arrayController setSortDescriptors:sortDescriptors];
    if (newTableColumn)
        [ov setIndicatorImage:[NSImage imageNamed:ascending ? @"NSAscendingSortIndicator" : @"NSDescendingSortIndicator"]
                inTableColumn:newTableColumn];
    [ov reloadData];
}

- (void)outlineViewColumnDidResize:(NSNotification *)notification{
    if (ndFlags.autoResizeRows && [(SKScrollView *)[[notification object] enclosingScrollView] isResizingSubviews] == NO)
        [self performSelectorOnce:@selector(resetRowHeights) afterDelay:0.0];
}

- (void)outlineViewColumnDidMove:(NSNotification *)notification {
    if (ndFlags.autoResizeRows) {
        NSInteger oldColumn = [[[notification userInfo] objectForKey:@"NSOldColumn"] integerValue];
        NSInteger newColumn = [[[notification userInfo] objectForKey:@"NSNewColumn"] integerValue];
        if (oldColumn == 0 || newColumn == 0)
                [self performSelectorOnce:@selector(resetRowHeights) afterDelay:0.0];
    }
}

- (void)outlineView:(NSOutlineView *)ov didChangeHiddenOfTableColumn:(NSTableColumn *)tableColumn {
    if (ndFlags.autoResizeRows)
        [self performSelectorOnce:@selector(resetRowHeights) afterDelay:0.0];
}

- (void)outlineView:(NSOutlineView *)ov copyItems:(NSArray *)items  {
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSMutableArray *copiedItems = [NSMutableArray array];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    BOOL isAttributed = NO;
    PDFAnnotation *item;
    
    for (item in items) {
        if ([item type] == nil)
            item = [(SKNoteText *)item note];
        
        if ([copiedItems containsObject:item] == NO && [item isMarkup] == NO)
            [copiedItems addObject:item];
    }
    for (item in items) {
        if ([attrString length])
            [attrString replaceCharactersInRange:NSMakeRange([attrString length], 0) withString:@"\n\n"];
        if ([item type] == nil && [[(SKNoteText *)item note] isNote]) {
            [attrString appendAttributedString:[(SKNoteText *)item text]];
            isAttributed = YES;
        } else {
            [attrString replaceCharactersInRange:NSMakeRange([attrString length], 0) withString:[item string] ?: @""];
        }
    }
    
    [pboard clearContents];
    if (isAttributed)
        [pboard writeObjects:@[attrString]];
    else
        [pboard writeObjects:@[[attrString string]]];
    if ([copiedItems count] > 0)
        [pboard writeObjects:copiedItems];
}

- (BOOL)outlineView:(NSOutlineView *)ov canCopyItems:(NSArray *)items  {
    return [items count] > 0;
}

- (CGFloat)outlineView:(NSOutlineView *)ov heightOfRowByItem:(id)item {
    CGFloat rowHeight = (NSInteger)NSMapGet(rowHeights, (__bridge void *)item);
    if (rowHeight <= 0.0) {
        if (ndFlags.autoResizeRows) {
            NSTableColumn *tableColumn = [ov outlineTableColumn];
            CGFloat width = 0.0;
            id cell = [tableColumn dataCell];
            [cell setObjectValue:[item objectValue]];
            if ([(PDFAnnotation *)item type] == nil)
                width = fmax(10.0, [outlineView fullWidthCellWidth]);
            else if ([tableColumn isHidden] == NO)
                width = [tableColumn width] - [outlineView outlineIndentation];
            if (width > 0.0)
                rowHeight = [cell cellSizeForBounds:NSMakeRect(0.0, 0.0, width, CGFLOAT_MAX)].height;
            rowHeight = round(fmax(rowHeight, [ov rowHeight]) + EXTRA_ROW_HEIGHT);
            NSMapInsert(rowHeights, (__bridge void *)item, (void *)(NSInteger)rowHeight);
        } else {
            rowHeight = [(PDFAnnotation *)item type] ? [ov rowHeight] + EXTRA_ROW_HEIGHT : DEFAULT_TEXT_ROW_HEIGHT;
        }
    }
    return rowHeight;
}

- (void)outlineView:(NSOutlineView *)ov setHeight:(CGFloat)newHeight ofRowByItem:(id)item {
    NSMapInsert(rowHeights, (__bridge void *)item, (void *)(NSInteger)round(newHeight));
}

- (NSArray *)outlineViewTypeSelectHelperSelectionStrings:(NSOutlineView *)ov {
    NSInteger i, count = [outlineView numberOfRows];
    NSMutableArray *texts = [NSMutableArray arrayWithCapacity:count];
    for (i = 0; i < count; i++) {
        id item = [outlineView itemAtRow:i];
        NSString *string = [item string];
        [texts addObject:string ?: @""];
    }
    return texts;
}

- (void)outlineView:(NSOutlineView *)ov typeSelectHelperDidFailToFindMatchForSearchString:(NSString *)searchString {
    [[statusBar leftField] setStringValue:[NSString stringWithFormat:NSLocalizedString(@"No match: \"%@\"", @"Status message"), searchString]];
}

- (void)outlineView:(NSOutlineView *)ov typeSelectHelperUpdateSearchString:(NSString *)searchString {
    if (searchString)
        [[statusBar leftField] setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Finding note: \"%@\"", @"Status message"), searchString]];
    else
        [[statusBar leftField] setStringValue:@""];
}

#pragma mark Contextual menu

- (void)menuNeedsUpdate:(NSMenu *)menu {
    if ([menu isEqual:[outlineView menu]]) {
        NSMenuItem *item;
        NSArray *items;
        NSIndexSet *rowIndexes = [outlineView selectedRowIndexes];
        NSInteger row = [outlineView clickedRow];
        [menu removeAllItems];
        if (row != -1) {
            if ([rowIndexes containsIndex:row] == NO)
                rowIndexes = [NSIndexSet indexSetWithIndex:row];
            items = [outlineView itemsAtRowIndexes:rowIndexes];
            
            if ([self outlineView:outlineView canCopyItems:items]) {
                item = [menu addItemWithTitle:NSLocalizedString(@"Copy", @"Menu item title") action:@selector(copyNotes:) target:self];
                [item setRepresentedObject:items];
                [menu addItem:[NSMenuItem separatorItem]];
            }
            item = [menu addItemWithTitle:[items count] == 1 ? NSLocalizedString(@"Auto Size Row", @"Menu item title") : NSLocalizedString(@"Auto Size Rows", @"Menu item title") action:@selector(autoSizeNoteRows:) target:self];
            [item setRepresentedObject:items];
            item = [menu addItemWithTitle:[items count] == 1 ? NSLocalizedString(@"Auto Size Row", @"Menu item title") : NSLocalizedString(@"Auto Size Rows", @"Menu item title") action:@selector(resetHeightOfNoteRows:) target:self];
            [item setRepresentedObject:items];
            [item setKeyEquivalentModifierMask:NSEventModifierFlagOption];
            [item setAlternate:YES];
            [menu addItemWithTitle:NSLocalizedString(@"Auto Size All", @"Menu item title") action:@selector(autoSizeNoteRows:) target:self];
            item = [menu addItemWithTitle:NSLocalizedString(@"Auto Size All", @"Menu item title") action:@selector(resetHeightOfNoteRows:) target:self];
            [item setKeyEquivalentModifierMask:NSEventModifierFlagOption];
            [item setAlternate:YES];
            [menu addItemWithTitle:NSLocalizedString(@"Automatically Resize", @"Menu item title") action:@selector(toggleAutoResizeNoteRows:) target:self];
        }
    }
}

#pragma mark SKNoteTypeSheetController delegate protocol

- (void)noteTypeSheetControllerNoteTypesDidChange {
    [self updateNoteFilterPredicate];
}

- (NSWindow *)windowForNoteTypeSheetController {
    return [outlineView window];
}

#pragma mark Toolbar

- (void)setupToolbarForWindow:(NSWindow *)aWindow {
    // Create a new toolbar instance, and attach it to our document window
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:SKNotesDocumentToolbarIdentifier];
    NSToolbarItem *item;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeDefault];
    
    // We are the delegate
    [toolbar setDelegate:self];
    
    // Add template toolbar items
    
    item = [[SKToolbarItem alloc] initWithItemIdentifier:SKNotesDocumentSearchToolbarItemIdentifier];
    [item setLabels:NSLocalizedString(@"Search", @"Toolbar item label")];
    [item setToolTip:NSLocalizedString(@"Search Notes", @"Tool tip message")];
    [item setView:searchField];
    if (@available(macOS 11.0, *)) {} else {
        NSSize size = [searchField frame].size;
        [item setMinSize:size];
        size.width = 240.0;
        [item setMaxSize:size];
    }
    [dict setObject:item forKey:SKNotesDocumentSearchToolbarItemIdentifier];
    
    item = [[SKToolbarItem alloc] initWithItemIdentifier:SKNotesDocumentOpenPDFToolbarItemIdentifier];
    [item setLabels:NSLocalizedString(@"Open PDF", @"Toolbar item label")];
    [item setToolTip:NSLocalizedString(@"Open Associated PDF File", @"Tool tip message")];
    [item setImage:[[NSWorkspace sharedWorkspace] iconForFileType:SKPDFDocumentType]];
    [item setTarget:self];
    [item setAction:@selector(openPDF:)];
    [dict setObject:item forKey:SKNotesDocumentOpenPDFToolbarItemIdentifier];
    
    toolbarItems = [dict mutableCopy];
    
    // Attach the toolbar to the window
    [aWindow setToolbar:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted {
    NSToolbarItem *item = [toolbarItems objectForKey:itemIdent];
    return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[SKNotesDocumentSearchToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier, 
        SKNotesDocumentOpenPDFToolbarItemIdentifier];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[SKNotesDocumentSearchToolbarItemIdentifier,
        SKNotesDocumentOpenPDFToolbarItemIdentifier, 
        NSToolbarPrintItemIdentifier, 
        NSToolbarFlexibleSpaceItemIdentifier, 
		NSToolbarSpaceItemIdentifier, 
		NSToolbarSeparatorItemIdentifier, 
		NSToolbarCustomizeToolbarItemIdentifier];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    if ([[[self window] toolbar] customizationPaletteIsRunning])
        return NO;
    else if ([[toolbarItem itemIdentifier] isEqualToString:SKNotesDocumentOpenPDFToolbarItemIdentifier])
        return [(sourceFileURL ?: [[self fileURL] URLReplacingPathExtension:@"pdf"]) checkResourceIsReachableAndReturnError:NULL];
    return YES;
}

#pragma mark Scripting

- (id)handleSaveScriptCommand:(NSScriptCommand *)command {
	NSDictionary *args = [command evaluatedArguments];
    id fileType = [args objectForKey:@"FileType"];
    id file = [args objectForKey:@"File"];
    // we don't want to expose the UTI types to the user, and we allow template file names without extension
    if (fileType && file) {
        NSString *normalizedType = nil;
        NSArray *writableTypes = [self writableTypesForSaveOperation:NSSaveToOperation];
        SKTemplateManager *tm = [SKTemplateManager sharedManager];
        if ([fileType isEqualToString:@"Skim Notes"])
            normalizedType = SKNotesDocumentType;
        else if ([fileType isEqualToString:@"Notes as Text"])
            normalizedType = SKNotesTextDocumentType;
        else if ([fileType isEqualToString:@"Notes as RTF"])
            normalizedType = SKNotesRTFDocumentType;
        else if ([fileType isEqualToString:@"Notes as RTFD"])
            normalizedType = SKNotesRTFDDocumentType;
        else if ([fileType isEqualToString:@"Notes as FDF"])
            normalizedType = SKNotesFDFDocumentType;
        else if ([writableTypes containsObject:fileType] == NO)
            normalizedType = [tm templateTypeForDisplayName:fileType];
        if ([writableTypes containsObject:normalizedType] || [[tm customTemplateTypes] containsObject:fileType]) {
            NSMutableDictionary *arguments = [args mutableCopy];
            if (normalizedType) {
                fileType = normalizedType;
                [arguments setObject:fileType forKey:@"FileType"];
            }
            // for some reason the default implementation adds the extension twice for template types
            if ([[file pathExtension] isCaseInsensitiveEqual:[tm fileNameExtensionForTemplateType:fileType]])
                [arguments setObject:[file URLByDeletingPathExtension] forKey:@"File"];
            [command setArguments:arguments];
        }
    }
    return [super handleSaveScriptCommand:command];
}

- (id)valueInNotesWithUniqueID:(NSString *)aUniqueID {
    for (PDFAnnotation *annotation in [self notes]) {
        if ([[annotation uniqueID] isEqualToString:aUniqueID])
            return annotation;
    }
    return nil;
}

- (NSArray *)noteSelection {
    NSMutableArray *selectedNotes = [NSMutableArray array];
    NSIndexSet *rowIndexes = [outlineView selectedRowIndexes];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop) {
        id item = [outlineView itemAtRow:row];
        if ([(PDFAnnotation *)item type] == nil)
            item = [(SKNoteText *)item note];
        if ([selectedNotes containsObject:item] == NO)
            [selectedNotes addObject:item];
    }];
    return selectedNotes;
}

- (void)setNoteSelection:(NSArray *)newNoteSelection {
    NSMutableIndexSet *rowIndexes = [NSMutableIndexSet indexSet];
    for (PDFAnnotation *note in newNoteSelection) {
        NSInteger row = [outlineView rowForItem:note];
        if (row != -1)
            [rowIndexes addIndex:row];
    }
    [outlineView selectRowIndexes:rowIndexes byExtendingSelection:NO];
}

- (NSInteger)scriptingInteractionMode {
    return [self interactionMode];
}

- (void)setScriptingInteractionMode:(NSInteger)mode {
    if (mode != [self interactionMode] && (mode == SKFullScreenMode || mode == SKNormalMode))
        [self toggleFullscreen:nil];
}

@end
