//
//  SKColorSwatch.h
//  Skim
//
//  Created by Christiaan Hofman on 7/4/07.
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

NS_ASSUME_NONNULL_BEGIN

extern NSString *SKColorSwatchColorsChangedNotification;

@class SKColorSwatchBackgroundView, SKColorSwatchItemView;

@interface SKColorSwatch : NSControl <NSDraggingSource, NSAccessibilityGroup> {
    NSMutableArray<NSColor *> *colors;
    NSMutableArray<SKColorSwatchItemView *> *itemViews;
    SKColorSwatchBackgroundView *backgroundView;
    CGFloat bezelHeight;
    
    NSInteger clickedIndex;
    NSInteger selectedIndex;
    NSInteger focusedIndex;
    NSInteger draggedIndex;
    
    SEL action;
    id target;
    
    BOOL autoResizes;
    BOOL selects;
    BOOL alternate;
}

@property (nonatomic, copy) NSArray<NSColor *> *colors;
@property (nonatomic, readonly) NSInteger clickedColorIndex;
@property (nonatomic, readonly) NSInteger selectedColorIndex;
@property (nonatomic, nullable, readonly) NSColor *color;
@property (nonatomic) BOOL autoResizes;
@property (nonatomic) BOOL selects;
@property (nonatomic, getter=isAlternate) BOOL alternate;

- (void)deactivate;

- (void)selectColorAtIndex:(NSInteger)idx;

- (void)setColor:(NSColor *)color atIndex:(NSInteger)idx;
- (void)insertColor:(NSColor *)color atIndex:(NSInteger)idx;
- (void)removeColorAtIndex:(NSInteger)idx;
- (void)moveColorAtIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx;

@end

NS_ASSUME_NONNULL_END
