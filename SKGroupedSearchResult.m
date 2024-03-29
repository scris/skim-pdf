//
//  SKGroupedSearchResult.m
//  Skim
//
//  Created by Christiaan Hofman on 4/29/08.
/*
 This software is Copyright (c) 2008
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

#import "SKGroupedSearchResult.h"
#import "PDFPage_SKExtensions.h"
#import "PDFSelection_SKExtensions.h"
#import "NSGeometry_SKExtensions.h"

NSString *SKGroupedSearchResultCountKey = @"count";

@implementation SKGroupedSearchResult

@synthesize page, maxCount, matches;
@dynamic pageIndex, count, label;

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"label"])
        keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:SKGroupedSearchResultCountKey, nil]];
    return keyPaths;
}

- (instancetype)initWithPage:(PDFPage *)aPage maxCount:(NSUInteger)aMaxCount {
    self = [super init];
    if (self) {
        page = aPage;
        maxCount = aMaxCount;
        matches = [[NSMutableArray alloc] init];
    }
    return self;
}


- (NSUInteger)pageIndex {
    return [page pageIndex];
}

- (NSUInteger)count {
    return [matches count];
}

- (NSString *)label {
    return [self count] == 1 ? NSLocalizedString(@"1 Result", @"") : [NSString stringWithFormat:NSLocalizedString(@"%ld Results", @""), (long)[self count]];
}

- (void)addMatch:(PDFSelection *)match {
    [self willChangeValueForKey:SKGroupedSearchResultCountKey];
    CGFloat order = [match boundsOrderForPage:page];
    NSInteger i = [matches count];
    while (i-- > 0) {
        PDFSelection *prevResult = [matches objectAtIndex:i];
        if (order >= [prevResult boundsOrderForPage:page])
            break;
    }
    [matches insertObject:match atIndex:i + 1];
    [self didChangeValueForKey:SKGroupedSearchResultCountKey];
}

@end
