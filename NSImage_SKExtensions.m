//
//  NSImage_SKExtensions.m
//  Skim
//
//  Created by Christiaan Hofman on 7/27/07.
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

#import "NSImage_SKExtensions.h"
#import "NSBitmapImageRep_SKExtensions.h"
#import "NSShadow_SKExtensions.h"
#import "NSBezierPath_SKExtensions.h"
#import "NSString_SKExtensions.h"
#import <SkimNotes/SkimNotes.h>


NSString *SKImageNameTextNote = @"TextNote";
NSString *SKImageNameAnchoredNote = @"AnchoredNote";
NSString *SKImageNameCircleNote = @"CircleNote";
NSString *SKImageNameSquareNote = @"SquareNote";
NSString *SKImageNameHighlightNote = @"HighlightNote";
NSString *SKImageNameUnderlineNote = @"UnderlineNote";
NSString *SKImageNameStrikeOutNote = @"StrikeOutNote";
NSString *SKImageNameLineNote = @"LineNote";
NSString *SKImageNameInkNote = @"InkNote";
NSString *SKImageNameWidgetNote = @"Widget";

NSString *SKImageNameToolbarPageUp = @"ToolbarPageUp";
NSString *SKImageNameToolbarPageDown = @"ToolbarPageDown";
NSString *SKImageNameToolbarFirstPage = @"ToolbarFirstPage";
NSString *SKImageNameToolbarLastPage = @"ToolbarLastPage";
NSString *SKImageNameToolbarBack = @"ToolbarBack";
NSString *SKImageNameToolbarForward = @"ToolbarForward";
NSString *SKImageNameToolbarZoomIn = @"ToolbarZoomIn";
NSString *SKImageNameToolbarZoomOut = @"ToolbarZoomOut";
NSString *SKImageNameToolbarZoomActual = @"ToolbarZoomActual";
NSString *SKImageNameToolbarZoomToFit = @"ToolbarZoomToFit";
NSString *SKImageNameToolbarZoomToSelection = @"ToolbarZoomToSelection";
NSString *SKImageNameToolbarAutoScales = @"ToolbarAutoScales";
NSString *SKImageNameToolbarRotateRight = @"ToolbarRotateRight";
NSString *SKImageNameToolbarRotateLeft = @"ToolbarRotateLeft";
NSString *SKImageNameToolbarCrop = @"ToolbarCrop";
NSString *SKImageNameToolbarFullScreen = @"ToolbarFullScreen";
NSString *SKImageNameToolbarPresentation = @"ToolbarPresentation";
NSString *SKImageNameToolbarSinglePage = @"ToolbarSinglePage";
NSString *SKImageNameToolbarTwoUp = @"ToolbarTwoUp";
NSString *SKImageNameToolbarSinglePageContinuous = @"ToolbarSinglePageContinuous";
NSString *SKImageNameToolbarTwoUpContinuous = @"ToolbarTwoUpContinuous";
NSString *SKImageNameToolbarHorizontal = @"ToolbarHorizontal";
NSString *SKImageNameToolbarRTL = @"ToolbarRTL";
NSString *SKImageNameToolbarBookMode = @"ToolbarBookMode";
NSString *SKImageNameToolbarPageBreaks = @"ToolbarPageBreaks";
NSString *SKImageNameToolbarMediaBox = @"ToolbarMediaBox";
NSString *SKImageNameToolbarCropBox = @"ToolbarCropBox";
NSString *SKImageNameToolbarLeftPane = @"ToolbarLeftPane";
NSString *SKImageNameToolbarRightPane = @"ToolbarRightPane";
NSString *SKImageNameToolbarSplitPDF = @"ToolbarSplitPDF";
NSString *SKImageNameToolbarTextNoteMenu = @"ToolbarTextNoteMenu";
NSString *SKImageNameToolbarAnchoredNoteMenu = @"ToolbarAnchoredNoteMenu";
NSString *SKImageNameToolbarCircleNoteMenu = @"ToolbarCircleNoteMenu";
NSString *SKImageNameToolbarSquareNoteMenu = @"ToolbarSquareNoteMenu";
NSString *SKImageNameToolbarHighlightNoteMenu = @"ToolbarHighlightNoteMenu";
NSString *SKImageNameToolbarUnderlineNoteMenu = @"ToolbarUnderlineNoteMenu";
NSString *SKImageNameToolbarStrikeOutNoteMenu = @"ToolbarStrikeOutNoteMenu";
NSString *SKImageNameToolbarLineNoteMenu = @"ToolbarLineNoteMenu";
NSString *SKImageNameToolbarInkNoteMenu = @"ToolbarInkNoteMenu";
NSString *SKImageNameToolbarAddTextNote = @"ToolbarAddTextNote";
NSString *SKImageNameToolbarAddAnchoredNote = @"ToolbarAddAnchoredNote";
NSString *SKImageNameToolbarAddCircleNote = @"ToolbarAddCircleNote";
NSString *SKImageNameToolbarAddSquareNote = @"ToolbarAddSquareNote";
NSString *SKImageNameToolbarAddHighlightNote = @"ToolbarAddHighlightNote";
NSString *SKImageNameToolbarAddUnderlineNote = @"ToolbarAddUnderlineNote";
NSString *SKImageNameToolbarAddStrikeOutNote = @"ToolbarAddStrikeOutNote";
NSString *SKImageNameToolbarAddLineNote = @"ToolbarAddLineNote";
NSString *SKImageNameToolbarAddInkNote = @"ToolbarAddInkNote";
NSString *SKImageNameToolbarAddTextNoteMenu = @"ToolbarAddTextNoteMenu";
NSString *SKImageNameToolbarAddAnchoredNoteMenu = @"ToolbarAddAnchoredNoteMenu";
NSString *SKImageNameToolbarAddCircleNoteMenu = @"ToolbarAddCircleNoteMenu";
NSString *SKImageNameToolbarAddSquareNoteMenu = @"ToolbarAddSquareNoteMenu";
NSString *SKImageNameToolbarAddHighlightNoteMenu = @"ToolbarAddHighlightNoteMenu";
NSString *SKImageNameToolbarAddUnderlineNoteMenu = @"ToolbarAddUnderlineNoteMenu";
NSString *SKImageNameToolbarAddStrikeOutNoteMenu = @"ToolbarAddStrikeOutNoteMenu";
NSString *SKImageNameToolbarAddLineNoteMenu = @"ToolbarAddLineNoteMenu";
NSString *SKImageNameToolbarAddInkNoteMenu = @"ToolbarAddInkNoteMenu";
NSString *SKImageNameToolbarTextTool = @"ToolbarTextTool";
NSString *SKImageNameToolbarMoveTool = @"ToolbarMoveTool";
NSString *SKImageNameToolbarMagnifyTool = @"ToolbarMagnifyTool";
NSString *SKImageNameToolbarSelectTool = @"ToolbarSelectTool";
NSString *SKImageNameToolbarSnapshotTool = @"ToolbarSnapshotTool";
NSString *SKImageNameToolbarShare = @"ToolbarShare";
NSString *SKImageNameToolbarPlay = @"ToolbarPlay";
NSString *SKImageNameToolbarPause = @"ToolbarPause";
NSString *SKImageNameToolbarInfo = @"ToolbarInfo";
NSString *SKImageNameToolbarColors = @"ToolbarColors";
NSString *SKImageNameToolbarFonts = @"ToolbarFonts";
NSString *SKImageNameToolbarLines = @"ToolbarLines";
NSString *SKImageNameToolbarPrint = @"ToolbarPrint";
NSString *SKImageNameToolbarCustomize = @"ToolbarCustomize";

NSString *SKImageNameTouchBarPageUp = @"TouchBarPageUp";
NSString *SKImageNameTouchBarPageDown = @"TouchBarPageDown";
NSString *SKImageNameTouchBarFirstPage = @"TouchBarFirstPage";
NSString *SKImageNameTouchBarLastPage = @"TouchBarLastPage";
NSString *SKImageNameTouchBarZoomIn = @"TouchBarZoomIn";
NSString *SKImageNameTouchBarZoomOut = @"TouchBarZoomOut";
NSString *SKImageNameTouchBarZoomActual = @"TouchBarZoomActual";
NSString *SKImageNameTouchBarZoomToSelection = @"TouchBarZoomToSelection";
NSString *SKImageNameTouchBarTextTool = @"TouchBarTextTool";
NSString *SKImageNameTouchBarMoveTool = @"TouchBarMoveTool";
NSString *SKImageNameTouchBarMagnifyTool = @"TouchBarMagnifyTool";
NSString *SKImageNameTouchBarSelectTool = @"TouchBarSelectTool";
NSString *SKImageNameTouchBarSnapshotTool = @"TouchBarSnapshotTool";
NSString *SKImageNameTouchBarTextNote = @"TouchBarTextNote";
NSString *SKImageNameTouchBarAnchoredNote = @"TouchBarAnchoredNote";
NSString *SKImageNameTouchBarCircleNote = @"TouchBarCircleNote";
NSString *SKImageNameTouchBarSquareNote = @"TouchBarSquareNote";
NSString *SKImageNameTouchBarHighlightNote = @"TouchBarHighlightNote";
NSString *SKImageNameTouchBarUnderlineNote = @"TouchBarUnderlineNote";
NSString *SKImageNameTouchBarStrikeOutNote = @"TouchBarStrikeOutNote";
NSString *SKImageNameTouchBarLineNote = @"TouchBarLineNote";
NSString *SKImageNameTouchBarInkNote = @"TouchBarInkNote";
NSString *SKImageNameTouchBarTextNotePopover = @"TouchBarTextNotePopover";
NSString *SKImageNameTouchBarAnchoredNotePopover = @"TouchBarAnchoredNotePopover";
NSString *SKImageNameTouchBarCircleNotePopover = @"TouchBarCircleNotePopover";
NSString *SKImageNameTouchBarSquareNotePopover = @"TouchBarSquareNotePopover";
NSString *SKImageNameTouchBarHighlightNotePopover = @"TouchBarHighlightNotePopover";
NSString *SKImageNameTouchBarUnderlineNotePopover = @"TouchBarUnderlineNotePopover";
NSString *SKImageNameTouchBarStrikeOutNotePopover = @"TouchBarStrikeOutNotePopover";
NSString *SKImageNameTouchBarLineNotePopover = @"TouchBarLineNotePopover";
NSString *SKImageNameTouchBarInkNotePopover = @"TouchBarInkNotePopover";
NSString *SKImageNameTouchBarAddTextNote = @"TouchBarAddTextNote";
NSString *SKImageNameTouchBarAddAnchoredNote = @"TouchBarAddAnchoredNote";
NSString *SKImageNameTouchBarAddCircleNote = @"TouchBarAddCircleNote";
NSString *SKImageNameTouchBarAddSquareNote = @"TouchBarAddSquareNote";
NSString *SKImageNameTouchBarAddHighlightNote = @"TouchBarAddHighlightNote";
NSString *SKImageNameTouchBarAddUnderlineNote = @"TouchBarAddUnderlineNote";
NSString *SKImageNameTouchBarAddStrikeOutNote = @"TouchBarAddStrikeOutNote";
NSString *SKImageNameTouchBarAddLineNote = @"TouchBbarAddLineNote";
NSString *SKImageNameTouchBarAddInkNote = @"TouchBarAddInkNote";
NSString *SKImageNameTouchBarNewSeparator = @"TouchBarNewSeparator";
NSString *SKImageNameTouchBarRefresh = @"TouchBarRefresh";
NSString *SKImageNameTouchBarStopProgress = @"TouchBarStopProgress";

NSString *SKImageNameGeneralPreferences = @"GeneralPreferences";
NSString *SKImageNameDisplayPreferences = @"DisplayPreferences";
NSString *SKImageNameNotesPreferences = @"NotesPreferences";
NSString *SKImageNameSyncPreferences = @"SyncPreferences";

NSString *SKImageNameToolbarNewFolder = @"ToolbarNewFolder";
NSString *SKImageNameToolbarNewSeparator = @"ToolbarNewSeparator";
NSString *SKImageNameToolbarDelete = @"ToolbarDelete";

NSString *SKImageNameOutlineViewAdorn = @"OutlineViewAdorn";
NSString *SKImageNameThumbnailViewAdorn = @"ThumbnailViewAdorn";
NSString *SKImageNameNoteViewAdorn = @"NoteViewAdorn";
NSString *SKImageNameSnapshotViewAdorn = @"SnapshotViewAdorn";
NSString *SKImageNameFindViewAdorn = @"FindViewAdorn";
NSString *SKImageNameGroupedFindViewAdorn = @"GroupedFindViewAdorn";
NSString *SKImageNameTextToolAdorn = @"TextToolAdorn";
NSString *SKImageNameInkToolAdorn = @"InkToolAdorn";

NSString *SKImageNameTextAlignLeft = @"TextAlignLeft";
NSString *SKImageNameTextAlignCenter = @"TextAlignCenter";
NSString *SKImageNameTextAlignRight = @"TextAlignRight";

NSString *SKImageNameResizeDiagonal45Cursor = @"ResizeDiagonal45Cursor";
NSString *SKImageNameResizeDiagonal135Cursor = @"ResizeDiagonal135Cursor";
NSString *SKImageNameZoomInCursor = @"ZoomInCursor";
NSString *SKImageNameZoomOutCursor = @"ZoomOutCursor";
NSString *SKImageNameCameraCursor = @"CameraCursor";
NSString *SKImageNameTextNoteCursor = @"TextNoteCursor";
NSString *SKImageNameAnchoredNoteCursor = @"AnchoredNoteCursor";
NSString *SKImageNameCircleNoteCursor = @"CircleNoteCursor";
NSString *SKImageNameSquareNoteCursor = @"SquareNoteCursor";
NSString *SKImageNameHighlightNoteCursor = @"HighlightNoteCursor";
NSString *SKImageNameUnderlineNoteCursor = @"UnderlineNoteCursor";
NSString *SKImageNameStrikeOutNoteCursor = @"StrikeOutNoteCursor";
NSString *SKImageNameLineNoteCursor = @"LineNoteCursor";
NSString *SKImageNameInkNoteCursor = @"InkNoteCursor";
NSString *SKImageNameOpenHandBarCursor = @"OpenHandBarCursor";
NSString *SKImageNameClosedHandBarCursor = @"ClosedHandBarCursor";

NSString *SKImageNameRemoteStateResize = @"RemoteStateResize";
NSString *SKImageNameRemoteStateScroll = @"RemoteStateScroll";

static void drawMenuBadge();
static void drawAddBadge();
static void drawPopoverBadge();

static inline void translate(CGFloat dx, CGFloat dy);

static inline void drawPageBackgroundInRect(NSRect rect);

static inline void drawArrowCursor();

static void evaluateLaserPointer(void *info, const CGFloat *in, CGFloat *out);

#define MAKE_IMAGE(name, isTemplate, width, height, instructions) \
do { \
static NSImage *image = nil; \
image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)]; \
[image lockFocus]; \
instructions \
[image unlockFocus]; \
[image setTemplate:isTemplate]; \
[image setName:name]; \
} while (0)

#define MAKE_VECTOR_IMAGE(name, isTemplate, width, height, instructions) \
do { \
static NSImage *image = nil; \
image = [[NSImage alloc] initVectorWithSize:NSMakeSize(width, height) drawingHandler:^(NSRect dstRect){ \
instructions \
}]; \
[image setTemplate:isTemplate]; \
[image setName:name]; \
} while (0)

#define APPLY_NOTE_TYPES(macro) \
macro(Text); \
macro(Anchored); \
macro(Circle); \
macro(Square); \
macro(Highlight); \
macro(Underline); \
macro(StrikeOut); \
macro(Line); \
macro(Ink)

#define DECLARE_NOTE_FUNCTIONS(name) \
static void draw ## name ## Note(); \
static void draw ## name ## NoteBackground()

APPLY_NOTE_TYPES(DECLARE_NOTE_FUNCTIONS);

@implementation NSImage (SKExtensions)

+ (NSImage *)bitmapImageWithSize:(NSSize)size scale:(CGFloat)scale drawingHandler:(void (^)(NSRect dstRect))drawingHandler {
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image addRepresentation:[NSBitmapImageRep imageRepWithSize:size scale:scale drawingHandler:drawingHandler]];
    return image;
}

- (instancetype)initPDFWithSize:(NSSize)size drawingHandler:(void (^)(NSRect dstRect))drawingHandler {
    CFMutableDataRef pdfData = CFDataCreateMutable(NULL, 0);
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData(pdfData);
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    CGContextRef context = CGPDFContextCreate(consumer, &rect, NULL);
    CGDataConsumerRelease(consumer);
    CGPDFContextBeginPage(context, NULL);
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithCGContext:context flipped:NO]];
    if (drawingHandler) drawingHandler((NSRect){NSZeroPoint, size});
    [NSGraphicsContext restoreGraphicsState];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    self = [self initWithData:CFBridgingRelease(pdfData)];
    return self;
}

- (instancetype)initVectorWithSize:(NSSize)size drawingHandler:(void (^)(NSRect dstRect))drawingHandler {
    return [self initPDFWithSize:size drawingHandler:drawingHandler];
}

// can't draw transparent gradients in a PDF context for some reason...
+ (NSImage *)laserPointerImageWithColor:(NSInteger)color {
    CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGPoint center = CGPointMake(12.0, 12.0);
    CGFloat domain[] = {0.0, 1.0};
    CGFloat range[] = {0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0};
    CGFunctionCallbacks callbacks = {0, &evaluateLaserPointer, NULL};
    CGFunctionRef function = CGFunctionCreate((void *)color, 1, domain, 4, range, &callbacks);
    CGShadingRef shading = CGShadingCreateRadial(colorspace, center, 0.0, center, 12.0, function, false, false);
    CGColorSpaceRelease(colorspace);
    CGFunctionRelease(function);
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(24.0, 24.0)];;
    NSSize size = NSMakeSize(24.0, 24.0);
    CGFloat scale;
    void (^drawingHandler)(NSRect) = ^(NSRect rect){
        CGContextDrawShading([[NSGraphicsContext currentContext] CGContext], shading);
    };
    for (scale = 1.0; scale <= 8.0; scale *= 2.0)
        [image addRepresentation:[NSBitmapImageRep imageRepWithSize:size scale:scale drawingHandler:drawingHandler]];
    CGShadingRelease(shading);
    return image;
}

+ (NSImage *)stampForType:(NSString *)type {
    static NSMutableDictionary *stamps = nil;
    NSImage *stamp = [stamps objectForKey:type];
    if (stamp == nil) {
        stamp = [[self alloc] initPDFWithSize:NSMakeSize(256.0, 256.0) drawingHandler:^(NSRect rect){
            NSFont *font = [NSFont fontWithName:@"Times-Bold" size:120.0] ?: [NSFont boldSystemFontOfSize:120.0];
            NSTextStorage *storage = [[NSTextStorage alloc] initWithString:type attributes:@{NSFontAttributeName:font}];
            NSLayoutManager *manager = [[NSLayoutManager alloc] init];
            NSTextContainer *container = [[NSTextContainer alloc] init];
            
            [storage addLayoutManager:manager];
            [manager addTextContainer:container];
            
            NSRange glyphRange = [manager glyphRangeForTextContainer:container];
            CGGlyph glyphArray[glyphRange.length];
            NSUInteger glyphCount = [manager getGlyphsInRange:glyphRange glyphs:glyphArray properties:NULL characterIndexes:NULL bidiLevels:NULL];
            CGFloat width = NSWidth([manager boundingRectForGlyphRange:glyphRange inTextContainer:container]);
            
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(0.5 * (NSWidth(rect) - width), 0.5 * (NSHeight(rect) - [font capHeight]))];
            [path appendBezierPathWithCGGlyphs:glyphArray count:glyphCount inFont:font];

            NSBezierPath *mask = [NSBezierPath bezierPathWithRect:rect];
            [mask appendBezierPath:path];
            [mask setWindingRule:NSEvenOddWindingRule];
            
            [path addClip];
            [NSShadow setShadowWithWhite:0 alpha:0.4 blurRadius:10.0 yOffset:0.0];
            [mask fill];
        }];
        if (stamps == nil)
            stamps = [[NSMutableDictionary alloc] init];
        [stamps setObject:stamp forKey:type];
    }
    return stamp;
}

+ (NSImage *)maskImageWithSize:(NSSize)size cornerRadius:(CGFloat)radius {
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:(NSRect){NSZeroPoint, size} xRadius:radius yRadius:radius];
    NSImage *mask = [[self alloc] initWithSize:size];
    [mask lockFocus];
    [[NSColor blackColor] set];
    [path fill];
    [mask unlockFocus];
    [mask setTemplate:YES];
    return mask;
}

+ (NSImage *)markImage {
    static NSImage *markImage = nil;
    if (markImage == nil) {
        markImage = [self imageWithSize:NSMakeSize(6.0, 10.0) flipped:NO drawingHandler:^(NSRect rect){
                [[NSColor colorWithSRGBRed:0.654 green:0.166 blue:0.392 alpha:1.0] setFill];
                NSBezierPath *path = [NSBezierPath bezierPath];
                [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
                [path lineToPoint:NSMakePoint(NSMidX(rect), NSMinY(rect) + 0.5 * NSWidth(rect))];
                [path lineToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
                [path lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
                [path lineToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];
                [path closePath];
                [path fill];
                return YES;
            }];
        [markImage setAccessibilityDescription:NSLocalizedString(@"marked page", @"Accessibility description")];
    }
    return markImage;
}

+ (void)makeToolbarImages {
    
    MAKE_IMAGE(SKImageNameToolbarPageUp, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.5, 10.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(9.5, 3.5) toPoint:NSMakePoint(17.5, 3.5) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.5, 3.5) toPoint:NSMakePoint(17.5, 10.5) radius:1.0];
        [path lineToPoint:NSMakePoint(17.5, 10.5)];
        [path lineToPoint:NSMakePoint(20.5, 10.5)];
        [path lineToPoint:NSMakePoint(13.5, 17.5)];
        [path lineToPoint:NSMakePoint(6.5, 10.5)];
        [path closePath];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarPageDown, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.5, 9.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(9.5, 16.5) toPoint:NSMakePoint(17.5, 16.5) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.5, 16.5) toPoint:NSMakePoint(17.5, 9.5) radius:1.0];
        [path lineToPoint:NSMakePoint(17.5, 9.5)];
        [path lineToPoint:NSMakePoint(20.5, 9.5)];
        [path lineToPoint:NSMakePoint(13.5, 2.5)];
        [path lineToPoint:NSMakePoint(6.5, 9.5)];
        [path closePath];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarFirstPage, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.5, 5.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(9.5, 3.5) toPoint:NSMakePoint(17.5, 3.5) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.5, 3.5) toPoint:NSMakePoint(17.5, 10.5) radius:1.0];
        [path lineToPoint:NSMakePoint(17.5, 5.5)];
        [path closePath];
        [path moveToPoint:NSMakePoint(9.5, 7.5)];
        [path lineToPoint:NSMakePoint(17.5, 7.5)];
        [path lineToPoint:NSMakePoint(17.5, 10.5)];
        [path lineToPoint:NSMakePoint(20.5, 10.5)];
        [path lineToPoint:NSMakePoint(13.5, 17.5)];
        [path lineToPoint:NSMakePoint(6.5, 10.5)];
        [path lineToPoint:NSMakePoint(9.5, 10.5)];
        [path closePath];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarLastPage, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.5, 14.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(9.5, 16.5) toPoint:NSMakePoint(17.5, 16.5) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.5, 16.5) toPoint:NSMakePoint(17.5, 9.5) radius:1.0];
        [path lineToPoint:NSMakePoint(17.5, 14.5)];
        [path closePath];
        [path moveToPoint:NSMakePoint(9.5, 12.5)];
        [path lineToPoint:NSMakePoint(17.5, 12.5)];
        [path lineToPoint:NSMakePoint(17.5, 9.5)];
        [path lineToPoint:NSMakePoint(20.5, 9.5)];
        [path lineToPoint:NSMakePoint(13.5, 2.5)];
        [path lineToPoint:NSMakePoint(6.5, 9.5)];
        [path lineToPoint:NSMakePoint(9.5, 9.5)];
        [path closePath];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarBack, YES, 27.0, 17.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(14.0, 3.0)];
        [path lineToPoint:NSMakePoint(8.5, 8.5)];
        [path lineToPoint:NSMakePoint(14.0, 14.0)];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarForward, YES, 27.0, 17.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(13.0, 3.0)];
        [path lineToPoint:NSMakePoint(18.5, 8.5)];
        [path lineToPoint:NSMakePoint(13.0, 14.0)];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarZoomIn, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect:NSMakeRect(6.5, 5.5, 10.0, 10.0)];
        [path moveToPoint:NSMakePoint(15.0, 7.0)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path moveToPoint:NSMakePoint(9.0, 10.5)];
        [path lineToPoint:NSMakePoint(14.0, 10.5)];
        [path moveToPoint:NSMakePoint(11.5, 8.0)];
        [path lineToPoint:NSMakePoint(11.5, 13.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarZoomOut, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect:NSMakeRect(6.5, 5.5, 10.0, 10.0)];
        [path moveToPoint:NSMakePoint(15.0, 7.0)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path moveToPoint:NSMakePoint(9.0, 10.5)];
        [path lineToPoint:NSMakePoint(14.0, 10.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarZoomActual, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect:NSMakeRect(6.5, 5.5, 10.0, 10.0)];
        [path moveToPoint:NSMakePoint(15.0, 7.0)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path moveToPoint:NSMakePoint(9.0, 9.5)];
        [path lineToPoint:NSMakePoint(14.0, 9.5)];
        [path moveToPoint:NSMakePoint(9.0, 11.5)];
        [path lineToPoint:NSMakePoint(14.0, 11.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarZoomToFit, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(5.5, 3.5, 16.0 , 12.0) xRadius:1.0 yRadius:1.0];
        [path appendBezierPathWithOvalInRect:NSMakeRect(8.5, 5.5, 8.0, 8.0)];
        [path moveToPoint:NSMakePoint(15.5, 6.5)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarZoomToSelection, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(5.5, 13.0)];
        [path lineToPoint:NSMakePoint(5.5, 15.5)];
        [path lineToPoint:NSMakePoint(9.0, 15.5)];
        [path moveToPoint:NSMakePoint(11.0, 15.5)];
        [path lineToPoint:NSMakePoint(16.0, 15.5)];
        [path moveToPoint:NSMakePoint(18.0, 15.5)];
        [path lineToPoint:NSMakePoint(21.5, 15.5)];
        [path lineToPoint:NSMakePoint(21.5, 13.0)];
        [path moveToPoint:NSMakePoint(21.5, 11.0)];
        [path lineToPoint:NSMakePoint(21.5, 8.0)];
        [path moveToPoint:NSMakePoint(21.5, 6.0)];
        [path lineToPoint:NSMakePoint(21.5, 3.5)];
        [path lineToPoint:NSMakePoint(18.0, 3.5)];
        [path moveToPoint:NSMakePoint(16.0, 3.5)];
        [path lineToPoint:NSMakePoint(11.0, 3.5)];
        [path moveToPoint:NSMakePoint(9.0, 3.5)];
        [path lineToPoint:NSMakePoint(5.5, 3.5)];
        [path lineToPoint:NSMakePoint(5.5, 6.0)];
        [path moveToPoint:NSMakePoint(5.5, 8.0)];
        [path lineToPoint:NSMakePoint(5.5, 11.0)];
        [path appendBezierPathWithOvalInRect:NSMakeRect(8.5, 5.5, 8.0, 8.0)];
        [path moveToPoint:NSMakePoint(15.5, 6.5)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarAutoScales, YES, 27.0, 19.0,
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect:NSMakeRect(6.5, 5.5, 10.0, 10.0)];
        [path moveToPoint:NSMakePoint(15.0, 7.0)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(8.5, 11.0)];
        [path lineToPoint:NSMakePoint(14.5, 11.0)];
        [path lineToPoint:NSMakePoint(11.5, 14.0)];
        [path closePath];
        [path moveToPoint:NSMakePoint(8.5, 10.0)];
        [path lineToPoint:NSMakePoint(14.5, 10.0)];
        [path lineToPoint:NSMakePoint(11.5, 7.0)];
        [path closePath];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarRotateLeft, YES, 27.0, 21.0,
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(7.5, 4.5, 9.0, 7.0) xRadius:1.0 yRadius:1.0];
        [path moveToPoint:NSMakePoint(20.5, 8.0)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(14.0, 10.0) radius:6.5 startAngle:0.0 endAngle:90.0 clockwise:NO];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(14.0, 14.0)];
        [path lineToPoint:NSMakePoint(14.0, 19.0)];
        [path lineToPoint:NSMakePoint(9.5, 16.5)];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarRotateRight, YES, 27.0, 21.0, 
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(10.5, 4.5, 9.0, 7.0) xRadius:1.0 yRadius:1.0];
        [path moveToPoint:NSMakePoint(6.5, 8.0)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(13.0, 10.0) radius:6.5 startAngle:180.0 endAngle:90.0 clockwise:YES];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(13.0, 14.0)];
        [path lineToPoint:NSMakePoint(13.0, 19.0)];
        [path lineToPoint:NSMakePoint(17.5, 16.5)];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarCrop, YES, 27.0, 21.0, 
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(5.5, 4.5, 16.0 , 12.0) xRadius:1.0 yRadius:1.0];
        [path moveToPoint:NSMakePoint(3.0, 7.5)];
        [path lineToPoint:NSMakePoint(24.0, 7.5)];
        [path moveToPoint:NSMakePoint(18.5, 2.0)];
        [path lineToPoint:NSMakePoint(18.5, 19.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarFullScreen, YES, 27.0, 19.0, 
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(5.5, 3.5, 16.0, 12.0) xRadius:3.0 yRadius:3.0];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(10.0, 11.0)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(10.0, 6.0) toPoint:NSMakePoint(15.0, 6.0) radius:1.0];
        [path lineToPoint:NSMakePoint(15.0, 6.0)];
        [path closePath];
        [path moveToPoint:NSMakePoint(17.0, 8.0)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.0, 13.0) toPoint:NSMakePoint(12.0, 13.0) radius:1.0];
        [path lineToPoint:NSMakePoint(12.0, 13.0)];
        [path closePath];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarPresentation, YES, 27.0, 19.0, 
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(5.5, 3.5, 16.0, 12.0) xRadius:3.0 yRadius:3.0];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(11.0, 6.0)];
        [path lineToPoint:NSMakePoint(18.0, 9.5)];
        [path lineToPoint:NSMakePoint(11.0, 13.0)];
        [path closePath];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarSinglePage, YES, 27.0, 19.0, 
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(9.0, 4.0, 9.0 , 12.0)];
        [path fill];
        drawPageBackgroundInRect(NSMakeRect(10.0, 5.0, 7.0 , 10.0));
    );
    
    MAKE_IMAGE(SKImageNameToolbarTwoUp, YES, 27.0, 19.0, 
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(5.0, 4.0, 17.0 , 12.0)];
        [path fill];
        drawPageBackgroundInRect(NSMakeRect(6.0, 5.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(14.0, 5.0, 7.0 , 10.0));
    );
    
    MAKE_IMAGE(SKImageNameToolbarSinglePageContinuous, YES, 27.0, 19.0, 
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(9.0, 4.0, 9.0 , 12.0)];
        [path fill];
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(9.0, 4.0, 9.0 , 12.0)];
        [path addClip];
        drawPageBackgroundInRect(NSMakeRect(10.0, 11.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(10.0, 0.0, 7.0 , 10.0));
    );
    
    MAKE_IMAGE(SKImageNameToolbarTwoUpContinuous, YES, 27.0, 19.0, 
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(5.0, 4.0, 17.0 , 12.0)];
        [path fill];
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(4.0, 4.0, 19.0 , 12.0)];
        [path addClip];
        drawPageBackgroundInRect(NSMakeRect(6.0, 11.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(14.0, 11.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(6.0, 0.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(14.0, 0.0, 7.0 , 10.0));
    );
    
    MAKE_IMAGE(SKImageNameToolbarHorizontal, YES, 27.0, 19.0,
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(5.0, 4.0, 17.0 , 12.0)];
        [path fill];
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(5.0, 4.0, 17.0 , 12.0)];
        [path addClip];
        drawPageBackgroundInRect(NSMakeRect(2.0, 5.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(10.0, 5.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(18.0, 5.0, 7.0 , 10.0));
    );
    
    MAKE_IMAGE(SKImageNameToolbarRTL, YES, 27.0, 19.0,
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(5.0, 4.0, 17.0 , 12.0)];
        [path fill];
        drawPageBackgroundInRect(NSMakeRect(6.0, 5.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(14.0, 5.0, 7.0 , 10.0));
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(19.0, 10.0)];
        [path lineToPoint:NSMakePoint(8.0, 10.0)];
        [path moveToPoint:NSMakePoint(11.0, 13.0)];
        [path lineToPoint:NSMakePoint(8.0, 10.0)];
        [path lineToPoint:NSMakePoint(11.0, 7.0)];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarBookMode, YES, 27.0, 19.0,
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(9.0, 9.0, 9.0 , 7.0)];
        [path appendBezierPathWithRect:NSMakeRect(5.0, 4.0, 17.0 , 6.0)];
        [path fill];
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(4.0, 4.0, 19.0 , 12.0)];
        [path addClip];
        drawPageBackgroundInRect(NSMakeRect(10.0, 10.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(6.0, -1.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(14.0, -1.0, 7.0 , 10.0));
    );
    
    MAKE_IMAGE(SKImageNameToolbarPageBreaks, YES, 27.0, 19.0, 
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(9.0, 11.0, 9.0 , 5.0)];
        [path appendBezierPathWithRect:NSMakeRect(9.0, 4.0, 9.0 , 5.0)];
        [path fill];
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(9.0, 4.0, 9.0 , 12.0)];
        [path addClip];
        drawPageBackgroundInRect(NSMakeRect(10.0, 12.0, 7.0 , 10.0));
        drawPageBackgroundInRect(NSMakeRect(10.0, -2.0, 7.0 , 10.0));
    );
    
    MAKE_IMAGE(SKImageNameToolbarMediaBox, YES, 27.0, 21.0, 
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(5.5, 4.5, 16.0 , 12.0) xRadius:1.0 yRadius:1.0];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarCropBox, YES, 27.0, 21.0, 
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(5.5, 4.5, 16.0 , 12.0) xRadius:1.0 yRadius:1.0];
        [path moveToPoint:NSMakePoint(3.0, 7.5)];
        [path lineToPoint:NSMakePoint(24.0, 7.5)];
        [path moveToPoint:NSMakePoint(18.5, 2.0)];
        [path lineToPoint:NSMakePoint(18.5, 19.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarLeftPane, YES, 27.0, 17.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(6.5, 3.5, 14.0 , 11.0) xRadius:1.0 yRadius:1.0];
        [path moveToPoint:NSMakePoint(11.5, 4.0)];
        [path lineToPoint:NSMakePoint(11.5, 14.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [[NSColor colorWithGenericGamma22White:0.0 alpha:0.5] set];
        [path moveToPoint:NSMakePoint(8.0, 8.5)];
        [path lineToPoint:NSMakePoint(10.0, 8.5)];
        [path moveToPoint:NSMakePoint(8.0, 10.5)];
        [path lineToPoint:NSMakePoint(10.0, 10.5)];
        [path moveToPoint:NSMakePoint(8.0, 12.5)];
        [path lineToPoint:NSMakePoint(10.0, 12.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarRightPane, YES, 27.0, 17.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(6.5, 3.5, 14.0 , 11.0) xRadius:1.0 yRadius:1.0];
        [path moveToPoint:NSMakePoint(15.5, 4.0)];
        [path lineToPoint:NSMakePoint(15.5, 14.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [[NSColor colorWithGenericGamma22White:0.0 alpha:0.5] set];
        [path moveToPoint:NSMakePoint(17.0, 8.5)];
        [path lineToPoint:NSMakePoint(19.0, 8.5)];
        [path moveToPoint:NSMakePoint(17.0, 10.5)];
        [path lineToPoint:NSMakePoint(19.0, 10.5)];
        [path moveToPoint:NSMakePoint(17.0, 12.5)];
        [path lineToPoint:NSMakePoint(19.0, 12.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarSplitPDF, YES, 27.0, 17.0,
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(6.5, 3.5, 14.0 , 11.0) xRadius:1.0 yRadius:1.0];
        [path moveToPoint:NSMakePoint(6.5, 7.5)];
        [path lineToPoint:NSMakePoint(20.5, 7.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarTextTool, YES, 27.0, 19.0,
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:12.0] ?: [NSFont systemFontOfSize:12.0];
        NSGlyph glyph = [font glyphWithName:@"A"];
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(7.5, 3.5, 12.0, 12.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(13.5 - NSMidX([font boundingRectForGlyph:glyph]), 5.0)];
        [path appendBezierPathWithGlyph:glyph inFont:font];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarMoveTool, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(10.5, 3.0)];
        [path curveToPoint:NSMakePoint(8.0, 7.0) controlPoint1:NSMakePoint(10.5, 4.5) controlPoint2:NSMakePoint(10.5, 4.5)];
        [path curveToPoint:NSMakePoint(6.5, 11.0) controlPoint1:NSMakePoint(5.5, 9.5) controlPoint2:NSMakePoint(5.5, 10.0)];
        [path curveToPoint:NSMakePoint(10.0, 9.5) controlPoint1:NSMakePoint(7.5, 12.0) controlPoint2:NSMakePoint(7.5, 12.0)];
        [path curveToPoint:NSMakePoint(9.5, 15.5) controlPoint1:NSMakePoint(7.5, 14.0) controlPoint2:NSMakePoint(7.0, 15.5)];
        [path curveToPoint:NSMakePoint(11.5, 11.5) controlPoint1:NSMakePoint(10.5, 15.5) controlPoint2:NSMakePoint(10.5, 15.5)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(13.0, 15.5) radius:1.5 startAngle:180.0 endAngle:0.0 clockwise:YES];
        [path moveToPoint:NSMakePoint(14.5, 11.0)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(16.0, 14.5) radius:1.5 startAngle:180.0 endAngle:0.0 clockwise:YES];
        [path lineToPoint:NSMakePoint(17.5, 12.5)];
        [path moveToPoint:NSMakePoint(17.5, 10.5)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(19.0, 12.5) radius:1.5 startAngle:180.0 endAngle:0.0 clockwise:YES];
        [path curveToPoint:NSMakePoint(17.5, 3.0) controlPoint1:NSMakePoint(20.5, 8.5) controlPoint2:NSMakePoint(17.5, 7.0)];
        [path setLineJoinStyle:NSRoundLineJoinStyle];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarMagnifyTool, YES, 27.0, 19.0,
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(8.5, 13.5)];
        [path lineToPoint:NSMakePoint(8.5, 11.5)];
        [path halfEllipseFromPoint:NSMakePoint(13.5, 9.5) toPoint:NSMakePoint(18.5, 11.5)];
        [path lineToPoint:NSMakePoint(18.5, 13.5)];
        [path halfEllipseFromPoint:NSMakePoint(13.5, 11.5) toPoint:NSMakePoint(8.5, 13.5)];
        [path fill];
        [path halfEllipseFromPoint:NSMakePoint(13.5, 15.5) toPoint:NSMakePoint(18.5, 13.5)];
        [path moveToPoint:NSMakePoint(9.5, 10.5)];
        [path curveToPoint:NSMakePoint(7.5, 6.0) controlPoint1:NSMakePoint(8.0, 9.0) controlPoint2:NSMakePoint(7.5, 7.5)];
        [path halfEllipseFromPoint:NSMakePoint(13.5, 3.5) toPoint:NSMakePoint(19.5, 6.0)];
        [path curveToPoint:NSMakePoint(17.5, 10.5) controlPoint1:NSMakePoint(19.5, 7.5) controlPoint2:NSMakePoint(19.0, 9.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarSelectTool, YES, 27.0, 19.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(7.5, 13.0)];
        [path lineToPoint:NSMakePoint(7.5, 15.5)];
        [path lineToPoint:NSMakePoint(10.0, 15.5)];
        [path moveToPoint:NSMakePoint(12.0, 15.5)];
        [path lineToPoint:NSMakePoint(15.0, 15.5)];
        [path moveToPoint:NSMakePoint(17.0, 15.5)];
        [path lineToPoint:NSMakePoint(19.5, 15.5)];
        [path lineToPoint:NSMakePoint(19.5, 13.0)];
        [path moveToPoint:NSMakePoint(19.5, 11.0)];
        [path lineToPoint:NSMakePoint(19.5, 8.0)];
        [path moveToPoint:NSMakePoint(19.5, 6.0)];
        [path lineToPoint:NSMakePoint(19.5, 3.5)];
        [path lineToPoint:NSMakePoint(17.0, 3.5)];
        [path moveToPoint:NSMakePoint(15.0, 3.5)];
        [path lineToPoint:NSMakePoint(12.0, 3.5)];
        [path moveToPoint:NSMakePoint(10.0, 3.5)];
        [path lineToPoint:NSMakePoint(7.5, 3.5)];
        [path lineToPoint:NSMakePoint(7.5, 6.0)];
        [path moveToPoint:NSMakePoint(7.5, 8.0)];
        [path lineToPoint:NSMakePoint(7.5, 11.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarSnapshotTool, YES, 27.0, 19.0,
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(6.0, 4.0, 15.0, 10.0)];
        [path appendBezierPathWithOvalInRect:NSMakeRect(10.5, 10.0, 6.0, 6.0)];
        [path fill];
        [NSGraphicsContext saveGraphicsState];
        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositingOperationClear];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(9.8, 5.8, 7.4, 7.4)] stroke];
        path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(13.5, 9.5) radius:1.8 startAngle:45.0 endAngle:225.0];
        [path closePath];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
    );
    
    MAKE_IMAGE(SKImageNameToolbarShare, YES, 27.0, 19.0,
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(15.0, 11.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(18.5, 11.5) toPoint:NSMakePoint(18.5, 2.5) radius:0.5];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(18.5, 2.5) toPoint:NSMakePoint(8.5, 2.5) radius:0.5];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(8.5, 2.5) toPoint:NSMakePoint(8.5, 11.5) radius:0.5];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(8.5, 11.5) toPoint:NSMakePoint(12.0, 11.5) radius:0.5];
        [path lineToPoint:NSMakePoint(12.0, 11.5)];
        [path moveToPoint:NSMakePoint(13.5, 7.0)];
        [path lineToPoint:NSMakePoint(13.5, 16.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(11.0, 13.5)];
        [path lineToPoint:NSMakePoint(13.5, 16.5)];
        [path lineToPoint:NSMakePoint(16.0, 13.5)];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameToolbarPlay, YES, 27.0, 19.0,
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.0, 4.5)];
        [path lineToPoint:NSMakePoint(19.0, 9.5)];
        [path lineToPoint:NSMakePoint(9.0, 14.5)];
        [path closePath];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarPause, YES, 27.0, 19.0,
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(8.0, 4.0, 4.0, 11.0)];
        [path appendBezierPathWithRect:NSMakeRect(15.0, 4.0, 4.0, 11.0)];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarInfo, YES, 27.0, 20.0,
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(7.5, 4.5, 12.0, 12.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(12.0, 7.4)];
        [path lineToPoint:NSMakePoint(15.3, 7.4)];
        [path moveToPoint:NSMakePoint(13.7, 7.4)];
        [path lineToPoint:NSMakePoint(13.7, 11.2)];
        [path lineToPoint:NSMakePoint(12.2, 11.2)];
        [path setLineWidth:0.8];
        [path stroke];
        path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(12.7, 12.8, 1.5, 1.5)];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarFonts, YES, 27.0, 20.0,
        [[NSColor blackColor] setFill];
        [NSBezierPath fillRect:NSMakeRect(4.0, 1.0, 19.0, 19.0)];
        [[NSImage imageNamed:NSImageNameFontPanel] drawInRect:NSMakeRect(4.0, 1.0, 19.0, 19.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationAtop fraction:1.0];
    );
    
    MAKE_IMAGE(SKImageNameToolbarLines, YES, 27.0, 20.0,
        [[NSColor blackColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(6.0, 14.0, 15.0, 1.0)];
        [path appendBezierPathWithRect:NSMakeRect(6.0, 10.0, 15.0, 2.0)];
        [path appendBezierPathWithRect:NSMakeRect(6.0, 5.0, 15.0, 3.0)];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameToolbarCustomize, YES, 27.0, 20.0,
        [[NSColor blackColor] setFill];
        [NSBezierPath fillRect:NSMakeRect(4.0, 1.0, 19.0, 19.0)];
        NSImage *customizeImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kToolbarCustomizeIcon)];
        [customizeImage drawInRect:NSMakeRect(4.0, 1.0, 19.0, 19.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationAtop fraction:1.0];
    );
    
    MAKE_IMAGE(SKImageNameToolbarPrint, YES, 27.0, 20.0, 
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(7.5, 15.0)];
        [path lineToPoint:NSMakePoint(7.5, 17.5)];
        [path lineToPoint:NSMakePoint(19.5, 17.5)];
        [path lineToPoint:NSMakePoint(19.5, 15.0)];
        [[NSColor blackColor] set];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(5.0, 14.0)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(24.0, 14.0) toPoint:NSMakePoint(24.0, 4.0) radius:2.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(24.0, 4.0) toPoint:NSMakePoint(20.0, 4.0) radius:1.0];
        [path lineToPoint:NSMakePoint(20.0, 4.0)];
        [path lineToPoint:NSMakePoint(20.0, 1.0)];
        [path lineToPoint:NSMakePoint(7.0, 1.0)];
        [path lineToPoint:NSMakePoint(7.0, 4.0)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(3.0, 4.0) toPoint:NSMakePoint(3.0, 14.0) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(3.0, 14.0) toPoint:NSMakePoint(5.0, 14.0) radius:2.0];
        [path closePath];
        [path appendBezierPathWithRect:NSMakeRect(8.0, 2.0, 11.0, 8.0)];
        [path setWindingRule:NSEvenOddWindingRule];
        [path fill];
    );
    
    MAKE_VECTOR_IMAGE(SKImageNameToolbarNewFolder, YES, 21.0, 19.0,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(11.5, 14.0)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(7.8, 14.0) toPoint:NSMakePoint(6.7, 15.1) radius:1.2];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(6.7, 15.1) toPoint:NSMakePoint(3.0, 15.1) radius:1.2];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(3.0, 15.1) toPoint:NSMakePoint(3.0, 13) radius:1.2];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(3.0, 4.5) toPoint:NSMakePoint(16.3, 4.5) radius:1.2];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(16.4, 4.5) toPoint:NSMakePoint(16.4, 14.0) radius:1.2];
        [path lineToPoint:NSMakePoint(16.4, 9.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(3.0, 11.6)];
        [path lineToPoint:NSMakePoint(14.5, 11.6)];
        [path setLineWidth:0.8];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(16.25, 17.5)];
        [path lineToPoint:NSMakePoint(16.25, 10.0)];
        [path moveToPoint:NSMakePoint(12.5, 13.75)];
        [path lineToPoint:NSMakePoint(20.0, 13.75)];
        [path setLineWidth:1.5];
        [path stroke];
    );
    
    MAKE_VECTOR_IMAGE(SKImageNameToolbarNewSeparator, YES, 21.0, 19.0,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(2.0, 8.5)];
        [path lineToPoint:NSMakePoint(19.0, 8.5)];
        [path setLineWidth:2.0];
        [NSGraphicsContext saveGraphicsState];
        [[NSColor colorWithGenericGamma22White:0.0 alpha:0.8] setFill];
        [path stroke];
        [NSGraphicsContext restoreGraphicsState];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(16.25, 17.5)];
        [path lineToPoint:NSMakePoint(16.25, 10.0)];
        [path moveToPoint:NSMakePoint(12.5, 13.75)];
        [path lineToPoint:NSMakePoint(20.0, 13.75)];
        [path setLineWidth:1.5];
        [path stroke];
    );
    
    MAKE_VECTOR_IMAGE(SKImageNameToolbarDelete, YES, 21.0, 19.0,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(5.75, 14.25)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(6.25, 3.5) toPoint:NSMakePoint(14.0, 3.5) radius:1.5];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(14.0, 3.5) toPoint:NSMakePoint(14.5, 14.25) radius:1.5];
        [path lineToPoint:NSMakePoint(14.5, 14.25)];
        [path moveToPoint:NSMakePoint(4.5, 14.25)];
        [path lineToPoint:NSMakePoint(15.75, 14.25)];
        [path moveToPoint:NSMakePoint(12.5, 14.25)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(12.5, 16.75) toPoint:NSMakePoint(7.75, 16.75) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(7.75, 16.75) toPoint:NSMakePoint(8.0, 14.25) radius:1];
        [path lineToPoint:NSMakePoint(8.0, 14.25)];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(10.125, 5.5)];
        [path lineToPoint:NSMakePoint(10.125, 12.0)];
        [path moveToPoint:NSMakePoint(8.25, 5.5)];
        [path lineToPoint:NSMakePoint(8.0, 12.0)];
        [path moveToPoint:NSMakePoint(12.0, 5.5)];
        [path lineToPoint:NSMakePoint(12.25, 12.0)];
        [path setLineWidth:0.8];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path stroke];
    );
    
#define MAKE_BADGED_IMAGES(name) \
    MAKE_IMAGE(SKImageNameToolbarAdd ## name ## Note, YES, 27.0, 19.0, \
        translate(3.0, 0.0); \
        draw ## name ## Note(); \
        drawAddBadge(); \
    ); \
    MAKE_IMAGE(SKImageNameToolbar ## name ## NoteMenu, YES, 27.0, 19.0, \
        drawMenuBadge(); \
        translate(1.0, 0.0); \
        draw ## name ## Note(); \
    ); \
    MAKE_IMAGE(SKImageNameToolbarAdd ## name ## NoteMenu, YES, 27.0, 19.0, \
        drawMenuBadge(); \
        translate(1.0, 0.0); \
        draw ## name ## Note(); \
        drawAddBadge(); \
    ); \

    APPLY_NOTE_TYPES(MAKE_BADGED_IMAGES);
    
}
    
+ (void)makeTouchBarImages {
    
    MAKE_IMAGE(SKImageNameTouchBarPageUp, YES, 26.0, 30.0,
        translate(-0.5, 5.0);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.5, 10.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(9.5, 3.5) toPoint:NSMakePoint(17.5, 3.5) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.5, 3.5) toPoint:NSMakePoint(17.5, 10.5) radius:1.0];
        [path lineToPoint:NSMakePoint(17.5, 10.5)];
        [path lineToPoint:NSMakePoint(20.5, 10.5)];
        [path lineToPoint:NSMakePoint(13.5, 17.5)];
        [path lineToPoint:NSMakePoint(6.5, 10.5)];
        [path closePath];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarPageDown, YES, 26.0, 30.0,
        translate(-0.5, 5.0);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.5, 9.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(9.5, 16.5) toPoint:NSMakePoint(17.5, 16.5) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.5, 16.5) toPoint:NSMakePoint(17.5, 9.5) radius:1.0];
        [path lineToPoint:NSMakePoint(17.5, 9.5)];
        [path lineToPoint:NSMakePoint(20.5, 9.5)];
        [path lineToPoint:NSMakePoint(13.5, 2.5)];
        [path lineToPoint:NSMakePoint(6.5, 9.5)];
        [path closePath];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarFirstPage, YES, 26.0, 30.0,
        translate(-0.5, 5.0);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.5, 5.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(9.5, 3.5) toPoint:NSMakePoint(17.5, 3.5) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.5, 3.5) toPoint:NSMakePoint(17.5, 10.5) radius:1.0];
        [path lineToPoint:NSMakePoint(17.5, 5.5)];
        [path closePath];
        [path moveToPoint:NSMakePoint(9.5, 7.5)];
        [path lineToPoint:NSMakePoint(17.5, 7.5)];
        [path lineToPoint:NSMakePoint(17.5, 10.5)];
        [path lineToPoint:NSMakePoint(20.5, 10.5)];
        [path lineToPoint:NSMakePoint(13.5, 17.5)];
        [path lineToPoint:NSMakePoint(6.5, 10.5)];
        [path lineToPoint:NSMakePoint(9.5, 10.5)];
        [path closePath];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarLastPage, YES, 26.0, 30.0,
        translate(-0.5, 5.0);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(9.5, 14.5)];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(9.5, 16.5) toPoint:NSMakePoint(17.5, 16.5) radius:1.0];
        [path appendBezierPathWithArcFromPoint:NSMakePoint(17.5, 16.5) toPoint:NSMakePoint(17.5, 9.5) radius:1.0];
        [path lineToPoint:NSMakePoint(17.5, 14.5)];
        [path closePath];
        [path moveToPoint:NSMakePoint(9.5, 12.5)];
        [path lineToPoint:NSMakePoint(17.5, 12.5)];
        [path lineToPoint:NSMakePoint(17.5, 9.5)];
        [path lineToPoint:NSMakePoint(20.5, 9.5)];
        [path lineToPoint:NSMakePoint(13.5, 2.5)];
        [path lineToPoint:NSMakePoint(6.5, 9.5)];
        [path lineToPoint:NSMakePoint(9.5, 9.5)];
        [path closePath];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarZoomIn, YES, 26.0, 30.0,
        translate(-0.5, 6.0);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect:NSMakeRect(6.5, 5.5, 10.0, 10.0)];
        [path moveToPoint:NSMakePoint(15.0, 7.0)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path moveToPoint:NSMakePoint(9.0, 10.5)];
        [path lineToPoint:NSMakePoint(14.0, 10.5)];
        [path moveToPoint:NSMakePoint(11.5, 8.0)];
        [path lineToPoint:NSMakePoint(11.5, 13.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarZoomOut, YES, 26.0, 30.0,
        translate(-0.5, 6.0);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect:NSMakeRect(6.5, 5.5, 10.0, 10.0)];
        [path moveToPoint:NSMakePoint(15.0, 7.0)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path moveToPoint:NSMakePoint(9.0, 10.5)];
        [path lineToPoint:NSMakePoint(14.0, 10.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarZoomActual, YES, 26.0, 30.0,
        translate(-0.5, 6.0);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect:NSMakeRect(6.5, 5.5, 10.0, 10.0)];
        [path moveToPoint:NSMakePoint(15.0, 7.0)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path moveToPoint:NSMakePoint(9.0, 9.5)];
        [path lineToPoint:NSMakePoint(14.0, 9.5)];
        [path moveToPoint:NSMakePoint(9.0, 11.5)];
        [path lineToPoint:NSMakePoint(14.0, 11.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarZoomToSelection, YES, 26.0, 30.0,
        translate(-0.5, 6.0);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(5.5, 13.0)];
        [path lineToPoint:NSMakePoint(5.5, 15.5)];
        [path lineToPoint:NSMakePoint(9.0, 15.5)];
        [path moveToPoint:NSMakePoint(11.0, 15.5)];
        [path lineToPoint:NSMakePoint(16.0, 15.5)];
        [path moveToPoint:NSMakePoint(18.0, 15.5)];
        [path lineToPoint:NSMakePoint(21.5, 15.5)];
        [path lineToPoint:NSMakePoint(21.5, 13.0)];
        [path moveToPoint:NSMakePoint(21.5, 11.0)];
        [path lineToPoint:NSMakePoint(21.5, 8.0)];
        [path moveToPoint:NSMakePoint(21.5, 6.0)];
        [path lineToPoint:NSMakePoint(21.5, 3.5)];
        [path lineToPoint:NSMakePoint(18.0, 3.5)];
        [path moveToPoint:NSMakePoint(16.0, 3.5)];
        [path lineToPoint:NSMakePoint(11.0, 3.5)];
        [path moveToPoint:NSMakePoint(9.0, 3.5)];
        [path lineToPoint:NSMakePoint(5.5, 3.5)];
        [path lineToPoint:NSMakePoint(5.5, 6.0)];
        [path moveToPoint:NSMakePoint(5.5, 8.0)];
        [path lineToPoint:NSMakePoint(5.5, 11.0)];
        [path appendBezierPathWithOvalInRect:NSMakeRect(8.5, 5.5, 8.0, 8.0)];
        [path moveToPoint:NSMakePoint(15.5, 6.5)];
        [path lineToPoint:NSMakePoint(20.0, 2.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarTextTool, YES, 26.0, 30.0,
        translate(-0.5, 5.5);
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:12.0] ?: [NSFont systemFontOfSize:12.0];
        NSGlyph glyph = [font glyphWithName:@"A"];
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(7.5, 3.5, 12.0, 12.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(13.5 - NSMidX([font boundingRectForGlyph:glyph]), 5.0)];
        [path appendBezierPathWithGlyph:glyph inFont:font];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarMoveTool, YES, 26.0, 30.0,
        translate(-0.5, 5.5);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(10.5, 3.0)];
        [path curveToPoint:NSMakePoint(8.0, 7.0) controlPoint1:NSMakePoint(10.5, 4.5) controlPoint2:NSMakePoint(10.5, 4.5)];
        [path curveToPoint:NSMakePoint(6.5, 11.0) controlPoint1:NSMakePoint(5.5, 9.5) controlPoint2:NSMakePoint(5.5, 10.0)];
        [path curveToPoint:NSMakePoint(10.0, 9.5) controlPoint1:NSMakePoint(7.5, 12.0) controlPoint2:NSMakePoint(7.5, 12.0)];
        [path curveToPoint:NSMakePoint(9.5, 15.5) controlPoint1:NSMakePoint(7.5, 14.0) controlPoint2:NSMakePoint(7.0, 15.5)];
        [path curveToPoint:NSMakePoint(11.5, 11.5) controlPoint1:NSMakePoint(10.5, 15.5) controlPoint2:NSMakePoint(10.5, 15.5)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(13.0, 15.5) radius:1.5 startAngle:180.0 endAngle:0.0 clockwise:YES];
        [path moveToPoint:NSMakePoint(14.5, 11.0)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(16.0, 14.5) radius:1.5 startAngle:180.0 endAngle:0.0 clockwise:YES];
        [path lineToPoint:NSMakePoint(17.5, 12.5)];
        [path moveToPoint:NSMakePoint(17.5, 10.5)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(19.0, 12.5) radius:1.5 startAngle:180.0 endAngle:0.0 clockwise:YES];
        [path curveToPoint:NSMakePoint(17.5, 3.0) controlPoint1:NSMakePoint(20.5, 8.5) controlPoint2:NSMakePoint(17.5, 7.0)];
        [path setLineJoinStyle:NSRoundLineJoinStyle];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarMagnifyTool, YES, 26.0, 30.0,
        translate(-0.5, 5.5);
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(8.5, 13.5)];
        [path lineToPoint:NSMakePoint(8.5, 11.5)];
        [path halfEllipseFromPoint:NSMakePoint(13.5, 9.5) toPoint:NSMakePoint(18.5, 11.5)];
        [path lineToPoint:NSMakePoint(18.5, 13.5)];
        [path halfEllipseFromPoint:NSMakePoint(13.5, 11.5) toPoint:NSMakePoint(8.5, 13.5)];
        [path fill];
        [path halfEllipseFromPoint:NSMakePoint(13.5, 15.5) toPoint:NSMakePoint(18.5, 13.5)];
        [path moveToPoint:NSMakePoint(9.5, 10.5)];
        [path curveToPoint:NSMakePoint(7.5, 6.0) controlPoint1:NSMakePoint(8.0, 9.0) controlPoint2:NSMakePoint(7.5, 7.5)];
        [path halfEllipseFromPoint:NSMakePoint(13.5, 3.5) toPoint:NSMakePoint(19.5, 6.0)];
        [path curveToPoint:NSMakePoint(17.5, 10.5) controlPoint1:NSMakePoint(19.5, 7.5) controlPoint2:NSMakePoint(19.0, 9.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarSelectTool, YES, 26.0, 30.0,
        translate(-0.5, 5.5);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(7.5, 13.0)];
        [path lineToPoint:NSMakePoint(7.5, 15.5)];
        [path lineToPoint:NSMakePoint(10.0, 15.5)];
        [path moveToPoint:NSMakePoint(12.0, 15.5)];
        [path lineToPoint:NSMakePoint(15.0, 15.5)];
        [path moveToPoint:NSMakePoint(17.0, 15.5)];
        [path lineToPoint:NSMakePoint(19.5, 15.5)];
        [path lineToPoint:NSMakePoint(19.5, 13.0)];
        [path moveToPoint:NSMakePoint(19.5, 11.0)];
        [path lineToPoint:NSMakePoint(19.5, 8.0)];
        [path moveToPoint:NSMakePoint(19.5, 6.0)];
        [path lineToPoint:NSMakePoint(19.5, 3.5)];
        [path lineToPoint:NSMakePoint(17.0, 3.5)];
        [path moveToPoint:NSMakePoint(15.0, 3.5)];
        [path lineToPoint:NSMakePoint(12.0, 3.5)];
        [path moveToPoint:NSMakePoint(10.0, 3.5)];
        [path lineToPoint:NSMakePoint(7.5, 3.5)];
        [path lineToPoint:NSMakePoint(7.5, 6.0)];
        [path moveToPoint:NSMakePoint(7.5, 8.0)];
        [path lineToPoint:NSMakePoint(7.5, 11.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarSnapshotTool, YES, 26.0, 30.0,
        translate(-0.5, 5.5);
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(6.0, 4.0, 15.0, 10.0)];
        [path appendBezierPathWithOvalInRect:NSMakeRect(10.5, 10.0, 6.0, 6.0)];
        [path fill];
        [NSGraphicsContext saveGraphicsState];
        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositingOperationClear];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(9.8, 5.8, 7.4, 7.4)] stroke];
        path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(13.5, 9.5) radius:1.8 startAngle:45.0 endAngle:225.0];
        [path closePath];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarNewSeparator, YES, 28.0, 30.0,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(20.5, 18.25)];
        [path lineToPoint:NSMakePoint(28.0, 18.25)];
        [path moveToPoint:NSMakePoint(24.25, 14.5)];
        [path lineToPoint:NSMakePoint(24.25, 22.0)];
        [path setLineWidth:1.5];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(1.0, 12.0)];
        [path lineToPoint:NSMakePoint(27.0, 12.0)];
        [path setLineWidth:2.0];
        [[NSColor colorWithGenericGamma22White:0.0 alpha:0.8] setStroke];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarRefresh, YES, 19.0, 30.0,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(9.5, 14.75) radius:8.2 startAngle:0.0 endAngle:90.0 clockwise:YES];
        [path setLineWidth:1.3];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(8.5, 26.0)];
        [path lineToPoint:NSMakePoint(14.5, 22.5)];
        [path lineToPoint:NSMakePoint(8.5, 19.0)];
        [path closePath];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameTouchBarStopProgress, YES, 19.0, 30.0,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(1.0, 6.5)];
        [path lineToPoint:NSMakePoint(18.0, 23.5)];
        [path moveToPoint:NSMakePoint(18.0, 6.5)];
        [path lineToPoint:NSMakePoint(1.0, 23.5)];
        [path setLineWidth:2.0];
        [path stroke];
    );
    
    
#define MAKE_NOTE_TOUCHBAR_IMAGES(name) \
    MAKE_IMAGE(SKImageNameTouchBar ## name ## Note, YES, 26.0, 30.0, \
        translate(1.5, 5.0); \
        draw ## name ## Note(); \
        ); \
    MAKE_IMAGE(SKImageNameTouchBarAdd ## name ## Note, YES, 28.0, 30.0, \
        translate(1.5, 5.0); \
        draw ## name ## Note(); \
        translate(4.5, 0.0); \
        drawAddBadge(); \
        ); \
    MAKE_IMAGE(SKImageNameTouchBar ## name ## NotePopover, YES, 36.0, 30.0, \
        drawPopoverBadge(); \
        translate(5.5, 5.0); \
        draw ## name ## Note(); \
        );
    
    APPLY_NOTE_TYPES(MAKE_NOTE_TOUCHBAR_IMAGES);
}

+ (void)makeColoredToolbarImages {

    MAKE_IMAGE(SKImageNameToolbarColors, NO, 27.0, 20.0,
        [[NSImage imageNamed:NSImageNameColorPanel] drawInRect:NSMakeRect(4.0, 1.0, 19.0, 19.0) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
    );
    
    MAKE_IMAGE(SKImageNameGeneralPreferences, NO, 32.0, 32.0,
        NSImage *generalImage = [NSImage imageNamed:NSImageNamePreferencesGeneral];
        [generalImage drawInRect:NSMakeRect(0.0, 0.0, 32.0, 32.0) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
    );
    
    MAKE_IMAGE(SKImageNameDisplayPreferences, NO, 32.0, 32.0,
        NSImage *fontImage = [NSImage imageNamed:NSImageNameFontPanel];
        NSImage *colorImage = [NSImage imageNamed:NSImageNameColorPanel];
        NSRectFill(NSMakeRect(0.0, 0.0, 21.0, 29.0));
        [fontImage drawInRect:NSMakeRect(-4.0, 0.0, 29.0, 29.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationAtop fraction:1.0];
        [colorImage drawInRect:NSMakeRect(0.0, 0.0, 32.0, 32.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationOver fraction:1.0];
    );
    
    MAKE_IMAGE(SKImageNameNotesPreferences, NO, 32.0, 32.0, 
        NSImage *clippingImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kClippingTextType)];
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithSRGBRed:1.0 green:0.939 blue:0.495 alpha:1.0] endingColor:[NSColor colorWithSRGBRed:1.0 green:0.976 blue:0.810 alpha:1.0]];
        [[NSColor blackColor] setFill];
        [NSBezierPath fillRect:NSMakeRect(2.0, 0.0, 28.0, 32.0)];
        [clippingImage drawInRect:NSMakeRect(2.0, 0.0, 28.0, 32.0) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositingOperationMultiply];
        [gradient drawInRect:NSMakeRect(2.0, 0.0, 28.0, 32.0) angle:90.0];
        [clippingImage drawInRect:NSMakeRect(2.0, 0.0, 28.0, 32.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationAtop fraction:1.0];
    );
    
    MAKE_IMAGE(SKImageNameSyncPreferences, NO, 32.0, 32.0,
        NSImage *refreshImage = [NSImage imageNamed:NSImageNameRefreshTemplate];
        NSImage *genericDocImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericDocumentIcon)];
        [[NSColor colorWithSRGBRed:0.3 green:0.45 blue:0.65 alpha:1.0] set];
        NSRectFill(NSMakeRect(11.0, 10.0, 10.0, 12.0));
        [refreshImage drawInRect:NSMakeRect(11.0, 10.0, 10.0, 12.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationAtop fraction:1.0];
        [genericDocImage drawInRect:NSMakeRect(0.0, 0.0, 32.0, 32.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationOver fraction:1.0];
    );
}

+ (void)makeNoteImages {
    
#define MAKE_NOTE_IMAGE(name) \
    MAKE_IMAGE(SKImageName ## name ## Note, YES, 21.0, 19.0, \
        draw ## name ## Note(); \
    )
    
    APPLY_NOTE_TYPES(MAKE_NOTE_IMAGE);
    
    MAKE_IMAGE(SKImageNameWidgetNote, YES, 21.0, 19.0,
        [[NSColor blackColor] setStroke];
        [NSBezierPath strokeRect:NSMakeRect(1.5, 2.5, 16.0, 10.0)];
        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositingOperationCopy];
        drawTextNote();
    );
    
    [[self imageNamed:SKImageNameTextNote] setAccessibilityDescription:[SKNFreeTextString typeName]];
    [[self imageNamed:SKImageNameAnchoredNote] setAccessibilityDescription:[SKNNoteString typeName]];
    [[self imageNamed:SKImageNameCircleNote] setAccessibilityDescription:[SKNCircleString typeName]];
    [[self imageNamed:SKImageNameSquareNote] setAccessibilityDescription:[SKNSquareString typeName]];
    [[self imageNamed:SKImageNameHighlightNote] setAccessibilityDescription:[SKNHighlightString typeName]];
    [[self imageNamed:SKImageNameUnderlineNote] setAccessibilityDescription:[SKNUnderlineString typeName]];
    [[self imageNamed:SKImageNameStrikeOutNote] setAccessibilityDescription:[SKNStrikeOutString typeName]];
    [[self imageNamed:SKImageNameLineNote] setAccessibilityDescription:[SKNLineString typeName]];
    [[self imageNamed:SKImageNameInkNote] setAccessibilityDescription:[SKNInkString typeName]];
    [[self imageNamed:SKImageNameWidgetNote] setAccessibilityDescription:[SKNWidgetString typeName]];
}

+ (void)makeAdornImages {
    
    MAKE_IMAGE(SKImageNameOutlineViewAdorn, YES, 25.0, 14.0,
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(7.0, 2.5)];
        [path lineToPoint:NSMakePoint(18.0, 2.5)];
        [path moveToPoint:NSMakePoint(7.0, 5.5)];
        [path lineToPoint:NSMakePoint(18.0, 5.5)];
        [path moveToPoint:NSMakePoint(7.0, 8.5)];
        [path lineToPoint:NSMakePoint(18.0, 8.5)];
        [path moveToPoint:NSMakePoint(7.0, 11.5)];
        [path lineToPoint:NSMakePoint(18.0, 11.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameThumbnailViewAdorn, YES, 25.0, 14.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRect:NSMakeRect(10.5, 1.5, 4.0, 4.0)];
        [path appendBezierPathWithRect:NSMakeRect(10.5, 8.5, 4.0, 4.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameNoteViewAdorn, YES, 25.0, 14.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(13.0, 3.5)];
        [path lineToPoint:NSMakePoint(18.0, 3.5)];
        [path moveToPoint:NSMakePoint(13.0, 10.5)];
        [path lineToPoint:NSMakePoint(18.0, 10.5)];
        [path moveToPoint:NSMakePoint(10.0, 1.5)];
        [path lineToPoint:NSMakePoint(7.5, 1.5)];
        [path lineToPoint:NSMakePoint(7.5, 5.5)];
        [path lineToPoint:NSMakePoint(11.5, 5.5)];
        [path lineToPoint:NSMakePoint(11.5, 3.0)];
        [path closePath];
        [path moveToPoint:NSMakePoint(10.5, 1.5)];
        [path lineToPoint:NSMakePoint(10.5, 2.5)];
        [path lineToPoint:NSMakePoint(11.5, 2.5)];
        [path moveToPoint:NSMakePoint(10.0, 8.5)];
        [path lineToPoint:NSMakePoint(7.5, 8.5)];
        [path lineToPoint:NSMakePoint(7.5, 12.5)];
        [path lineToPoint:NSMakePoint(11.5, 12.5)];
        [path lineToPoint:NSMakePoint(11.5, 10.0)];
        [path closePath];
        [path moveToPoint:NSMakePoint(10.5, 8.5)];
        [path lineToPoint:NSMakePoint(10.5, 9.5)];
        [path lineToPoint:NSMakePoint(11.5, 9.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameSnapshotViewAdorn, YES, 25.0, 14.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRect:NSMakeRect(7.5, 1.5, 10.0, 4.0)];
        [path appendBezierPathWithRect:NSMakeRect(7.5, 8.5, 10.0, 4.0)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameFindViewAdorn, YES, 25.0, 14.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(7.0, 2.5)];
        [path lineToPoint:NSMakePoint(9.0, 2.5)];
        [path moveToPoint:NSMakePoint(7.0, 5.5)];
        [path lineToPoint:NSMakePoint(9.0, 5.5)];
        [path moveToPoint:NSMakePoint(7.0, 8.5)];
        [path lineToPoint:NSMakePoint(9.0, 8.5)];
        [path moveToPoint:NSMakePoint(7.0, 11.5)];
        [path lineToPoint:NSMakePoint(9.0, 11.5)];
        [path moveToPoint:NSMakePoint(10.0, 2.5)];
        [path lineToPoint:NSMakePoint(18.0, 2.5)];
        [path moveToPoint:NSMakePoint(10.0, 5.5)];
        [path lineToPoint:NSMakePoint(18.0, 5.5)];
        [path moveToPoint:NSMakePoint(10.0, 8.5)];
        [path lineToPoint:NSMakePoint(18.0, 8.5)];
        [path moveToPoint:NSMakePoint(10.0, 11.5)];
        [path lineToPoint:NSMakePoint(18.0, 11.5)];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameGroupedFindViewAdorn, YES, 25.0, 14.0, 
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(7.0, 3.0)];
        [path lineToPoint:NSMakePoint(12.0, 3.0)];
        [path moveToPoint:NSMakePoint(7.0, 7.0)];
        [path lineToPoint:NSMakePoint(16.0, 7.0)];
        [path moveToPoint:NSMakePoint(7.0, 11.0)];
        [path lineToPoint:NSMakePoint(18.0, 11.0)];
        [path setLineWidth:2.0];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTextToolAdorn, YES, 12.0, 12.0,
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:11.0] ?: [NSFont systemFontOfSize:11.0];
        NSGlyph glyph = [font glyphWithName:@"A"];
        [[NSColor blackColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(0.5, 0.5, 11.0, 11.0)];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(6.0 - NSMidX([font boundingRectForGlyph:glyph]), 2.0)];
        [path appendBezierPathWithGlyph:glyph inFont:font];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameInkToolAdorn, YES, 30.0, 24.0,
        NSAffineTransform *t = [NSAffineTransform transform];
        [t translateXBy:0.0 yBy:2.5];
        [t concat];
        drawMenuBadge();
        t = [NSAffineTransform transform];
        [t translateXBy:1.5 yBy:3.0];
        [t concat];
        drawTextNote();
        t = [NSAffineTransform transform];
        [t rotateByDegrees:-45.0];
        [t translateXBy:-4 yBy:-2];
        [t concat];
        drawInkNote();
    );
    
}

+ (void)makeTextAlignImages {
    
    MAKE_IMAGE(SKImageNameTextAlignLeft, YES, 16.0, 11.0,
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(1.0, 1.5)];
        [path lineToPoint:NSMakePoint(15.0, 1.5)];
        [path moveToPoint:NSMakePoint(1.0, 3.5)];
        [path lineToPoint:NSMakePoint(12.0, 3.5)];
        [path moveToPoint:NSMakePoint(1.0, 5.5)];
        [path lineToPoint:NSMakePoint(14.0, 5.5)];
        [path moveToPoint:NSMakePoint(1.0, 7.5)];
        [path lineToPoint:NSMakePoint(11.0, 7.5)];
        [path moveToPoint:NSMakePoint(1.0, 9.5)];
        [path lineToPoint:NSMakePoint(15.0, 9.5)];
        [path setLineWidth:1.0];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTextAlignCenter, YES, 16.0, 11.0,
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(1.0, 1.5)];
        [path lineToPoint:NSMakePoint(15.0, 1.5)];
        [path moveToPoint:NSMakePoint(4.0, 3.5)];
        [path lineToPoint:NSMakePoint(12.0, 3.5)];
        [path moveToPoint:NSMakePoint(2.0, 5.5)];
        [path lineToPoint:NSMakePoint(14.0, 5.5)];
        [path moveToPoint:NSMakePoint(5.0, 7.5)];
        [path lineToPoint:NSMakePoint(11.0, 7.5)];
        [path moveToPoint:NSMakePoint(1.0, 9.5)];
        [path lineToPoint:NSMakePoint(15.0, 9.5)];
        [path setLineWidth:1.0];
        [path stroke];
    );
    
    MAKE_IMAGE(SKImageNameTextAlignRight, YES, 16.0, 11.0,
        [[NSColor blackColor] setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(1.0, 1.5)];
        [path lineToPoint:NSMakePoint(15.0, 1.5)];
        [path moveToPoint:NSMakePoint(4.0, 3.5)];
        [path lineToPoint:NSMakePoint(15.0, 3.5)];
        [path moveToPoint:NSMakePoint(2.0, 5.5)];
        [path lineToPoint:NSMakePoint(15.0, 5.5)];
        [path moveToPoint:NSMakePoint(5.0, 7.5)];
        [path lineToPoint:NSMakePoint(15.0, 7.5)];
        [path moveToPoint:NSMakePoint(1.0, 9.5)];
        [path lineToPoint:NSMakePoint(15.0, 9.5)];
        [path setLineWidth:1.0];
        [path stroke];
    );
    
    [[self imageNamed:SKImageNameTextAlignLeft] setAccessibilityDescription:NSLocalizedString(@"align left", @"Accessibility description")];
    [[self imageNamed:SKImageNameTextAlignCenter] setAccessibilityDescription:NSLocalizedString(@"center", @"Accessibility description")];
    [[self imageNamed:SKImageNameTextAlignRight] setAccessibilityDescription:NSLocalizedString(@"align right", @"Accessibility description")];
}

+ (void)makeCursorImages {
    
    MAKE_VECTOR_IMAGE(SKImageNameResizeDiagonal45Cursor, NO, 16.0, 16.0,
        [[NSGraphicsContext currentContext] setShouldAntialias:NO];
        [[NSColor whiteColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(2.0, 2.0)];
        [path lineToPoint:NSMakePoint(9.5, 2.0)];
        [path lineToPoint:NSMakePoint(7.0, 4.5)];
        [path lineToPoint:NSMakePoint(8.0, 5.5)];
        [path lineToPoint:NSMakePoint(12.5, 1.0)];
        [path lineToPoint:NSMakePoint(15.0, 3.5)];
        [path lineToPoint:NSMakePoint(10.5, 8.0)];
        [path lineToPoint:NSMakePoint(11.5, 9.0)];
        [path lineToPoint:NSMakePoint(14.0, 6.5)];
        [path lineToPoint:NSMakePoint(14.0, 14.0)];
        [path lineToPoint:NSMakePoint(6.5, 14.0)];
        [path lineToPoint:NSMakePoint(9.0, 11.5)];
        [path lineToPoint:NSMakePoint(8.0, 10.5)];
        [path lineToPoint:NSMakePoint(3.5, 15.0)];
        [path lineToPoint:NSMakePoint(1.0, 12.5)];
        [path lineToPoint:NSMakePoint(5.5, 8.0)];
        [path lineToPoint:NSMakePoint(4.5, 7.0)];
        [path lineToPoint:NSMakePoint(2.0, 9.5)];
        [path closePath];
        [NSGraphicsContext saveGraphicsState];
        [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:1.0 yOffset:-1.0];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
        [[NSColor blackColor] setFill];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(3.0, 3.0)];
        [path lineToPoint:NSMakePoint(7.0, 3.0)];
        [path lineToPoint:NSMakePoint(5.5, 4.5)];
        [path lineToPoint:NSMakePoint(8.0, 7.0)];
        [path lineToPoint:NSMakePoint(12.5, 2.5)];
        [path lineToPoint:NSMakePoint(13.5, 3.5)];
        [path lineToPoint:NSMakePoint(9.0, 8.0)];
        [path lineToPoint:NSMakePoint(11.5, 10.5)];
        [path lineToPoint:NSMakePoint(13.0, 9.0)];
        [path lineToPoint:NSMakePoint(13.0, 13.0)];
        [path lineToPoint:NSMakePoint(9.0, 13.0)];
        [path lineToPoint:NSMakePoint(10.5, 11.5)];
        [path lineToPoint:NSMakePoint(8.0, 9.0)];
        [path lineToPoint:NSMakePoint(3.5, 13.5)];
        [path lineToPoint:NSMakePoint(2.5, 12.5)];
        [path lineToPoint:NSMakePoint(7.0, 8.0)];
        [path lineToPoint:NSMakePoint(4.5, 5.5)];
        [path lineToPoint:NSMakePoint(3.0, 7.0)];
        [path closePath];
        [path fill];
    );
    
    MAKE_VECTOR_IMAGE(SKImageNameResizeDiagonal135Cursor, NO, 16.0, 16.0,
        [[NSGraphicsContext currentContext] setShouldAntialias:NO];
        [[NSColor whiteColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(14.0, 2.0)];
        [path lineToPoint:NSMakePoint(14.0, 9.5)];
        [path lineToPoint:NSMakePoint(11.5, 7.0)];
        [path lineToPoint:NSMakePoint(10.5, 8.0)];
        [path lineToPoint:NSMakePoint(15.0, 12.5)];
        [path lineToPoint:NSMakePoint(12.5, 15.0)];
        [path lineToPoint:NSMakePoint(8.0, 10.5)];
        [path lineToPoint:NSMakePoint(7.0, 11.5)];
        [path lineToPoint:NSMakePoint(9.5, 14.0)];
        [path lineToPoint:NSMakePoint(2.0, 14.0)];
        [path lineToPoint:NSMakePoint(2.0, 6.5)];
        [path lineToPoint:NSMakePoint(4.5, 9.0)];
        [path lineToPoint:NSMakePoint(5.5, 8.0)];
        [path lineToPoint:NSMakePoint(1.0, 3.5)];
        [path lineToPoint:NSMakePoint(3.5, 1.0)];
        [path lineToPoint:NSMakePoint(8.0, 5.5)];
        [path lineToPoint:NSMakePoint(9.0, 4.5)];
        [path lineToPoint:NSMakePoint(6.5, 2.0)];
        [path closePath];
        [NSGraphicsContext saveGraphicsState];
        [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:1.0 yOffset:-1.0];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
        [[NSColor blackColor] setFill];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(13.0, 3.0)];
        [path lineToPoint:NSMakePoint(13.0, 7.0)];
        [path lineToPoint:NSMakePoint(11.5, 5.5)];
        [path lineToPoint:NSMakePoint(9.0, 8.0)];
        [path lineToPoint:NSMakePoint(13.5, 12.5)];
        [path lineToPoint:NSMakePoint(12.5, 13.5)];
        [path lineToPoint:NSMakePoint(8.0, 9.0)];
        [path lineToPoint:NSMakePoint(5.5, 11.5)];
        [path lineToPoint:NSMakePoint(7.0, 13.0)];
        [path lineToPoint:NSMakePoint(3.0, 13.0)];
        [path lineToPoint:NSMakePoint(3.0, 9.0)];
        [path lineToPoint:NSMakePoint(4.5, 10.5)];
        [path lineToPoint:NSMakePoint(7.0, 8.0)];
        [path lineToPoint:NSMakePoint(2.5, 3.5)];
        [path lineToPoint:NSMakePoint(3.5, 2.5)];
        [path lineToPoint:NSMakePoint(8.0, 7.0)];
        [path lineToPoint:NSMakePoint(10.5, 4.5)];
        [path lineToPoint:NSMakePoint(9.0, 3.0)];
        [path closePath];
        [path fill];
    );
    
    MAKE_VECTOR_IMAGE(SKImageNameZoomInCursor, NO, 18.0, 18.0,
        [[NSColor whiteColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(1.0, 5.0, 13.0, 13.0)];
        [path moveToPoint:NSMakePoint(14.5, 1.5)];
        [path lineToPoint:NSMakePoint(17.5, 4.5)];
        [path lineToPoint:NSMakePoint(12.5, 9.5)];
        [path lineToPoint:NSMakePoint(9.5, 6.5)];
        [path closePath];
        [NSGraphicsContext saveGraphicsState];
        [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:1.0 yOffset:-1.0];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
        [[NSColor blackColor] setStroke];
        path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(3.0, 7.0, 9.0, 9.0)];
        [path setLineWidth:2.0];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(15.5, 3.5)];
        [path lineToPoint:NSMakePoint(10.5, 8.5)];
        [path setLineWidth:2.5];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(5.0, 11.5)];
        [path lineToPoint:NSMakePoint(10.0, 11.5)];
        [path moveToPoint:NSMakePoint(7.5, 9.0)];
        [path lineToPoint:NSMakePoint(7.5, 14.0)];
        [path setLineWidth:1.0];
        [path stroke];
    );
    
    MAKE_VECTOR_IMAGE(SKImageNameZoomOutCursor, NO, 18.0, 18.0,
        [[NSColor whiteColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(1.0, 5.0, 13.0, 13.0)];
        [path moveToPoint:NSMakePoint(14.5, 1.5)];
        [path lineToPoint:NSMakePoint(17.5, 4.5)];
        [path lineToPoint:NSMakePoint(12.5, 9.5)];
        [path lineToPoint:NSMakePoint(9.5, 6.5)];
        [path closePath];
        [NSGraphicsContext saveGraphicsState];
        [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:1.0 yOffset:-1.0];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
        [[NSColor blackColor] setStroke];
        path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(3.0, 7.0, 9.0, 9.0)];
        [path setLineWidth:2.0];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(15.5, 3.5)];
        [path lineToPoint:NSMakePoint(10.5, 8.5)];
        [path setLineWidth:2.5];
        [path stroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(5.0, 11.5)];
        [path lineToPoint:NSMakePoint(10.0, 11.5)];
        [path setLineWidth:1.0];
        [path stroke];
    );
    
    MAKE_VECTOR_IMAGE(SKImageNameCameraCursor, NO, 18.0, 16.0,
        [[NSColor whiteColor] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(1.0, 2.0, 16.0, 11.0)];
        [path appendBezierPathWithOvalInRect:NSMakeRect(4.7, 6.7, 8.6, 8.6)];
        [NSGraphicsContext saveGraphicsState];
        [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:1.0 yOffset:-1.0];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
        [[NSColor blackColor] set];
        path = [NSBezierPath bezierPathWithRect:NSMakeRect(2.0, 3.0, 14.0, 9.0)];
        [path appendBezierPathWithOvalInRect:NSMakeRect(6.0, 8.0, 6.0, 6.0)];
        [path fill];
        [[NSColor whiteColor] set];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(5.3, 4.3, 7.4, 7.4)] stroke];
        path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(9.0, 8.0) radius:1.8 startAngle:45.0 endAngle:225.0];
        [path closePath];
        [path fill];
    );
    
    NSSize size = [[[NSCursor openHandCursor] image] size];
    
    if (NSEqualSizes(size, NSMakeSize(32.0, 32.0))) {
    
    MAKE_VECTOR_IMAGE(SKImageNameOpenHandBarCursor, NO, 32.0, 32.0,
        [[NSColor blackColor] setFill];
        [NSGraphicsContext saveGraphicsState];
        [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:1.0 yOffset:-1.0];
        [NSBezierPath fillRect:NSMakeRect(2.0, 14.0, 28.0, 4.0)];
        [NSGraphicsContext restoreGraphicsState];
        [[[NSCursor openHandCursor] image] drawInRect:NSMakeRect(0.0, 0.0, 32.0, 32.0) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    );
        
    MAKE_VECTOR_IMAGE(SKImageNameClosedHandBarCursor, NO, 32.0, 32.0,
        [[NSColor blackColor] setFill];
        [NSGraphicsContext saveGraphicsState];
        [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:1.0 yOffset:-1.0];
        [NSBezierPath fillRect:NSMakeRect(2.0, 14.0, 28.0, 4.0)];
        [NSGraphicsContext restoreGraphicsState];
        [[[NSCursor closedHandCursor] image] drawInRect:NSMakeRect(0.0, 0.0, 32.0, 32.0) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    );
    
    } else {
    
    MAKE_VECTOR_IMAGE(SKImageNameOpenHandBarCursor, NO, size.width, size.width,
        [[NSColor blackColor] setFill];
        [NSBezierPath fillRect:NSMakeRect(0.0, 9.0 / 16.0 * size.height, size.width, 3.0 / 16.0 * size.height)];
        [[[NSCursor openHandCursor] image] drawInRect:NSMakeRect(0.0, 0.0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    );
    
    MAKE_VECTOR_IMAGE(SKImageNameClosedHandBarCursor, NO, size.width, size.width,
        [[NSColor blackColor] setFill];
        [NSBezierPath fillRect:NSMakeRect(0.0, 6.0 / 16.0 * size.height, size.width, 3.0 / 16.0 * size.height)];
        [[[NSCursor closedHandCursor] image] drawInRect:NSMakeRect(0.0, 0.0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    );
    
    }
    
#define MAKE_NOTE_CURSOR_IMAGE(name) \
    MAKE_VECTOR_IMAGE(SKImageName ## name ## NoteCursor, NO, 24.0, 42.0, \
        drawArrowCursor(); \
        translate(2.0, 2.0); \
        draw ## name ## NoteBackground(); \
        draw ## name ## Note(); \
    )
    
    APPLY_NOTE_TYPES(MAKE_NOTE_CURSOR_IMAGE);
    
}

+ (void)makeRemoteStateImages {
    
    MAKE_IMAGE(SKImageNameRemoteStateResize, YES, 60.0, 60.0,
        NSPoint center = NSMakePoint(30.0, 30.0);
        NSRect rect = NSMakeRect(0.0, 0.0, 60.0, 60.0);
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rect, 20.0, 20.0) xRadius:3.0 yRadius:3.0];
        [path appendBezierPath:[NSBezierPath bezierPathWithRect:NSInsetRect(rect, 24.0, 24.0)]];
        
        NSBezierPath *arrow = [NSBezierPath bezierPath];
        [arrow moveToPoint:NSMakePoint(NSMinX(rect) + 10.0, NSMinY(rect) + 10.0)];
        [arrow relativeLineToPoint:NSMakePoint(6.0, 0.0)];
        [arrow relativeLineToPoint:NSMakePoint(-2.0, 2.0)];
        [arrow relativeLineToPoint:NSMakePoint(2.0, 2.0)];
        [arrow relativeLineToPoint:NSMakePoint(2.0, -2.0)];
        [arrow relativeLineToPoint:NSMakePoint(0.0, 6.0)];
        [arrow relativeLineToPoint:NSMakePoint(-6.0, 0.0)];
        [arrow relativeLineToPoint:NSMakePoint(2.0, -2.0)];
        [arrow relativeLineToPoint:NSMakePoint(-2.0, -2.0)];
        [arrow relativeLineToPoint:NSMakePoint(-2.0, 2.0)];
        [arrow closePath];
        
        NSAffineTransform *transform = [[NSAffineTransform alloc] init];
        [transform translateXBy:center.x yBy:center.y];
        [transform rotateByDegrees:90.0];
        [transform translateXBy:-center.x yBy:-center.y];
        [path appendBezierPath:arrow];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        
        arrow = [NSBezierPath bezierPath];
        [arrow moveToPoint:NSMakePoint(NSMinX(rect) + 5.0, NSMidY(rect))];
        [arrow relativeLineToPoint:NSMakePoint(10.0, 5.0)];
        [arrow relativeLineToPoint:NSMakePoint(0.0, -10.0)];
        [arrow closePath];
        [path appendBezierPath:arrow];
        [transform translateXBy:center.x yBy:center.y];
        [transform rotateByDegrees:90.0];
        [transform translateXBy:-center.x yBy:-center.y];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        
        [path setWindingRule:NSEvenOddWindingRule];
        
        [[NSColor colorWithGenericGamma22White:1.0 alpha:1.0] setFill];
        [path fill];
    );
    
    MAKE_IMAGE(SKImageNameRemoteStateScroll, YES, 60.0, 60.0,
        NSPoint center = NSMakePoint(30.0, 30.0);
        NSRect rect = NSMakeRect(0.0, 0.0, 60.0, 60.0);
        
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 8.0, 8.0)];
        [path appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 9.0, 9.0)]];
        [path appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 25.0, 25.0)]];
        
        NSBezierPath *arrow = [NSBezierPath bezierPath];
        [arrow moveToPoint:NSMakePoint(NSMidX(rect), NSMinY(rect) + 12.0)];
        [arrow relativeLineToPoint:NSMakePoint(7.0, 7.0)];
        [arrow relativeLineToPoint:NSMakePoint(-14.0, 0.0)];
        [arrow closePath];
        
        NSAffineTransform *transform = [[NSAffineTransform alloc] init];
        [transform translateXBy:center.x yBy:center.y];
        [transform rotateByDegrees:90.0];
        [transform translateXBy:-center.x yBy:-center.y];
        [path appendBezierPath:arrow];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        
        [path setWindingRule:NSEvenOddWindingRule];
        
        [[NSColor colorWithGenericGamma22White:1.0 alpha:1.0] setFill];
        [path fill];
    );
    
}

+ (void)makeImages {
    [self makeNoteImages];
    [self makeToolbarImages];
    [self makeColoredToolbarImages];
    [self makeTouchBarImages];
    [self makeAdornImages];
    [self makeTextAlignImages];
    [self makeCursorImages];
    [self makeRemoteStateImages];
}

@end


static void drawTextNote() {
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.75] setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(5.0, 5.0)];
    [path lineToPoint:NSMakePoint(9.0, 6.5)];
    [path halfEllipseFromPoint:NSMakePoint(8.25, 8.25) toPoint:NSMakePoint(6.5, 9.0)];
    [path closePath];
    [path moveToPoint:NSMakePoint(16.0, 13.0)];
    [path halfEllipseFromPoint:NSMakePoint(15.1, 15.1) toPoint:NSMakePoint(13.0, 16.0)];
    [path lineToPoint:NSMakePoint(7.0, 10.0)];
    [path halfEllipseFromPoint:NSMakePoint(9.1, 9.1) toPoint:NSMakePoint(10.0, 7.0)];
    [path closePath];
    [path fill];
}

static void drawAnchoredNote() {
    [[NSColor blackColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(12.0, 6.5)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(16.5, 6.5) toPoint:NSMakePoint(16.5, 15.5) radius:4.5];
    [path halfEllipseFromPoint:NSMakePoint(10.0, 15.5) toPoint:NSMakePoint(3.5, 11.0)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(3.5, 6.5) toPoint:NSMakePoint(16.5, 6.5) radius:4.5];
    [path lineToPoint:NSMakePoint(8.5, 4.5)];
    [path closePath];
    [path stroke];
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.333] setStroke];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(8.0, 11.5)];
    [path lineToPoint:NSMakePoint(12.0, 11.5)];
    [path moveToPoint:NSMakePoint(8.0, 10.5)];
    [path lineToPoint:NSMakePoint(11.0, 10.5)];
    [path stroke];
}

static void drawCircleNote() {
    [[NSColor blackColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(4.5, 4.5, 12.0, 11.0)];
    [path stroke];
}

static void drawSquareNote() {
    [[NSColor blackColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(4.5, 4.5, 12.0, 11.0)];
    [path stroke];
}

static void drawHighlightNote() {
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:14.0] ?: [NSFont systemFontOfSize:14.0];
    NSGlyph glyph = [font glyphWithName:@"H"];
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.25] setFill];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(3.0, 2.0, 15.0, 16.0)];
    [path fill];
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.75] setFill];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(10.5 - NSMidX([font boundingRectForGlyph:glyph]), 5.0)];
    [path appendBezierPathWithGlyph:glyph inFont:font];
    [path fill];
}

static void drawUnderlineNote() {
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:14.0] ?: [NSFont systemFontOfSize:14.0];
    NSGlyph glyph = [font glyphWithName:@"U"];
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.75] setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(10.5 - NSMidX([font boundingRectForGlyph:glyph]), 6.0)];
    [path appendBezierPathWithGlyph:glyph inFont:font];
    [path fill];
    [[NSColor blackColor] setStroke];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(2.0, 4.5)];
    [path lineToPoint:NSMakePoint(19.0, 4.5)];
    [path stroke];
}

static void drawStrikeOutNote() {
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:14.0] ?: [NSFont systemFontOfSize:14.0];
    NSGlyph glyph = [font glyphWithName:@"S"];
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.75] setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(10.5 - NSMidX([font boundingRectForGlyph:glyph]), 5.0)];
    [path appendBezierPathWithGlyph:glyph inFont:font];
    [path fill];
    [[NSColor blackColor] setStroke];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(2.0, 9.5)];
    [path lineToPoint:NSMakePoint(19.0, 9.5)];
    [path stroke];
}

static void drawLineNote() {
    [[NSColor blackColor] setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(3.0, 10.0)];
    [path lineToPoint:NSMakePoint(15.0, 10.0)];
    [path lineToPoint:NSMakePoint(15.0, 7.5)];
    [path lineToPoint:NSMakePoint(18.5, 10.5)];
    [path lineToPoint:NSMakePoint(15.0, 13.5)];
    [path lineToPoint:NSMakePoint(15.0, 11.0)];
    [path lineToPoint:NSMakePoint(3.0, 11.0)];
    [path closePath];
    [path fill];
}

static void drawInkNote() {
    [[NSColor blackColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(4.0, 9.0)];
    [path curveToPoint:NSMakePoint(10.5, 10.0) controlPoint1:NSMakePoint(10.0, 5.0) controlPoint2:NSMakePoint(13.0, 5.0)];
    [path curveToPoint:NSMakePoint(17.0, 11.0) controlPoint1:NSMakePoint(8.0, 15.0) controlPoint2:NSMakePoint(11.0, 15.0)];
    [path stroke];
}

static void drawTextNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(3.22, 3.22)];
    [path lineToPoint:NSMakePoint(10.1, 5.7)];
    [path lineToPoint:NSMakePoint(16.7, 12.3)];
    [path halfEllipseFromPoint:NSMakePoint(15.8, 15.8) toPoint:NSMakePoint(12.3, 16.7)];
    [path lineToPoint:NSMakePoint(5.7, 10.1)];
    [path closePath];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawAnchoredNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(12.15, 5.0)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(18.0, 5.0) toPoint:NSMakePoint(18.0, 15.5) radius:6.0];
    [path halfEllipseFromPoint:NSMakePoint(10.0, 17.0) toPoint:NSMakePoint(2.0, 11.0)];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(8.0, 11.0) radius:6.0 startAngle:180.0 endAngle:260.0];
    [path lineToPoint:NSMakePoint(7.6, 2.4)];
    [path closePath];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawCircleNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(4.5, 4.5, 12.0, 11.0)];
    [path setLineWidth:3.0];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawSquareNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(4.5, 4.5, 12.0, 11.0)];
    [path setLineWidth:3.0];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawHighlightNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setFill];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(2.0, 1.0, 17.0, 18.0)];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawUnderlineNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setStroke];
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:14.0] ?: [NSFont systemFontOfSize:14.0];
    NSGlyph glyph = [font glyphWithName:@"U"];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(10.5 - NSMidX([font boundingRectForGlyph:glyph]), 6.0)];
    [path appendBezierPathWithGlyph:glyph inFont:font];
    [path appendBezierPathWithRect:NSMakeRect(2.0, 4.0, 17.0, 1.0)];
    [path setLineWidth:2.0];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawStrikeOutNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setStroke];
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:14.0] ?: [NSFont systemFontOfSize:14.0];
    NSGlyph glyph = [font glyphWithName:@"S"];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(10.5 - NSMidX([font boundingRectForGlyph:glyph]), 5.0)];
    [path appendBezierPathWithGlyph:glyph inFont:font];
    [path appendBezierPathWithRect:NSMakeRect(2.0, 9.0, 17.0, 1.0)];
    [path setLineWidth:2.0];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawLineNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setFill];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(2.0, 9.0)];
    [path lineToPoint:NSMakePoint(14.0, 9.0)];
    [path lineToPoint:NSMakePoint(14.0, 5.5)];
    [path lineToPoint:NSMakePoint(20.5, 10.5)];
    [path lineToPoint:NSMakePoint(14.0, 15.5)];
    [path lineToPoint:NSMakePoint(14.0, 12.0)];
    [path lineToPoint:NSMakePoint(2.0, 12.0)];
    [path closePath];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawInkNoteBackground() {
    [NSGraphicsContext saveGraphicsState];
    [NSShadow setShadowWithWhite:0.0 alpha:0.33333 blurRadius:2.0 yOffset:-1.0];
    [[NSColor whiteColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(3.24, 9.52)];
    [path lineToPoint:NSMakePoint(4.0, 9.0)];
    [path curveToPoint:NSMakePoint(10.5, 10.0) controlPoint1:NSMakePoint(10.0, 5.0) controlPoint2:NSMakePoint(13.0, 5.0)];
    [path curveToPoint:NSMakePoint(17.0, 11.0) controlPoint1:NSMakePoint(8.0, 15.0) controlPoint2:NSMakePoint(11.0, 15.0)];
    [path lineToPoint:NSMakePoint(17.76, 10.48)];
    [path setLineWidth:3.0];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawMenuBadge() {
    NSBezierPath *arrowPath = [NSBezierPath bezierPath];
    [arrowPath moveToPoint:NSMakePoint(25.5, 10.5)];
    [arrowPath relativeLineToPoint:NSMakePoint(-2.0, -2.0)];
    [arrowPath relativeLineToPoint:NSMakePoint(-2.0, 2.0)];
    [[NSColor blackColor] setStroke];
    [arrowPath stroke];
}

static void drawAddBadge() {
    NSBezierPath *addPath = [NSBezierPath bezierPath];
    [addPath appendBezierPathWithRect:NSMakeRect(16.0, 4.0, 5.0, 1.0)];
    [addPath appendBezierPathWithRect:NSMakeRect(18.0, 2.0, 1.0, 5.0)];
    [NSGraphicsContext saveGraphicsState];
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositingOperationCopy];
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.6] setFill];
    [addPath fill];
    [NSGraphicsContext restoreGraphicsState];
}

static void drawPopoverBadge() {
    NSBezierPath *arrowPath = [NSBezierPath bezierPath];
    [arrowPath moveToPoint:NSMakePoint(32.0, 20.5)];
    [arrowPath relativeLineToPoint:NSMakePoint(3.0, -5.5)];
    [arrowPath relativeLineToPoint:NSMakePoint(-3.0, -5.5)];
    [arrowPath setLineWidth:1.5];
    [arrowPath setLineCapStyle:NSRoundLineCapStyle];
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.5] setStroke];
    [arrowPath stroke];
}

static inline void translate(CGFloat dx, CGFloat dy) {
    NSAffineTransform *t = [NSAffineTransform transform];
    [t translateXBy:dx yBy:dy];
    [t concat];
}

static inline void drawPageBackgroundInRect(NSRect rect) {
    [NSGraphicsContext saveGraphicsState];
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositingOperationCopy];
    [[NSColor colorWithGenericGamma22White:0.0 alpha:0.25] setFill];
    [NSBezierPath fillRect:rect];
    [NSGraphicsContext restoreGraphicsState];
}

static inline void drawArrowCursor() {
    NSImage *arrowCursor = [[NSCursor arrowCursor] image];
    [arrowCursor drawAtPoint:NSMakePoint(0.0, 42.0 - [arrowCursor size].height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
}

static void evaluateLaserPointer(void *info, const CGFloat *in, CGFloat *out) {
    static const CGFloat laserPointerRGB[21] = {1.0,      0.0,      0.0,
                                                1.0,      0.624406, 0.0,
                                                1.0,      0.719051, 0.0,
                                                0.0,      1.0,      0.0,
                                                0.0,      0.449970, 1.0,
                                                0.167576, 0.0,      1.0,
                                                0.338719, 0.0,      1.0};
    NSInteger i, offset = 3 * ((NSInteger)info % 7);
    for (i = 0; i < 3; i++)
        out[i] = laserPointerRGB[offset + i];
    CGFloat x = M_PI * in[0];
    if (x < 1.0) {
        for (i = 0; i < 3; i++)
            out[i] = 1.0 + x * x * (out[i] - 1.0);
    }
    out[3] = 0.5 + 0.5 * cos(x);
}
