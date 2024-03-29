//
//  SKRightSideViewController.m
//  Skim
//
//  Created by Christiaan Hofman on 3/28/10.
/*
 This software is Copyright (c) 2010
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

#import "SKRightSideViewController.h"
#import "SKMainWindowController.h"
#import "SKMainWindowController_Actions.h"
#import "SKMainWindowController_UI.h"
#import "NSMenu_SKExtensions.h"
#import "NSSegmentedControl_SKExtensions.h"
#import "SKTypeSelectHelper.h"
#import "SKNoteOutlineView.h"
#import "SKTableView.h"
#import "NSColor_SKExtensions.h"
#import <SkimNotes/SkimNotes.h>
#import "PDFAnnotation_SKExtensions.h"
#import "SKSnapshotWindowController.h"
#import "NSURL_SKExtensions.h"
#import "PDFPage_SKExtensions.h"

@implementation SKRightSideViewController

@synthesize noteArrayController, noteOutlineView, snapshotArrayController, snapshotTableView;

- (void)dealloc {
    [snapshotTableView setDelegate:nil];
    [snapshotTableView setDataSource:nil];
    [noteOutlineView setDelegate:nil];
    [noteOutlineView setDataSource:nil];
}

- (NSString *)nibName {
    return @"RightSideView";
}

- (void)handleSnapshotViewFrameChanged:(NSNotification *)notification {
    NSView *view = [notification object];
    [[[view subviews] firstObject] setFrame:[view bounds]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [button setHelp:NSLocalizedString(@"View Notes", @"Tool tip message") forSegment:SKSidePaneStateNote];
    [button setHelp:NSLocalizedString(@"View Snapshots", @"Tool tip message") forSegment:SKSidePaneStateSnapshot];
    
    NSMenu *menu = [NSMenu menu];
    [menu addItemWithTitle:NSLocalizedString(@"Ignore Case", @"Menu item title") action:@selector(toggleCaseInsensitiveFilter:) target:mainController];
    [[searchField cell] setSearchMenuTemplate:menu];
    [[searchField cell] setPlaceholderString:NSLocalizedString(@"Filter", @"placeholder")];
    
    [searchField setAction:@selector(searchNotes:)];
    [searchField setTarget:mainController];
    
    [noteOutlineView setAutoresizesOutlineColumn: NO];
    
    [noteOutlineView setStronglyReferencesItems:YES];
    
    [noteOutlineView setDelegate:mainController];
    [noteOutlineView setDataSource:mainController];
    [snapshotTableView setDelegate:mainController];
    [snapshotTableView setDataSource:mainController];
    [[noteOutlineView menu] setDelegate:mainController];
    [[snapshotTableView menu] setDelegate:mainController];
    
    [noteOutlineView setDoubleAction:@selector(selectSelectedNote:)];
    [noteOutlineView setTarget:mainController];
    [snapshotTableView setDoubleAction:@selector(toggleSelectedSnapshots:)];
    [snapshotTableView setTarget:mainController];
    
    [noteOutlineView setTypeSelectHelper:[SKTypeSelectHelper typeSelectHelperWithMatchOption:SKSubstringMatch]];
    
    NSSortDescriptor *pageIndexSortDescriptor = [[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationPageIndexKey ascending:YES];
    NSSortDescriptor *boundsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:SKPDFAnnotationBoundsOrderKey ascending:YES selector:@selector(compare:)];
    [noteArrayController setSortDescriptors:@[pageIndexSortDescriptor, boundsSortDescriptor]];
    [snapshotArrayController setSortDescriptors:@[pageIndexSortDescriptor]];
    
    [noteOutlineView setIndentationPerLevel:1.0];
    
    [noteOutlineView registerForDraggedTypes:[NSColor readableTypesForPasteboard:[NSPasteboard pasteboardWithName:NSPasteboardNameDrag]]];
    [noteOutlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];

    [snapshotTableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

- (void)setMainController:(SKMainWindowController *)newMainController {
    if (mainController && newMainController == nil) {
        [snapshotTableView setDelegate:nil];
        [snapshotTableView setDataSource:nil];
        [noteOutlineView setDelegate:nil];
        [noteOutlineView setDataSource:nil];
    }
    [super setMainController:newMainController];
}

- (NSArray *)tableViews {
    return [NSArray arrayWithObjects:noteOutlineView, snapshotTableView, nil];
}

@end
