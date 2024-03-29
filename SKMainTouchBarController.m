//
//  SKMainTouchBarController.m
//  Skim
//
//  Created by Christiaan Hofman on 06/05/2019.
/*
 This software is Copyright (c) 2019
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

#import "SKMainTouchBarController.h"
#import "SKMainWindowController.h"
#import "SKMainWindowController_Actions.h"
#import "SKPDFView.h"
#import "PDFView_SKExtensions.h"
#import "PDFSelection_SKExtensions.h"
#import "NSImage_SKExtensions.h"
#import "NSEvent_SKExtensions.h"
#import <SkimNotes/SkimNotes.h>
#import "PDFAnnotation_SKExtensions.h"
#import "NSUserDefaults_SKExtensions.h"
#import "SKColorList.h"

#define SKDocumentTouchBarIdentifier @"net.sourceforge.skim-app.touchbar.document"

#define SKTouchBarItemIdentifierNavigation     @"net.sourceforge.skim-app.touchbar-item.navigation"
#define SKTouchBarItemIdentifierNavigationFull @"net.sourceforge.skim-app.touchbar-item.navigationFull"
#define SKTouchBarItemIdentifierZoom           @"net.sourceforge.skim-app.touchbar-item.zoom"
#define SKTouchBarItemIdentifierToolMode       @"net.sourceforge.skim-app.touchbar-item.toolMode"
#define SKTouchBarItemIdentifierAnnotationMode @"net.sourceforge.skim-app.touchbar-item.annotationMode"
#define SKTouchBarItemIdentifierAddNote        @"net.sourceforge.skim-app.touchbar-item.addNote"
#define SKTouchBarItemIdentifierAddNoteTypes   @"net.sourceforge.skim-app.touchbar-item.addNote-types"
#define SKTouchBarItemIdentifierFullScreen     @"net.sourceforge.skim-app.touchbar-item.fullScreen"
#define SKTouchBarItemIdentifierPresentation   @"net.sourceforge.skim-app.touchbar-item.presentation"
#define SKTouchBarItemIdentifierFavoriteColors @"net.sourceforge.skim-app.touchbar-item.favoriteColors"
#define SKTouchBarItemIdentifierColors         @"net.sourceforge.skim-app.touchbar-item.clors"

static NSString *noteToolImageNames[] = {@"TouchBarTextNotePopover", @"TouchBarAnchoredNotePopover", @"TouchBarCircleNotePopover", @"TouchBarSquareNotePopover", @"TouchBarHighlightNotePopover", @"TouchBarUnderlineNotePopover", @"TouchBarStrikeOutNotePopover", @"TouchBarLineNotePopover", @"TouchBarInkNotePopover"};

@interface SKMainTouchBarController (SKPrivate)

- (void)chooseColor:(id)sender;
- (void)goToPreviousNextPage:(id)sender;
- (void)goToPreviousNextFirstLastPage:(id)sender;
- (void)zoomInActualOut:(id)sender;
- (void)changeToolMode:(id)sender;
- (void)changeAnnotationMode:(id)sender;
- (void)createNewNote:(id)sender;
- (void)toggleFullscreen:(id)sender;
- (void)togglePresentation:(id)sender;

- (void)registerForNotifications;
- (void)unregisterForNotifications;
- (void)handlePageChangedNotification:(NSNotification *)notification;
- (void)handleToolModeChangedNotification:(NSNotification *)notification;
- (void)handleAnnotationModeChangedNotification:(NSNotification *)notification;

@end

@implementation SKMainTouchBarController

@synthesize mainController;

- (void)setMainController:(SKMainWindowController *)newMainController {
    if (newMainController != mainController) {
        if (mainController) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            if (newMainController == nil)
                [colorPicker setDelegate:nil];
        }
        mainController = newMainController;
        if (mainController)
            [self registerForNotifications];
    }
}

- (NSTouchBar *)makeTouchBar {
    NSTouchBar *touchBar = [[NSTouchBar alloc] init];
    [touchBar setCustomizationIdentifier:SKDocumentTouchBarIdentifier];
    [touchBar setDelegate:self];
    [touchBar setCustomizationAllowedItemIdentifiers:@[SKTouchBarItemIdentifierNavigation, SKTouchBarItemIdentifierNavigationFull, SKTouchBarItemIdentifierZoom, SKTouchBarItemIdentifierToolMode, SKTouchBarItemIdentifierAddNote, SKTouchBarItemIdentifierFullScreen, SKTouchBarItemIdentifierPresentation, SKTouchBarItemIdentifierFavoriteColors, SKTouchBarItemIdentifierColors, NSTouchBarItemIdentifierFlexibleSpace]];
    [touchBar setDefaultItemIdentifiers:@[SKTouchBarItemIdentifierNavigation, SKTouchBarItemIdentifierToolMode, SKTouchBarItemIdentifierAddNote, SKTouchBarItemIdentifierFavoriteColors]];
    return touchBar;
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)aTouchBar makeItemForIdentifier:(NSString *)identifier {
    NSTouchBarItem *item = [touchBarItems objectForKey:identifier];
    if (item == nil) {
        if (touchBarItems == nil)
            touchBarItems = [[NSMutableDictionary alloc] init];
        
        if ([identifier isEqualToString:SKTouchBarItemIdentifierNavigation]) {
            
            if (previousNextPageButton == nil) {
                NSArray *images = @[[NSImage imageNamed:SKImageNameTouchBarPageUp], [NSImage imageNamed:SKImageNameTouchBarPageDown]];
                previousNextPageButton = [NSSegmentedControl segmentedControlWithImages:images trackingMode:NSSegmentSwitchTrackingMomentary target:self action:@selector(goToPreviousNextPage:)];
                [self handlePageChangedNotification:nil];
                [previousNextPageButton setSegmentStyle:NSSegmentStyleSeparated];
            }
            item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSCustomTouchBarItem *)item setView:previousNextPageButton];
            [(NSCustomTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Previous/Next", @"Toolbar item label")];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierNavigationFull]) {
            
            if (previousNextFirstLastPageButton == nil) {
                NSArray *images = @[[NSImage imageNamed:SKImageNameTouchBarFirstPage], [NSImage imageNamed:SKImageNameTouchBarPageUp], [NSImage imageNamed:SKImageNameTouchBarPageDown], [NSImage imageNamed:SKImageNameTouchBarLastPage]];
                previousNextFirstLastPageButton = [NSSegmentedControl segmentedControlWithImages:images trackingMode:NSSegmentSwitchTrackingMomentary target:self action:@selector(goToPreviousNextPage:)];
                [self handlePageChangedNotification:nil];
                [previousNextFirstLastPageButton setSegmentStyle:NSSegmentStyleSeparated];
            }
            item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSCustomTouchBarItem *)item setView:previousNextFirstLastPageButton];
            [(NSCustomTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Previous/Next", @"Toolbar item label")];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierZoom]) {
            
            if (zoomInActualOutButton == nil) {
                NSArray *images = @[[NSImage imageNamed:SKImageNameTouchBarZoomOut], [NSImage imageNamed:SKImageNameTouchBarZoomActual], [NSImage imageNamed:SKImageNameTouchBarZoomIn]];
                zoomInActualOutButton = [NSSegmentedControl segmentedControlWithImages:images trackingMode:NSSegmentSwitchTrackingMomentary target:self action:@selector(zoomInActualOut:)];
                [zoomInActualOutButton setSegmentStyle:NSSegmentStyleSeparated];
                [self handleScaleChangedNotification:nil];
                [self overviewChanged];
            }
            item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSCustomTouchBarItem *)item setView:zoomInActualOutButton];
            [(NSCustomTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Zoom", @"Toolbar item label")];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierToolMode]) {
            
            NSTouchBar *popoverTouchBar = [[NSTouchBar alloc] init];
            [popoverTouchBar setDelegate:self];
            [popoverTouchBar setDefaultItemIdentifiers:@[SKTouchBarItemIdentifierAnnotationMode]];
            if (toolModeButton == nil) {
                NSArray *images = @[[NSImage imageNamed:SKImageNameTouchBarTextTool],
                                   [NSImage imageNamed:SKImageNameTouchBarMoveTool],
                                   [NSImage imageNamed:SKImageNameTouchBarMagnifyTool],
                                   [NSImage imageNamed:SKImageNameTouchBarSelectTool],
                                   [NSImage imageNamed:SKImageNameTouchBarTextNotePopover]];
                toolModeButton = [NSSegmentedControl segmentedControlWithImages:images trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(changeToolMode:)];
                [self handleToolModeChangedNotification:nil];
                [self handleAnnotationModeChangedNotification:nil];
                [self interactionModeChanged];
            }
            item = [[NSPopoverTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSPopoverTouchBarItem *)item setCollapsedRepresentation:toolModeButton];
            [(NSPopoverTouchBarItem *)item setPopoverTouchBar:popoverTouchBar];
            [(NSPopoverTouchBarItem *)item setPressAndHoldTouchBar:popoverTouchBar];
            [(NSPopoverTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Tool Mode", @"Toolbar item label")];
            [toolModeButton addGestureRecognizer:[(NSPopoverTouchBarItem *)item makeStandardActivatePopoverGestureRecognizer]];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierAnnotationMode]) {
            
            if (annotationModeButton == nil) {
                NSArray *images = @[[NSImage imageNamed:SKImageNameTextNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAnchoredNote],
                                   [NSImage imageNamed:SKImageNameTouchBarCircleNote],
                                   [NSImage imageNamed:SKImageNameTouchBarSquareNote],
                                   [NSImage imageNamed:SKImageNameTouchBarHighlightNote],
                                   [NSImage imageNamed:SKImageNameTouchBarUnderlineNote],
                                   [NSImage imageNamed:SKImageNameTouchBarStrikeOutNote],
                                   [NSImage imageNamed:SKImageNameTouchBarLineNote],
                                   [NSImage imageNamed:SKImageNameTouchBarInkNote]];
                annotationModeButton = [NSSegmentedControl segmentedControlWithImages:images trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(changeAnnotationMode:)];
                [self handleAnnotationModeChangedNotification:nil];
                [self interactionModeChanged];
            }
            item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSCustomTouchBarItem *)item setView:annotationModeButton];
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierAddNote]) {
            NSTouchBar *popoverTouchBar = [[NSTouchBar alloc] init];
            [popoverTouchBar setDelegate:self];
            [popoverTouchBar setDefaultItemIdentifiers:@[SKTouchBarItemIdentifierAddNoteTypes]];
            item = [[NSPopoverTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSPopoverTouchBarItem *)item setCollapsedRepresentationImage:[NSImage imageNamed:NSImageNameTouchBarAddTemplate]];
            [(NSPopoverTouchBarItem *)item setPopoverTouchBar:popoverTouchBar];
            [(NSPopoverTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Add Note", @"Toolbar item label")];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierAddNoteTypes]) {
            
            if (noteButton == nil) {
                NSArray *images = @[[NSImage imageNamed:SKImageNameTouchBarAddTextNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAddAnchoredNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAddCircleNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAddSquareNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAddHighlightNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAddUnderlineNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAddStrikeOutNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAddLineNote],
                                   [NSImage imageNamed:SKImageNameTouchBarAddInkNote]];
                noteButton = [NSSegmentedControl segmentedControlWithImages:images trackingMode:NSSegmentSwitchTrackingMomentary target:self action:@selector(createNewNote:)];
                [self handleToolModeChangedNotification:nil];
                [self interactionModeChanged];
            }
            item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSCustomTouchBarItem *)item setView:noteButton];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierFullScreen]) {
            
            if (fullScreenButton == nil) {
                fullScreenButton = [NSSegmentedControl segmentedControlWithImages:@[[NSImage imageNamed:NSImageNameTouchBarEnterFullScreenTemplate]] trackingMode:NSSegmentSwitchTrackingMomentary target:self action:@selector(toggleFullscreen:)];
                [self interactionModeChanged];
            }
            item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSCustomTouchBarItem *)item setView:fullScreenButton];
            [(NSCustomTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Full Screen", @"Toolbar item label")];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierPresentation]) {
            
            if (presentationButton == nil) {
                presentationButton = [NSSegmentedControl segmentedControlWithImages:@[[NSImage imageNamed:NSImageNameTouchBarSlideshowTemplate]] trackingMode:NSSegmentSwitchTrackingMomentary target:self action:@selector(togglePresentation:)];
            }
            item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSCustomTouchBarItem *)item setView:presentationButton];
            [(NSCustomTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Presentation", @"Toolbar item label")];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierFavoriteColors]) {
            
            if (colorPicker == nil) {
                colorPicker = [[SKColorPicker alloc] init];
                [colorPicker setDelegate:self];
            }
            item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSCustomTouchBarItem *)item setViewController:colorPicker];
            [(NSCustomTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Favorite Colors", @"Toolbar item label")];
            
        } else if ([identifier isEqualToString:SKTouchBarItemIdentifierColors]) {
            
            item = [[NSColorPickerTouchBarItem alloc] initWithIdentifier:identifier];
            [(NSColorPickerTouchBarItem *)item setColorList:[SKColorList favoriteColorList]];
            [(NSColorPickerTouchBarItem *)item setAction:@selector(chooseColor:)];
            [(NSColorPickerTouchBarItem *)item setTarget:self];
            [(NSColorPickerTouchBarItem *)item setCustomizationLabel:NSLocalizedString(@"Colors", @"Toolbar item label")];
            
        }
        if (item) {
            [touchBarItems setObject:item forKey:identifier];
        }
    }
    return item;
    
}

#pragma mark SKColorPickerDelegate

- (void)colorPickerDidSelectColor:(NSColor *)color {
    PDFAnnotation *annotation = [mainController.pdfView currentAnnotation];
    BOOL isShift = ([NSEvent standardModifierFlags] & NSEventModifierFlagShift) != 0;
    BOOL isAlt = ([NSEvent standardModifierFlags] & NSEventModifierFlagOption) != 0;
    if ([annotation isSkimNote]) {
        [annotation setColor:color alternate:isAlt updateDefaults:isShift];
    } else {
       NSString *defaultKey = [mainController.pdfView currentColorDefaultKeyForAlternate:isAlt];
       if (defaultKey)
           [[NSUserDefaults standardUserDefaults] setColor:color forKey:defaultKey];
   }
}

#pragma mark Actions

- (void)chooseColor:(id)sender {
    [self colorPickerDidSelectColor:[sender color]];
}

- (void)goToPreviousNextPage:(id)sender {
    NSInteger tag = [sender selectedSegment];
    if (tag == 0)
        [mainController.pdfView goToPreviousPage:sender];
    else if (tag == 1)
        [mainController.pdfView goToNextPage:sender];
}

- (void)goToPreviousNextFirstLastPage:(id)sender {
    NSInteger tag = [sender selectedSegment];
    if (tag == 0)
        [mainController.pdfView goToFirstPage:sender];
    else if (tag == 1)
        [mainController.pdfView goToNextPage:sender];
    else if (tag == 2)
        [mainController.pdfView goToPreviousPage:sender];
    else if (tag == 3)
        [mainController.pdfView goToLastPage:sender];
}

- (void)zoomInActualOut:(id)sender {
    NSInteger tag = [sender selectedSegment];
    if ([mainController interactionMode] == SKPresentationMode) {
        if (tag == 0) {
            if ([mainController.pdfView autoScales])
                [mainController.pdfView setScaleFactor:1.0];
        } else if (tag == 1) {
            [mainController.pdfView setScaleFactor:1.0];
        } else if (tag == 2) {
            [mainController.pdfView setAutoScales:YES];
        }
    } else {
        if (tag == 0) {
            [mainController.pdfView zoomOut:sender];
        } else if (tag == 1) {
            ([NSEvent standardModifierFlags] & NSEventModifierFlagOption) ? [mainController.pdfView setPhysicalScaleFactor:1.0] : [mainController.pdfView setScaleFactor:1.0];
        } else if (tag == 2) {
            [mainController.pdfView zoomIn:sender];
        }
    }
}

- (void)changeToolMode:(id)sender {
    NSInteger newToolMode = [sender selectedSegment];
    [mainController.pdfView setToolMode:newToolMode];
}

- (void)changeAnnotationMode:(id)sender {
    NSInteger newAnnotationMode = [sender selectedSegment];
    [mainController.pdfView setToolMode:SKNoteToolMode];
    [mainController.pdfView setAnnotationMode:newAnnotationMode];
}

- (void)createNewNote:(id)sender {
    if ([mainController.pdfView canSelectNote]) {
        NSInteger type = [sender selectedSegment];
        [mainController.pdfView addAnnotationWithType:type];
    } else NSBeep();
}

- (void)toggleFullscreen:(id)sender {
    [mainController toggleFullscreen:sender];
}

- (void)togglePresentation:(id)sender {
    [mainController togglePresentation:sender];
}

#pragma mark Notifications

- (void)handlePageChangedNotification:(NSNotification *)notification {
    [previousNextPageButton setEnabled:[mainController.pdfView canGoToPreviousPage] forSegment:0];
    [previousNextPageButton setEnabled:[mainController.pdfView canGoToNextPage] forSegment:1];
    [previousNextFirstLastPageButton setEnabled:[mainController.pdfView canGoToFirstPage] forSegment:0];
    [previousNextFirstLastPageButton setEnabled:[mainController.pdfView canGoToPreviousPage] forSegment:1];
    [previousNextFirstLastPageButton setEnabled:[mainController.pdfView canGoToPreviousPage] forSegment:2];
    [previousNextFirstLastPageButton setEnabled:[mainController.pdfView canGoToLastPage] forSegment:3];
}

- (void)handleScaleChangedNotification:(NSNotification *)notification {
    [zoomInActualOutButton setEnabled:[mainController.pdfView canZoomOut] forSegment:0];
    [zoomInActualOutButton setEnabled:YES forSegment:1];
    [zoomInActualOutButton setEnabled:[mainController.pdfView canZoomIn] forSegment:2];
}

- (void)handleToolModeChangedNotification:(NSNotification *)notification {
    [toolModeButton selectSegmentWithTag:[mainController.pdfView toolMode]];
    [noteButton setEnabled:[mainController.pdfView canSelectNote]];
    if ([mainController.pdfView toolMode] == SKNoteToolMode) {
        [annotationModeButton selectSegmentWithTag:[mainController.pdfView annotationMode]];
    } else {
        NSInteger i = [annotationModeButton selectedSegment];
        if (i != -1)
            [annotationModeButton setSelected:NO forSegment:i];
    }
}

- (void)handleTemporaryToolModeChangedNotification:(NSNotification *)notification {
    SKToolMode toolMode = [mainController.pdfView toolMode];
    NSString *name = nil;
    switch ([mainController.pdfView temporaryToolMode]) {
        case SKZoomToolMode :      name = SKImageNameTouchBarZoomToSelection;  break;
        case SKSnapshotToolMode :  name = SKImageNameTouchBarSnapshotTool;     break;
        case SKHighlightToolMode : name = SKImageNameTouchBarAddHighlightNote; break;
        case SKUnderlineToolMode : name = SKImageNameTouchBarAddUnderlineNote; break;
        case SKStrikeOutToolMode : name = SKImageNameTouchBarAddStrikeOutNote; break;
        case SKInkToolMode :       name = SKImageNameTouchBarAddInkNote;       break;
        case SKNoToolMode:
            switch (toolMode) {
                case SKTextToolMode :    name = SKImageNameTouchBarTextTool;    break;
                case SKMoveToolMode :    name = SKImageNameTouchBarMoveTool;    break;
                case SKMagnifyToolMode : name = SKImageNameTouchBarMagnifyTool; break;
                case SKSelectToolMode :  name = SKImageNameTouchBarSelectTool;  break;
                case SKNoteToolMode :    name = noteToolImageNames[mainController.pdfView.annotationMode]; break;
            }
            break;
    }
    [toolModeButton setImage:[NSImage imageNamed:name] forSegment:toolMode];
}

- (void)handleAnnotationModeChangedNotification:(NSNotification *)notification {
    [toolModeButton setImage:[NSImage imageNamed:noteToolImageNames[[mainController.pdfView annotationMode]]] forSegment:SKNoteToolMode];
    if ([mainController.pdfView toolMode] == SKNoteToolMode)
        [annotationModeButton selectSegmentWithTag:[mainController.pdfView annotationMode]];
}

- (void)interactionModeChanged {
    SKInteractionMode mode = [mainController interactionMode];
    
    NSString *imageName = mode == SKFullScreenMode ? @"NSTouchBarExitFullScreenTemplate" : @"NSTouchBarEnterFullScreenTemplate";
    [fullScreenButton setImage:[NSImage imageNamed:imageName] forSegment:0];
    
    BOOL enabled = mode != SKPresentationMode && [mainController hasOverview] == NO;
    [toolModeButton setEnabled:enabled];
    [annotationModeButton setEnabled:enabled];
    [noteButton setEnabled:enabled];
}

- (void)overviewChanged {
    BOOL showPDF = [mainController hasOverview] == NO;
    
    BOOL enabled = [mainController interactionMode] != SKPresentationMode && showPDF;
    [toolModeButton setEnabled:enabled];
    [annotationModeButton setEnabled:enabled];
    [noteButton setEnabled:enabled];
    
    [zoomInActualOutButton setEnabled:showPDF];
}

- (void)registerForNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(handlePageChangedNotification:)
               name:PDFViewPageChangedNotification object:mainController.pdfView];
    [nc addObserver:self selector:@selector(handleScaleChangedNotification:)
               name:PDFViewScaleChangedNotification object:mainController.pdfView];
    [nc addObserver:self selector:@selector(handleToolModeChangedNotification:)
               name:SKPDFViewToolModeChangedNotification object:mainController.pdfView];
    [nc addObserver:self selector:@selector(handleTemporaryToolModeChangedNotification:)
                             name:SKPDFViewTemporaryToolModeChangedNotification object:mainController.pdfView];
    [nc addObserver:self selector:@selector(handleAnnotationModeChangedNotification:)
               name:SKPDFViewAnnotationModeChangedNotification object:mainController.pdfView];
}

@end
