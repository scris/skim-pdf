//
//  SKMainDocument.m
//  Skim
//
//  Created by Michael McCracken on 12/5/06.
/*
 This software is Copyright (c) 2006
 Michael O. McCracken. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 - Neither the name of Michael O. McCracken nor the names of any
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

#import "SKMainDocument.h"
#import <Quartz/Quartz.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SkimNotes/SkimNotes.h>
#import "SKMainWindowController.h"
#import "SKMainWindowController_Actions.h"
#import "SKMainWindowController_FullScreen.h"
#import "SKPDFDocument.h"
#import "PDFAnnotation_SKExtensions.h"
#import "SKConversionProgressController.h"
#import "SKFindController.h"
#import "NSUserDefaultsController_SKExtensions.h"
#import "SKStringConstants.h"
#import "SKPDFView.h"
#import "SKNoteWindowController.h"
#import "SKPDFSynchronizer.h"
#import "NSString_SKExtensions.h"
#import "SKDocumentController.h"
#import "SKTemplateParser.h"
#import "SKApplicationController.h"
#import "PDFSelection_SKExtensions.h"
#import "SKInfoWindowController.h"
#import "SKApplicationController.h"
#import "NSFileManager_SKExtensions.h"
#import "SKFDFParser.h"
#import "NSData_SKExtensions.h"
#import "SKProgressController.h"
#import "NSView_SKExtensions.h"
#import "SKKeychain.h"
#import "SKBookmarkController.h"
#import "PDFPage_SKExtensions.h"
#import "NSGeometry_SKExtensions.h"
#import "SKSnapshotWindowController.h"
#import "NSDocument_SKExtensions.h"
#import "SKApplication.h"
#import "NSResponder_SKExtensions.h"
#import "SKTextFieldSheetController.h"
#import "PDFAnnotationMarkup_SKExtensions.h"
#import "NSWindowController_SKExtensions.h"
#import "NSInvocation_SKExtensions.h"
#import "SKSyncPreferences.h"
#import "NSScreen_SKExtensions.h"
#import "NSURL_SKExtensions.h"
#import "SKFileUpdateChecker.h"
#import "NSError_SKExtensions.h"
#import "PDFDocument_SKExtensions.h"
#import "SKPrintAccessoryController.h"
#import "SKTemporaryData.h"
#import "SKTemplateManager.h"
#import "SKExportAccessoryController.h"
#import "SKFileShare.h"
#import "SKAnimatedBorderlessWindow.h"
#import "PDFOutline_SKExtensions.h"
#import "PDFView_SKExtensions.h"
#import "SKLine.h"
#import "NSPasteboard_SKExtensions.h"
#import "NSPointerFunctions_SKExtensions.h"

#define BUNDLE_DATA_FILENAME @"data"
#define PRESENTATION_OPTIONS_KEY @"net_sourceforge_skim-app_presentation_options"
#define OPEN_META_TAGS_KEY @"com.apple.metadata:kMDItemOMUserTags"
#define OPEN_META_RATING_KEY @"com.apple.metadata:kMDItemStarRating"

#define SKIM_NOTES_PREFIX @"net_sourceforge_skim-app"

NSString *SKSkimFileDidSaveNotification = @"SKSkimFileDidSaveNotification";

#define SKLastExportedTypeKey @"SKLastExportedType"
#define SKLastExportedOptionKey @"SKLastExportedOption"

#define NOTIFYPATH_KEY       @"notifyPath"
#define WANTSUPDATECHECK_KEY @"wantsUpdateCheck"
#define CALLBACK_KEY         @"callback"

#define SOURCEURL_KEY   @"sourceURL"
#define TARGETURL_KEY   @"targetURL"
#define EMAIL_KEY       @"email"

#define SKPresentationOptionsKey    @"PresentationOptions"
#define SKTagsKey                   @"Tags"
#define SKRatingKey                 @"Rating"

static NSString *SKPDFPasswordServiceName = @"Skim PDF password";

enum {
    SKExportOptionDefault,
    SKExportOptionWithoutNotes,
    SKExportOptionWithEmbeddedNotes,
};

enum {
   SKArchiveDiskImageMask = 1,
   SKArchiveEmailMask = 2,
};

enum {
    SKOptionAsk = -1,
    SKOptionNever = 0,
    SKOptionAlways = 1
};

@interface PDFAnnotation (SKPrivateDeclarations)
- (void)setPage:(PDFPage *)newPage;
@end

@interface PDFDocument (SKPrivateDeclarations)
- (NSString *)passwordUsedForUnlocking;
@end

@interface SKMainDocument (SKPrivate)

- (void)tryToUnlockDocument:(PDFDocument *)document;

- (void)handleWindowWillCloseNotification:(NSNotification *)notification;

@end

#pragma mark -

@implementation SKMainDocument

@synthesize mainWindowController;
@dynamic pdfDocument, pdfView, synchronizer, snapshots, tags, rating, notes, currentPage, activeNote, richText, selectionSpecifier, selectionQDRect, selectionPage, pdfViewSettings;

+ (BOOL)isPDFDocument { return YES; }

- (void)dealloc {
    // shouldn't need this here, but better be safe
    if (fileUpdateChecker) {
        SKENSURE_MAIN_THREAD( [fileUpdateChecker terminate]; );
        fileUpdateChecker = nil;
    }
}

- (void)makeWindowControllers{
    mainWindowController = [[SKMainWindowController alloc] init];
    [mainWindowController setShouldCloseDocument:YES];
    [self addWindowController:mainWindowController];
}

- (void)updateChangeCount:(NSDocumentChangeType)change {
    if ((change & NSChangeDiscardable) == 0)
        [super updateChangeCount:change];
}

- (void)setDataFromTmpData {
    PDFDocument *pdfDoc = [tmpData pdfDocument];
    
    mdFlags.needsPasswordToConvert = [pdfDoc allowsPrinting] == NO || [pdfDoc allowsNotes] == NO;
    
    [self tryToUnlockDocument:pdfDoc];
    
    [[self undoManager] disableUndoRegistration];
    
    [[self mainWindowController] setPdfDocument:pdfDoc addAnnotationsFromDictionaries:[tmpData noteDicts]];
    
    if ([tmpData presentationOptions])
        [[self mainWindowController] setPresentationOptions:[tmpData presentationOptions]];
    
    [[self mainWindowController] setTags:[tmpData openMetaTags]];
    
    [[self mainWindowController] setRating:[tmpData openMetaRating]];
    
    [[self undoManager] enableUndoRegistration];
    
    tmpData = nil;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController{
    [self setDataFromTmpData];
    
    fileUpdateChecker = [[SKFileUpdateChecker alloc] initForDocument:self];
    // the file update checker starts disabled, setting enabled will start checking if it should
    [fileUpdateChecker setEnabled:YES];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWindowWillCloseNotification:) 
                                                 name:NSWindowWillCloseNotification object:[[self mainWindowController] window]];
}

- (void)showWindows{
    BOOL wasVisible = [[self mainWindowController] isWindowLoaded] && [[[self mainWindowController] window] isVisible];
    
    [super showWindows];
    
    if (wasVisible == NO)
        [[NSNotificationCenter defaultCenter] postNotificationName:SKDocumentDidShowNotification object:self];
}

- (void)removeWindowController:(NSWindowController *)windowController {
    if ([windowController isEqual:mainWindowController]) {
        // if the window delegate is nil, windowWillClose: has already cleaned up, and should have called saveRecentDocumentInfo
        // otherwise, windowWillClose: comes after this (as it did on Tiger) and we need to do this now
        if ([mainWindowController isWindowLoaded] && [[mainWindowController window] delegate]) {
            [mainWindowController setRecentInfoNeedsUpdate:YES];
            [self saveRecentDocumentInfo];
        }
        mainWindowController = nil;
    }
    [super removeWindowController:windowController];
}

- (void)saveRecentDocumentInfo {
    if ([[self mainWindowController] recentInfoNeedsUpdate]) {
        NSURL *fileURL = [self fileURL];
        NSUInteger pageIndex = [[[self pdfView] currentPage] pageIndex];
        if (fileURL && pageIndex != NSNotFound) {
            [[SKBookmarkController sharedBookmarkController] addRecentDocumentForURL:fileURL pageIndex:pageIndex snapshots:[[[self mainWindowController] snapshots] valueForKey:SKSnapshotCurrentSetupKey]];
            [[self mainWindowController] setRecentInfoNeedsUpdate:NO];
        }
    }
}

- (void)applySetup:(NSDictionary *)setup {
    if ([self mainWindowController] == nil)
        [self makeWindowControllers];
    [[self mainWindowController] applySetup:setup];
}

- (void)applyOptions:(NSDictionary *)options {
    [[self mainWindowController] applyOptions:options];
}

#pragma mark Writing

- (NSString *)fileType {
    mdFlags.gettingFileType = YES;
    NSString *fileType = [super fileType];
    mdFlags.gettingFileType = NO;
    return fileType;
}

- (NSArray *)writableTypesForSaveOperation:(NSSaveOperationType)saveOperation {
    if (mdFlags.gettingFileType)
        return [super writableTypesForSaveOperation:saveOperation];
    NSMutableArray *writableTypes = [[super writableTypesForSaveOperation:saveOperation] mutableCopy];
    NSString *type = [self fileType];
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    if ([ws type:type conformsToType:SKEncapsulatedPostScriptDocumentType] == NO)
        [writableTypes removeObject:SKEncapsulatedPostScriptDocumentType];
    else
        [writableTypes removeObject:SKPostScriptDocumentType];
    if ([ws type:type conformsToType:SKPostScriptDocumentType] == NO)
        [writableTypes removeObject:SKPostScriptDocumentType];
    if ([ws type:type conformsToType:SKDVIDocumentType] == NO)
        [writableTypes removeObject:SKDVIDocumentType];
    if ([ws type:type conformsToType:SKXDVDocumentType] == NO)
        [writableTypes removeObject:SKXDVDocumentType];
    if (saveOperation == NSSaveToOperation) {
        [[SKTemplateManager sharedManager] resetCustomTemplateTypes];
        [writableTypes addObjectsFromArray:[[SKTemplateManager sharedManager] customTemplateTypes]];
    }
    return writableTypes;
}

- (NSString *)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation {
    return [super fileNameExtensionForType:typeName saveOperation:saveOperation] ?: [[SKTemplateManager sharedManager] fileNameExtensionForTemplateType:typeName];
}

- (BOOL)canAttachNotesForType:(NSString *)typeName {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    return ([ws type:typeName conformsToType:SKPDFDocumentType] || 
            [ws type:typeName conformsToType:SKPostScriptDocumentType] || 
            [ws type:typeName conformsToType:SKDVIDocumentType] || 
            [ws type:typeName conformsToType:SKXDVDocumentType]);
}

- (NSInteger)exportOption {
    return mdFlags.exportOption;
}

- (void)setExportOption:(NSInteger)option {
    mdFlags.exportOption = option;
}

- (NSString *)fileTypeFromLastRunSavePanel {
    return [exportAccessoryController selectedFileType] ?: [super fileTypeFromLastRunSavePanel];
}

- (void)changeExportType:(id)sender {
    NSString *type = [exportAccessoryController selectedFileType];
    if (@available(macOS 11.0, *))
        [[exportAccessoryController savePanel] setAllowedFileTypes:[NSArray arrayWithObjects:type, nil]];
    else
        [[exportAccessoryController savePanel] setAllowedFileTypes:[NSArray arrayWithObjects:[self fileNameExtensionForType:type saveOperation:NSSaveToOperation], nil]];
    if ([self canAttachNotesForType:type] == NO) {
        [exportAccessoryController setHasExportOptions:NO];
    } else {
        [exportAccessoryController setHasExportOptions:YES];
        if ([[NSWorkspace sharedWorkspace] type:type conformsToType:SKPDFDocumentType] && ([[self pdfDocument] isLocked] == NO && [[self pdfDocument] allowsPrinting])) {
            [exportAccessoryController setAllowsEmbeddedOption:YES];
        } else {
            [exportAccessoryController setAllowsEmbeddedOption:NO];
            if (mdFlags.exportOption == SKExportOptionWithEmbeddedNotes)
                [self setExportOption:SKExportOptionDefault];
        }
    }
}

- (BOOL)shouldRunSavePanelWithAccessoryView {
    return [super shouldRunSavePanelWithAccessoryView] && mdFlags.exportUsingPanel == 0;
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel {
    BOOL success = [super prepareSavePanel:savePanel];
    if (success && mdFlags.exportUsingPanel) {
        NSString *lastExportedType = [[NSUserDefaults standardUserDefaults] stringForKey:SKLastExportedTypeKey];
        NSInteger lastExportedOption = [[NSUserDefaults standardUserDefaults] integerForKey:SKLastExportedOptionKey];
        
        mdFlags.exportOption = lastExportedOption;
        
        exportAccessoryController = [[SKExportAccessoryController alloc] init];
        [exportAccessoryController setRepresentedObject:self];
        [exportAccessoryController setSavePanel:savePanel];
        NSView *accessoryView = [exportAccessoryController view];
        
        NSPopUpButton *formatPopUpButton = [exportAccessoryController formatPopUpButton];
        NSDocumentController *controller = [NSDocumentController sharedDocumentController];
        for (NSString *type in [self writableTypesForSaveOperation:NSSaveToOperation]) {
            [formatPopUpButton addItemWithTitle:[controller displayNameForType:type]];
            [[formatPopUpButton lastItem] setRepresentedObject:type];
        }
        [formatPopUpButton setAction:@selector(changeExportType:)];
        [formatPopUpButton setTarget:self];
        [savePanel setAccessoryView:accessoryView];
        
        NSInteger idx = lastExportedType ? [formatPopUpButton indexOfItemWithRepresentedObject:lastExportedType] : -1;
        if (idx == -1) {
            idx = [formatPopUpButton indexOfItemWithRepresentedObject:[self fileType]];
            [self setExportOption:SKExportOptionDefault];
        }
        [formatPopUpButton selectItemAtIndex:MAX(idx, 0)];
        // update the last selected type and option view
        [self changeExportType:formatPopUpButton];
    }
    return success;
}

- (void)document:(NSDocument *)doc didSaveUsingPanel:(BOOL)didSave contextInfo:(void *)contextInfo {
    // we should reset this for the next save
    mdFlags.exportUsingPanel = NO;
    // just reset this as well, in case the panel was canceled
    mdFlags.exportOption = SKExportOptionDefault;
    
    [exportAccessoryController setRepresentedObject:nil];
    exportAccessoryController = nil;
    
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
    mdFlags.exportUsingPanel = (saveOperation == NSSaveToOperation);
    // Should already be reset long ago, just to be sure
    mdFlags.exportOption = SKExportOptionDefault;
    NSInvocation *invocation = nil;
    if (delegate && didSaveSelector) {
        invocation = [NSInvocation invocationWithTarget:delegate selector:didSaveSelector];
        [invocation setArgument:&contextInfo atIndex:4];
    }
    [super runModalSavePanelForSaveOperation:saveOperation delegate:self didSaveSelector:@selector(document:didSaveUsingPanel:contextInfo:) contextInfo:(void *)CFBridgingRetain(invocation)];
}

- (NSArray *)SkimNoteProperties {
    NSArray *array = [super SkimNoteProperties];
    NSArray *widgetProperties = [[self mainWindowController] widgetProperties];
    if ([widgetProperties count])
        array = [array arrayByAddingObjectsFromArray:widgetProperties];
    if (pageOffsets != nil) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            NSUInteger pageIndex = [[dict objectForKey:SKNPDFAnnotationPageIndexKey] unsignedIntegerValue];
            NSPointPointer offsetPtr = (NSPointPointer)NSMapGet(pageOffsets, (const void *)pageIndex);
            if (offsetPtr != NULL) {
                NSMutableDictionary *mutableDict = [dict mutableCopy];
                NSRect bounds = NSRectFromString([dict objectForKey:SKNPDFAnnotationBoundsKey]);
                bounds.origin.x -= offsetPtr->x;
                bounds.origin.y -= offsetPtr->y;
                [mutableDict setObject:NSStringFromRect(bounds) forKey:SKNPDFAnnotationBoundsKey];
                [mutableArray addObject:mutableDict];
            } else {
                [mutableArray addObject:dict];
            }
        }
        array = mutableArray;
    }
    return  array;
}

- (BOOL)attachNotesAtURL:(NSURL *)absoluteURL {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSNumber *permissions = [[fm attributesOfItemAtPath:[absoluteURL path] error:NULL] objectForKey:NSFilePosixPermissions];
    NSNumber *isLocked = nil;
    [absoluteURL getResourceValue:&isLocked forKey:NSURLIsUserImmutableKey error:NULL];
    
    if (permissions && ([permissions shortValue] & S_IWUSR) == 0)
        [fm setAttributes:@{NSFilePosixPermissions:[NSNumber numberWithUnsignedInteger:[permissions shortValue] | S_IWUSR]} ofItemAtPath:[absoluteURL path] error:NULL];
    else
        permissions = nil;
    if ([isLocked boolValue])
        [absoluteURL setResourceValue:@NO forKey:NSURLIsUserImmutableKey error:NULL];
    else
        isLocked = nil;
    
    SKNSkimNotesWritingOptions writeOptions = 0;
    SKNXattrFlags flags = kSKNXattrDefault;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKWriteLegacySkimNotesKey] == NO) {
        writeOptions = SKNSkimNotesWritingSyncable;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SKWriteSkimNotesAsArchiveKey] == NO)
            writeOptions |= SKNSkimNotesWritingPlist;
        flags = kSKNXattrSyncable;
    }
    
    BOOL success = [fm writeSkimNotes:[self SkimNoteProperties] textNotes:[self notesString] richTextNotes:[self notesRTFData] toExtendedAttributesAtURL:absoluteURL options:writeOptions error:NULL];
    
    NSDictionary *options = [[self mainWindowController] presentationOptions];
    SKNExtendedAttributeManager *eam = [SKNExtendedAttributeManager sharedNoSplitManager];
    [eam removeExtendedAttributeNamed:PRESENTATION_OPTIONS_KEY atPath:[absoluteURL path] traverseLink:YES error:NULL];
    if (options)
        [eam setExtendedAttributeNamed:PRESENTATION_OPTIONS_KEY toPropertyListValue:options atPath:[absoluteURL path] options:flags error:NULL];
    
    if (permissions)
        [fm setAttributes:@{NSFilePosixPermissions:permissions} ofItemAtPath:[absoluteURL path] error:NULL];
    if (isLocked)
        [absoluteURL setResourceValue:isLocked forKey:NSURLIsUserImmutableKey error:NULL];
    
    return success;
}

- (BOOL)writeBackupNotesToURL:(NSURL *)absoluteURL forSaveOperation:(NSSaveOperationType)saveOperation {
    BOOL writeNotesOK = NO;
    BOOL fileExists = [absoluteURL checkResourceIsReachableAndReturnError:NULL];
    
    if (fileExists && (saveOperation == NSSaveAsOperation || saveOperation == NSSaveToOperation)) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"\"%@\" already exists. Do you want to replace it?", @"Message in alert dialog"), [absoluteURL lastPathComponent]]];
        [alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"A file or folder with the same name already exists in %@. Replacing it will overwrite its current contents.", @"Informative text in alert dialog"), [[absoluteURL URLByDeletingLastPathComponent] lastPathComponent]]];
        [alert addButtonWithTitle:NSLocalizedString(@"Save", @"Button title")];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Button title")];
        
        writeNotesOK = NSAlertFirstButtonReturn == [alert runModal];
    } else {
        writeNotesOK = YES;
    }
    
    if (writeNotesOK) {
        if ([self hasNotes])
            writeNotesOK = [super writeSafelyToURL:absoluteURL ofType:SKNotesDocumentType forSaveOperation:NSSaveToOperation error:NULL];
        else if (fileExists)
            writeNotesOK = [[NSFileManager defaultManager] removeItemAtURL:absoluteURL error:NULL];
    }
    
    return writeNotesOK;
}

// Prepare for saving and use callback to save notes and cleanup
// On 10.7+ all save operations go through this method, so we use this
- (void)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler {
    
    BOOL wantsUpdateCheck = NO;
    NSString *notifyPath = nil;
    
    if (saveOperation != NSAutosaveElsewhereOperation) {
        if (saveOperation != NSSaveToOperation) {
            [fileUpdateChecker setEnabled:NO];
            wantsUpdateCheck = YES;
        } else if (mdFlags.exportUsingPanel) {
            [[NSUserDefaults standardUserDefaults] setObject:typeName forKey:SKLastExportedTypeKey];
            [[NSUserDefaults standardUserDefaults] setInteger:[self canAttachNotesForType:typeName] ? mdFlags.exportOption : SKExportOptionDefault forKey:SKLastExportedOptionKey];
        }
        if (saveOperation != NSAutosaveAsOperation && [[self class] isNativeType:typeName])
            notifyPath = [absoluteURL path];
    }
    
    // just to make sure
    if (saveOperation != NSSaveToOperation)
        mdFlags.exportOption = SKExportOptionDefault;

    [super saveToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation completionHandler:^(NSError *errorOrNil){
        
        if (wantsUpdateCheck) {
            if (errorOrNil == nil)
                [fileUpdateChecker didUpdateFromURL:[self fileURL]];
            [fileUpdateChecker setEnabled:YES];
        }
        
        // reset this for the next save, in case this was set in the save script command
        mdFlags.exportOption = SKExportOptionDefault;
        
        if (completionHandler)
            completionHandler(errorOrNil);
        
        if (errorOrNil == nil && notifyPath)
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:SKSkimFileDidSaveNotification object:notifyPath];
    }];
}

- (BOOL)writeSafelyToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    NSURL *tmpURL = nil;
    NSMutableDictionary *attributes = nil;
    SKNExtendedAttributeManager *eam = nil;
    NSString *path = nil;
    BOOL attachNotes = [self canAttachNotesForType:typeName] && mdFlags.exportOption == SKExportOptionDefault;
    
    if ([ws type:typeName conformsToType:SKPDFBundleDocumentType] &&
        [ws type:[self fileType] conformsToType:SKPDFBundleDocumentType] &&
        [self fileURL] &&
        (saveOperation == NSSaveOperation || saveOperation == NSSaveAsOperation || saveOperation == NSAutosaveInPlaceOperation)) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *fileURL = [self fileURL];
        // we move everything that's not ours out of the way, so we can preserve version control info
        NSSet *ourExtensions = [NSSet setWithObjects:@"pdf", @"skim", @"fdf", @"txt", @"text", @"rtf", @"plist", nil];
        for (NSURL *url in [fm contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:@[] options:0 error:NULL]) {
            if ([ourExtensions containsObject:[[url pathExtension] lowercaseString]] == NO) {
                if (tmpURL == nil)
                    tmpURL = [fm URLForDirectory:NSItemReplacementDirectory inDomain:NSUserDomainMask appropriateForURL:fileURL create:YES error:NULL];
                [fm copyItemAtURL:url toURL:[tmpURL URLByAppendingPathComponent:[url lastPathComponent] isDirectory:NO] error:NULL];
            }
        }
    }
    
    // There seems to be a bug on 10.9 when saving to an existing file that has a lot of extended attributes
    if (attachNotes && [self fileURL] && (saveOperation == NSSaveOperation || saveOperation == NSAutosaveInPlaceOperation)) {
        path = [[self fileURL] path];
        eam = [SKNExtendedAttributeManager sharedNoSplitManager];
        attributes = [NSMutableDictionary dictionary];
        [[eam allExtendedAttributesAtPath:path traverseLink:YES error:NULL] enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop){
            if ([key hasPrefix:SKIM_NOTES_PREFIX]) {
                [attributes setObject:value forKey:key];
                [eam removeExtendedAttributeNamed:key atPath:path traverseLink:YES error:NULL];
            }
        }];
    }
    
    BOOL didSave = [super writeSafelyToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation error:outError];
    
    if (didSave) {
        if (attachNotes) {
            BOOL didWriteBackupNotes = NO;
            // we check for notes and may save a .skim as well:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:SKAutoSaveSkimNotesKey] &&
                (saveOperation != NSAutosaveElsewhereOperation && saveOperation != NSAutosaveAsOperation))
                didWriteBackupNotes = [self writeBackupNotesToURL:[absoluteURL URLReplacingPathExtension:@"skim"] forSaveOperation:saveOperation];
            if (NO == [self attachNotesAtURL:absoluteURL]) {
                NSString *message = didWriteBackupNotes ? NSLocalizedString(@"The notes could not be saved with the PDF at \"%@\". However a companion .skim file was successfully updated.", @"Informative text in alert dialog") :
                NSLocalizedString(@"The notes could not be saved with the PDF at \"%@\"", @"Informative text in alert dialog");
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Unable to save notes", @"Message in alert dialog")];
                [alert setInformativeText:[NSString stringWithFormat:message, [absoluteURL lastPathComponent]]];
                [alert runModal];
            }
        } else if (tmpURL) {
            // move extra package content like version info to the new location
            NSFileManager *fm = [NSFileManager defaultManager];
            for (NSURL *url in [fm contentsOfDirectoryAtURL:tmpURL includingPropertiesForKeys:@[] options:0 error:NULL])
                [fm moveItemAtURL:url toURL:[absoluteURL URLByAppendingPathComponent:[url lastPathComponent] isDirectory:NO] error:NULL];
        }
    } else if ([attributes count]) {
        [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            [eam setExtendedAttributeNamed:key toValue:obj atPath:path options:0 error:NULL];
        }];
    }
    
    if (tmpURL)
        [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:NULL];

    return didSave;
}

- (NSFileWrapper *)PDFBundleFileWrapperForName:(NSString *)name {
    if ([name isCaseInsensitiveEqual:BUNDLE_DATA_FILENAME])
        name = [name stringByAppendingString:@"1"];
    NSData *data;
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:@{}];
    NSDictionary *info = [[SKInfoWindowController sharedInstance] infoForDocument:self];
    NSDictionary *options = [[self mainWindowController] presentationOptions];
    if (options) {
        info = [info mutableCopy];
        [(NSMutableDictionary *)info setObject:options forKey:SKPresentationOptionsKey];
    }
    [fileWrapper addRegularFileWithContents:pdfData preferredFilename:[name stringByAppendingPathExtension:@"pdf"]];
    if ((data = [[[self pdfDocument] string] dataUsingEncoding:NSUTF8StringEncoding]))
        [fileWrapper addRegularFileWithContents:data preferredFilename:[BUNDLE_DATA_FILENAME stringByAppendingPathExtension:@"txt"]];
    if ((data = [NSPropertyListSerialization dataWithPropertyList:info format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL]))
        [fileWrapper addRegularFileWithContents:data preferredFilename:[BUNDLE_DATA_FILENAME stringByAppendingPathExtension:@"plist"]];
    if ([self hasNotes]) {
        if ((data = [self notesData]))
            [fileWrapper addRegularFileWithContents:data preferredFilename:[name stringByAppendingPathExtension:@"skim"]];
        if ((data = [[self notesString] dataUsingEncoding:NSUTF8StringEncoding]))
            [fileWrapper addRegularFileWithContents:data preferredFilename:[name stringByAppendingPathExtension:@"txt"]];
        if ((data = [self notesRTFData]))
            [fileWrapper addRegularFileWithContents:data preferredFilename:[name stringByAppendingPathExtension:@"rtf"]];
        if ((data = [self notesFDFDataForFile:[name stringByAppendingPathExtension:@"pdf"] fileIDStrings:[[self pdfDocument] fileIDStrings]]))
            [fileWrapper addRegularFileWithContents:data preferredFilename:[name stringByAppendingPathExtension:@"fdf"]];
    }
    return fileWrapper;
}

- (NSTask *)taskForWritingArchiveAtURL:(NSURL *)targetURL fromURL:(NSURL *)sourceURL {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/tar"];
    [task setArguments:@[@"-czf", [targetURL path], [sourceURL lastPathComponent]]];
    [task setCurrentDirectoryPath:[[sourceURL URLByDeletingLastPathComponent] path]];
    [task setStandardOutput:[NSFileHandle fileHandleWithNullDevice]];
    [task setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    return task;
}

- (BOOL)writeArchiveToURL:(NSURL *)absoluteURL error:(NSError **)outError {
    NSString *typeName = [self fileType];
    NSURL *tmpURL = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory inDomain:NSUserDomainMask appropriateForURL:absoluteURL create:YES error:NULL];
    NSString *ext = [self fileNameExtensionForType:typeName saveOperation:NSSaveToOperation];
    NSURL *tmpFileURL = [tmpURL URLByAppendingPathComponent:[[absoluteURL URLReplacingPathExtension:ext] lastPathComponent] isDirectory:NO];
    BOOL didWrite = [self writeToURL:tmpFileURL ofType:typeName error:outError];
    if (didWrite) {
        if ([self canAttachNotesForType:typeName])
            didWrite = [self attachNotesAtURL:tmpFileURL];
        if (didWrite) {
            NSTask *task = [self taskForWritingArchiveAtURL:absoluteURL fromURL:tmpFileURL];
            @try { [task launch]; }
            @catch (id exception) { didWrite = NO; }
            if (didWrite) {
                [task waitUntilExit];
                didWrite = [task terminationStatus] == 0;
            }
        }
    }
    [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:NULL];
    return didWrite;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError{
    BOOL didWrite = NO;
    NSError *error = nil;
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    if ([ws type:SKNotesTextDocumentType conformsToType:typeName]) {
        NSString *string = [self notesString];
        if (string)
            didWrite = [string writeToURL:absoluteURL atomically:NO encoding:NSUTF8StringEncoding error:&error];
        else
            error = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write notes as text", @"Error description")];
    } else if ([ws type:SKPDFDocumentType conformsToType:typeName]) {
        if (mdFlags.exportOption == SKExportOptionWithEmbeddedNotes)
            didWrite = [[self pdfDocument] writeToURL:absoluteURL];
        else
            didWrite = [pdfData writeToURL:absoluteURL options:0 error:&error];
    } else if ([ws type:SKEncapsulatedPostScriptDocumentType conformsToType:typeName] || 
               [ws type:SKDVIDocumentType conformsToType:typeName] || 
               [ws type:SKXDVDocumentType conformsToType:typeName]) {
        if ([ws type:[self fileType] conformsToType:typeName])
            didWrite = [originalData writeToURL:absoluteURL options:0 error:&error];
    } else if ([ws type:SKPDFBundleDocumentType conformsToType:typeName]) {
        NSFileWrapper *fileWrapper = [self PDFBundleFileWrapperForName:[[absoluteURL lastPathComponent] stringByDeletingPathExtension]];
        if (fileWrapper)
            didWrite = [fileWrapper writeToURL:absoluteURL options:0 originalContentsURL:nil error:&error];
        else
            error = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write file", @"Error description")];
    } else if ([ws type:SKArchiveDocumentType conformsToType:typeName]) {
        didWrite = [self writeArchiveToURL:absoluteURL error:&error];
    } else if ([ws type:SKNotesDocumentType conformsToType:typeName]) {
        SKNSkimNotesWritingOptions options = [[NSUserDefaults standardUserDefaults] boolForKey:SKWriteLegacySkimNotesKey] || [[NSUserDefaults standardUserDefaults] boolForKey:SKWriteSkimNotesAsArchiveKey] ? 0 : SKNSkimNotesWritingPlist;
        didWrite = [[NSFileManager defaultManager] writeSkimNotes:[self SkimNoteProperties] toSkimFileAtURL:absoluteURL options:options error:&error];
    } else if ([ws type:SKNotesRTFDocumentType conformsToType:typeName]) {
        NSData *data = [self notesRTFData];
        if (data)
            didWrite = [data writeToURL:absoluteURL options:0 error:&error];
        else
            error = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write notes as RTF", @"Error description")];
    } else if ([ws type:SKNotesRTFDDocumentType conformsToType:typeName]) {
        NSFileWrapper *fileWrapper = [self notesFileWrapperForTemplateType:typeName];
        if (fileWrapper)
            didWrite = [fileWrapper writeToURL:absoluteURL options:0 originalContentsURL:nil error:&error];
        else
            error = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write notes as RTFD", @"Error description")];
    } else if ([ws type:SKNotesFDFDocumentType conformsToType:typeName]) {
        NSURL *fileURL = [self fileURL];
        if (fileURL && [ws type:[self fileType] conformsToType:SKPDFBundleDocumentType])
            fileURL = [[NSFileManager defaultManager] bundledFileURLWithExtension:@"pdf" inPDFBundleAtURL:fileURL error:NULL];
        NSData *data = [self notesFDFDataForFile:[fileURL lastPathComponent] fileIDStrings:[[self pdfDocument] fileIDStrings]];
        if (data)
            didWrite = [data writeToURL:absoluteURL options:0 error:&error];
        else 
            error = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write notes as FDF", @"Error description")];
    } else if ([[SKTemplateManager sharedManager] isRichTextBundleTemplateType:typeName]) {
        NSFileWrapper *fileWrapper = [self notesFileWrapperForTemplateType:typeName];
        if (fileWrapper)
            didWrite = [fileWrapper writeToURL:absoluteURL options:0 originalContentsURL:nil error:&error];
        else
            error = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write notes using template", @"Error description")];
    } else {
        NSData *data = [self notesDataForTemplateType:typeName];
        if (data)
            didWrite = [data writeToURL:absoluteURL options:0 error:&error];
        else
            error = [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write notes using template", @"Error description")];
    }
    
    if (didWrite == NO && outError != NULL)
        *outError = error ?: [NSError writeFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to write file", @"Error description")];
    
    return didWrite;
}

- (NSDictionary *)fileAttributesToWriteToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError **)outError {
    NSMutableDictionary *dict = [[super fileAttributesToWriteToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation originalContentsURL:absoluteOriginalContentsURL error:outError] mutableCopy];
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
    // only set the creator code for our native types
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKShouldSetCreatorCodeKey] && 
        ([[self class] isNativeType:typeName] || [typeName isEqualToString:SKNotesDocumentType]))
        [dict setObject:[NSNumber numberWithUnsignedInt:'SKim'] forKey:NSFileHFSCreatorCode];
    
    if ([ws type:typeName conformsToType:SKPDFDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'PDF '] forKey:NSFileHFSTypeCode];
    else if ([ws type:typeName conformsToType:SKPDFBundleDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'PDFD'] forKey:NSFileHFSTypeCode];
    else if ([ws type:typeName conformsToType:SKNotesDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'SKNT'] forKey:NSFileHFSTypeCode];
    else if ([ws type:typeName conformsToType:SKNotesFDFDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'FDF '] forKey:NSFileHFSTypeCode];
    else if ([[absoluteURL pathExtension] isEqualToString:@"rtf"] || [ws type:typeName conformsToType:SKNotesRTFDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'RTF '] forKey:NSFileHFSTypeCode];
    else if ([[absoluteURL pathExtension] isEqualToString:@"txt"] || [ws type:typeName conformsToType:SKNotesTextDocumentType])
        [dict setObject:[NSNumber numberWithUnsignedInt:'TEXT'] forKey:NSFileHFSTypeCode];
    
    return dict;
}

#pragma mark Reading

+ (NSArray *)readableTypes {
    static NSArray *readableTypes = nil;
    if (readableTypes == nil) {
        NSMutableArray *tmpTypes = [[super readableTypes] mutableCopy];
        if ([SKConversionProgressController toolPathForType:SKDVIDocumentType] == nil)
            [tmpTypes removeObject:SKDVIDocumentType];
        if ([SKConversionProgressController toolPathForType:SKXDVDocumentType] == nil)
            [tmpTypes removeObject:SKXDVDocumentType];
        if (@available(macOS 14.0, *)) {
            if ([SKConversionProgressController toolPathForType:SKPostScriptDocumentType] == nil) {
                [tmpTypes removeObject:SKPostScriptDocumentType];
                [tmpTypes removeObject:SKEncapsulatedPostScriptDocumentType];
            }
        }
        readableTypes = tmpTypes;
    }
    return readableTypes;
}

- (void)setPDFData:(NSData *)data {
    if (pdfData != data) {
        pdfData = data;
    }
    pageOffsets = nil;
}

- (void)setOriginalData:(NSData *)data {
    if (originalData != data) {
        originalData = data;
    }
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)docType error:(NSError **)outError {
    NSData *inData = nil;
    PDFDocument *pdfDoc = nil;
    NSError *error = nil;
    
    tmpData = [[SKTemporaryData alloc] init];
    
    if ([[NSWorkspace sharedWorkspace] type:docType conformsToType:SKPostScriptDocumentType]) {
        inData = data;
        data = [SKConversionProgressController newPDFDataWithPostScriptData:data error:&error];
    }
    
    if (data)
        pdfDoc = [[SKPDFDocument alloc] initWithData:data];
    
    if (pdfDoc) {
        [self setPDFData:data];
        [tmpData setPdfDocument:pdfDoc];
        [self setOriginalData:inData];
        [self updateChangeCount:NSChangeReadOtherContents];
        return YES;
    } else {
        tmpData = nil;
        if (outError != NULL)
            *outError = error ?: [NSError readFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to load file", @"Error description")];
        return NO;
    }
}

static BOOL isIgnorablePOSIXError(NSError *error) {
    if ([[error domain] isEqualToString:NSPOSIXErrorDomain])
        return [error code] == ENOATTR || [error code] == ENOTSUP || [error code] == EINVAL || [error code] == EPERM || [error code] == EACCES || [error code] == ENOENT;
    else
        return NO;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)docType error:(NSError **)outError{
    NSData *fileData = nil;
    NSData *data = nil;
    PDFDocument *pdfDoc = nil;
    NSError *error = nil;
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
    tmpData = [[SKTemporaryData alloc] init];
    
    if ([ws type:docType conformsToType:SKPDFBundleDocumentType]) {
        NSURL *pdfURL = [[NSFileManager defaultManager] bundledFileURLWithExtension:@"pdf" inPDFBundleAtURL:absoluteURL error:&error];
        if (pdfURL) {
            if ((data = [[NSData alloc] initWithContentsOfURL:pdfURL options:NSDataReadingUncached error:&error]) &&
                (pdfDoc = [[SKPDFDocument alloc] initWithURL:pdfURL])) {
                NSArray *array = [[NSFileManager defaultManager] readSkimNotesFromPDFBundleAtURL:absoluteURL error:&error];
                if (array == nil) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:NSLocalizedString(@"Unable to Read Notes", @"Message in alert dialog")];
                    [alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"Skim was not able to read the notes at %@. %@ Do you want to continue to open the PDF document anyway?", @"Informative text in alert dialog"), [[pdfURL path] stringByAbbreviatingWithTildeInPath], [error localizedDescription]]];
                    [alert addButtonWithTitle:NSLocalizedString(@"No", @"Button title")];
                    [alert addButtonWithTitle:NSLocalizedString(@"Yes", @"Button title")];
                    if ([alert runModal] == NSAlertFirstButtonReturn) {
                        data = nil;
                        pdfDoc = nil;
                        error = [NSError userCancelledErrorWithUnderlyingError:error];
                    }
                } else if ([array count]) {
                    [tmpData setNoteDicts:array];
                }
            }
        }
    } else if ((data = [[NSData alloc] initWithContentsOfURL:absoluteURL options:NSDataReadingUncached error:&error])) {
        if ([ws type:docType conformsToType:SKPDFDocumentType]) {
            pdfDoc = [[SKPDFDocument alloc] initWithURL:absoluteURL];
        } else {
            fileData = data;
            if ((data = [SKConversionProgressController newPDFDataFromURL:absoluteURL ofType:docType error:&error]))
                pdfDoc = [[SKPDFDocument alloc] initWithData:data];
        }
        if (pdfDoc) {
            NSArray *array = [[NSFileManager defaultManager] readSkimNotesFromExtendedAttributesAtURL:absoluteURL error:&error];
            BOOL foundEANotes = [array count] > 0;
            if (foundEANotes) {
                [tmpData setNoteDicts:array];
            } else {
                // we found no notes, see if we had an error finding notes. if EAs were not supported we ignore the error, as we may assume there won't be any notes
                if (array == nil && isIgnorablePOSIXError(error) == NO) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:NSLocalizedString(@"Unable to Read Notes", @"Message in alert dialog")];
                    [alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"Skim was not able to read the notes at %@. %@ Do you want to continue to open the PDF document anyway?", @"Informative text in alert dialog"), [[absoluteURL path] stringByAbbreviatingWithTildeInPath], [error localizedDescription]]];
                    [alert addButtonWithTitle:NSLocalizedString(@"No", @"Button title")];
                    [alert addButtonWithTitle:NSLocalizedString(@"Yes", @"Button title")];
                    if ([alert runModal] == NSAlertFirstButtonReturn) {
                        fileData = nil;
                        data = nil;
                        pdfDoc = nil;
                        error = [NSError userCancelledErrorWithUnderlyingError:error];
                    }
                }
            }
            NSInteger readOption = [[NSUserDefaults standardUserDefaults] integerForKey:foundEANotes ? SKReadNonMissingNotesFromSkimFileOptionKey : SKReadMissingNotesFromSkimFileOptionKey];
            if (pdfDoc && readOption != SKOptionNever) {
                NSURL *notesURL = [absoluteURL URLReplacingPathExtension:@"skim"];
                if ([notesURL checkResourceIsReachableAndReturnError:NULL]) {
                    if (readOption == SKOptionAsk) {
                        NSAlert *alert = [[NSAlert alloc] init];
                        [alert setMessageText:NSLocalizedString(@"Found Separate Notes", @"Message in alert dialog") ];
                        if (foundEANotes)
                            [alert setInformativeText:NSLocalizedString(@"A Skim notes file with the same name was found.  Do you want Skim to read the notes from this file?", @"Informative text in alert dialog")];
                        else
                            [alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"Unable to read notes for %@, but a Skim notes file with the same name was found.  Do you want Skim to read the notes from this file?", @"Informative text in alert dialog"), [[absoluteURL path] stringByAbbreviatingWithTildeInPath]]];
                        [[alert addButtonWithTitle:NSLocalizedString(@"Yes", @"Button title")] setTag:SKOptionAlways];
                        [[alert addButtonWithTitle:NSLocalizedString(@"No", @"Button title")] setTag:SKOptionNever];
                        readOption = [alert runModal];
                    }
                    if (readOption == SKOptionAlways) {
                        array = [[NSFileManager defaultManager] readSkimNotesFromSkimFileAtURL:notesURL error:NULL];
                        if ([array count] && [array isEqualToArray:[tmpData noteDicts]] == NO) {
                            [tmpData setNoteDicts:array];
                            [self updateChangeCount:NSChangeReadOtherContents];
                        }
                    }
                }
            }
        }
    }
    
    if (data) {
        if (pdfDoc) {
            [self setPDFData:data];
            [tmpData setPdfDocument:pdfDoc];
            [self setOriginalData:fileData];
            [fileUpdateChecker didUpdateFromURL:absoluteURL];
            
            NSDictionary *dictionary = nil;
            NSArray *array = nil;
            NSNumber *number = nil;
            if ([docType isEqualToString:SKPDFBundleDocumentType]) {
                NSDictionary *info = [NSDictionary dictionaryWithContentsOfURL:[[absoluteURL URLByAppendingPathComponent:BUNDLE_DATA_FILENAME isDirectory:NO] URLByAppendingPathExtension:@"plist"]];
                if ([info isKindOfClass:[NSDictionary class]]) {
                    dictionary = [info objectForKey:SKPresentationOptionsKey];
                    array = [info objectForKey:SKTagsKey];
                    number = [info objectForKey:SKRatingKey];
                }
            } else {
                SKNExtendedAttributeManager *eam = [SKNExtendedAttributeManager sharedNoSplitManager];
                NSError *err = nil;
                dictionary = [eam propertyListFromExtendedAttributeNamed:PRESENTATION_OPTIONS_KEY atPath:[absoluteURL path] traverseLink:YES error:&err];
                array = [eam propertyListFromExtendedAttributeNamed:OPEN_META_TAGS_KEY atPath:[absoluteURL path] traverseLink:YES error:NULL];
                number = [eam propertyListFromExtendedAttributeNamed:OPEN_META_RATING_KEY atPath:[absoluteURL path] traverseLink:YES error:NULL];
            }
            if ([dictionary isKindOfClass:[NSDictionary class]] && [dictionary count])
                [tmpData setPresentationOptions:dictionary];
            if ([array isKindOfClass:[NSArray class]] && [array count])
                [tmpData setOpenMetaTags:array];
            if ([number respondsToSelector:@selector(doubleValue)] && [number doubleValue] > 0.0)
                [tmpData setOpenMetaRating:[number doubleValue]];
        }
    }
    
    if ([tmpData pdfDocument] == nil) {
        tmpData = nil;
        if (outError)
            *outError = error ?: [NSError readFileErrorWithLocalizedDescription:NSLocalizedString(@"Unable to load file", @"Error description")];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)revertToContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError{
    NSWindow *mainWindow = [[self mainWindowController] window];
    NSWindow *modalwindow = nil;
    NSModalSession session;
    
    if ([mainWindow attachedSheet] == nil && [mainWindow isMainWindow]) {
        modalwindow = [[SKAnimatedBorderlessWindow alloc] initWithContentRect:NSZeroRect];
        [(SKApplication *)NSApp setUserAttentionDisabled:YES];
        session = [NSApp beginModalSessionForWindow:modalwindow];
        [(SKApplication *)NSApp setUserAttentionDisabled:NO];
    }
    
    BOOL success = [super revertToContentsOfURL:absoluteURL ofType:typeName error:outError];
    
    if (success) {
        [self setDataFromTmpData];
        [[self undoManager] removeAllActions];
        [fileUpdateChecker reset];
    } else {
        tmpData = nil;
    }
    
    if (modalwindow) {
        [NSApp endModalSession:session];
        [modalwindow orderOut:nil];
    }
    
    return success;
}

#pragma mark Printing

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError {
    NSPrintInfo *printInfo = [[self printInfo] copy];
    PDFDocument *pdfDoc = [self pdfDocument];
    
    [[printInfo dictionary] setValue:[NSNumber numberWithUnsignedInteger:[pdfDoc pageCount]] forKey:NSPrintLastPage];
    [[printInfo dictionary] addEntriesFromDictionary:printSettings];

    NSPrintOperation *printOperation = [pdfDoc printOperationForPrintInfo:printInfo scalingMode:kPDFPrintPageScaleNone autoRotate:YES];
    
    // NSPrintProtected is a private key that disables the items in the PDF popup of the Print panel, and is set for encrypted documents
    if ([pdfDoc isEncrypted])
        [[[printOperation printInfo] dictionary] setValue:@NO forKey:@"NSPrintProtected"];
    
    NSPrintPanel *printPanel = [printOperation printPanel];
    [printPanel setOptions:NSPrintPanelShowsCopies | NSPrintPanelShowsPageRange | NSPrintPanelShowsPaperSize | NSPrintPanelShowsOrientation | NSPrintPanelShowsScaling | NSPrintPanelShowsPreview];
    [printPanel addAccessoryController:[[SKPrintAccessoryController alloc] init]];
    
    [printOperation setJobTitle:[self displayName]];
    
    if (printOperation == nil && outError)
        *outError = [NSError printDocumentErrorWithLocalizedDescription:nil];
    
    return printOperation;
}

#pragma mark Actions

- (IBAction)copyURL:(id)sender {
    NSURL *skimURL = [[[self pdfView] currentPage] skimURL];
    if (skimURL) {
        NSString *searchString = [mainWindowController searchString];
        if ([searchString length] > 0) {
            searchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSURLComponents *components = [[NSURLComponents alloc] initWithURL:skimURL resolvingAgainstBaseURL:NO];
            NSString *fragment = [components fragment];
            [components setFragment:[fragment length] ? [fragment stringByAppendingFormat:@"&search=%@", searchString] : [@"search=" stringByAppendingString:searchString]];
            skimURL = [components URL];
        }
        NSPasteboard *pboard = [NSPasteboard generalPasteboard];
        [pboard clearContents];
        [pboard writeURLs:@[skimURL] names:@[[self displayName]]];
    } else {
        NSBeep();
    }
}

- (void)readNotesFromURL:(NSURL *)notesURL replace:(BOOL)replace {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    NSString *type = [ws typeOfFile:[notesURL path] error:NULL];
    NSArray *array = nil;
    
    if ([ws type:type conformsToType:SKNotesDocumentType]) {
        array = [[NSFileManager defaultManager] readSkimNotesFromSkimFileAtURL:notesURL error:NULL];
    } else if ([ws type:type conformsToType:SKNotesFDFDocumentType]) {
        NSData *fdfData = [NSData dataWithContentsOfURL:notesURL];
        if (fdfData)
            array = [SKFDFParser noteDictionariesFromFDFData:fdfData];
    }
    
    if (array) {
        [[self mainWindowController] addAnnotationsFromDictionaries:array removeAnnotations:replace ? [self notes] : nil];
        [[self undoManager] setActionName:replace ? NSLocalizedString(@"Replace Notes", @"Undo action name") : NSLocalizedString(@"Add Notes", @"Undo action name")];
    } else
        NSBeep();
}

#define CHECK_BUTTON_OFFSET_X 16.0
#define CHECK_BUTTON_OFFSET_Y 8.0

- (IBAction)readNotes:(id)sender{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    NSURL *fileURL = [self fileURL];
    NSButton *replaceNotesCheckButton = nil;
    NSView *readNotesAccessoryView = nil;
    
    if ([self hasNotes]) {
        replaceNotesCheckButton = [[NSButton alloc] init];
        [replaceNotesCheckButton setButtonType:NSSwitchButton];
        [replaceNotesCheckButton setTitle:NSLocalizedString(@"Replace existing notes", @"Check button title")];
        [replaceNotesCheckButton sizeToFit];
        [replaceNotesCheckButton setFrameOrigin:NSMakePoint(CHECK_BUTTON_OFFSET_X, CHECK_BUTTON_OFFSET_Y)];
        readNotesAccessoryView = [[NSView alloc] initWithFrame:NSInsetRect([replaceNotesCheckButton frame], -CHECK_BUTTON_OFFSET_X, -CHECK_BUTTON_OFFSET_Y)];
        [readNotesAccessoryView addSubview:replaceNotesCheckButton];
        [oPanel setAccessoryView:readNotesAccessoryView];
        [replaceNotesCheckButton setState:NSOnState];
        [oPanel setAccessoryViewDisclosed:YES];
    }
    
    [oPanel setDirectoryURL:[fileURL URLByDeletingLastPathComponent]];
    [oPanel setAllowedFileTypes:@[SKNotesDocumentType]];
    [oPanel beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSModalResponse result){
            if (result == NSModalResponseOK) {
                NSURL *notesURL = [[oPanel URLs] objectAtIndex:0];
                BOOL replace = (replaceNotesCheckButton && [replaceNotesCheckButton state] == NSOnState);
                [self readNotesFromURL:notesURL replace:replace];
            }
        }];
}

- (void)setPDFData:(NSData *)data pageOffsets:(NSMapTable *)newPageOffsets {
    [[[self undoManager] prepareWithInvocationTarget:self] setPDFData:pdfData pageOffsets:pageOffsets];
    [self setPDFData:data];
    if (newPageOffsets != pageOffsets) {
        pageOffsets = newPageOffsets;
    }
}

- (void)convertNotesUsingPDFDocument:(PDFDocument *)pdfDocWithoutNotes {
    [[self mainWindowController] beginProgressSheetWithMessage:[NSLocalizedString(@"Converting notes", @"Message for progress sheet") stringByAppendingEllipsis] maxValue:0];
    
    NSMapTable *offsets = nil;
    NSMutableArray *annotations = nil;
    NSMutableArray *noteDicts = nil;

    for (PDFPage *page in [self pdfDocument]) {
        NSPoint pageOrigin = [page boundsForBox:kPDFDisplayBoxMediaBox].origin;
        
        for (PDFAnnotation *annotation in [[page annotations] copy]) {
            if ([annotation isSkimNote] == NO && [annotation isConvertibleAnnotation]) {
                if (annotations == nil)
                    annotations = [[NSMutableArray alloc] init];
                [annotations addObject:annotation];
                NSDictionary *properties = [annotation SkimNoteProperties];
                if ([[annotation type] isEqualToString:SKNTextString])
                    properties = [PDFAnnotation textToNoteSkimNoteProperties:properties];
                if (noteDicts == nil)
                    noteDicts = [[NSMutableArray alloc] init];
                [noteDicts addObject:properties];
            }
        }
        
        if (NSEqualPoints(pageOrigin, NSZeroPoint) == NO) {
            if (offsets == nil)
                offsets = [[NSMapTable alloc] initWithKeyPointerFunctions:[NSPointerFunctions integerPointerFunctions] valuePointerFunctions:[NSPointerFunctions pointPointerFunctions] capacity:0];
            NSMapInsert(offsets, (const void *)[page pageIndex], &pageOrigin);
        }
    }
    
    if (annotations) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // if pdfDocWithoutNotes was nil, the document was not encrypted, so no need to try to unlock
            PDFDocument *pdfDoc = pdfDocWithoutNotes ?: [[PDFDocument alloc] initWithData:pdfData];
            
            for (PDFPage *page in pdfDoc) {
                for (PDFAnnotation *annotation in [[page annotations] copy]) {
                    if ([annotation isSkimNote] == NO && [annotation isConvertibleAnnotation]) {
                        PDFAnnotation *popup = [annotation popup];
                        if (popup)
                            [page removeAnnotation:popup];
                        [page removeAnnotation:annotation];
                    }
                }
            }
            
            NSData *data = [pdfDoc dataRepresentation];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[self mainWindowController] addAnnotationsFromDictionaries:noteDicts removeAnnotations:annotations];
                
                [self setPDFData:data pageOffsets:offsets];
                
                [[self undoManager] setActionName:NSLocalizedString(@"Convert Notes", @"Undo action name")];
                
                [[self mainWindowController] dismissProgressSheet];
                
                mdFlags.convertingNotes = 0;
            });
        });
        
    } else {
        
        [[self mainWindowController] dismissProgressSheet];
        
        mdFlags.convertingNotes = 0;
    }
}

- (void)beginConvertNotesPasswordSheetForPDFDocument:(PDFDocument *)pdfDoc {
    SKTextFieldSheetController *passwordSheetController = [[SKTextFieldSheetController alloc] initWithWindowNibName:@"PasswordSheet"];
    
    [passwordSheetController beginSheetModalForWindow:[[self mainWindowController] window] completionHandler:^(NSModalResponse result) {
            if (result == NSModalResponseOK) {
                [[passwordSheetController window] orderOut:nil];
                
                if (pdfDoc && ([pdfDoc allowsNotes] == NO || [pdfDoc allowsPrinting] == NO) &&
                    ([pdfDoc unlockWithPassword:[passwordSheetController stringValue]] == NO || [pdfDoc allowsNotes] == NO || [pdfDoc allowsPrinting] == NO)) {
                    [self beginConvertNotesPasswordSheetForPDFDocument:pdfDoc];
                } else {
                    [self convertNotesUsingPDFDocument:pdfDoc];
                }
            } else {
                mdFlags.convertingNotes = 0;
            }
        }];
}

- (void)convertNotes {
    mdFlags.convertingNotes = 1;
    
    PDFDocument *pdfDocWithoutNotes = nil;
    
    if (mdFlags.needsPasswordToConvert) {
        pdfDocWithoutNotes = [[PDFDocument alloc] initWithData:pdfData];
        [self tryToUnlockDocument:pdfDocWithoutNotes];
        if ([pdfDocWithoutNotes allowsNotes] == NO || [pdfDocWithoutNotes allowsPrinting] == NO) {
            [self beginConvertNotesPasswordSheetForPDFDocument:pdfDocWithoutNotes];
            return;
        }
    }
    [self convertNotesUsingPDFDocument:pdfDocWithoutNotes];
}

- (BOOL)hasConvertibleAnnotations {
    for (PDFPage *page in [self pdfDocument]) {
        for (PDFAnnotation *annotation in [page annotations]) {
            if ([annotation isSkimNote] == NO && [annotation isConvertibleAnnotation])
                return YES;
        }
    }
    return NO;
}

- (IBAction)convertNotes:(id)sender {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    if (([ws type:[self fileType] conformsToType:SKPDFDocumentType] == NO && [ws type:[self fileType] conformsToType:SKPDFBundleDocumentType] == NO) ||
        [self hasConvertibleAnnotations] == NO) {
        NSBeep();
        return;
    }
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Convert Notes", @"Alert text when trying to convert notes")];
    [alert setInformativeText:NSLocalizedString(@"This will convert PDF annotations to Skim notes. Do you want to proceed?", @"Informative text in alert dialog")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"Button title")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Button title")];
    [alert beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSModalResponse returnCode){
        if (returnCode == NSAlertFirstButtonReturn) {
            // remove the sheet, to make place for either the password or progress sheet
            [[alert window] orderOut:nil];
            [self convertNotes];
        }
    }];
}

- (IBAction)share:(id)sender {
    BOOL shouldArchive = ([self hasNotes] || [[[self mainWindowController] presentationOptions] count] > 0 || [[[self mainWindowController] widgetProperties] count] > 0);
    
    NSString *typeName = [self fileType];
    if (shouldArchive == NO && [typeName isEqualToString:SKPDFBundleDocumentType])
        typeName = SKPDFDocumentType;
    
    NSString *typeExt = [self fileNameExtensionForType:typeName saveOperation:NSAutosaveElsewhereOperation];
    NSString *targetExt = shouldArchive ? @"tgz" : typeExt;
    NSString *targetFileName = [[self fileURL] lastPathComponentReplacingPathExtension:targetExt];
    if (targetFileName == nil)
        targetFileName = [[self displayName] stringByAppendingPathExtension:targetExt];
    
    NSURL *targetDirURL = [[NSFileManager defaultManager] uniqueChewableItemsDirectoryURL];
    NSURL *targetFileURL = [targetDirURL URLByAppendingPathComponent:targetFileName isDirectory:NO];
    NSURL *tmpURL = nil;
    NSURL *fileURL = targetFileURL;
    
    if (shouldArchive) {
        tmpURL = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory inDomain:NSUserDomainMask appropriateForURL:targetFileURL create:YES error:NULL];
        fileURL = [[tmpURL URLByAppendingPathComponent:targetFileName isDirectory:NO] URLReplacingPathExtension:typeExt];
    }
    
    if ([self writeSafelyToURL:fileURL ofType:typeName forSaveOperation:NSAutosaveElsewhereOperation error:NULL] == NO) {
        NSBeep();
        return;
    }
    
    if (shouldArchive) {
        NSTask *task = [self taskForWritingArchiveAtURL:targetFileURL fromURL:fileURL];
        NSSharingService *service = [sender representedObject];
        [service setSubject:[self displayName]];
        
        [SKFileShare shareURL:targetFileURL
               preparedByTask:task
                 usingService:service
            completionHandler:^(BOOL success){
                NSFileManager *fm = [NSFileManager defaultManager];
                [fm removeItemAtURL:tmpURL error:NULL];
                if (success == NO) {
                    [fm removeItemAtURL:targetDirURL error:NULL];
                    NSBeep();
                }
            }];
    } else {
        NSArray *items = @[targetFileURL];
        NSSharingService *service = [sender representedObject];
        if ([service canPerformWithItems:items]) {
            [service setSubject:[self displayName]];
            [service performWithItems:items];
        } else {
            [[NSFileManager defaultManager] removeItemAtURL:targetDirURL error:NULL];
        }
    }
}

- (IBAction)moveToTrash:(id)sender {
    NSURL *fileURL = [self fileURL];
    if ([fileURL checkResourceIsReachableAndReturnError:NULL]) {
        [[NSWorkspace sharedWorkspace] recycleURLs:@[fileURL] completionHandler:^(NSDictionary *newuRLs, NSError *error){
            if (error == nil)
                [self close];
            else
                NSBeep();
        }];
    } else NSBeep();
}

- (void)revertDocumentToSaved:(id)sender { 	 
     if ([self fileURL]) {
         if ([self isDocumentEdited]) {
             [super revertDocumentToSaved:sender]; 	 
         } else if ([fileUpdateChecker fileChangedOnDisk] || 
                    NSOrderedAscending == [[self fileModificationDate] compare:[[[NSFileManager defaultManager] attributesOfItemAtPath:[[self fileURL] path] error:NULL] fileModificationDate]]) {
             NSAlert *alert = [[NSAlert alloc] init];
             [alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Do you want to revert to the version of the document \"%@\" on disk?", @"Message in alert dialog"), [[self fileURL] lastPathComponent]]];
             [alert setInformativeText:NSLocalizedString(@"Your current changes will be lost.", @"Informative text in alert dialog")];
             [alert addButtonWithTitle:NSLocalizedString(@"Revert", @"Button title")];
             [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Button title")];
             [alert beginSheetModalForWindow:[[self mainWindowController] window] completionHandler:^(NSModalResponse returnCode){
                 if (returnCode == NSAlertFirstButtonReturn) {
                     NSError *error = nil;
                     if (NO == [self revertToContentsOfURL:[self fileURL] ofType:[self fileType] error:&error] && [error isUserCancelledError] == NO) {
                         [[alert window] orderOut:nil];
                         [self presentError:error modalForWindow:[self windowForSheet] delegate:nil didPresentSelector:NULL contextInfo:NULL];
                     }
                 }
             }];
         } else {
             [super revertDocumentToSaved:sender];
         }
    }
}

- (void)performFindPanelAction:(id)sender {
    [[self mainWindowController] performFindPanelAction:sender];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem {
	if ([anItem action] == @selector(revertDocumentToSaved:)) {
        if ([self fileURL] == nil || [[self fileURL] checkResourceIsReachableAndReturnError:NULL] == NO)
            return NO;
        if ([self isDocumentEdited] || [fileUpdateChecker fileChangedOnDisk] ||
               NSOrderedAscending == [[self fileModificationDate] compare:[[[NSFileManager defaultManager] attributesOfItemAtPath:[[self fileURL] path] error:NULL] fileModificationDate]])
            return YES;
        return [super validateUserInterfaceItem:anItem];
    } else if ([anItem action] == @selector(printDocument:)) {
        return [[self pdfDocument] allowsPrinting];
    } else if ([anItem action] == @selector(convertNotes:)) {
        return [[NSWorkspace sharedWorkspace] type:[self fileType] conformsToType:SKPDFDocumentType] && [[self pdfDocument] allowsNotes];
    } else if ([anItem action] == @selector(readNotes:)) {
        return [[self pdfDocument] allowsNotes];
    } else if ([anItem action] == @selector(moveToTrash:)) {
        return [self fileURL] && [[self fileURL] checkResourceIsReachableAndReturnError:NULL];
    } else if ([anItem action] == @selector(performFindPanelAction:)) {
        if ([[self mainWindowController] interactionMode] == SKPresentationMode)
            return NO;
        switch ([anItem tag]) {
            case NSFindPanelActionShowFindPanel:
                return YES;
            case NSFindPanelActionNext:
            case NSFindPanelActionPrevious:
                return YES;
            case NSFindPanelActionSetFindString:
                return [[[self pdfView] currentSelection] hasCharacters];
            default:
                return NO;
        }
    } else if ([anItem action] == @selector(copyURL:)) {
        return [self fileURL] != nil;
    }
    return [super validateUserInterfaceItem:anItem];
}

- (void)remoteButtonPressed:(NSEvent *)theEvent {
    [[self mainWindowController] remoteButtonPressed:theEvent];
}

#pragma mark Notification handlers

- (void)handleWindowWillCloseNotification:(NSNotification *)notification {
    NSWindow *window = [notification object];
    // ignore when we're switching fullscreen/main windows
    if ([window isEqual:[[window windowController] window]]) {
        [fileUpdateChecker terminate];
        fileUpdateChecker = nil;
        [synchronizer terminate];
    }
}

#pragma mark Pdfsync support

- (void)setFileURL:(NSURL *)absoluteURL {
    [super setFileURL:absoluteURL];
    
    if ([absoluteURL isFileURL])
        [synchronizer setFileName:[absoluteURL path]];
    else
        [synchronizer setFileName:nil];
    
    [[self mainWindowController] setRecentInfoNeedsUpdate:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SKDocumentFileURLDidChangeNotification object:self];
}

- (SKPDFSynchronizer *)synchronizer {
    if (synchronizer == nil) {
        synchronizer = [[SKPDFSynchronizer alloc] init];
        [synchronizer setDelegate:self];
        [synchronizer setFileName:[[self fileURL] path]];
    }
    return synchronizer;
}

static void replaceInShellCommand(NSMutableString *cmdString, NSString *find, NSString *replace) {
    NSRange range = NSMakeRange(0, 0);
    unichar prevChar, nextChar;
    while (NSMaxRange(range) < [cmdString length]) {
        range = [cmdString rangeOfString:find options:NSLiteralSearch range:NSMakeRange(NSMaxRange(range), [cmdString length] - NSMaxRange(range))];
        if (range.location == NSNotFound)
            break;
        prevChar = range.location > 0 ? [cmdString characterAtIndex:range.location - 1] : 0;
        nextChar = NSMaxRange(range) < [cmdString length] ? [cmdString characterAtIndex:NSMaxRange(range)] : 0;
        if ([[NSCharacterSet letterCharacterSet] characterIsMember:nextChar] == NO) {
            if (prevChar != '\'' || nextChar != '\'')
                replace = [replace stringByEscapingShellChars];
            [cmdString replaceCharactersInRange:range withString:replace];
            range.length = [replace length];
        }
    }
}

- (void)synchronizerFoundLine:(NSInteger)line inFile:(NSString *)file {
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        
        NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
        NSString *editorPreset = [sud stringForKey:SKTeXEditorPresetKey];
        NSDictionary *editor = [SKSyncPreferences TeXEditorForPreset:editorPreset];
        NSString *editorCmd = [editor objectForKey:SKSyncTeXEditorCommandKey] ?: [sud stringForKey:SKTeXEditorCommandKey];
        NSString *editorArgs = [editor objectForKey:SKSyncTeXEditorArgumentsKey] ?: [sud stringForKey:SKTeXEditorArgumentsKey];
        NSMutableString *cmdString = [editorArgs mutableCopy];
        
        if ([editorCmd isAbsolutePath] == NO) {
            NSMutableArray *searchPaths = [NSMutableArray arrayWithObjects:@"/usr/bin", @"/usr/local/bin", nil];
            NSString *path;
            NSString *toolPath;
            NSBundle *appBundle;
            NSFileManager *fm = [NSFileManager defaultManager];
            
            if ([editorPreset isEqualToString:@""] == NO) {
                if ((path = [[NSWorkspace sharedWorkspace] fullPathForApplication:editorPreset]) &&
                    (appBundle = [NSBundle bundleWithPath:path])) {
                    if ((path = [[appBundle bundlePath] stringByDeletingLastPathComponent]))
                        [searchPaths insertObject:path atIndex:0];
                    if ((path = [[appBundle bundlePath] stringByAppendingPathComponent:@"Contents"]))
                        [searchPaths insertObject:path atIndex:0];
                    if ((path = [[[appBundle bundlePath] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Helpers"]))
                        [searchPaths insertObject:path atIndex:0];
                    if ([editorPreset isEqualToString:@"BBEdit"] == NO &&
                        (path = [[appBundle executablePath] stringByDeletingLastPathComponent]))
                        [searchPaths insertObject:path atIndex:0];
                    if ((path = [appBundle resourcePath]))
                        [searchPaths insertObject:path atIndex:0];
                    if ((path = [appBundle sharedSupportPath]))
                        [searchPaths insertObject:path atIndex:0];
                }
            } else {
                [searchPaths addObjectsFromArray:[[fm applicationSupportDirectoryURLs] valueForKey:@"path"]];
            }
            
            for (path in searchPaths) {
                toolPath = [path stringByAppendingPathComponent:editorCmd];
                if ([fm isExecutableFileAtPath:toolPath]) {
                    editorCmd = toolPath;
                    break;
                }
                toolPath = [[path stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:editorCmd];
                if ([fm isExecutableFileAtPath:toolPath]) {
                    editorCmd = toolPath;
                    break;
                }
            }
        }
        
        replaceInShellCommand(cmdString, @"%line", [NSString stringWithFormat:@"%ld", (long)(line + 1)]);
        replaceInShellCommand(cmdString, @"%zline", [NSString stringWithFormat:@"%ld", (long)line]);
        replaceInShellCommand(cmdString, @"%file", file);
        replaceInShellCommand(cmdString, @"%urlfile", [file stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]);
        replaceInShellCommand(cmdString, @"%output", [[self fileURL] path]);
        
        [cmdString insertString:@"\" " atIndex:0];
        [cmdString insertString:editorCmd atIndex:0];
        [cmdString insertString:@"\"" atIndex:0];
        
        NSWorkspace *ws = [NSWorkspace sharedWorkspace];
        NSString *theUTI = [ws typeOfFile:[[editorCmd stringByStandardizingPath] stringByResolvingSymlinksInPath] error:NULL];
        if ([ws type:theUTI conformsToType:@"com.apple.applescript.script"] || [ws type:theUTI conformsToType:@"com.apple.applescript.text"])
            [cmdString insertString:@"/usr/bin/osascript " atIndex:0];
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/sh"];
        [task setCurrentDirectoryPath:[file stringByDeletingLastPathComponent]];
        [task setArguments:@[@"-c", cmdString]];
        [task setStandardOutput:[NSFileHandle fileHandleWithNullDevice]];
        [task setStandardError:[NSFileHandle fileHandleWithNullDevice]];
        @try {
            [task launch];
        }
        @catch(id exception) {
            NSLog(@"command failed: %@: %@", cmdString, exception);
        }
    }
}

- (void)synchronizerFoundLocation:(NSPoint)point atPageIndex:(NSUInteger)pageIndex options:(SKPDFSynchronizerOption)options {
    PDFDocument *pdfDoc = [self pdfDocument];
    if (pageIndex < [pdfDoc pageCount]) {
        PDFPage *page = [pdfDoc pageAtIndex:pageIndex];
        if ((options & SKPDFSynchronizerFlippedMask))
            point.y = NSMaxY([page boundsForBox:kPDFDisplayBoxMediaBox]) - point.y;
        [[self pdfView] displayLineAtPoint:point inPageAtIndex:pageIndex select:(options & SKPDFSynchronizerSelectMask) != 0 showReadingBar:(options & SKPDFSynchronizerShowReadingBarMask) != 0];
    }
}


#pragma mark Accessors

- (SKInteractionMode)systemInteractionMode {
    // only return the real interaction mode when the fullscreen window is on the primary screen, otherwise no need to block main menu and dock
    if ([NSScreen screenForWindowHasMenuBar:[[self mainWindowController] window]])
        return [[self mainWindowController] interactionMode];
    return SKNormalMode;
}

- (NSWindow *)mainWindow {
    return [mainWindowController window];
}

- (PDFDocument *)pdfDocument{
    return [[self mainWindowController] pdfDocument];
}

- (PDFDocument *)placeholderPdfDocument{
    return [[self mainWindowController] placeholderPdfDocument];
}

- (NSDictionary *)currentDocumentSetup {
    NSMutableDictionary *setup = [[super currentDocumentSetup] mutableCopy];
    if ([setup count])
        [setup addEntriesFromDictionary:[[self mainWindowController] currentSetup]];
    return setup;
}

- (SKPDFView *)pdfView {
    return [[self mainWindowController] pdfView];
}

- (NSArray *)snapshots {
    return [[self mainWindowController] snapshots];
}

- (NSArray *)tags {
    return [[self mainWindowController] tags] ?: @[];
}

- (double)rating {
    return [[self mainWindowController] rating];
}

- (NSMenu *)notesMenu {
    return [[self mainWindowController] notesMenu];
}

#pragma mark Passwords

- (NSString *)fileIDStringForDocument:(PDFDocument *)document {
    return [[document fileIDStrings] lastObject] ?: [pdfData md5String];
}

- (void)savePasswordInKeychain:(NSString *)password {
    NSString *fileID = [self fileIDStringForDocument:[self pdfDocument]];
    if (fileID) {
        NSString *label = [@"Skim: " stringByAppendingString:[self displayName]];
        NSString *comment = [[self fileURL] path];
        // try to update the password in an existing item
        SKPasswordStatus status = [SKKeychain updatePassword:password service:nil account:nil label:label comment:comment forService:SKPDFPasswordServiceName account:fileID];
        if (status == SKPasswordStatusNotFound) {
            // try to update an item in the old format
            status = [SKKeychain updatePassword:password service:SKPDFPasswordServiceName account:fileID label:label comment:comment forService:[@"Skim - " stringByAppendingString:fileID] account:nil];
            if (status == SKPasswordStatusNotFound) {
                // add a new password item if no existing item was found
                [SKKeychain setPassword:password forService:SKPDFPasswordServiceName account:fileID label:label comment:comment];
            }
        }
    }
}

- (void)tryToUnlockDocument:(PDFDocument *)document {
    if ([document permissionsStatus] != kPDFDocumentPermissionsOwner) {
        NSString *password = nil;
        if  (SKOptionNever != [[NSUserDefaults standardUserDefaults] integerForKey:SKSavePasswordOptionKey]) {
            NSString *fileID = [self fileIDStringForDocument:document];
            if (fileID) {
                SKPasswordStatus status = SKPasswordStatusError;
                password = [SKKeychain passwordForService:SKPDFPasswordServiceName account:fileID status:&status];
                if (status == SKPasswordStatusNotFound) {
                    // try to find an item in the old format
                    NSString *oldService = [@"Skim - " stringByAppendingString:fileID];
                    password = [SKKeychain passwordForService:oldService account:nil status:&status];
                    if (status == SKPasswordStatusFound) {
                        // update to new format
                        [SKKeychain updatePassword:nil service:SKPDFPasswordServiceName account:fileID label:[@"Skim: " stringByAppendingString:[self displayName]] comment:[[self fileURL] path] forService:oldService account:nil];
                    }
                }
            }
        }
        if (password == nil && [[self pdfDocument] respondsToSelector:@selector(passwordUsedForUnlocking)])
            password = [[self pdfDocument] passwordUsedForUnlocking];
        if (password)
            [document unlockWithPassword:password];
    }
}

#pragma mark Scripting support

- (BOOL)hasNotes {
    return [[self mainWindowController] hasNotes];
}

- (NSArray *)notes {
    return [[self mainWindowController] notes];
}

- (PDFAnnotation *)valueInNotesWithUniqueID:(NSString *)aUniqueID {
    for (PDFAnnotation *annotation in [[self mainWindowController] notes]) {
        if ([[annotation uniqueID] isEqualToString:aUniqueID])
            return annotation;
    }
    return nil;
}

- (void)insertObject:(PDFAnnotation *)newNote inNotesAtIndex:(NSUInteger)anIndex {
    if ([[self pdfDocument] allowsNotes]) {
        PDFPage *page = [newNote page];
        if (page && [[page annotations] containsObject:newNote] == NO) {
            [[self pdfDocument] addAnnotation:newNote toPage:page];
            [[self undoManager] setActionName:NSLocalizedString(@"Add Note", @"Undo action name")];
        } else {
            [[NSScriptCommand currentCommand] setScriptErrorNumber:NSReceiversCantHandleCommandScriptError];
        }
    }
}

- (void)removeObjectFromNotesAtIndex:(NSUInteger)anIndex {
    if ([[self pdfDocument] allowsNotes]) {
        PDFAnnotation *note = [[self notes] objectAtIndex:anIndex];
        
        [[self pdfDocument] removeAnnotation:note];
        [[self undoManager] setActionName:NSLocalizedString(@"Remove Note", @"Undo action name")];
    }
}

- (NSUInteger)countOfOutlines {
    return [[[self pdfDocument] outlineRoot] numberOfChildren];
}

- (PDFOutline *)objectInOutlinesAtIndex:(NSUInteger)idx {
    return [[[self pdfDocument] outlineRoot] childAtIndex:idx];
}

- (BOOL)isOutlineExpanded:(PDFOutline *)outline {
    return [[self mainWindowController] isOutlineExpanded:outline];
}

- (void)setExpanded:(BOOL)flag forOutline:(PDFOutline *)outline {
    [[self mainWindowController] setExpanded:flag forOutline:outline];
}

- (PDFPage *)currentPage {
    return [[self pdfView] currentPage];
}

- (void)setCurrentPage:(PDFPage *)page {
    [[self pdfView] goToCurrentPage:page];
}

- (NSData *)currentQDPoint {
    NSPoint point;
    [[self pdfView] currentPageIndexAndPoint:&point rotated:NULL];
    Point qdPoint = SKQDPointFromNSPoint(point);
    return [NSData dataWithBytes:&qdPoint length:sizeof(Point)];
}

- (PDFAnnotation *)activeNote {
    return [[self pdfView] currentAnnotation];
}

- (void)setActiveNote:(PDFAnnotation *)note {
    if ([note isEqual:[NSNull null]] == NO && [note isSkimNote])
        [[self pdfView] setCurrentAnnotation:note];
}

- (NSTextStorage *)richText {
    PDFDocument *doc = [self pdfDocument];
    NSUInteger i, count = [doc pageCount];
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    NSAttributedString *attrString;
    [textStorage beginEditing];
    for (i = 0; i < count; i++) {
        if (i > 0)
            [[textStorage mutableString] appendString:@"\n"];
        if ((attrString = [[doc pageAtIndex:i] attributedString]))
            [textStorage appendAttributedString:attrString];
    }
    [textStorage endEditing];
    return textStorage;
}

- (id)selectionSpecifier {
    PDFSelection *sel = [[self pdfView] currentSelection];
    return [sel hasCharacters] ? [sel objectSpecifiers] : @[];
}

- (void)setSelectionSpecifier:(id)specifier {
    PDFSelection *selection = [PDFSelection selectionWithSpecifier:specifier];
    [[self pdfView] setCurrentSelection:selection];
}

- (NSData *)selectionQDRect {
    Rect qdRect = SKQDRectFromNSRect([[self pdfView] currentSelectionRect]);
    return [NSData dataWithBytes:&qdRect length:sizeof(Rect)];
}

- (void)setSelectionQDRect:(NSData *)inQDRectAsData {
    if ([inQDRectAsData length] == sizeof(Rect)) {
        const Rect *qdBounds = (const Rect *)[inQDRectAsData bytes];
        NSRect newBounds = SKNSRectFromQDRect(*qdBounds);
        [[self pdfView] setCurrentSelectionRect:newBounds];
        if ([[self pdfView] currentSelectionPage] == nil)
            [[self pdfView] setCurrentSelectionPage:[[self pdfView] currentPage]];
    }
}

- (id)selectionPage {
    return [[self pdfView] currentSelectionPage];
}

- (void)setSelectionPage:(PDFPage *)page {
    [[self pdfView] setCurrentSelectionPage:[page isKindOfClass:[PDFPage class]] ? page : nil];
}

- (NSArray *)noteSelection {
    return [[self mainWindowController] selectedNotes];
}

- (void)setNoteSelection:(NSArray *)newNoteSelection {
    return [[self mainWindowController] setSelectedNotes:newNoteSelection];
}

- (NSDictionary *)pdfViewSettings {
    return [[self mainWindowController] currentPDFSettings];
}

- (void)setPdfViewSettings:(NSDictionary *)pdfViewSettings {
    [[self mainWindowController] applyPDFSettings:pdfViewSettings rewind:NO];
}

- (NSInteger)toolMode {
    NSInteger toolMode = [[self pdfView] toolMode];
    if (toolMode == SKNoteToolMode)
        toolMode += [[self pdfView] annotationMode];
    return toolMode;
}

- (void)setToolMode:(NSInteger)newToolMode {
    if (newToolMode >= SKNoteToolMode) {
        [[self pdfView] setAnnotationMode:newToolMode - SKNoteToolMode];
        newToolMode = SKNoteToolMode;
    }
    [[self pdfView] setToolMode:newToolMode];
}

- (NSInteger)scriptingInteractionMode {
    return [[self mainWindowController] interactionMode];
}

- (void)setScriptingInteractionMode:(NSInteger)mode {
    if (mode == SKNormalMode) {
        if ([[self mainWindowController] canExitFullscreen])
            [[self mainWindowController] exitFullscreen];
        else if ([[self mainWindowController] canExitPresentation])
            [[self mainWindowController] exitPresentation];
    } else if (mode == SKFullScreenMode) {
        if ([[self mainWindowController] canEnterFullscreen])
            [[self mainWindowController] enterFullscreen];
    } else if (mode == SKPresentationMode) {
        if ([[self mainWindowController] canEnterPresentation])
            [[self mainWindowController] enterPresentation];
    }
}

- (NSDocument *)presentationNotesDocument {
    return [[self mainWindowController] presentationNotesDocument];
}

- (void)setPresentationNotesDocument:(NSDocument *)document {
    if ([document isPDFDocument] && [document countOfPages] == [self countOfPages]) {
        [[self mainWindowController] setPresentationNotesDocument:document];
        if (document != self)
            [[self mainWindowController] setPresentationNotesOffset:0];
    }
}

- (NSInteger)presentationNotesOffset {
    return [[self mainWindowController] presentationNotesOffset];
}

- (void)setPresentationNotesOffset:(NSInteger)offset {
    [[self mainWindowController] setPresentationNotesOffset:offset];
}

- (BOOL)isPDFDocument {
    return YES;
}

- (id)readingBar {
    return [[self pdfView] readingBar];
}

- (BOOL)hasReadingBar {
    return [[self pdfView] hasReadingBar];
}

- (void)setHasReadingBar:(BOOL)flag {
    if ([[self pdfView] hasReadingBar] != flag)
        [[self pdfView] toggleReadingBar];
}

- (id)newScriptingObjectOfClass:(Class)class forValueForKey:(NSString *)key withContentsValue:(id)contentsValue properties:(NSDictionary *)properties {
    if ([key isEqualToString:@"notes"]) {
        PDFAnnotation *annotation = nil;
        id selSpec = contentsValue ?: [[[[NSScriptCommand currentCommand] arguments] objectForKey:@"KeyDictionary"] objectForKey:SKPDFAnnotationSelectionSpecifierKey];
        PDFSelection *sel = selSpec ? [PDFSelection selectionWithSpecifier:selSpec] : nil;
        PDFPage *page = [sel safeFirstPage];
        if (page == nil || [page document] != [self pdfDocument]) {
            [[NSScriptCommand currentCommand] setScriptErrorNumber:NSReceiversCantHandleCommandScriptError]; 
        } else {
            annotation = [page newScriptingObjectOfClass:class forValueForKey:key withContentsValue:sel ?: contentsValue properties:properties];
            if ([annotation respondsToSelector:@selector(setPage:)])
                [annotation performSelector:@selector(setPage:) withObject:page];
        }
        return annotation;
    }
    return [super newScriptingObjectOfClass:class forValueForKey:key withContentsValue:contentsValue properties:properties];
}

- (id)copyScriptingValue:(id)value forKey:(NSString *)key withProperties:(NSDictionary *)properties {
    if ([key isEqualToString:@"notes"]) {
        NSMutableArray *copiedValue = [[NSMutableArray alloc] init];
        for (PDFAnnotation *annotation in value) {
            if ([annotation isMovable] && [[annotation page] document] == [self pdfDocument]) {
                PDFAnnotation *copiedAnnotation = [PDFAnnotation newSkimNoteWithProperties:[annotation SkimNoteProperties]];
                [copiedAnnotation registerUserName];
                if ([copiedAnnotation respondsToSelector:@selector(setPage:)])
                    [copiedAnnotation performSelector:@selector(setPage:) withObject:[annotation page]];
                if ([properties count])
                    [copiedAnnotation setScriptingProperties:[copiedAnnotation coerceValue:properties forKey:@"scriptingProperties"]];
                [copiedValue addObject:copiedAnnotation];
            } else {
                // we don't want to duplicate markup
                NSScriptCommand *cmd = [NSScriptCommand currentCommand];
                [cmd setScriptErrorNumber:NSReceiversCantHandleCommandScriptError];
                [cmd setScriptErrorString:@"Cannot duplicate markup note."];
                copiedValue = nil;
            }
        }
        return copiedValue;
    }
    return [super copyScriptingValue:value forKey:key withProperties:properties];
}

- (id)handleSaveScriptCommand:(NSScriptCommand *)command {
	NSDictionary *args = [command arguments];
    id fileType = [args objectForKey:@"FileType"];
    id file = [args objectForKey:@"File"];
    // we don't want to expose the UTI types to the user, and we allow template file names without extension
    if (fileType && file) {
        NSString *normalizedType = nil;
        NSInteger option = SKExportOptionDefault;
        NSArray *writableTypes = [self writableTypesForSaveOperation:NSSaveToOperation];
        SKTemplateManager *tm = [SKTemplateManager sharedManager];
        if ([fileType isEqualToString:@"PDF"]) {
            normalizedType = SKPDFDocumentType;
        } else if ([fileType isEqualToString:@"PDF With Embedded Notes"]) {
            normalizedType = SKPDFDocumentType;
            option = SKExportOptionWithEmbeddedNotes;
        } else if ([fileType isEqualToString:@"PDF Without Notes"]) {
            normalizedType = SKPDFDocumentType;
            option = SKExportOptionWithoutNotes;
        } else if ([fileType isEqualToString:@"PostScript"]) {
            normalizedType = [[NSWorkspace sharedWorkspace] type:[self fileType] conformsToType:SKEncapsulatedPostScriptDocumentType] ? SKEncapsulatedPostScriptDocumentType : SKPostScriptDocumentType;
        } else if ([fileType isEqualToString:@"PostScript Without Notes"]) {
            normalizedType = [[NSWorkspace sharedWorkspace] type:[self fileType] conformsToType:SKEncapsulatedPostScriptDocumentType] ? SKEncapsulatedPostScriptDocumentType : SKPostScriptDocumentType;
            option = SKExportOptionWithoutNotes;
        } else if ([fileType isEqualToString:@"Encapsulated PostScript"]) {
            normalizedType = SKEncapsulatedPostScriptDocumentType;
        } else if ([fileType isEqualToString:@"Encapsulated PostScript Without Notes"]) {
            normalizedType = SKEncapsulatedPostScriptDocumentType;
            option = SKExportOptionWithoutNotes;
        } else if ([fileType isEqualToString:@"DVI"]) {
            normalizedType = SKDVIDocumentType;
        } else if ([fileType isEqualToString:@"DVI Without Notes"]) {
            normalizedType = SKDVIDocumentType;
            option = SKExportOptionWithoutNotes;
        } else if ([fileType isEqualToString:@"XDV"]) {
            normalizedType = SKXDVDocumentType;
        } else if ([fileType isEqualToString:@"XDV Without Notes"]) {
            normalizedType = SKXDVDocumentType;
            option = SKExportOptionWithoutNotes;
        } else if ([fileType isEqualToString:@"PDF Bundle"]) {
            normalizedType = SKPDFBundleDocumentType;
        } else if ([fileType isEqualToString:@"Skim Notes"]) {
            normalizedType = SKNotesDocumentType;
        } else if ([fileType isEqualToString:@"Notes as Text"]) {
            normalizedType = SKNotesTextDocumentType;
        } else if ([fileType isEqualToString:@"Notes as RTF"]) {
            normalizedType = SKNotesRTFDocumentType;
        } else if ([fileType isEqualToString:@"Notes as RTFD"]) {
            normalizedType = SKNotesRTFDDocumentType;
        } else if ([fileType isEqualToString:@"Notes as FDF"]) {
            normalizedType = SKNotesFDFDocumentType;
        } else if ([writableTypes containsObject:fileType] == NO) {
            normalizedType = [tm templateTypeForDisplayName:fileType];
        }
        if ([writableTypes containsObject:normalizedType] || [[tm customTemplateTypes] containsObject:fileType]) {
            mdFlags.exportOption = option;
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

- (void)handleRevertScriptCommand:(NSScriptCommand *)command {
    if ([self fileURL] && [[self fileURL] checkResourceIsReachableAndReturnError:NULL]) {
        if ([fileUpdateChecker isUpdatingFile] == NO && [self revertToContentsOfURL:[self fileURL] ofType:[self fileType] error:NULL] == NO) {
            [command setScriptErrorNumber:NSInternalScriptError];
            [command setScriptErrorString:@"Revert failed."];
        }
    } else {
        [command setScriptErrorNumber:NSArgumentsWrongScriptError];
        [command setScriptErrorString:@"File does not exist."];
    }
}

- (void)handleGoToScriptCommand:(NSScriptCommand *)command {
	NSDictionary *args = [command evaluatedArguments];
    id location = [args objectForKey:@"To"];
    
    if ([location isKindOfClass:[PDFPage class]]) {
        id pointData = [args objectForKey:@"At"];
        if ([pointData isKindOfClass:[NSData class]]) {
            NSPoint point = [(NSData *)pointData pointValueAsQDPoint];
            [[self pdfView] goToDestination:[[PDFDestination alloc] initWithPage:(PDFPage *)location atPoint:point]];
        } else {
            [[self pdfView] goToCurrentPage:(PDFPage *)location];
        }
    } else if ([location isKindOfClass:[PDFAnnotation class]]) {
           [[self pdfView] scrollAnnotationToVisible:(PDFAnnotation *)location];
    } else if ([location isKindOfClass:[PDFOutline class]]) {
        PDFDestination *dest = [(PDFOutline *)location destination];
        if (dest) {
            [[self pdfView] goToDestination:dest];
        } else {
            PDFAction *action = [(PDFOutline *)location action];
            if (action)
                 [[self pdfView] performAction:action];
        }
    } else if ([location isKindOfClass:[SKLine class]]) {
        PDFPage *page = [(SKLine *)location page];
        NSRect bounds = [(SKLine *)location bounds];
        [[self pdfView] goToRect:bounds onPage:page];
    } else if ([location isKindOfClass:[NSNumber class]]) {
        id source = [args objectForKey:@"Source"];
        NSInteger options = SKPDFSynchronizerDefaultOptions;
        BOOL showBar = [[args objectForKey:@"ShowReadingBar"] boolValue];
        if (showBar)
            options |= SKPDFSynchronizerShowReadingBarMask;
        if ([[args objectForKey:@"Selecting"] boolValue] || (showBar == NO && [args objectForKey:@"Selecting"] == nil))
            options |= SKPDFSynchronizerSelectMask;
        if ([source isKindOfClass:[NSString class]])
            source = [NSURL fileURLWithPath:source isDirectory:NO];
        else if ([source isKindOfClass:[NSURL class]] == NO)
            source = nil;
        [[self synchronizer] findPageAndLocationForLine:[location integerValue] inFile:[source path] options:options];
    } else {
        PDFSelection *selection = [PDFSelection selectionWithSpecifier:[[command arguments] objectForKey:@"To"]];
        if ([selection hasCharacters]) {
            PDFPage *page = [selection safeFirstPage];
            NSRect bounds = [selection boundsForPage:page];
            [[self pdfView] goToRect:bounds onPage:page];
        }
    }
}

- (id)handleFindScriptCommand:(NSScriptCommand *)command {
	NSDictionary *args = [command evaluatedArguments];
    id text = [args objectForKey:@"Text"];
    id specifier = nil;
    
    if ([text isKindOfClass:[NSString class]] == NO) {
        [command setScriptErrorNumber:NSArgumentsWrongScriptError];
        [command setScriptErrorString:@"The text to find is missing or is not a string."];
        return nil;
    } else {
        id from = [[command arguments] objectForKey:@"From"];
        id backward = [args objectForKey:@"Backward"];
        id caseSensitive = [args objectForKey:@"CaseSensitive"];
        PDFSelection *selection = nil;
        NSInteger options = 0;
        
        if (from)
            selection = [PDFSelection selectionWithSpecifier:from];
        
        if ([backward isKindOfClass:[NSNumber class]] && [backward boolValue])
            options |= NSBackwardsSearch;
        if ([caseSensitive isKindOfClass:[NSNumber class]] == NO || [caseSensitive boolValue] == NO)
            options |= NSCaseInsensitiveSearch;
        
        if ((selection = [[self pdfDocument] findString:text fromSelection:selection withOptions:options]))
            specifier = [selection objectSpecifiers];
    }
    
    return specifier ?: @[];
}

- (void)handleEditScriptCommand:(NSScriptCommand *)command {
	NSDictionary *args = [command evaluatedArguments];
    id page = [args objectForKey:@"Page"];
    id pointData = [args objectForKey:@"Point"];
    NSPoint point = NSZeroPoint;
    
    if ([page isKindOfClass:[PDFPage class]] == NO)
        page = [[self pdfView] currentPage];
    if ([pointData isKindOfClass:[NSDate class]]) {
        point = [pointData pointValueAsQDPoint];
    } else {
        NSRect bounds = [page boundsForBox:[[self pdfView] displayBox]];
        point = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
    }
    if (page) {
        NSUInteger pageIndex = [page pageIndex];
        PDFSelection *sel = [page selectionForLineAtPoint:point];
        NSRect rect = [sel hasCharacters] ? [sel boundsForPage:page] : NSMakeRect(point.x - 20.0, point.y - 5.0, 40.0, 10.0);
        
        [[self synchronizer] findFileAndLineForLocation:point inRect:rect pageBounds:[page boundsForBox:kPDFDisplayBoxMediaBox] atPageIndex:pageIndex];
    }
}

- (void)handleConvertNotesScriptCommand:(NSScriptCommand *)command {
    if ([[NSWorkspace sharedWorkspace] type:[self fileType] conformsToType:SKPDFDocumentType] == NO && [[NSWorkspace sharedWorkspace] type:[self fileType] conformsToType:SKPDFBundleDocumentType] == NO) {
        [command setScriptErrorNumber:NSArgumentsWrongScriptError];
    } else if (mdFlags.convertingNotes || [[self pdfDocument] isLocked]) {
        [command setScriptErrorNumber:NSInternalScriptError];
    } else if ([self hasConvertibleAnnotations]) {
        NSDictionary *args = [command evaluatedArguments];
        NSNumber *wait = [args objectForKey:@"Wait"];
        [self convertNotes];
        if (wait == nil || [wait boolValue])
            while (mdFlags.convertingNotes == 1 && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    }
}

- (void)handleReadNotesScriptCommand:(NSScriptCommand *)command {
    NSDictionary *args = [command evaluatedArguments];
    NSURL *notesURL = [args objectForKey:@"File"];
    if (notesURL == nil) {
        [command setScriptErrorNumber:NSRequiredArgumentsMissingScriptError];
    } else if ([[self pdfDocument] isLocked]) {
        [command setScriptErrorNumber:NSInternalScriptError];
    } else {
        NSNumber *replaceNumber = [args objectForKey:@"Replace"];
        NSString *fileType = [[NSDocumentController sharedDocumentController] typeForContentsOfURL:notesURL error:NULL];
        if ([[NSWorkspace sharedWorkspace] type:fileType conformsToType:SKNotesDocumentType])
            [self readNotesFromURL:notesURL replace:(replaceNumber ? [replaceNumber boolValue] : YES)];
        else
            [command setScriptErrorNumber:NSArgumentsWrongScriptError];
    }
}

@end
