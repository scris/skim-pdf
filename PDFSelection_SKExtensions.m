//
//  PDFSelection_SKExtensions.m
//  Skim
//
//  Created by Christiaan Hofman on 4/24/07.
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

#import "PDFSelection_SKExtensions.h"
#import "NSString_SKExtensions.h"
#import "NSParagraphStyle_SKExtensions.h"
#import "PDFPage_SKExtensions.h"
#import "SKStringConstants.h"
#import "SKMainDocument.h"
#import "NSPointerArray_SKExtensions.h"
#import "NSColor_SKExtensions.h"
#import "NSCharacterSet_SKExtensions.h"

#define SKIncludeNewlinesFromEnclosedTextKey @"SKIncludeNewlinesFromEnclosedText"

#define ELLIPSIS_CHARACTER (unichar)0x2026
#define HYPHEN_CHARACTER (unichar)0x002D
#define SOFT_HYPHEN_CHARACTER (unichar)0x00AD

@interface NSTextStorage (SKNSSubTextStoragePrivateDeclarations)
- (NSRange)range;
@end

@interface PDFSelection (PDFSelectionPrivateDeclarations)
// defined on 10.6
- (NSIndexSet *)indexOfCharactersOnPage:(PDFPage *)page;
@end

@implementation PDFSelection (SKExtensions)

+ (PDFSelection *)selectionByAddingSelections:(NSArray *)selections {
    PDFSelection *selection = nil;
    NSUInteger count = [selections count];
    if (count > 0) {
        selection = [[selections objectAtIndex:0] copy];
        if (count > 1)
            [selection addSelections:[selections subarrayWithRange:NSMakeRange(1, count - 1)]];
    }
    return selection;
}

static BOOL inline isHyphenated(NSString *string, PDFSelection *line, PDFSelection *nextLine) {
    NSUInteger l = [string length];
    unichar ch = [string characterAtIndex:l - 1];
    if (ch != SOFT_HYPHEN_CHARACTER && (ch != HYPHEN_CHARACTER || l < 2 || [[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:l - 2]] == NO))
        return NO;
    PDFPage *page = [line safeLastPage];
    PDFPage *nextPage = [nextLine safeFirstPage];
    if ([nextPage isEqual:page] == NO && [nextPage pageIndex] != [page pageIndex] + 1)
        return NO;
    NSUInteger i = [line safeIndexOfLastCharacterOnPage:page];
    NSUInteger j = [nextLine safeIndexOfFirstCharacterOnPage:nextPage];
    if (nextPage != page) {
        if (j > 0)
            return NO;
        j = [[page string] length];
    }
    return i + 1 == j || (i + 1 < j && i + 5 > j && [[page string] rangeOfCharacterFromSet:[NSCharacterSet nonWhitespaceAndNewlineCharacterSet] options:0 range:NSMakeRange(i + 1, j - i - 1)].location == NSNotFound);
}

- (NSString *)compactedCleanedString {
    NSArray *lines = [self selectionsByLine];
    if ([lines count] < 2)
        return [[[self string] stringByRemovingAliens] stringByCollapsingWhitespaceAndNewlinesAndRemovingSurroundingWhitespaceAndNewlines];
    NSMutableString *string = [NSMutableString string];
    PDFSelection *lastLine = nil;
    for (PDFSelection *line in lines) {
        NSString *str = [[[line string] stringByRemovingAliens] stringByCollapsingWhitespaceAndNewlinesAndRemovingSurroundingWhitespaceAndNewlines];
        if ([str length] == 0) continue;
        if ([string length]) {
            if (isHyphenated(string, lastLine, line))
                [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
            else
                [string appendString:@" "];
        }
        [string appendString:str];
        lastLine = line;
    }
    return string;
}

- (NSString *)cleanedString {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKIncludeNewlinesFromEnclosedTextKey])
        return [[[self string] stringByRemovingAliens] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [self compactedCleanedString];
}

- (NSAttributedString *)contextString {
	NSMutableAttributedString *attributedSample;
    NSString *searchString = [self compactedCleanedString] ?: @"";
    PDFSelection *extendedSelection;
	NSString *sample;
    NSMutableString *attributedString;
	NSString *ellipse = [NSString stringWithFormat:@"%C", ELLIPSIS_CHARACTER];
	NSRange foundRange;
    CGFloat fontSize = [[NSUserDefaults standardUserDefaults] doubleForKey:SKTableFontSizeKey] - 2.0;
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:fontSize], NSFontAttributeName, [NSParagraphStyle defaultTruncatingTailParagraphStyle], NSParagraphStyleAttributeName, nil];
    PDFPage *page = [self safeFirstPage];
    NSString *pageString = [page string];
    NSUInteger length = [pageString length];
    NSUInteger i = [self safeIndexOfFirstCharacterOnPage:page];
    NSUInteger j = [self safeIndexOfLastCharacterOnPage:page];
    NSUInteger start = MAX(i, 15) - 15;
    NSUInteger end = MIN(j + 55, length);
    
    // Extend selection, try to break at space
    if (start > 0) {
        NSUInteger k = NSMaxRange([pageString rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:NSMakeRange(start, i - start)]);
        if (k == NSNotFound)
            start = MAX(i, 10) - 10;
        else if (k + 5 <= i)
            start = k;
    }
    if (end < length) {
        NSUInteger k = [pageString rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(MAX(j, end - 10), end - MAX(j, end - 10))].location;
        if (k == NSNotFound)
            end = MIN(j + 50, length);
        else if (j + 10 < k)
            end = k;
    }
    extendedSelection = [page selectionForRange:NSMakeRange(start, end - start)];
    
    // get the cleaned string
    sample = [extendedSelection compactedCleanedString] ?: @"";
    
	// Finally, create attributed string.
    attributedSample = [[NSMutableAttributedString alloc] initWithString:sample attributes:attributes];
    
	// Find instances of search string and "bold" them.
    foundRange = [sample rangeOfString:searchString options:NSBackwardsSearch range:NSMakeRange(0, MIN([searchString length] + i - start, [sample length]))];
    if (foundRange.location == NSNotFound)
        foundRange = [sample rangeOfString:searchString];
    if (foundRange.location != NSNotFound)
        // Use bold font for the text range where the search term was found.
        [attributedSample addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:fontSize] range:foundRange];
    
    attributedString = [attributedSample mutableString];
    if (start > 0)
        [attributedString insertString:ellipse atIndex:0];
    if (end < length)
        [attributedString appendString:ellipse];
    
	return attributedSample;
}

- (PDFDestination *)destination {
    PDFDestination *destination = nil;
    PDFPage *page = [self safeFirstPage];
    if (page) {
        NSRect bounds = [self boundsForPage:page];
        destination = [[PDFDestination alloc] initWithPage:page atPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
    }
    return destination;
}

- (NSUInteger)safeIndexOfFirstCharacterOnPage:(PDFPage *)page {
    NSInteger i, count = [self numberOfTextRangesOnPage:page];
    for (i = 0; i < count; i++) {
        NSRange range = [self rangeAtIndex:i onPage:page];
        if (range.length > 0)
            return range.location;
    }
    return NSNotFound;
}

- (NSUInteger)safeIndexOfLastCharacterOnPage:(PDFPage *)page {
    NSInteger i, count = [self numberOfTextRangesOnPage:page];
    for (i = count - 1; i >= 0; i--) {
        NSRange range = [self rangeAtIndex:i onPage:page];
        if (range.length > 0)
            return NSMaxRange(range) - 1;
    }
    return NSNotFound;
}

- (BOOL)hasCharactersOnPage:(PDFPage *)page {
    NSInteger i, count = [self numberOfTextRangesOnPage:page];
    for (i = 0; i < count; i++) {
        if ([self rangeAtIndex:i onPage:page].length > 0)
            return YES;
    }
    return NO;
}

- (PDFPage *)safeFirstPage {
    for (PDFPage *page in [self pages]) {
        if ([self hasCharactersOnPage:page])
            return page;
    }
    return nil;
}

- (PDFPage *)safeLastPage {
    for (PDFPage *page in [[self pages] reverseObjectEnumerator]) {
        if ([self hasCharactersOnPage:page])
            return page;
    }
    return nil;
}

- (BOOL)hasCharacters {
    return [self safeFirstPage] != nil;
}

- (CGFloat)boundsOrderForPage:(PDFPage *)page {
    return [page sortOrderForBounds:[self boundsForPage:page]];
}

static NSRange rangeOfSubstringOfStringAtIndex(NSString *string, NSArray *substrings, NSUInteger anIndex) {
    if (anIndex >= [substrings count])
        return NSMakeRange(NSNotFound, 0);
    
    NSUInteger length = [string length];
    __block NSRange range = NSMakeRange(0, 0);
    
    [substrings enumerateObjectsUsingBlock:^(NSString *substring, NSUInteger i, BOOL *stop) {
        NSRange searchRange = NSMakeRange(NSMaxRange(range), length - NSMaxRange(range));
        if ([substring length] == 0) {
            if (i == anIndex) {
                range = NSMakeRange(NSNotFound, 0);
                *stop = YES;
            }
            return;
        }
        range = [string rangeOfString:substring options:NSLiteralSearch range:searchRange];
        if (range.location == NSNotFound) {
            range = NSMakeRange(NSNotFound, 0);
            *stop = YES;
        }
    }];
    return range;
}

#define TEXT_KEY @"text"
#define RANGES_KEY @"ranges"
#define CONTAINER_KEY @"container"

#define RICH_TEXT_CLASSNAME @"rich text"
#define CHARACTERS_KEY @"characters"

static NSArray *characterRangesAndContainersForSpecifier(NSScriptObjectSpecifier *specifier, BOOL continuous, BOOL continuousContainers) {
    if ([specifier isKindOfClass:[NSScriptObjectSpecifier class]] == NO)
        return nil;
    
    NSMutableArray *rangeDicts = [NSMutableArray array];
    NSString *key = [specifier key];
    
    static NSSet *richTextElementKeys = nil;
    if (richTextElementKeys == nil)
        richTextElementKeys = [[NSSet alloc] initWithObjects:@"characters", @"words", @"paragraphs", @"attributeRuns", nil];
    
    if ([richTextElementKeys containsObject:key]) {
        
        // get the richText specifier and textStorage
        NSArray *dicts = characterRangesAndContainersForSpecifier([specifier containerSpecifier], continuousContainers, continuousContainers);
        if ([dicts count] == 0)
            return nil;
        
        for (NSMutableDictionary *dict in dicts) {
            NSTextStorage *containerText = [dict objectForKey:TEXT_KEY];
            NSPointerArray *textRanges = [dict objectForKey:RANGES_KEY];
            NSUInteger ri, numRanges = [textRanges count];
            NSPointerArray *ranges = [[NSPointerArray alloc] initForRangePointers];
            
            for (ri = 0; ri < numRanges; ri++) {
                NSRange textRange = [textRanges rangeAtIndex:ri];
                NSTextStorage *textStorage = nil;
                if (NSEqualRanges(textRange, NSMakeRange(0, [containerText length])))
                    textStorage = containerText;
                else
                    textStorage = [[NSTextStorage alloc] initWithAttributedString:[containerText attributedSubstringFromRange:textRange]];
                
                // now get the ranges, which can be any kind of specifier
                NSInteger startIndex, endIndex, i, count = -2, *indices;
                NSPointerArray *tmpRanges = [[NSPointerArray alloc] initForRangePointers];
                
                if ([specifier isKindOfClass:[NSPropertySpecifier class]]) {
                    // this should be the full range of characters, words, or paragraphs
                    NSRange range = NSMakeRange(0, [[textStorage valueForKey:key] count]);
                    if (range.length)
                        [tmpRanges addPointer:&range];
                } else if ([specifier isKindOfClass:[NSRangeSpecifier class]]) {
                    // somehow getting the indices as for the general case sometimes leads to an exception for NSRangeSpecifier, so we get the indices of the start/endSpecifiers
                    NSScriptObjectSpecifier *startSpec = [(NSRangeSpecifier *)specifier startSpecifier];
                    NSScriptObjectSpecifier *endSpec = [(NSRangeSpecifier *)specifier endSpecifier];
                    
                    if (startSpec || endSpec) {
                        if (startSpec) {
                            count = -2;
                            indices = [startSpec indicesOfObjectsByEvaluatingWithContainer:textStorage count:&count];
                            startIndex = count > 0 ? indices[0] : -1;
                        } else {
                            startIndex = 0;
                        }
                        if (endSpec) {
                            count = -2;
                            indices = [endSpec indicesOfObjectsByEvaluatingWithContainer:textStorage count:&count];
                            endIndex = count > 0 ? indices[count - 1] : -1;
                        } else {
                            endIndex = [[textStorage valueForKey:key] count] - 1;
                        }
                        if (startIndex >= 0 && endIndex >= 0) {
                            NSRange range = NSMakeRange(MIN(startIndex, endIndex), MAX(startIndex, endIndex) + 1 - MIN(startIndex, endIndex));
                            [tmpRanges addPointer:&range];
                        }
                    }
                } else {
                    // this handles other objectSpecifiers (index, middel, random, relative, whose). It can contain several ranges, e.g. for aan NSWhoseSpecifier
                    indices = [specifier indicesOfObjectsByEvaluatingWithContainer:textStorage count:&count];
                    NSRange range = NSMakeRange(0, 0);
                    if (count == -1) {
                        range.length = [[textStorage valueForKey:key] count];
                    } else if (count > 0) {
                        for (i = 0; i < count; i++) {
                            NSUInteger idx = indices[i];
                            if (range.length == 0 || idx > NSMaxRange(range)) {
                                if (range.length)
                                    [tmpRanges addPointer:&range];
                                range = NSMakeRange(idx, 1);
                            } else {
                                ++(range.length);
                            }
                        }
                    }
                    if (range.length)
                        [tmpRanges addPointer:&range];
                }
                
                count = [tmpRanges count];
                if (count == 0) {
                } else if ([key isEqualToString:CHARACTERS_KEY]) {
                    for (i = 0; i < count; i++) {
                        NSRange range = [tmpRanges rangeAtIndex:i];
                        range.location += textRange.location;
                        range = NSIntersectionRange(range, textRange);
                        if (range.length) {
                            if (continuous) {
                                [ranges addPointer:&range];
                            } else {
                                NSUInteger j;
                                for (j = range.location; j < NSMaxRange(range); j++) {
                                    NSRange r = NSMakeRange(j, 1);
                                    [ranges addPointer:&r];
                                }
                            }
                        }
                    }
                } else {
                    // translate from subtext ranges to character ranges
                    NSArray *subTextStorages = [textStorage valueForKey:key];
                    if ([subTextStorages count]) {
                        NSString *string = nil;
                        NSArray *substrings = nil;
                        // The private subclass NSSubTextStorage has a -range method
                        BOOL knowsRange = [[subTextStorages objectAtIndex:0] respondsToSelector:@selector(range)];
                        if (knowsRange == NO) {
                            // if we can't get the range directly, we try to search a substring
                            string = [textStorage string];
                            substrings = [subTextStorages valueForKey:@"string"];
                        }
                        for (i = 0; i < count; i++) {
                            NSRange range = [tmpRanges rangeAtIndex:i];
                            startIndex = MIN(range.location, [subTextStorages count] - 1);
                            endIndex = MIN(NSMaxRange(range) - 1, [subTextStorages count] - 1);
                            if (endIndex == startIndex) endIndex = -1;
                            if (continuous) {
                                if (knowsRange)
                                    range = [[subTextStorages objectAtIndex:startIndex] range];
                                else
                                    range = rangeOfSubstringOfStringAtIndex(string, substrings, startIndex);
                                if (range.location == NSNotFound)
                                    continue;
                                startIndex = range.location;
                                if (endIndex >= 0) {
                                    if (knowsRange)
                                        range = [[subTextStorages objectAtIndex:endIndex] range];
                                    else
                                        range = rangeOfSubstringOfStringAtIndex(string, substrings, endIndex);
                                    if (range.location == NSNotFound)
                                        continue;
                                }
                                endIndex = NSMaxRange(range) - 1;
                                range = NSMakeRange(textRange.location + startIndex, endIndex + 1 - startIndex);
                                [ranges addPointer:&range];
                            } else {
                                if (endIndex == -1) endIndex = startIndex;
                                NSInteger j;
                                for (j = startIndex; j <= endIndex; j++) {
                                    if (knowsRange)
                                        range = [[subTextStorages objectAtIndex:j] range];
                                    else
                                        range = rangeOfSubstringOfStringAtIndex(string, substrings, j);
                                    if (range.location == NSNotFound)
                                        continue;
                                    range.location += textRange.location;
                                    [ranges addPointer:&range];
                                }
                            }
                        }
                    }
                }
            }
            
            if ([ranges count]) {
                [dict setObject:ranges forKey:RANGES_KEY];
                [rangeDicts addObject:dict];
            }
        }
        
    } else {
        
        NSScriptClassDescription *classDesc = [specifier keyClassDescription];
        if ([[classDesc className] isEqualToString:RICH_TEXT_CLASSNAME]) {
            if ([[[specifier containerClassDescription] toManyRelationshipKeys] containsObject:key])
                return nil;
            specifier = [specifier containerSpecifier];
        } else {
            key = [[classDesc toOneRelationshipKeys] lastObject];
            if (key == nil || [[[classDesc classDescriptionForKey:key] className] isEqualToString:RICH_TEXT_CLASSNAME] == NO)
                return nil;
        }
        
        NSArray *containers = [specifier objectsByEvaluatingSpecifier];
        if (containers && [containers isKindOfClass:[NSArray class]] == NO)
            containers = @[containers];
        if ([containers count] == 0)
            return nil;
        
        for (id container in containers) {
            NSTextStorage *containerText = [container valueForKey:key];
            if ([containerText isKindOfClass:[NSTextStorage class]] == NO || [containerText length] == 0)
                continue;
            NSPointerArray *ranges = [[NSPointerArray alloc] initForRangePointers];
            NSRange range = NSMakeRange(0, [containerText length]);
            [ranges addPointer:&range];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ranges, RANGES_KEY, containerText, TEXT_KEY, container, CONTAINER_KEY, nil];
            [rangeDicts addObject:dict];
        }
        
    }
    
    return rangeDicts;
}

+ (instancetype)selectionWithSpecifier:(id)specifier {
    return [self selectionWithSpecifier:specifier onPage:nil];
}

+ (instancetype)selectionWithSpecifier:(id)specifier onPage:(PDFPage *)aPage {
    if (specifier == nil || [specifier isEqual:[NSNull null]])
        return nil;
    if ([specifier isKindOfClass:[NSPropertySpecifier class]] &&
        [[[specifier containerClassDescription] toManyRelationshipKeys] containsObject:[specifier key]] == NO &&
        [[[specifier keyClassDescription] className] isEqualToString:RICH_TEXT_CLASSNAME] == NO) {
        // this allows to use selection properties directly
        specifier = [specifier objectsByEvaluatingSpecifier];
        if (specifier == nil)
            return nil;
        else if ([specifier isKindOfClass:[NSArray class]] == NO)
            specifier = @[specifier];
    } else if ([specifier isKindOfClass:[NSArray class]] == NO) {
        specifier = @[specifier];
    }
    
    NSMutableArray *selections = [NSMutableArray array];
    
    for (NSScriptObjectSpecifier *spec in specifier) {
        if ([spec isKindOfClass:[NSScriptObjectSpecifier class]] == NO)
            continue;
        
        NSArray *dicts = characterRangesAndContainersForSpecifier(spec, YES, NO);
        PDFDocument *doc = nil;
        
        for (NSDictionary *dict in dicts) {
            id container = [dict objectForKey:CONTAINER_KEY];
            NSPointerArray *ranges = [dict objectForKey:RANGES_KEY];
            NSUInteger i, numRanges = [ranges count];
            
            if ([container isKindOfClass:[SKMainDocument class]] && (doc == nil || [doc isEqual:[container pdfDocument]])) {
                
                PDFDocument *document = [container pdfDocument];
                NSUInteger aPageIndex = (aPage ? [aPage pageIndex] : NSNotFound), page, numPages = [document pageCount];
                NSUInteger *pageLengths = (NSUInteger *)malloc(numPages * sizeof(NSUInteger));
                
                for (page = 0; page < numPages; page++)
                    pageLengths[page] = NSNotFound;
                
                for (i = 0; i < numRanges; i++) {
                    NSRange range = [ranges rangeAtIndex:i];
                    NSUInteger pageStart = 0, startPage = NSNotFound, endPage = NSNotFound, startIndex = NSNotFound, endIndex = NSNotFound;
                    
                    for (page = 0; (page < numPages) && (pageStart < NSMaxRange(range)); page++) {
                        if (pageLengths[page] == NSNotFound)
                            pageLengths[page] = [[[document pageAtIndex:page] attributedString] length];
                        if ((aPageIndex == NSNotFound || page == aPageIndex) && pageLengths[page] && range.location < pageStart + pageLengths[page]) {
                            if (startPage == NSNotFound && startIndex == NSNotFound) {
                                startPage = page;
                                startIndex = MAX(pageStart, range.location) - pageStart;
                            }
                            if (startPage != NSNotFound && startIndex != NSNotFound) {
                                endPage = page;
                                endIndex = MIN(NSMaxRange(range) - pageStart, pageLengths[page]) - 1;
                            }
                        }
                        pageStart += pageLengths[page] + 1; // text of pages is separated by newlines, see -[SKMainDocument richText]
                    }
                    
                    if (startPage != NSNotFound && startIndex != NSNotFound && endPage != NSNotFound && endIndex != NSNotFound) {
                        PDFSelection *sel = [document selectionFromPage:[document pageAtIndex:startPage] atCharacterIndex:startIndex toPage:[document pageAtIndex:endPage] atCharacterIndex:endIndex];
                        if ([sel hasCharacters]) {
                            [selections addObject:sel];
                            doc = document;
                        }
                    }
                }
                
                free(pageLengths);
                
            } else if ([container isKindOfClass:[PDFPage class]] && (aPage == nil || [aPage isEqual:container]) && (doc == nil || [doc isEqual:[container document]])) {
                
                for (i = 0; i < numRanges; i++) {
                    PDFSelection *sel;
                    NSRange range = [ranges rangeAtIndex:i];
                    if (range.length && (sel = [container selectionForRange:range]) && [sel hasCharacters]) {
                        [selections addObject:sel];
                        doc = [container document];
                    }
                }
                
            }
        }
    }
    
    PDFSelection *selection = [selections firstObject];
    if ([selections count] > 1) {
        [selections removeObjectAtIndex:0];
        [selection addSelections:selections];
    }
    return selection;
}

static inline void addSpecifierWithCharacterRangeAndPage(NSMutableArray *ranges, NSRange range, PDFPage *page) {
    NSRangeSpecifier *rangeSpec = nil;
    NSIndexSpecifier *startSpec = nil;
    NSIndexSpecifier *endSpec = nil;
    NSScriptObjectSpecifier *textSpec = [[NSPropertySpecifier alloc] initWithContainerSpecifier:[page objectSpecifier] key:@"richText"];
    NSScriptClassDescription *containerClassDescription = nil;
    
    if (textSpec) {
        containerClassDescription = [textSpec keyClassDescription];
        if ((startSpec = [[NSIndexSpecifier alloc] initWithContainerClassDescription:containerClassDescription containerSpecifier:textSpec key:CHARACTERS_KEY index:range.location])) {
            if (range.length == 1) {
                [ranges addObject:startSpec];
            } else if ((endSpec = [[NSIndexSpecifier alloc] initWithContainerClassDescription:containerClassDescription containerSpecifier:textSpec key:CHARACTERS_KEY index:NSMaxRange(range) - 1]) &&
                       (rangeSpec = [[NSRangeSpecifier alloc] initWithContainerClassDescription:containerClassDescription containerSpecifier:textSpec key:CHARACTERS_KEY startSpecifier:startSpec endSpecifier:endSpec])) {
                // in theory we should set the containerSpecifier of startSpec and endSpec to nil, and set containerIsRangeContainerObject to YES, but then AppleScript raises an errAENoSuchObject error
                [ranges addObject:rangeSpec];
            }
        }
    }
}

static inline NSRange addSpecifierWithCharacterRangeAndPageOrAppendRange(NSMutableArray *ranges, NSRange nextRange, NSRange range, PDFPage *page) {
    if (nextRange.length == 0) {
    } else if (range.length == 0) {
        range = nextRange;
    } else if (NSMaxRange(range) == nextRange.location) {
        range.length += nextRange.length;
    } else {
        addSpecifierWithCharacterRangeAndPage(ranges, range, page);
        range = nextRange;
    }
    return range;
}

- (id)objectSpecifiers {
    NSMutableArray *ranges = [NSMutableArray array];
    for (PDFPage *page in [self pages]) {
        __block NSRange range = NSMakeRange(0, 0);
        NSInteger i, iMax = [self numberOfTextRangesOnPage:page];
        for (i = 0; i < iMax; i++)
            range = addSpecifierWithCharacterRangeAndPageOrAppendRange(ranges, [self rangeAtIndex:i onPage:page], range, page);
        if (range.length)
            addSpecifierWithCharacterRangeAndPage(ranges, range, page);
    }
    return ranges;
}

@end
