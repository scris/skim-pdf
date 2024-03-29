//
//  SKBookmarkController.h
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

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "SKOutlineView.h"

NS_ASSUME_NONNULL_BEGIN

@class SKBookmark, SKRecentDocumentInfo, SKStatusBar;

@interface SKBookmarkController : NSWindowController <NSWindowDelegate, NSToolbarDelegate, NSMenuDelegate, SKOutlineViewDelegate, NSOutlineViewDataSource, QLPreviewPanelDataSource, QLPreviewPanelDelegate, NSTouchBarDelegate> {
    SKOutlineView *outlineView;
    SKStatusBar *statusBar;
    NSSegmentedControl *folderSegmentedControl;
    NSSegmentedControl *separatorSegmentedControl;
    NSSegmentedControl *deleteSegmentedControl;
    NSButton *newFolderButton;
    NSButton *newSeparatorButton;
    NSButton *deleteButton;
    NSButton *previewButton;
    SKBookmark *bookmarkRoot;
    SKBookmark *previousSession;
    NSMutableArray<SKRecentDocumentInfo *> *recentDocuments;
    NSUndoManager *undoManager;
    NSArray<SKBookmark *> *draggedBookmarks;
    NSDictionary<NSString *, NSToolbarItem *> *toolbarItems;
    NSArray<NSDictionary<NSString *, id> *> *bookmarksCache;
    BOOL needsBeginUpdates;
}

@property (class, nonatomic, readonly) SKBookmarkController *sharedBookmarkController;

@property (nonatomic, nullable, strong) IBOutlet SKOutlineView *outlineView;
@property (nonatomic, nullable, strong) IBOutlet SKStatusBar *statusBar;
@property (nonatomic, nullable, strong) IBOutlet NSSegmentedControl *folderSegmentedControl;
@property (nonatomic, nullable, strong) IBOutlet NSSegmentedControl *separatorSegmentedControl;
@property (nonatomic, nullable, strong) IBOutlet NSSegmentedControl *deleteSegmentedControl;
@property (nonatomic, readonly) SKBookmark *bookmarkRoot;
@property (nonatomic, nullable, readonly) SKBookmark *previousSession;

- (IBAction)openBookmark:(nullable id)sender;

- (IBAction)doubleClickBookmark:(nullable id)sender;
- (IBAction)insertBookmarkFolder:(nullable id)sender;
- (IBAction)insertBookmarkSeparator:(nullable id)sender;
- (IBAction)addBookmark:(nullable id)sender;
- (IBAction)deleteBookmark:(nullable id)sender;
- (IBAction)toggleStatusBar:(nullable id)sender;

- (IBAction)copyURL:(nullable id)sender;

- (nullable SKBookmark *)bookmarkForURL:(NSURL *)bookmarkURL;

- (void)insertBookmark:(SKBookmark *)bookmark atIndex:(NSUInteger)anIndex ofBookmark:(SKBookmark *)parent animate:(BOOL)animate;
- (void)removeBookmarkAtIndex:(NSUInteger)anIndex ofBookmark:(SKBookmark *)parent animate:(BOOL)animate;
- (void)replaceBookmarkAtIndex:(NSUInteger)anIndex ofBookmark:(SKBookmark *)parent withBookmark:(SKBookmark *)bookmark animate:(BOOL)animate;

- (void)addRecentDocumentForURL:(NSURL *)fileURL pageIndex:(NSUInteger)pageIndex snapshots:(nullable NSArray<NSDictionary<NSString *, id> *> *)setups;
- (NSUInteger)pageIndexForRecentDocumentAtURL:(NSURL *)fileURL;
- (NSArray<NSDictionary<NSString *, id> *> *)snapshotsForRecentDocumentAtURL:(NSURL *)fileURL;

- (BOOL)isBookmarkExpanded:(SKBookmark *)bookmark;
- (void)setExpanded:(BOOL)flag forBookmark:(SKBookmark *)bookmark;

@end

NS_ASSUME_NONNULL_END
