//
//  SKPDFSynchronizer.h
//  Skim
//
//  Created by Christiaan Hofman on 4/21/07.
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
#import "synctex_parser.h"
#import <stdatomic.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SKPDFSynchronizerOption) {
    SKPDFSynchronizerDefaultOptions = 0,
    SKPDFSynchronizerSelectMask = 1 << 0,
    SKPDFSynchronizerShowReadingBarMask = 1 << 1,
    SKPDFSynchronizerFlippedMask = 1 << 2,
};

@protocol SKPDFSynchronizerDelegate;
@class SKPDFSyncRecord;

@interface SKPDFSynchronizer : NSObject {
    __weak id <SKPDFSynchronizerDelegate> delegate;
    
    dispatch_queue_t queue;
    
    NSLock *lock;
    
    NSString *fileName;
    NSString *syncFileName;
    NSDate *lastModDate;
    BOOL isPdfsync;
    
    NSFileManager *fileManager;
    
    NSMutableArray<NSMutableArray<SKPDFSyncRecord *> *> *pages;
    NSMapTable *lines;
    
    NSMapTable *filenames;
    synctex_scanner_p scanner;
    
    _Atomic(BOOL) shouldKeepRunning;
}

@property (nonatomic, nullable, weak) id <SKPDFSynchronizerDelegate> delegate;
@property (nullable, copy) NSString *fileName;
@property (readonly) BOOL shouldKeepRunning;

- (void)findFileAndLineForLocation:(NSPoint)point inRect:(NSRect)rect pageBounds:(NSRect)bounds atPageIndex:(NSUInteger)pageIndex;
- (void)findPageAndLocationForLine:(NSInteger)line inFile:(NSString *)file options:(SKPDFSynchronizerOption)options;

// this must be called to stop the DO server from running in the server thread
- (void)terminate;

@end


@protocol SKPDFSynchronizerDelegate <NSObject>

- (void)synchronizerFoundLine:(NSInteger)line inFile:(NSString *)file;
- (void)synchronizerFoundLocation:(NSPoint)point atPageIndex:(NSUInteger)pageIndex options:(SKPDFSynchronizerOption)options;

@end

NS_ASSUME_NONNULL_END
