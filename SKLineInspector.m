//
//  SKLineInspector.m
//  Skim
//
//  Created by Christiaan Hofman on 6/20/07.
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

#import "SKLineInspector.h"
#import "SKLineWell.h"
#import <SkimNotes/SkimNotes.h>
#import "NSSegmentedControl_SKExtensions.h"
#import "NSImage_SKExtensions.h"

NSString *SKLineInspectorLineAttributeDidChangeNotification = @"SKLineInspectorLineAttributeDidChangeNotification";

#define LINEWIDTH_KEY       @"lineWidth"
#define STYLE_KEY           @"style"
#define DASHPATTERN_KEY     @"dashPattern"
#define STARTLINESTYLE_KEY  @"startLineStyle"
#define ENDLINESTYLE_KEY    @"endLineStyle"
#define ACTION_KEY          @"action"

#define SKLineInspectorFrameAutosaveName @"SKLineInspector"

#define MAKE_IMAGE(control, segment, size, instructions) \
do { \
NSImage *image = [NSImage imageWithSize:size flipped:NO drawingHandler:^(NSRect rect){ \
instructions \
return YES; \
}]; \
[image setTemplate:YES]; \
[control setImage:image forSegment:segment]; \
} while (0)


@implementation SKLineInspector

@synthesize startLineStyleButton, endLineStyleButton, lineWell, lineWidth, style, dashPattern, startLineStyle, endLineStyle, currentLineChangeAction;

static SKLineInspector *sharedLineInspector = nil;

+ (SKLineInspector *)sharedLineInspector {
    if (sharedLineInspector == nil)
        sharedLineInspector = [[self alloc] init];
    return sharedLineInspector;
}

+ (BOOL)sharedLineInspectorExists {
    return sharedLineInspector != nil;
}

- (instancetype)init {
    if (sharedLineInspector) NSLog(@"Attempt to allocate second instance of %@", [self class]);
    self = [super initWithWindowNibName:@"LineInspector"];
    if (self) {
        style = kPDFBorderStyleSolid;
        lineWidth = 1.0;
        dashPattern = nil;
        startLineStyle = kPDFLineStyleNone;
        endLineStyle = kPDFLineStyleNone;
        currentLineChangeAction = SKNoLineChangeAction;
    }
    return self;
}

- (void)windowDidLoad {
    [lineWell setCanActivate:NO];
    [lineWell bind:SKLineWellLineWidthKey toObject:self withKeyPath:LINEWIDTH_KEY options:nil];
    [lineWell bind:SKLineWellStyleKey toObject:self withKeyPath:STYLE_KEY options:nil];
    [lineWell bind:SKLineWellDashPatternKey toObject:self withKeyPath:DASHPATTERN_KEY options:nil];
    [lineWell bind:SKLineWellStartLineStyleKey toObject:self withKeyPath:STARTLINESTYLE_KEY options:nil];
    [lineWell bind:SKLineWellEndLineStyleKey toObject:self withKeyPath:ENDLINESTYLE_KEY options:nil];
    
    [startLineStyleButton setHelp:NSLocalizedString(@"No start line style", @"Tool tip message") forSegment:kPDFLineStyleNone];
    [startLineStyleButton setHelp:NSLocalizedString(@"Square start line style", @"Tool tip message") forSegment:kPDFLineStyleSquare];
    [startLineStyleButton setHelp:NSLocalizedString(@"Circle start line style", @"Tool tip message") forSegment:kPDFLineStyleCircle];
    [startLineStyleButton setHelp:NSLocalizedString(@"Diamond start line style", @"Tool tip message") forSegment:kPDFLineStyleDiamond];
    [startLineStyleButton setHelp:NSLocalizedString(@"Open arrow start line style", @"Tool tip message") forSegment:kPDFLineStyleOpenArrow];
    [startLineStyleButton setHelp:NSLocalizedString(@"Closed arrow start line style", @"Tool tip message") forSegment:kPDFLineStyleClosedArrow];
    
    [endLineStyleButton setHelp:NSLocalizedString(@"No end line style", @"Tool tip message") forSegment:kPDFLineStyleNone];
    [endLineStyleButton setHelp:NSLocalizedString(@"Square end line style", @"Tool tip message") forSegment:kPDFLineStyleSquare];
    [endLineStyleButton setHelp:NSLocalizedString(@"Circle end line style", @"Tool tip message") forSegment:kPDFLineStyleCircle];
    [endLineStyleButton setHelp:NSLocalizedString(@"Diamond end line style", @"Tool tip message") forSegment:kPDFLineStyleDiamond];
    [endLineStyleButton setHelp:NSLocalizedString(@"Open arrow end line style", @"Tool tip message") forSegment:kPDFLineStyleOpenArrow];
    [endLineStyleButton setHelp:NSLocalizedString(@"Closed arrow end line style", @"Tool tip message") forSegment:kPDFLineStyleClosedArrow];
    
    [self setWindowFrameAutosaveName:SKLineInspectorFrameAutosaveName];
    
	NSSize size = NSMakeSize(24.0, 12.0);
    
    MAKE_IMAGE(startLineStyleButton, kPDFLineStyleNone, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(20.0, 6.0)];
        [path lineToPoint:NSMakePoint(8.0, 6.0)];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
	);
	
    MAKE_IMAGE(endLineStyleButton, kPDFLineStyleNone, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(4.0, 6.0)];
        [path lineToPoint:NSMakePoint(16.0, 6.0)];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
	);
	
    MAKE_IMAGE(startLineStyleButton, kPDFLineStyleSquare, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(20.0, 6.0)];
        [path lineToPoint:NSMakePoint(8.0, 6.0)];
        [path appendBezierPathWithRect:NSMakeRect(5.0, 3.0, 6.0, 6.0)];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
        return YES;
	);
    
    MAKE_IMAGE(endLineStyleButton, kPDFLineStyleSquare, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(4.0, 6.0)];
        [path lineToPoint:NSMakePoint(16.0, 6.0)];
        [path appendBezierPathWithRect:NSMakeRect(13.0, 3.0, 6.0, 6.0)];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
	);
	
    MAKE_IMAGE(startLineStyleButton, kPDFLineStyleCircle, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(20.0, 6.0)];
        [path lineToPoint:NSMakePoint(8.0, 6.0)];
        [path appendBezierPathWithOvalInRect:NSMakeRect(5.0, 3.0, 6.0, 6.0)];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
    );
	
    MAKE_IMAGE(endLineStyleButton, kPDFLineStyleCircle, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(4.0, 6.0)];
        [path lineToPoint:NSMakePoint(16.0, 6.0)];
        [path appendBezierPathWithOvalInRect:NSMakeRect(13.0, 3.0, 6.0, 6.0)];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
	);
	
    MAKE_IMAGE(startLineStyleButton, kPDFLineStyleDiamond, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(20.0, 6.0)];
        [path lineToPoint:NSMakePoint(8.0, 6.0)];
        [path moveToPoint:NSMakePoint(12.0, 6.0)];
        [path lineToPoint:NSMakePoint(8.0, 10.0)];
        [path lineToPoint:NSMakePoint(4.0, 6.0)];
        [path lineToPoint:NSMakePoint(8.0, 2.0)];
        [path closePath];
        [path setLineWidth:2.0];
        [path stroke];
    );
	
    MAKE_IMAGE(endLineStyleButton, kPDFLineStyleDiamond, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(4.0, 6.0)];
        [path lineToPoint:NSMakePoint(16.0, 6.0)];
        [path moveToPoint:NSMakePoint(12.0, 6.0)];
        [path lineToPoint:NSMakePoint(16.0, 10.0)];
        [path lineToPoint:NSMakePoint(20.0, 6.0)];
        [path lineToPoint:NSMakePoint(16.0, 2.0)];
        [path closePath];
        [path setLineWidth:2.0];
        [path stroke];
	);
	
    MAKE_IMAGE(startLineStyleButton, kPDFLineStyleOpenArrow, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(20.0, 6.0)];
        [path lineToPoint:NSMakePoint(8.0, 6.0)];
        [path moveToPoint:NSMakePoint(14.0, 3.0)];
        [path lineToPoint:NSMakePoint(8.0, 6.0)];
        [path lineToPoint:NSMakePoint(14.0, 9.0)];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
    );
	
    MAKE_IMAGE(endLineStyleButton, kPDFLineStyleOpenArrow, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(4.0, 6.0)];
        [path lineToPoint:NSMakePoint(16.0, 6.0)];
        [path moveToPoint:NSMakePoint(10.0, 3.0)];
        [path lineToPoint:NSMakePoint(16.0, 6.0)];
        [path lineToPoint:NSMakePoint(10.0, 9.0)];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
	);
	
    MAKE_IMAGE(startLineStyleButton, kPDFLineStyleClosedArrow, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(20.0, 6.0)];
        [path lineToPoint:NSMakePoint(8.0, 6.0)];
        [path moveToPoint:NSMakePoint(14.0, 3.0)];
        [path lineToPoint:NSMakePoint(8.0, 6.0)];
        [path lineToPoint:NSMakePoint(14.0, 9.0)];
        [path closePath];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
    );
	
    MAKE_IMAGE(endLineStyleButton, kPDFLineStyleClosedArrow, size,
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(4.0, 6.0)];
        [path lineToPoint:NSMakePoint(16.0, 6.0)];
        [path moveToPoint:NSMakePoint(10.0, 3.0)];
        [path lineToPoint:NSMakePoint(16.0, 6.0)];
        [path lineToPoint:NSMakePoint(10.0, 9.0)];
        [path closePath];
        [path setLineWidth:2.0];
        [[NSColor blackColor] setStroke];
        [path stroke];
	);
}

- (void)notifyChangeAction:(SKLineChangeAction)action {
    currentLineChangeAction = action;
    
    SEL selector = @selector(changeLineAttribute:);
    NSWindow *mainWindow = [NSApp mainWindow];
    NSResponder *responder = [mainWindow firstResponder];
    
    while (responder && [responder respondsToSelector:selector] == NO)
        responder = [responder nextResponder];
    
    [(id)responder changeLineAttribute:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SKLineInspectorLineAttributeDidChangeNotification object:self userInfo:@{ACTION_KEY:[NSNumber numberWithInteger:action]}];
    
    currentLineChangeAction = SKNoLineChangeAction;
}

#pragma mark Accessors

- (void)setLineWidth:(CGFloat)width {
    if (fabs(lineWidth - width) > 0.00001) {
        lineWidth = width;
        [self notifyChangeAction:SKLineChangeActionLineWidth];
    }
}

- (void)setStyle:(PDFBorderStyle)newStyle {
    if (newStyle != style) {
        style = newStyle;
        [self notifyChangeAction:SKLineChangeActionStyle];
    }
}

- (void)setDashPattern:(NSArray *)pattern {
    if ([pattern isEqualToArray:dashPattern] == NO && (pattern || dashPattern)) {
        dashPattern = [pattern copy];
        [self notifyChangeAction:SKLineChangeActionDashPattern];
        [self setStyle:[dashPattern count] > 0 ? kPDFBorderStyleDashed : kPDFBorderStyleSolid];
    }
}

- (void)setStartLineStyle:(PDFLineStyle)newStyle {
    if (newStyle != startLineStyle) {
        startLineStyle = newStyle;
        [self notifyChangeAction:SKLineChangeActionStartLineStyle];
    }
}

- (void)setEndLineStyle:(PDFLineStyle)newStyle {
    if (newStyle != endLineStyle) {
        endLineStyle = newStyle;
        [self notifyChangeAction:SKLineChangeActionEndLineStyle];
    }
}

- (void)setAnnotationStyle:(PDFAnnotation *)annotation {
    NSString *type = [annotation type];
    if ([type isEqualToString:SKNFreeTextString] || [type isEqualToString:SKNCircleString] || [type isEqualToString:SKNSquareString] || [type isEqualToString:SKNLineString] || [type isEqualToString:SKNInkString]) {
        [self setLineWidth:[annotation border] ? [[annotation border] lineWidth] : 0.0];
        [self setDashPattern:[[annotation border] dashPattern]];
        [self setStyle:[annotation border] ? [[annotation border] style] : 0];
    }
    if ([type isEqualToString:SKNLineString]) {
        [self setStartLineStyle:[annotation startLineStyle]];
        [self setEndLineStyle:[annotation endLineStyle]];
    }
}

- (void)setNilValueForKey:(NSString *)key {
    if ([key isEqualToString:LINEWIDTH_KEY]) {
        [self setValue:@0.0 forKey:key];
    } else if ([key isEqualToString:STYLE_KEY] || [key isEqualToString:STARTLINESTYLE_KEY] || [key isEqualToString:ENDLINESTYLE_KEY]) {
        [self setValue:@0 forKey:key];
    } else {
        [super setNilValueForKey:key];
    }
}

@end
