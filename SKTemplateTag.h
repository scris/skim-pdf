//
//  SKTemplateTag.h
//  Skim
//
//  Created by Christiaan Hofman on 10/12/07.
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

typedef NS_ENUM(NSInteger, SKTemplateTagType) {
    SKTemplateTagValue,
    SKTemplateTagCollection,
    SKTemplateTagCondition,
    SKTemplateTagText
};

typedef NS_ENUM(NSInteger, SKTemplateTagMatchType) {
    SKTemplateTagMatchOther,
    SKTemplateTagMatchEqual,
    SKTemplateTagMatchContain,
    SKTemplateTagMatchSmaller,
    SKTemplateTagMatchSmallerOrEqual,
    SKTemplateTagMatchLarger,
    SKTemplateTagMatchLargerOrEqual,
    SKTemplateTagMatchNotEqual,
    SKTemplateTagMatchNotContain
};

@class SKAttributeTemplate;

@interface SKTemplateTag : NSObject

@property (nonatomic, readonly) SKTemplateTagType type;

@end

#pragma mark -

@interface SKValueTemplateTag : SKTemplateTag {
    NSString *keyPath;
}

- (instancetype)initWithKeyPath:(NSString *)aKeyPath;

@property (nonatomic, readonly) NSString *keyPath;

@end

#pragma mark -

@interface SKRichValueTemplateTag : SKValueTemplateTag {
    NSDictionary<NSString *, id> *attributes;
    SKAttributeTemplate *linkTemplate;
}

- (instancetype)initWithKeyPath:(NSString *)aKeyPath attributes:(NSDictionary<NSString *, id> *)anAttributes;

@property (nonatomic, readonly) NSDictionary<NSString *, id> *attributes;
@property (nonatomic, nullable, readonly) SKAttributeTemplate *linkTemplate;

@end

#pragma mark -

@interface SKCollectionTemplateTag : SKValueTemplateTag {
    NSString *itemTemplateString;
    NSString *separatorTemplateString;
    NSArray<__kindof SKTemplateTag *> *itemTemplate;
    NSArray<__kindof SKTemplateTag *> *separatorTemplate;
}

- (instancetype)initWithKeyPath:(NSString *)aKeyPath itemTemplateString:(NSString *)anItemTemplateString separatorTemplateString:(nullable NSString *)aSeparatorTemplateString;

@property (nonatomic, nullable, readonly) NSArray<__kindof SKTemplateTag *> *itemTemplate, *separatorTemplate;

@end

#pragma mark -

@interface SKRichCollectionTemplateTag : SKValueTemplateTag {
    NSAttributedString *itemTemplateAttributedString;
    NSAttributedString *separatorTemplateAttributedString;
    NSArray<__kindof SKTemplateTag *> *itemTemplate;
    NSArray<__kindof SKTemplateTag *> *separatorTemplate;
}

- (instancetype)initWithKeyPath:(NSString *)aKeyPath itemTemplateAttributedString:(NSAttributedString *)anItemTemplateAttributedString separatorTemplateAttributedString:(nullable NSAttributedString *)aSeparatorTemplateAttributedString;

@property (nonatomic, nullable, readonly) NSArray<__kindof SKTemplateTag *> *itemTemplate, *separatorTemplate;

@end

#pragma mark -

@interface SKConditionTemplateTag : SKValueTemplateTag {
    SKTemplateTagMatchType matchType;
    NSMutableArray *subtemplates;
    NSArray<NSString *> *matchStrings;
}

- (instancetype)initWithKeyPath:(NSString *)aKeyPath matchType:(SKTemplateTagMatchType)aMatchType matchStrings:(NSArray *)aMatchStrings subtemplates:(NSArray *)aSubtemplates;

@property (nonatomic, readonly) SKTemplateTagMatchType matchType;
@property (nonatomic, readonly) NSArray<NSString *> *matchStrings;

- (NSUInteger)countOfSubtemplates;
- (NSArray<__kindof SKTemplateTag *> *)objectInSubtemplatesAtIndex:(NSUInteger)anIndex;

@end

#pragma mark -

@interface SKRichConditionTemplateTag : SKConditionTemplateTag
@end

#pragma mark -

@interface SKTextTemplateTag : SKTemplateTag {
    NSString *text;
}

- (instancetype)initWithText:(NSString *)aText;

@property (nonatomic, strong) NSString *text;

- (void)appendText:(NSString *)newText;

@end

#pragma mark -

@interface SKRichTextTemplateTag : SKTemplateTag {
    NSAttributedString *attributedText;
    NSArray<NSArray<__kindof SKTemplateTag *> *> *linkTemplates;
}

- (instancetype)initWithAttributedText:(NSAttributedString *)anAttributedText;

@property (nonatomic, strong) NSAttributedString *attributedText;

- (void)appendAttributedText:(NSAttributedString *)newAttributedText;

@property (nonatomic, nullable, readonly) NSArray<NSArray<__kindof SKTemplateTag *> *> *linkTemplates;

@end

#pragma mark -

@interface SKAttributeTemplate : NSObject {
    NSArray<__kindof SKTemplateTag *> *template;
    NSRange range;
    Class attributeClass;
}

- (instancetype)initWithTemplate:(nullable NSArray<__kindof SKTemplateTag *> *)aTemplate range:(NSRange)aRange attributeClass:(Class)aClass;

@property (nonatomic, nullable, readonly) NSArray<__kindof SKTemplateTag *> *template;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) Class attributeClass;

@end

NS_ASSUME_NONNULL_END
