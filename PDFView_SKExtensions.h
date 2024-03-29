//
//  PDFView_SKExtensions.h
//  Skim
//
//  Created by Christiaan Hofman on 7/3/11.
/*
 This software is Copyright (c) 2011
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

extern const NSPoint SKUnspecifiedPoint;

@interface PDFView (SKExtensions) <NSDraggingSource>

@property (nonatomic) CGFloat physicalScaleFactor;
@property (nonatomic, readonly) NSScrollView *scrollView;
@property (nonatomic, readonly) NSArray<PDFPage *> *displayedPages;
@property (nonatomic, readonly) NSRect visibleContentRect;

- (BOOL)isPageAtIndexDisplayed:(NSUInteger)pageIndex;

- (void)setNeedsDisplayInRect:(NSRect)rect ofPage:(PDFPage *)page;
- (void)setNeedsDisplayForAnnotation:(PDFAnnotation *)annotation onPage:(PDFPage *)page;
- (void)setNeedsDisplayForAnnotation:(PDFAnnotation *)annotation;
- (void)setNeedsDisplayForAddedAnnotation:(PDFAnnotation *)annotation onPage:(PDFPage *)page;
- (void)setNeedsDisplayForRemovedAnnotation:(PDFAnnotation *)annotation onPage:(PDFPage *)page;
- (void)requiresDisplay;

- (void)doPdfsyncWithEvent:(NSEvent *)theEvent;
- (void)doDragWithEvent:(NSEvent *)theEvent;
- (BOOL)doDragTextWithEvent:(NSEvent *)theEvent;

- (PDFPage *)pageAndPoint:(NSPoint *)point forEvent:(NSEvent *)event nearest:(BOOL)nearest;

- (NSUInteger)currentPageIndexAndPoint:(NSPoint *)point rotated:(BOOL *)rotated;
- (void)goToPageAtIndex:(NSUInteger)pageIndex point:(NSPoint)point;

- (void)goToCurrentPage:(PDFPage *)page;

- (NSRect)layoutBoundsForPage:(PDFPage *)page;

@property (class, nonatomic, readonly) NSColor *defaultBackgroundColor;
@property (class, nonatomic, readonly) NSColor *defaultFullScreenBackgroundColor;

@end


@interface PDFView (SKPrivateDeclarations)
- (NSInteger)currentHistoryIndex;
- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types;
@end
