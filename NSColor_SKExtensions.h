//
//  NSColor_SKExtensions.h
//  Skim
//
//  Created by Christiaan Hofman on 6/17/07.
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

enum {
    SKScriptingColorRed = 'Red ',
    SKScriptingColorGreen = 'Gren',
    SKScriptingColorBlue = 'Blue',
    SKScriptingColorYellow = 'Yelw',
    SKScriptingColorMagenta = 'Mgnt',
    SKScriptingColorCyan = 'Cyan',
    SKScriptingColorDarkRed = 'DRed',
    SKScriptingColorDarkGreen = 'DGrn',
    SKScriptingColorDarkBlue = 'DBlu',
    SKScriptingColorBanana = 'Bana',
    SKScriptingColorTurquoise = 'Turq',
    SKScriptingColorViolet = 'Viol',
    SKScriptingColorOrange = 'Orng',
    SKScriptingColorDeepPink = 'DpPk',
    SKScriptingColorSpringGreen = 'SprG',
    SKScriptingColorAqua = 'Aqua',
    SKScriptingColorLime = 'Lime',
    SKScriptingColorDarkViolet = 'DVio',
    SKScriptingColorPurple = 'Prpl',
    SKScriptingColorTeal = 'Teal',
    SKScriptingColorOlive = 'Oliv',
    SKScriptingColorBrown = 'Brwn',
    SKScriptingColorBlack = 'Blck',
    SKScriptingColorWhite = 'Whit',
    SKScriptingColorGray = 'Gray',
    SKScriptingColorLightGray = 'LGry',
    SKScriptingColorDarkGray = 'DGry',
    SKScriptingColorClear = 'Clea',
    SKScriptingColorUnderPageBackground = 'UPgB',
    SKScriptingColorWindowBackground = 'WinB',
    SKScriptingColorControlBackground = 'CtrB',
};

@interface NSColor (SKExtensions)

+ (void)makeHighlightColors;

+ (NSColor *)selectionHighlightColor:(BOOL)active;
+ (NSColor *)selectionHighlightInteriorColor:(BOOL)active;

@property (class, nonatomic, readonly) NSArray<NSColor *> *favoriteColors;

- (NSComparisonResult)colorCompare:(NSColor *)aColor;

@property (nonatomic, readonly) CGFloat luminance;

- (void)drawSwatchInRoundedRect:(NSRect)rect;

@property (nonatomic, readonly) NSColor *opaqueColor;

+ (nullable instancetype)scriptingRgbaColorWithDescriptor:(NSAppleEventDescriptor *)descriptor;
@property (nonatomic, readonly) NSAppleEventDescriptor *scriptingRgbaColorDescriptor;

@property (nonatomic, nullable, readonly) NSString *accessibilityValue;

@property (nonatomic, nullable, readonly) NSString *hexString;

@end

NS_ASSUME_NONNULL_END
