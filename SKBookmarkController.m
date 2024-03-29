//
//  SKBookmarkController.m
//  Skim
//
//  Created by Christiaan Hofman on 3/16/07.
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

#import "SKBookmarkController.h"
#import "SKBookmark.h"
#import "SKTypeSelectHelper.h"
#import "SKStatusBar.h"
#import "SKToolbarItem.h"
#import "NSToolbarItem_SKExtensions.h"
#import "SKStringConstants.h"
#import "NSMenu_SKExtensions.h"
#import "NSURL_SKExtensions.h"
#import "NSString_SKExtensions.h"
#import "NSEvent_SKExtensions.h"
#import "NSImage_SKExtensions.h"
#import "NSShadow_SKExtensions.h"
#import "NSView_SKExtensions.h"
#import "NSError_SKExtensions.h"
#import "SKDocumentController.h"
#import "SKRecentDocumentInfo.h"
#import "NSPasteboard_SKExtensions.h"

#define SKPasteboardTypeBookmarkRow @"net.sourceforge.skim-app.pasteboard.bookmarkrow"

#define SKBookmarksToolbarIdentifier                 @"SKBookmarksToolbarIdentifier"
#define SKBookmarksNewFolderToolbarItemIdentifier    @"SKBookmarksNewFolderToolbarItemIdentifier"
#define SKBookmarksNewSeparatorToolbarItemIdentifier @"SKBookmarksNewSeparatorToolbarItemIdentifier"
#define SKBookmarksDeleteToolbarItemIdentifier       @"SKBookmarksDeleteToolbarItemIdentifier"

#define SKBookmarksTouchBarIdentifier        @"net.sourceforge.skim-app.touchbar.bookmarks"
#define SKTouchBarItemIdentifierNewFolder    @"net.sourceforge.skim-app.touchbar-item.newFolder"
#define SKTouchBarItemIdentifierNewSeparator @"net.sourceforge.skim-app.touchbar-item.newSeparator"
#define SKTouchBarItemIdentifierDelete       @"net.sourceforge.skim-app.touchbar-item.delete"
#define SKTouchBarItemIdentifierPreview      @"net.sourceforge.skim-app.touchbar-item.preview"

#define SKBookmarksWindowFrameAutosaveName @"SKBookmarksWindow"

#define LABEL_COLUMNID @"label"
#define FILE_COLUMNID  @"file"
#define PAGE_COLUMNID  @"page"

#define SKMaximumDocumentPageHistoryCountKey @"SKMaximumDocumentPageHistoryCount"

#define BOOKMARKS_KEY       @"bookmarks"
#define RECENTDOCUMENTS_KEY @"recentDocuments"

#define PAGEINDEX_KEY @"pageIndex"
#define CHILDREN_KEY @"children"
#define LABEL_KEY    @"label"

#define SKImageNameSeparator @"SKSeparator"

#define INDENT 9.0
#define OLD_INDENT 16.0

#define SAVE_DELAY 10.0

static char SKBookmarkPropertiesObservationContext;

static NSString *SKBookmarksIdentifier = nil;

static NSArray *minimumCoverForBookmarks(NSArray *items);

@interface SKBookmarkController (SKPrivate)
- (void)setupToolbar;
- (void)saveBookmarksData;
- (void)handleApplicationWillTerminateNotification:(NSNotification *)notification;
- (void)endEditing;
- (void)startObservingBookmarks:(NSArray *)newBookmarks;
- (void)stopObservingBookmarks:(NSArray *)oldBookmarks;
@end

@interface SKBookmarkController ()
@property (nonatomic, readonly) NSUndoManager *undoManager;
@end

@implementation SKBookmarkController

@synthesize outlineView, statusBar, folderSegmentedControl, separatorSegmentedControl, deleteSegmentedControl, bookmarkRoot, previousSession, undoManager;

static SKBookmarkController *sharedBookmarkController = nil;

static NSUInteger maxRecentDocumentsCount = 0;

+ (void)initialize {
    SKINITIALIZE;
    
    maxRecentDocumentsCount = [[NSUserDefaults standardUserDefaults] integerForKey:SKMaximumDocumentPageHistoryCountKey];
    if (maxRecentDocumentsCount == 0)
        maxRecentDocumentsCount = 50;
    
    SKBookmarksIdentifier = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".bookmarks"];
    
    static NSImage *separatorImage = nil;
    separatorImage = [[NSImage alloc] initWithSize:NSMakeSize(2.0, 2.0)];
    [separatorImage lockFocus];
    [[NSColor gridColor] setFill];
    [NSBezierPath fillRect:NSMakeRect(0.0, 0.0, 2.0, 2.0)];
    [separatorImage unlockFocus];
    [separatorImage setName:SKImageNameSeparator];
    [separatorImage setAccessibilityDescription:NSLocalizedString(@"separator", @"Accessibility description")];
}

+ (SKBookmarkController *)sharedBookmarkController {
    if (sharedBookmarkController == nil)
        (void)[[self alloc] init];
    return sharedBookmarkController;
}

+ (instancetype)allocWithZone:(NSZone *)zone {
    return sharedBookmarkController ?: [super allocWithZone:zone];
}

- (instancetype)init {
    if (sharedBookmarkController == nil) {
        self = [super initWithWindowNibName:@"BookmarksWindow"];
        if (self) {
            NSDictionary *bookmarkDictionary = [[NSUserDefaults standardUserDefaults] persistentDomainForName:SKBookmarksIdentifier];
            
            bookmarksCache = [bookmarkDictionary objectForKey:BOOKMARKS_KEY];
            
            recentDocuments = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in [bookmarkDictionary objectForKey:RECENTDOCUMENTS_KEY]) {
                SKRecentDocumentInfo *info = [[SKRecentDocumentInfo alloc] initWithProperties:dict];
                [recentDocuments addObject:info];
            }
            
            bookmarkRoot = [[SKBookmark alloc] initRootWithChildrenProperties:bookmarksCache];
            [self startObservingBookmarks:@[bookmarkRoot]];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleApplicationWillTerminateNotification:)
                                                         name:NSApplicationWillTerminateNotification
                                                       object:NSApp];
            
            NSArray *lastOpenFiles = [[NSUserDefaults standardUserDefaults] arrayForKey:SKLastOpenFileNamesKey];
            if ([lastOpenFiles count] > 0)
                previousSession = [[SKBookmark alloc] initSessionWithSetups:lastOpenFiles label:NSLocalizedString(@"Restore Previous Session", @"Menu item title")];
        }
        sharedBookmarkController = self;
    } else if (self != sharedBookmarkController) {
        NSLog(@"Attempt to allocate second instance of %@", [self class]);
        self = sharedBookmarkController;
    }
    return self;
}

- (void)dealloc {
    [self stopObservingBookmarks:@[bookmarkRoot]];
}

- (void)windowDidLoad {
    [self setupToolbar];
    
    [self setWindowFrameAutosaveName:SKBookmarksWindowFrameAutosaveName];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKShowBookmarkStatusBarKey] == NO)
        [self toggleStatusBar:nil];
    
    [outlineView setStronglyReferencesItems:YES];
    
    [outlineView setTypeSelectHelper:[SKTypeSelectHelper typeSelectHelper]];
    
    [outlineView registerForDraggedTypes:@[SKPasteboardTypeBookmarkRow, (__bridge NSString *)kUTTypeFileURL, NSFilenamesPboardType]];
    
    [outlineView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [outlineView setDraggingSourceOperationMask:NSDragOperationDelete forLocal:NO];
    
    [outlineView setDoubleAction:@selector(doubleClickBookmark:)];
    
    [outlineView setSupportsQuickLook:YES];
    
    [outlineView sizeToFit];
    
    NSArray *sendTypes = @[(__bridge NSString *)kUTTypeFileURL];
    [NSApp registerServicesMenuSendTypes:sendTypes returnTypes:@[]];
}

- (void)updateStatus {
    NSInteger row = [outlineView selectedRow];
    NSString *message = @"";
    if (row != -1) {
        SKBookmark *bookmark = [outlineView itemAtRow:row];
        if ([bookmark bookmarkType] == SKBookmarkTypeBookmark) {
            message = [[bookmark fileURL] path];
        } else if ([bookmark bookmarkType] == SKBookmarkTypeFolder) {
            NSInteger count = [bookmark countOfChildren];
            message = count == 1 ? NSLocalizedString(@"1 item", @"Bookmark folder description") : [NSString stringWithFormat:NSLocalizedString(@"%ld items", @"Bookmark folder description"), (long)count];
        }
    }
    [[statusBar leftField] setStringValue:message ?: @""];
}

- (void)saveBookmarksData {
    if (bookmarksCache == nil)
        bookmarksCache = [[bookmarkRoot children] valueForKey:@"properties"];
    NSDictionary *bookmarksDictionary = @{BOOKMARKS_KEY:bookmarksCache, RECENTDOCUMENTS_KEY:[recentDocuments valueForKey:@"properties"]};
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:bookmarksDictionary forName:SKBookmarksIdentifier];
}

#pragma mark Recent Documents

- (SKRecentDocumentInfo *)recentDocumentInfoAtURL:(NSURL *)fileURL {
    NSString *path = [fileURL path];
    for (SKRecentDocumentInfo *info in recentDocuments) {
        if ([[[info fileURL] path] isCaseInsensitiveEqual:path])
            return info;
    }
    return nil;
}

- (void)addRecentDocumentForURL:(NSURL *)fileURL pageIndex:(NSUInteger)pageIndex snapshots:(NSArray *)setups {
    if (fileURL == nil)
        return;
    
    SKRecentDocumentInfo *info = [[SKRecentDocumentInfo alloc] initWithURL:fileURL pageIndex:pageIndex snapshots:setups];
    if (info) {
        SKRecentDocumentInfo *oldInfo = [self recentDocumentInfoAtURL:fileURL];
        if (oldInfo)
            [recentDocuments removeObjectIdenticalTo:oldInfo];
        [recentDocuments insertObject:info atIndex:0];
        if ([recentDocuments count] > maxRecentDocumentsCount)
            [recentDocuments removeLastObject];
    }
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveBookmarksData) object:nil];
    [self performSelector:@selector(saveBookmarksData) withObject:nil afterDelay:SAVE_DELAY];
}

- (NSUInteger)pageIndexForRecentDocumentAtURL:(NSURL *)fileURL {
    SKRecentDocumentInfo *info = fileURL ? [self recentDocumentInfoAtURL:fileURL] : nil;
    return info ? [info pageIndex] : NSNotFound;
}

- (NSArray *)snapshotsForRecentDocumentAtURL:(NSURL *)fileURL {
    return fileURL ? [[self recentDocumentInfoAtURL:fileURL] snapshots] : nil;
}

#pragma mark Bookmarks support

- (SKBookmark *)bookmarkForURL:(NSURL *)bookmarkURL {
    SKBookmark *bookmark = nil;
    if ([bookmarkURL isSkimBookmarkURL]) {
        bookmark = [self bookmarkRoot];
        NSArray *components = [[[bookmarkURL absoluteString] substringFromIndex:17] componentsSeparatedByString:@"/"];
        for (NSString *component in components) {
            if ([component length] == 0)
                continue;
            NSString *cleanComponent = [component stringByRemovingPercentEncoding];
            NSArray *children = [bookmark children];
            bookmark = nil;
            for (SKBookmark *child in children) {
                if ([[child label] isEqualToString:cleanComponent]) {
                    bookmark = child;
                    break;
                }
                if (bookmark == nil && [[child label] caseInsensitiveCompare:cleanComponent] == NSOrderedSame)
                    bookmark = child;
            }
            if (bookmark == nil)
                break;
        }
        if (bookmark == nil && [components count] == 1) {
            NSArray *allBookmarks = [bookmarkRoot entireContents];
            NSArray *names = [allBookmarks valueForKey:@"label"];
            NSString *name = [components lastObject];
            NSUInteger i = [names indexOfObject:name];
            if (i != NSNotFound) {
                bookmark = [allBookmarks objectAtIndex:i];
            } else {
                i = [[names valueForKey:@"lowercaseString"] indexOfObject:[name lowercaseString]];
                if (i != NSNotFound)
                    bookmark = [allBookmarks objectAtIndex:i];
            }
        }
    }
    return bookmark;
}

#define OV_ITEM(parent) (parent == bookmarkRoot ? nil : parent)

- (void)insertBookmarks:(NSArray *)newBookmarks atIndexes:(NSIndexSet *)indexes ofBookmark:(SKBookmark *)parent animate:(BOOL)animate {
    NSTableViewAnimationOptions options = NSTableViewAnimationEffectGap | NSTableViewAnimationSlideDown;
    if (animate == NO || [self isWindowLoaded] == NO || [[self window] isVisible] == NO || [NSView shouldShowSlideAnimation] == NO)
        options = NSTableViewAnimationEffectNone;
    if (needsBeginUpdates) {
        [outlineView beginUpdates];
        needsBeginUpdates = NO;
    }
    [outlineView insertItemsAtIndexes:indexes inParent:OV_ITEM(parent) withAnimation:options];
    [parent insertChildren:newBookmarks atIndexes:indexes];
}

- (void)removeBookmarksAtIndexes:(NSIndexSet *)indexes ofBookmark:(SKBookmark *)parent animate:(BOOL)animate {
    NSTableViewAnimationOptions options = NSTableViewAnimationEffectGap | NSTableViewAnimationSlideUp;
    if (animate == NO || [self isWindowLoaded] == NO || [[self window] isVisible] == NO || [NSView shouldShowSlideAnimation] == NO)
        options = NSTableViewAnimationEffectNone;
    if (needsBeginUpdates) {
        [outlineView beginUpdates];
        needsBeginUpdates = NO;
    }
    [outlineView removeItemsAtIndexes:indexes inParent:OV_ITEM(parent) withAnimation:options];
    [parent removeChildrenAtIndexes:indexes];
}

- (void)moveBookmarkAtIndex:(NSUInteger)fromIndex ofBookmark:(SKBookmark *)fromParent toIndex:(NSUInteger)toIndex ofBookmark:(SKBookmark *)toParent {
    if ([NSView shouldShowSlideAnimation]) {
        [outlineView moveItemAtIndex:fromIndex inParent:OV_ITEM(fromParent) toIndex:toIndex inParent:OV_ITEM(toParent)];
    } else {
        [outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] inParent:OV_ITEM(fromParent) withAnimation:NSTableViewAnimationEffectNone];
        [outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:toIndex] inParent:OV_ITEM(toParent) withAnimation:NSTableViewAnimationEffectNone];
    }
    SKBookmark *bookmark = [fromParent objectInChildrenAtIndex:fromIndex];
    [fromParent removeObjectFromChildrenAtIndex:fromIndex];
    [toParent insertObject:bookmark inChildrenAtIndex:toIndex];
}

- (void)replaceBookmarksAtIndexes:(NSIndexSet *)indexes ofBookmark:(SKBookmark *)bookmark withBookmarks:(NSArray *)newBookmarks animate:(BOOL)animate {
    NSIndexSet *removeIndexes = indexes ?: [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [bookmark countOfChildren])];
    if ([NSView shouldShowSlideAnimation] == NO)
        animate = NO;
    if ([removeIndexes count] > 0)
        [self removeBookmarksAtIndexes:removeIndexes ofBookmark:bookmark animate:animate];
    NSIndexSet *insertIndexes = indexes ?: [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [newBookmarks count])];
    if ([insertIndexes count] > 0)
        [self insertBookmarks:newBookmarks atIndexes:insertIndexes ofBookmark:bookmark animate:animate];
}

- (void)insertBookmark:(SKBookmark *)bookmark atIndex:(NSUInteger)anIndex ofBookmark:(SKBookmark *)parent animate:(BOOL)animate {
    [outlineView beginUpdates];
    [self insertBookmarks:@[bookmark] atIndexes:[NSIndexSet indexSetWithIndex:anIndex] ofBookmark:parent animate:animate];
    [outlineView endUpdates];
}

- (void)removeBookmarkAtIndex:(NSUInteger)anIndex ofBookmark:(SKBookmark *)parent animate:(BOOL)animate {
    [outlineView beginUpdates];
    [self removeBookmarksAtIndexes:[NSIndexSet indexSetWithIndex:anIndex] ofBookmark:parent animate:animate];
    [outlineView endUpdates];
}

- (void)replaceBookmarkAtIndex:(NSUInteger)anIndex ofBookmark:(SKBookmark *)parent withBookmark:(SKBookmark *)bookmark animate:(BOOL)animate {
    [outlineView beginUpdates];
    [self replaceBookmarksAtIndexes:[NSIndexSet indexSetWithIndex:anIndex] ofBookmark:parent withBookmarks:@[bookmark] animate:animate];
    [outlineView endUpdates];
}

- (BOOL)isBookmarkExpanded:(SKBookmark *)bookmark {
    if (-1 != [outlineView rowForItem:bookmark])
        return NO;
    return [outlineView isItemExpanded:bookmark];
}

- (void)setExpanded:(BOOL)flag forBookmark:(SKBookmark *)bookmark {
    if ([bookmark bookmarkType] != SKBookmarkTypeFolder || [self isBookmarkExpanded:bookmark] == flag)
        return;
    if (flag) {
        SKBookmark *parent = [bookmark parent];
        if ([parent parent])
            [self setExpanded:YES forBookmark:parent];
        [outlineView expandItem:bookmark];
    } else {
        [outlineView collapseItem:bookmark];
    }
}

- (SKBookmark *)insertionFolderAndChildIndex:(NSUInteger *)indexPtr {
    NSInteger rowIndex = [outlineView clickedRow];
    NSIndexSet *indexes = [outlineView selectedRowIndexes];
    if (rowIndex != -1 && [indexes containsIndex:rowIndex] == NO)
        indexes = [NSIndexSet indexSetWithIndex:rowIndex];
    rowIndex = [indexes lastIndex];
    
    SKBookmark *item = bookmarkRoot;
    NSUInteger idx = [bookmarkRoot countOfChildren];
    
    if (rowIndex != NSNotFound) {
        SKBookmark *selectedItem = [outlineView itemAtRow:rowIndex];
        if ([outlineView isItemExpanded:selectedItem]) {
            item = selectedItem;
            idx = [item countOfChildren];
        } else {
            item = [selectedItem parent];
            idx = [[item children] indexOfObject:selectedItem] + 1;
        }
    }
    
    *indexPtr = idx;
    
    return item;
}

- (IBAction)openBookmark:(id)sender {
    [[NSDocumentController sharedDocumentController] openDocumentWithBookmark:[sender representedObject] completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error){
        if (document == nil && error && [error isUserCancelledError] == NO)
            [NSApp presentError:error];
    }];
}

- (IBAction)doubleClickBookmark:(id)sender {
    NSInteger row = [outlineView clickedRow];
    SKBookmark *bm = row == -1 ? nil : [outlineView itemAtRow:row];
    if (bm && ([bm bookmarkType] == SKBookmarkTypeBookmark || [bm bookmarkType] == SKBookmarkTypeSession)) {
        [[NSDocumentController sharedDocumentController] openDocumentWithBookmark:bm completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error){
            if (document == nil && error && [error isUserCancelledError] == NO)
                [NSApp presentError:error];
        }];
    }
}

- (IBAction)insertBookmarkFolder:(id)sender {
    SKBookmark *folder = [[SKBookmark alloc] initFolderWithChildren:nil label:NSLocalizedString(@"Folder", @"default folder name")];
    NSUInteger idx = 0;
    SKBookmark *item = [self insertionFolderAndChildIndex:&idx];
    
    [self insertBookmark:folder atIndex:idx ofBookmark:item animate:YES];
    
    CGFloat delay = [NSView shouldShowFadeAnimation] ? 0.25 : 0.0;
    DISPATCH_MAIN_AFTER_SEC(delay, ^{
        NSInteger row = [outlineView rowForItem:folder];
        [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [outlineView editColumn:0 row:row withEvent:nil select:YES];
    });
}

- (IBAction)insertBookmarkSeparator:(id)sender {
    SKBookmark *separator = [[SKBookmark alloc] initSeparator];
    NSUInteger idx = 0;
    SKBookmark *item = [self insertionFolderAndChildIndex:&idx];
    
    [self insertBookmark:separator atIndex:idx ofBookmark:item animate:YES];
    
    NSInteger row = [outlineView rowForItem:separator];
    [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (IBAction)addBookmark:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSMutableArray *types = [NSMutableArray array];
    for (NSString *docClass in [[NSDocumentController sharedDocumentController] documentClassNames])
        [types addObjectsFromArray:[NSClassFromString(docClass) readableTypes]];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowedFileTypes:types];
    [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result){
            if (result == NSModalResponseOK) {
                NSArray *newBookmarks = [SKBookmark bookmarksForURLs:[openPanel URLs]];
                if ([newBookmarks count] > 0) {
                    NSUInteger anIndex = 0;
                    SKBookmark *item = [self insertionFolderAndChildIndex:&anIndex];
                    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(anIndex, [newBookmarks count])];
                    [outlineView beginUpdates];
                    [self insertBookmarks:newBookmarks atIndexes:indexes ofBookmark:item animate:YES];
                    [outlineView endUpdates];
                    if (item == bookmarkRoot || [outlineView isItemExpanded:item]) {
                        if (item != bookmarkRoot)
                            [indexes shiftIndexesStartingAtIndex:0 by:[outlineView rowForItem:item] + 1];
                        [outlineView selectRowIndexes:indexes byExtendingSelection:NO];
                    }
                }
            }
        }];
}

- (IBAction)deleteBookmark:(id)sender {
    [outlineView delete:sender];
}

- (IBAction)toggleStatusBar:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(NO == [statusBar isVisible]) forKey:SKShowBookmarkStatusBarKey];
    [statusBar toggleBelowView:[outlineView enclosingScrollView] animate:sender != nil];
}

- (NSArray *)clickedBookmarks {
    NSArray *items = nil;
    NSInteger row = [outlineView clickedRow];
    if (row != -1) {
        NSIndexSet *indexes = [outlineView selectedRowIndexes];
        if ([indexes containsIndex:row] == NO)
            indexes = [NSIndexSet indexSetWithIndex:row];
        items = [outlineView itemsAtRowIndexes:indexes];
    }
    return items;
}

- (IBAction)deleteBookmarks:(id)sender {
    [self outlineView:outlineView deleteItems:[self clickedBookmarks]];
}

- (IBAction)openBookmarks:(id)sender {
    NSArray *allBookmarks = minimumCoverForBookmarks([self clickedBookmarks]);
    if ([allBookmarks count] == 1) {
        [[NSDocumentController sharedDocumentController] openDocumentWithBookmark:[allBookmarks firstObject] completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error){
            if (document == nil && error && [error isUserCancelledError] == NO)
                [NSApp presentError:error];
        }];
    } else if ([allBookmarks count] > 1) {
        allBookmarks = [allBookmarks valueForKeyPath:@"@unionOfArrays.containingBookmarks"];
        [[NSDocumentController sharedDocumentController] openDocumentWithBookmarks:allBookmarks completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error){
            if (document == nil && error && [error isUserCancelledError] == NO)
                [NSApp presentError:error];
        }];
    }
}

- (IBAction)previewBookmarks:(id)sender {
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    } else {
        NSInteger row = [outlineView clickedRow];
        if (row != -1 && [[outlineView selectedRowIndexes] containsIndex:row] == NO)
            [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
    }
}

- (IBAction)chooseFile:(id)sender {
    SKBookmark *bm = [[self clickedBookmarks] firstObject];
    NSURL *oldURL = [bm fileURL];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setAllowedFileTypes:@[SKPDFDocumentType, SKPDFBundleDocumentType, SKPostScriptDocumentType, SKEncapsulatedPostScriptDocumentType, SKDVIDocumentType, SKXDVDocumentType, SKNotesDocumentType]];
    if (oldURL)
        [oPanel setDirectoryURL:[oldURL URLByDeletingLastPathComponent]];
    [oPanel beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result){
            if (result == NSModalResponseOK) {
                NSURL *fileURL = [[oPanel URLs] firstObject];
                if (fileURL)
                    [bm setFileURL:fileURL];
            }
        }];
}

- (IBAction)copyURL:(id)sender {
    NSArray *selectedBookmarks = minimumCoverForBookmarks([outlineView selectedItems]);
    NSMutableArray *skimURLs = [NSMutableArray array];
    NSMutableArray *labels = [NSMutableArray array];
    for (SKBookmark *bookmark in selectedBookmarks) {
        NSURL *skimURL = [bookmark skimURL];
        if (skimURL) {
            [skimURLs addObject:skimURL];
            [labels addObject:[bookmark label]];
        }
    }
    if ([skimURLs count]) {
        NSPasteboard *pboard = [NSPasteboard generalPasteboard];
        [pboard clearContents];
        [pboard writeURLs:skimURLs names:labels];
    } else {
        NSBeep();
    }
}

#pragma mark NSMenu delegate methods

- (void)addItemForBookmark:(SKBookmark *)bookmark toMenu:(NSMenu *)menu isFolder:(BOOL)isFolder isAlternate:(BOOL)isAlternate {
    NSMenuItem *item = nil;
    if (isFolder) {
        item = [menu addItemWithSubmenuAndTitle:[bookmark label]];
        [[item submenu] setDelegate:self];
    } else {
        item = [menu addItemWithTitle:[bookmark label] action:@selector(openBookmark:) target:self];
    }
    [item setRepresentedObject:bookmark];
    if (isAlternate) {
        [item setKeyEquivalentModifierMask:NSEventModifierFlagOption];
        [item setAlternate:YES];
        [item setImageAndSize:[bookmark alternateIcon]];
    } else {
        [item setImageAndSize:[bookmark icon]];
    }
}

static inline BOOL containsFolders(SKBookmark *bookmark) {
    for (SKBookmark *bm in [bookmark children]) {
        if ([bm bookmarkType] == SKBookmarkTypeFolder)
            return YES;
    }
    return NO;
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    if (menu == [outlineView menu]) {
        NSInteger row = [outlineView clickedRow];
        [menu removeAllItems];
        if (row != -1) {
            [menu addItemWithTitle:NSLocalizedString(@"Remove", @"Menu item title") action:@selector(deleteBookmarks:) target:self];
            NSArray *clickedBookmarks = [self clickedBookmarks];
            for (SKBookmark *bm in clickedBookmarks) {
                if ([bm bookmarkType] != SKBookmarkTypeSeparator) {
                    [menu addItemWithTitle:NSLocalizedString(@"Open", @"Menu item title") action:@selector(openBookmarks:) target:self];
                    [menu addItemWithTitle:NSLocalizedString(@"Quick Look", @"Menu item title") action:@selector(previewBookmarks:) target:self];
                    break;
                }
            }
            if ([clickedBookmarks count] == 1 && [[clickedBookmarks firstObject] bookmarkType] == SKBookmarkTypeBookmark)
                [menu addItemWithTitle:NSLocalizedString(@"Choose File", @"Menu item title") action:@selector(chooseFile:) target:self];
            [menu addItem:[NSMenuItem separatorItem]];
        }
        [menu addItemWithTitle:NSLocalizedString(@"New Folder", @"Menu item title") action:@selector(insertBookmarkFolder:) target:self];
        [menu addItemWithTitle:NSLocalizedString(@"New Separator", @"Menu item title") action:@selector(insertBookmarkSeparator:) target:self];
    } else {
        NSMenu *supermenu = [menu supermenu];
        NSInteger idx = [supermenu indexOfItemWithSubmenu:menu]; 
        SKBookmark *bm = nil;
        
        if (supermenu == [NSApp mainMenu])
            bm = [self bookmarkRoot];
        else if (idx >= 0)
            bm = [[supermenu itemAtIndex:idx] representedObject];
        
        if ([bm isKindOfClass:[SKBookmark class]]) {
            NSArray *bookmarks = [bm children];
            NSInteger i = [menu numberOfItems];
            while (i-- > 0 && ([[menu itemAtIndex:i] isSeparatorItem] || [[menu itemAtIndex:i] representedObject]))
                [menu removeItemAtIndex:i];
            if (supermenu == [NSApp mainMenu]) {
                NSURL *fileURL = [[[[NSApp mainWindow] windowController] document] fileURL];
                NSArray *currentBookmarks = nil;
                if (fileURL)
                    currentBookmarks = [[[self bookmarkRoot] entireContents] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fileURL = %@", fileURL]];
                if (previousSession || [currentBookmarks count] > 0)
                    [menu addItem:[NSMenuItem separatorItem]];
                if (previousSession) {
                    [self addItemForBookmark:previousSession toMenu:menu isFolder:NO isAlternate:NO];
                    [self addItemForBookmark:previousSession toMenu:menu isFolder:YES isAlternate:YES];
                }
                if ([currentBookmarks count] > 0) {
                    NSMenuItem *item = [menu addItemWithSubmenuAndTitle:NSLocalizedString(@"Current Document", @"Menu item title")];
                    [item setRepresentedObject:fileURL];
                    NSMenu *submenu = [item submenu];
                    for (bm in currentBookmarks)
                        [self addItemForBookmark:bm toMenu:submenu isFolder:NO isAlternate:NO];
                }
            }
            if ([menu numberOfItems] > 0 && [bookmarks count] > 0)
                [menu addItem:[NSMenuItem separatorItem]];
            for (bm in bookmarks) {
                switch ([bm bookmarkType]) {
                    case SKBookmarkTypeFolder:
                        [self addItemForBookmark:bm toMenu:menu isFolder:YES isAlternate:NO];
                        if (containsFolders(bm) == NO)
                            [self addItemForBookmark:bm toMenu:menu isFolder:NO isAlternate:YES];
                        break;
                    case SKBookmarkTypeSession:
                        [self addItemForBookmark:bm toMenu:menu isFolder:NO isAlternate:NO];
                        [self addItemForBookmark:bm toMenu:menu isFolder:YES isAlternate:YES];
                        break;
                    case SKBookmarkTypeSeparator:
                        [menu addItem:[NSMenuItem separatorItem]];
                        break;
                    default:
                        [self addItemForBookmark:bm toMenu:menu isFolder:NO isAlternate:NO];
                        break;
                }
            }
        }
    }
}

// avoid rebuilding the bookmarks menu on every key event
- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(id *)target action:(SEL *)action { return NO; }

#pragma mark Undo support

- (void)handleWillUndoChange:(NSNotification *)notification {
    needsBeginUpdates = YES;
}

- (void)handleDidUndoChange:(NSNotification *)notification {
    if (needsBeginUpdates == NO)
        [outlineView endUpdates];
    needsBeginUpdates = NO;
}

- (NSUndoManager *)undoManager {
    if(undoManager == nil) {
        undoManager = [[NSUndoManager alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(handleWillUndoChange:) name:NSUndoManagerWillUndoChangeNotification object:undoManager];
        [nc addObserver:self selector:@selector(handleWillUndoChange:) name:NSUndoManagerWillRedoChangeNotification object:undoManager];
        [nc addObserver:self selector:@selector(handleDidUndoChange:) name:NSUndoManagerDidUndoChangeNotification object:undoManager];
        [nc addObserver:self selector:@selector(handleDidUndoChange:) name:NSUndoManagerDidRedoChangeNotification object:undoManager];
    }
    return undoManager;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender {
    return [self undoManager];
}

- (void)startObservingBookmarks:(NSArray *)newBookmarks {
    for (SKBookmark *bm in newBookmarks) {
        if ([bm bookmarkType] != SKBookmarkTypeSeparator) {
            [bm addObserver:self forKeyPath:LABEL_KEY options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&SKBookmarkPropertiesObservationContext];
            [bm addObserver:self forKeyPath:PAGEINDEX_KEY options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&SKBookmarkPropertiesObservationContext];
            if ([bm bookmarkType] == SKBookmarkTypeFolder) {
                [bm addObserver:self forKeyPath:CHILDREN_KEY options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&SKBookmarkPropertiesObservationContext];
                [self startObservingBookmarks:[bm children]];
            }
        }
    }
}

- (void)stopObservingBookmarks:(NSArray *)oldBookmarks {
    for (SKBookmark *bm in oldBookmarks) {
        if ([bm bookmarkType] != SKBookmarkTypeSeparator) {
            [bm removeObserver:self forKeyPath:LABEL_KEY context:&SKBookmarkPropertiesObservationContext];
            [bm removeObserver:self forKeyPath:PAGEINDEX_KEY context:&SKBookmarkPropertiesObservationContext];
            if ([bm bookmarkType] == SKBookmarkTypeFolder) {
                [bm removeObserver:self forKeyPath:CHILDREN_KEY context:&SKBookmarkPropertiesObservationContext];
                [self stopObservingBookmarks:[bm children]];
            }
        }
    }
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &SKBookmarkPropertiesObservationContext) {
        SKBookmark *bookmark = (SKBookmark *)object;
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        BOOL changed = NO;
        NSIndexSet *indexes = [[change objectForKey:NSKeyValueChangeIndexesKey] copy];
        
        if ([newValue isEqual:[NSNull null]]) newValue = nil;
        if ([oldValue isEqual:[NSNull null]]) oldValue = nil;
        changed = (oldValue || newValue) && [newValue isEqual:oldValue] == NO;
        
        switch ([[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue]) {
            case NSKeyValueChangeSetting:
                if (changed == NO) break;
                if ([keyPath isEqualToString:CHILDREN_KEY]) {
                    NSMutableArray *old = [NSMutableArray arrayWithArray:oldValue];
                    NSMutableArray *new = [NSMutableArray arrayWithArray:newValue];
                    [old removeObjectsInArray:newValue];
                    [new removeObjectsInArray:oldValue];
                    [self stopObservingBookmarks:old];
                    [self startObservingBookmarks:new];
                    [[[self undoManager] prepareWithInvocationTarget:self] replaceBookmarksAtIndexes:nil ofBookmark:bookmark withBookmarks:[oldValue copy] animate:YES];
                } else if ([keyPath isEqualToString:LABEL_KEY]) {
                    [[[self undoManager] prepareWithInvocationTarget:bookmark] setLabel:oldValue];
                    [outlineView reloadTypeSelectStrings];
                } else if ([keyPath isEqualToString:PAGEINDEX_KEY]) {
                    [[[self undoManager] prepareWithInvocationTarget:bookmark] setPageIndex:[oldValue unsignedIntegerValue]];
                }
                break;
            case NSKeyValueChangeInsertion:
                if ([newValue count] == 0) break;
                if ([keyPath isEqualToString:CHILDREN_KEY]) {
                    [self startObservingBookmarks:newValue];
                    [[[self undoManager] prepareWithInvocationTarget:self] removeBookmarksAtIndexes:indexes ofBookmark:bookmark animate:YES];
                }
                break;
            case NSKeyValueChangeRemoval:
                if ([oldValue count] == 0) break;
                if ([keyPath isEqualToString:CHILDREN_KEY]) {
                    [self stopObservingBookmarks:oldValue];
                    [[[self undoManager] prepareWithInvocationTarget:self] insertBookmarks:[oldValue copy] atIndexes:indexes ofBookmark:bookmark animate:YES];
                }
                break;
            case NSKeyValueChangeReplacement:
                if ([newValue count] == 0 && [oldValue count] == 0) break;
                if ([keyPath isEqualToString:CHILDREN_KEY]) {
                    [self stopObservingBookmarks:oldValue];
                    [self startObservingBookmarks:newValue];
                    [[[self undoManager] prepareWithInvocationTarget:self] replaceBookmarksAtIndexes:indexes ofBookmark:bookmark withBookmarks:[oldValue copy] animate:YES];
                }
                break;
        }
        bookmarksCache = nil;
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveBookmarksData) object:nil];
        [self performSelector:@selector(saveBookmarksData) withObject:nil afterDelay:SAVE_DELAY];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Notification handlers

- (void)handleApplicationWillTerminateNotification:(NSNotification *)notification  {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveBookmarksData) object:nil];
    [self saveBookmarksData];
}

- (void)endEditing {
    if ([outlineView editedRow] && [[self window] makeFirstResponder:outlineView] == NO)
        [[self window] endEditingFor:nil];
}

#pragma mark NSOutlineView datasource methods

static NSArray *minimumCoverForBookmarks(NSArray *items) {
    SKBookmark *lastBm = nil;
    NSMutableArray *minimalCover = [NSMutableArray array];
    
    for (SKBookmark *bm in items) {
        if ([bm isDescendantOf:lastBm] == NO) {
            [minimalCover addObject:bm];
            lastBm = bm;
        }
    }
    return minimalCover;
}

- (NSInteger)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item {
    if (item == nil) item = bookmarkRoot;
    return [item bookmarkType] == SKBookmarkTypeFolder ? [item countOfChildren] : 0;
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item {
    return [item bookmarkType] == SKBookmarkTypeFolder;
}

- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)anIndex ofItem:(id)item {
    return [(item ?: bookmarkRoot) objectInChildrenAtIndex:anIndex];
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return item;
}

- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)ov pasteboardWriterForItem:(id)item {
    NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
    [pbItem setData:[NSData data] forType:SKPasteboardTypeBookmarkRow];
    return pbItem;
}

- (void)outlineView:(NSOutlineView *)ov draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems {
    draggedBookmarks = minimumCoverForBookmarks(draggedItems);
}

- (void)outlineView:(NSOutlineView *)ov draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    if (operation == NSDragOperationDelete && [draggedBookmarks count])
        [self outlineView:ov deleteItems:draggedBookmarks];
    draggedBookmarks = nil;
}

- (void)outlineView:(NSOutlineView *)ov updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo {
    if ([draggingInfo draggingSource] != ov) {
        NSDictionary *searchOptions = @{NSPasteboardURLReadingFileURLsOnlyKey:@YES};
        NSTableColumn *tableColumn = [ov outlineTableColumn];
        NSTableCellView *view = [ov makeViewWithIdentifier:[tableColumn identifier] owner:self];
        __block NSInteger validCount = 0;
        NSRect frame = NSMakeRect(0.0, 0.0, [tableColumn width], [ov rowHeight]);
        if (@available(macOS 11.0, *))
            frame.size.width -= INDENT;
        else
            frame.size.width -= OLD_INDENT;
        [view setFrame:frame];
        frame.origin = [draggingInfo draggingLocation];
        
        [draggingInfo enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationClearNonenumeratedImages forView:ov classes:@[[NSURL class]] searchOptions:searchOptions usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop){
            SKBookmark *bookmark = [[SKBookmark bookmarksForURLs:@[[draggingItem item]]] firstObject];
            if (bookmark) {
                [draggingItem setImageComponentsProvider:^{
                    [view setObjectValue:bookmark];
                    return [view draggingImageComponents];
                }];
                [draggingItem setDraggingFrame:frame];
                validCount++;
            } else {
                [draggingItem setImageComponentsProvider:nil];
            }
        }];
        [draggingInfo setNumberOfValidItemsForDrop:validCount];
        [draggingInfo setDraggingFormation:NSDraggingFormationList];
    }
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)anIndex {
    NSDragOperation dragOp = NSDragOperationNone;
    if (anIndex != NSOutlineViewDropOnItemIndex) {
        NSPasteboard *pboard = [info draggingPasteboard];
        if ([pboard canReadItemWithDataConformingToTypes:@[SKPasteboardTypeBookmarkRow]] &&
            [info draggingSource] == ov) {
            if (NO == [item isDescendantOfArray:draggedBookmarks])
                dragOp = NSDragOperationMove;
        } else if ([NSURL canReadFileURLFromPasteboard:pboard]) {
            dragOp = NSDragOperationEvery;
        }
    }
    return dragOp;
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)anIndex {
    NSPasteboard *pboard = [info draggingPasteboard];
    
    if ([pboard canReadItemWithDataConformingToTypes:@[SKPasteboardTypeBookmarkRow]] &&
        [info draggingSource] == ov) {
        NSMutableArray *movedBookmarks = [NSMutableArray array];
        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
        
        if (item == nil) item = bookmarkRoot;
        
        [self endEditing];
        [ov beginUpdates];
		for (SKBookmark *bookmark in draggedBookmarks) {
            SKBookmark *parent = [bookmark parent];
            NSInteger bookmarkIndex = [[parent children] indexOfObject:bookmark];
            if (item == parent) {
                if (anIndex > bookmarkIndex)
                    anIndex--;
                if (anIndex == bookmarkIndex) {
                    anIndex++;
                    continue;
                }
            }
            [self moveBookmarkAtIndex:bookmarkIndex ofBookmark:parent toIndex:anIndex++ ofBookmark:item];
            [movedBookmarks addObject:bookmark];
		}
        [ov endUpdates];
        
        for (SKBookmark *bookmark in movedBookmarks) {
            NSInteger row = [outlineView rowForItem:bookmark];
            if (row != -1)
                [indexes addIndex:row];
        }
        if ([indexes count])
            [outlineView selectRowIndexes:indexes byExtendingSelection:NO];
        
        return YES;
    } else {
        NSArray *urls = [NSURL readFileURLsFromPasteboard:pboard];
        NSArray *newBookmarks = [SKBookmark bookmarksForURLs:urls];
        if ([newBookmarks count] > 0) {
            if (item == nil) item = bookmarkRoot;
            [self endEditing];
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(anIndex, [newBookmarks count])];
            [ov beginUpdates];
            [self insertBookmarks:newBookmarks atIndexes:indexes ofBookmark:item animate:YES];
            [ov endUpdates];
            if (item == bookmarkRoot || [outlineView isItemExpanded:item]) {
                if (item != bookmarkRoot)
                    [indexes shiftIndexesStartingAtIndex:0 by:[outlineView rowForItem:item] + 1];
                [outlineView selectRowIndexes:indexes byExtendingSelection:NO];
            }
            return YES;
        }
        return NO;
    }
    return NO;
}

#pragma mark NSOutlineView delegate methods

- (NSView *)outlineView:(NSOutlineView *)ov viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    BOOL isSep = ([item bookmarkType] == SKBookmarkTypeSeparator);
    NSString *identifier = isSep ? @"separator" : [tableColumn identifier];
    NSTableCellView *view = [ov makeViewWithIdentifier:identifier owner:self];
    if (@available(macOS 11.0, *)) {} else {
        BOOL isLast = [[tableColumn identifier] isEqualToString:FILE_COLUMNID];
        if (isLast || isSep)
            [[view constraintWithFirstItem:view firstAttribute:NSLayoutAttributeTrailing] setConstant:isSep == NO ? 4.0 : isLast ? 2.0 : 0.0];
    }
    if ([identifier isEqualToString:FILE_COLUMNID]) {
        if ([item bookmarkType] == SKBookmarkTypeBookmark)
            [[view textField] setTextColor:[NSColor controlTextColor]];
        else
            [[view textField] setTextColor:[NSColor disabledControlTextColor]];
    }
    return view;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [self updateStatus];
    BOOL hasFile = NO;
    for (SKBookmark *bm in [outlineView selectedItems]) {
        if ([bm bookmarkType] != SKBookmarkTypeSeparator) {
            hasFile = YES;
            break;
        }
    }
    [deleteSegmentedControl setEnabled:[outlineView canDelete]];
    [deleteButton setEnabled:[outlineView canDelete]];
    [previewButton setEnabled:hasFile];
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible] && [[QLPreviewPanel sharedPreviewPanel] dataSource] == self)
        [[QLPreviewPanel sharedPreviewPanel] reloadData];
}

- (void)outlineView:(NSOutlineView *)ov deleteItems:(NSArray *)items {
    [self endEditing];
    [ov beginUpdates];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    SKBookmark *parent = nil;
    for (SKBookmark *item in minimumCoverForBookmarks(items)) {
        SKBookmark *itemParent = [item parent];
        NSUInteger itemIndex = [[itemParent children] indexOfObject:item];
        if (itemIndex != NSNotFound) {
            if (itemParent != parent) {
                if (parent && [indexes count])
                    [self removeBookmarksAtIndexes:indexes ofBookmark:parent animate:YES];
                parent = itemParent;
                [indexes removeAllIndexes];
            }
            [indexes addIndex:itemIndex];
        }
    }
    if (parent && [indexes count])
        [self removeBookmarksAtIndexes:indexes ofBookmark:parent animate:YES];
    [ov endUpdates];
}

- (BOOL)outlineView:(NSOutlineView *)ov canDeleteItems:(NSArray *)items {
    return [items count] > 0;
}

static void addBookmarkURLsToArray(NSArray *items, NSMutableArray *array) {
    for (SKBookmark *bm in items) {
        if ([bm bookmarkType] == SKBookmarkTypeBookmark) {
            NSURL *url = [bm fileURL];
            if (url)
                [array addObject:url];
        } else if ([bm bookmarkType] != SKBookmarkTypeSeparator) {
            addBookmarkURLsToArray([bm children], array);
        }
    }
}

- (void)outlineView:(NSOutlineView *)ov copyItems:(NSArray *)items {
    NSMutableArray *urls = [NSMutableArray array];
    addBookmarkURLsToArray(minimumCoverForBookmarks(items), urls);
    if ([urls count] > 0) {
        NSPasteboard *pboard = [NSPasteboard generalPasteboard];
        [pboard clearContents];
        [pboard writeObjects:urls];
    } else {
        NSBeep();
    }
}

- (BOOL)outlineView:(NSOutlineView *)ov canCopyItems:(NSArray *)items {
    return [items count] > 0;
}

- (void)outlineView:(NSOutlineView *)ov pasteFromPasteboard:(NSPasteboard *)pboard {
    NSArray *urls = [NSURL readFileURLsFromPasteboard:pboard];
    if ([urls count] > 0) {
        NSArray *newBookmarks = [SKBookmark bookmarksForURLs:urls];
        if ([newBookmarks count] > 0) {
            NSUInteger anIndex = 0;
            SKBookmark *item = [self insertionFolderAndChildIndex:&anIndex];
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(anIndex, [newBookmarks count])];
            [ov beginUpdates];
            [self insertBookmarks:newBookmarks atIndexes:indexes ofBookmark:item animate:YES];
            [ov endUpdates];
            if (item == bookmarkRoot || [outlineView isItemExpanded:item]) {
                if (item != bookmarkRoot)
                    [indexes shiftIndexesStartingAtIndex:0 by:[outlineView rowForItem:item] + 1];
                [outlineView selectRowIndexes:indexes byExtendingSelection:NO];
            }
        } else NSBeep();
    } else NSBeep();
}

- (BOOL)outlineView:(NSOutlineView *)ov canPasteFromPasteboard:(NSPasteboard *)pboard {
    return [NSURL canReadFileURLFromPasteboard:pboard];
}

- (NSArray *)outlineViewTypeSelectHelperSelectionStrings:(NSOutlineView *)ov {
    NSInteger i, count = [outlineView numberOfRows];
    NSMutableArray *labels = [NSMutableArray arrayWithCapacity:count];
    for (i = 0; i < count; i++) {
        NSString *label = [[outlineView itemAtRow:i] label];
        [labels addObject:label ?: @""];
    }
    return labels;
}

- (void)outlineView:(NSOutlineView *)ov typeSelectHelperDidFailToFindMatchForSearchString:(NSString *)searchString {
    [[statusBar leftField] setStringValue:[NSString stringWithFormat:NSLocalizedString(@"No match: \"%@\"", @"Status message"), searchString]];
}

- (void)outlineView:(NSOutlineView *)ov typeSelectHelperUpdateSearchString:(NSString *)searchString {
    if (searchString)
        [[statusBar leftField] setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Finding: \"%@\"", @"Status message"), searchString]];
    else
        [self updateStatus];
}

#pragma mark Toolbar

- (void)setupToolbar {
    // Create a new toolbar instance, and attach it to our document window
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:SKBookmarksToolbarIdentifier];
    NSToolbarItem *item;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeDefault];
    
    // We are the delegate
    [toolbar setDelegate: self];
    
    // Add template toolbar items
    
    item = [[SKToolbarItem alloc] initWithItemIdentifier:SKBookmarksNewFolderToolbarItemIdentifier];
    [item setLabels:NSLocalizedString(@"New Folder", @"Toolbar item label")];
    [item setToolTip:NSLocalizedString(@"Add a New Folder", @"Tool tip message")];
    [item setView:folderSegmentedControl];
    if (@available(macOS 11.0, *)) {} else
        [folderSegmentedControl setImageScaling:NSImageScaleNone forSegment:0];
    [dict setObject:item forKey:SKBookmarksNewFolderToolbarItemIdentifier];
    
    item = [[SKToolbarItem alloc] initWithItemIdentifier:SKBookmarksNewSeparatorToolbarItemIdentifier];
    [item setLabels:NSLocalizedString(@"New Separator", @"Toolbar item label")];
    [item setToolTip:NSLocalizedString(@"Add a New Separator", @"Tool tip message")];
    [item setImage:[NSImage imageNamed:SKImageNameToolbarNewSeparator]];
    [item setView:separatorSegmentedControl];
    if (@available(macOS 11.0, *)) {} else
        [separatorSegmentedControl setImageScaling:NSImageScaleNone forSegment:0];
    [dict setObject:item forKey:SKBookmarksNewSeparatorToolbarItemIdentifier];
    
    item = [[SKToolbarItem alloc] initWithItemIdentifier:SKBookmarksDeleteToolbarItemIdentifier];
    [item setLabels:NSLocalizedString(@"Delete", @"Toolbar item label")];
    [item setToolTip:NSLocalizedString(@"Delete Selected Items", @"Tool tip message")];
    [item setImage:[NSImage imageNamed:SKImageNameToolbarDelete]];
    [item setView:deleteSegmentedControl];
    [deleteSegmentedControl setEnabled:[outlineView canDelete]];
    if (@available(macOS 11.0, *)) {} else
        [deleteSegmentedControl setImageScaling:NSImageScaleNone forSegment:0];
    [dict setObject:item forKey:SKBookmarksDeleteToolbarItemIdentifier];
    
    toolbarItems = [dict mutableCopy];
    
    // Attach the toolbar to the window
    [[self window] setToolbar:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted {
    NSToolbarItem *item = [toolbarItems objectForKey:itemIdent];
    return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[SKBookmarksNewFolderToolbarItemIdentifier,
        SKBookmarksNewSeparatorToolbarItemIdentifier, 
        SKBookmarksDeleteToolbarItemIdentifier];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[SKBookmarksNewFolderToolbarItemIdentifier,
        SKBookmarksNewSeparatorToolbarItemIdentifier, 
		SKBookmarksDeleteToolbarItemIdentifier, 
        NSToolbarFlexibleSpaceItemIdentifier, 
		NSToolbarSpaceItemIdentifier, 
		NSToolbarSeparatorItemIdentifier, 
		NSToolbarCustomizeToolbarItemIdentifier];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([menuItem action] == @selector(toggleStatusBar:)) {
        if ([statusBar isVisible])
            [menuItem setTitle:NSLocalizedString(@"Hide Status Bar", @"Menu item title")];
        else
            [menuItem setTitle:NSLocalizedString(@"Show Status Bar", @"Menu item title")];
        return YES;
    } else if ([menuItem action] == @selector(addBookmark:)) {
        return [menuItem tag] == 0;
    } else if ([menuItem action] == @selector(copyURL:)) {
        return [outlineView selectedRow] >= 0;
    }
    return YES;
}

#pragma mark Touch bar

- (NSTouchBar *)makeTouchBar {
    NSTouchBar *touchBar = [[NSTouchBar alloc] init];
    [touchBar setCustomizationIdentifier:SKBookmarksTouchBarIdentifier];
    [touchBar setDelegate:self];
    [touchBar setCustomizationAllowedItemIdentifiers:@[SKTouchBarItemIdentifierNewFolder, SKTouchBarItemIdentifierNewSeparator, SKTouchBarItemIdentifierDelete, SKTouchBarItemIdentifierPreview, NSTouchBarItemIdentifierFlexibleSpace]];
    [touchBar setDefaultItemIdentifiers:@[SKTouchBarItemIdentifierNewFolder, SKTouchBarItemIdentifierNewSeparator, NSTouchBarItemIdentifierFixedSpaceLarge, SKTouchBarItemIdentifierDelete, SKTouchBarItemIdentifierPreview]];
    return touchBar;
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)aTouchBar makeItemForIdentifier:(NSString *)identifier {
    NSCustomTouchBarItem *item = nil;
    if ([identifier isEqualToString:SKTouchBarItemIdentifierNewFolder]) {
        if (newFolderButton == nil) {
            newFolderButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameTouchBarNewFolderTemplate] target:self action:@selector(insertBookmarkFolder:)];
        }
        item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
        [item setView:newFolderButton];
        [item setCustomizationLabel:NSLocalizedString(@"New Folder", @"Toolbar item label")];
    } else if ([identifier isEqualToString:SKTouchBarItemIdentifierNewSeparator]) {
        if (newSeparatorButton == nil) {
            newSeparatorButton = [NSButton buttonWithImage:[NSImage imageNamed:SKImageNameTouchBarNewSeparator] target:self action:@selector(insertBookmarkSeparator:)];
        }
        item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
        [item setView:newSeparatorButton];
        [item setCustomizationLabel:NSLocalizedString(@"New Separator", @"Toolbar item label")];
    } else if ([identifier isEqualToString:SKTouchBarItemIdentifierDelete]) {
        if (deleteButton == nil) {
            deleteButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameTouchBarDeleteTemplate] target:self action:@selector(deleteBookmark:)];
            [deleteButton setEnabled:[outlineView canDelete]];
        }
        item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
        [item setView:deleteButton];
        [item setCustomizationLabel:NSLocalizedString(@"Delete", @"Toolbar item label")];
    } else if ([identifier isEqualToString:SKTouchBarItemIdentifierPreview]) {
        if (previewButton == nil) {
            previewButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameTouchBarQuickLookTemplate] target:self action:@selector(previewBookmarks:)];
            [previewButton setEnabled:[outlineView selectedRow] != -1];
        }
        item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
        [item setView:previewButton];
        [item setCustomizationLabel:NSLocalizedString(@"Quick Look", @"Toolbar item label")];
    }
    return item;
}

#pragma mark Quick Look Panel Support

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
    [panel setDelegate:self];
    [panel setDataSource:self];
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
}

- (NSArray *)previewItems {
    NSMutableArray *items = [NSMutableArray array];
    
    [[outlineView selectedRowIndexes] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        SKBookmark *item = [outlineView itemAtRow:idx];
        if ([item bookmarkType] == SKBookmarkTypeBookmark)
            [items addObject:item];
        else if ([item bookmarkType] == SKBookmarkTypeSession)
            [items addObjectsFromArray:[item children]];
    }];
    return items;
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
    return [[self previewItems] count];
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)anIndex {
    return [[self previewItems] objectAtIndex:anIndex];
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item {
    if ([[(SKBookmark *)item parent] bookmarkType] == SKBookmarkTypeSession)
        item = [(SKBookmark *)item parent];
    NSInteger row = [outlineView rowForItem:item];
    NSRect iconRect = NSZeroRect;
    if (item != nil && row != -1) {
        NSImageView *imageView = [[outlineView viewAtColumn:0 row:row makeIfNecessary:NO] imageView];
        if (imageView && NSIsEmptyRect([imageView visibleRect]) == NO)
            iconRect = [imageView convertRectToScreen:[imageView bounds]];
    }
    return iconRect;
}

- (NSImage *)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect {
    if ([[(SKBookmark *)item parent] bookmarkType] == SKBookmarkTypeSession)
        item = [(SKBookmark *)item parent];
    return [(SKBookmark *)item icon];
}

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event {
    if ([event type] == NSEventTypeKeyDown) {
        [outlineView keyDown:event];
        return YES;
    }
    return NO;
}

#pragma mark Services

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types {
    if ([types containsObject:(__bridge NSString *)kUTTypeFileURL] && ([outlineView selectedRow] != -1 || [outlineView clickedRow] != -1)) {
        NSInteger rowIndex = [outlineView clickedRow];
        NSIndexSet *indexes = [outlineView selectedRowIndexes];
        if (rowIndex != -1 && [indexes containsIndex:rowIndex] == NO)
            indexes = [NSIndexSet indexSetWithIndex:rowIndex];
        NSArray *allBookmarks = minimumCoverForBookmarks([outlineView itemsAtRowIndexes:indexes]);
        allBookmarks = [allBookmarks valueForKeyPath:@"@distinctUnionOfArrays.containingBookmarks.fileURL"];
        if ([allBookmarks containsObject:[NSNull null]]) {
            NSMutableArray *bms = [allBookmarks mutableCopy];
            [bms removeObject:[NSNull null]];
            allBookmarks = bms;
        }
        if ([allBookmarks count] > 0) {
            [pboard clearContents];
            [pboard writeObjects:allBookmarks];
            return YES;
        }
    }
    return NO;
}

- (id)validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType {
    if ([sendType isEqualToString:(__bridge NSString *)kUTTypeFileURL] && returnType == nil)
        return [outlineView selectedRow] != -1 || [outlineView clickedRow] != -1 ? self : nil;
    return [super validRequestorForSendType:sendType returnType:returnType];
}

@end
