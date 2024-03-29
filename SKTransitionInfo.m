//
//  SKTransitionInfo.m
//  Skim
//
//  Created by Christiaan Hofman on 8/10/09.
/*
 This software is Copyright (c) 2009
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

#import "SKTransitionInfo.h"
#import "SKThumbnail.h"
#import "SKTransitionController.h"

#define SKStyleNameKey      @"styleName"
#define SKDurationKey       @"duration"
#define SKShouldRestrictKey @"shouldRestrict"

NSString *SKPasteboardTypeTransition = @"net.sourceforge.skim-app.pasteboard.transition";

@implementation SKTransitionInfo

@synthesize transitionStyle, duration, shouldRestrict;
@dynamic properties, label, title;

- (instancetype)init {
    self = [super init];
    if (self) {
        transitionStyle = SKNoTransition;
        duration = 1.0;
        shouldRestrict = YES;
    }
    return self;
}

- (instancetype)initWithProperties:(NSDictionary *)properies {
    self = [self init];
    [self setProperties:properies];
    return self;
}

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[SKPasteboardTypeTransition];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString:SKPasteboardTypeTransition])
        return NSPasteboardReadingAsPropertyList;
    return NSPasteboardReadingAsData;
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[SKPasteboardTypeTransition];
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:SKPasteboardTypeTransition])
        return [self properties];
    return nil;
}

- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    if ([type isEqualToString:SKPasteboardTypeTransition]) {
        self = [self initWithProperties:propertyList];
    } else {
        self = nil;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> %@", [self class], self, [self properties]];
}

- (NSDictionary *)properties {
    return @{SKStyleNameKey:([SKTransitionController nameForStyle:transitionStyle] ?: @""),
             SKDurationKey:[NSNumber numberWithDouble:duration],
             SKShouldRestrictKey:[NSNumber numberWithBool:shouldRestrict]};
}

- (void)setProperties:(NSDictionary *)dictionary {
    id value;
    if ((value = [dictionary objectForKey:SKStyleNameKey]))
        [self setTransitionStyle:[SKTransitionController styleForName:value]];
    if ((value = [dictionary objectForKey:SKDurationKey]))
        [self setDuration:[value doubleValue]];
    if ((value = [dictionary objectForKey:SKShouldRestrictKey]))
        [self setShouldRestrict:[value boolValue]];
}

- (NSString *)label {
    return nil;
}

- (NSString *)title {
    return NSLocalizedString(@"Page Transition", @"Box title");
}

@end

#pragma mark -

@implementation SKLabeledTransitionInfo

@synthesize thumbnail, toThumbnail;
@dynamic transitionName;

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"transitionName"])
        keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:@"transitionStyle", nil]];
    else if ([key isEqualToString:@"label"])
        keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:@"thumbnail.label", @"toThumbnail.label", nil]];
    return keyPaths;
}

- (NSString *)label {
    if ([self thumbnail] && [self toThumbnail])
        return [NSString stringWithFormat:@"%@\u2192%@", [[self thumbnail] label], [[self toThumbnail] label]];
    return nil;
}

- (NSString *)transitionName {
    return [SKTransitionController localizedNameForStyle:[self transitionStyle]];
}

@end
