//
//  NSString_SKExtensions.h
//  Skim
//
//  Created by Christiaan Hofman on 2/12/07.
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

@interface NSString (SKExtensions)

- (NSComparisonResult)noteTypeCompare:(NSString *)other;

@property (nonatomic, readonly) NSString *stringByCollapsingWhitespaceAndNewlinesAndRemovingSurroundingWhitespaceAndNewlines;
@property (nonatomic, readonly) NSString *stringByRemovingAliens;

@property (nonatomic, readonly) NSString *stringByAppendingEllipsis;

- (NSString *)stringByAppendingEmDashAndString:(NSString *)aString;
- (NSString *)stringByAppendingDashAndString:(NSString *)aString;

- (NSString *)stringByBackslashEscapingCharactersFromSet:(NSCharacterSet *)charSet;
@property (nonatomic, readonly) NSString *stringByEscapingShellChars;
@property (nonatomic, readonly) NSString *stringByEscapingDoubleQuotes;
@property (nonatomic, readonly) NSString *stringByEscapingParenthesis;

- (NSComparisonResult)localizedCaseInsensitiveNumericCompare:(NSString *)aStr;

- (BOOL)isCaseInsensitiveEqual:(NSString *)aString;

- (NSString *)lossyStringUsingEncoding:(NSStringEncoding)encoding;

@property (nonatomic, readonly) NSString *typeName;

@property (nonatomic, readonly) NSString *rectString;
@property (nonatomic, readonly) NSString *pointString;
@property (nonatomic, readonly) NSString *originString;
@property (nonatomic, readonly) NSString *sizeString;
@property (nonatomic, readonly) NSString *midPointString;
@property (nonatomic, readonly) CGFloat rectX;
@property (nonatomic, readonly) CGFloat rectY;
@property (nonatomic, readonly) CGFloat rectWidth;
@property (nonatomic, readonly) CGFloat rectHeight;
@property (nonatomic, readonly) CGFloat pointX;
@property (nonatomic, readonly) CGFloat pointY;

@property (nonatomic, readonly) NSString *stringBySurroundingWithSpacesIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByAppendingSpaceIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByAppendingDoubleSpaceIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByPrependingSpaceIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByAppendingCommaIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByAppendingFullStopIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByAppendingCommaAndSpaceIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByAppendingFullStopAndSpaceIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByPrependingCommaAndSpaceIfNotEmpty;
@property (nonatomic, readonly) NSString *stringByPrependingFullStopAndSpaceIfNotEmpty;
@property (nonatomic, readonly) NSString *parenthesizedStringIfNotEmpty;

@property (nonatomic, nullable, readonly) NSURL *url;
@property (nonatomic, nullable, readonly) NSAttributedString *icon;
@property (nonatomic, nullable, readonly) NSAttributedString *smallIcon;

@property (nonatomic, nullable, readonly) NSAttributedString *typeIcon;

@property (nonatomic, readonly) NSString *xmlString;

@end

NS_ASSUME_NONNULL_END
