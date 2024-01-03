//
//  SKRecentDocumentInfo.h
//  Skim
//
//  Created by Christiaan Hofman on 23/11/2020.
/*
This software is Copyright (c) 2020
Adam Maxwell. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

- Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in
the documentation and/or other materials provided with the
distribution.

- Neither the name of Adam Maxwell nor the names of any
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

@class SKAlias;

@interface SKRecentDocumentInfo : NSObject {
    SKAlias *alias;
    NSUInteger pageIndex;
    NSArray<NSDictionary<NSString *, id> *> *snapshots;
}

- (instancetype)initWithProperties:(NSDictionary<NSString *, id> *)properties;
- (instancetype)initWithURL:(NSURL *)fileURL pageIndex:(NSUInteger)aPageIndex snapshots:(NSArray<NSDictionary<NSString *, id> *> *)aSnapshots;

@property (nonatomic, nullable, readonly) NSURL *fileURL;
@property (nonatomic, readonly) NSUInteger pageIndex;
@property (nonatomic, nullable, readonly) NSArray<NSDictionary<NSString *, id> *> *snapshots;
@property (nonatomic, readonly) NSDictionary<NSString *, id> *properties;

@end

NS_ASSUME_NONNULL_END
