//
//  SKDownload.m
//  Skim
//
//  Created by Christiaan Hofman on 8/11/07.
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

#import "SKDownload.h"
#import "NSFileManager_SKExtensions.h"
#import "SKDownloadController.h"
#import "SKStringConstants.h"
#import "NSString_SKExtensions.h"
#import "NSImage_SKExtensions.h"
#import "NSURL_SKExtensions.h"

NSString *SKDownloadFileNameKey = @"fileName";
NSString *SKDownloadFileURLKey = @"fileURL";
NSString *SKDownloadStatusKey = @"status";

@interface SKDownload ()
@property (nonatomic) SKDownloadStatus status;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSImage *fileIcon;
@property (nonatomic) int64_t expectedContentLength, receivedContentLength;
- (void)handleApplicationWillTerminateNotification:(NSNotification *)notification;
@end


@implementation SKDownload

@synthesize URL, resumeData, fileURL, fileIcon, expectedContentLength, receivedContentLength, status;
@dynamic properties, fileName, statusDescription, hasExpectedContentLength, downloading, canCancel, canRemove, canResume, cancelImage, resumeImage, cancelToolTip, resumeToolTip, scriptingURL, scriptingStatus;

static NSSet *keysAffectedByStatus = nil;

+ (void)initialize {
    SKINITIALIZE;
    keysAffectedByStatus = [[NSSet alloc] initWithObjects:@"downloading", @"statusDescription", @"cancelImage", @"resumeImage", @"cancelToolTip", @"resumeToolTip", nil];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:SKDownloadFileNameKey])
        keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:SKDownloadFileURLKey, nil]];
    else if ([keysAffectedByStatus containsObject:key])
        keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:SKDownloadStatusKey, nil]];
    else if ([key isEqualToString:@"hasExpectedContentLength"])
        keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:@"expectedContentLength", nil]];
    return keyPaths;
}

+ (NSImage *)deleteImage {
    static NSImage *deleteImage = nil;
    if (deleteImage == nil) {
        deleteImage = [NSImage imageWithSize:NSMakeSize(16.0, 16.0) flipped:NO drawingHandler:^(NSRect rect){
            [[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kToolbarDeleteIcon)] drawInRect:NSMakeRect(-2.0, -1.0, 20.0, 20.0) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
            return YES;
        }];
        [deleteImage setAccessibilityDescription:NSLocalizedString(@"delete", @"Accessibility description")];
    }
    return deleteImage;
}

+ (NSImage *)cancelImage {
    static NSImage *cancelImage = nil;
    if (cancelImage == nil) {
        cancelImage = [NSImage imageWithSize:NSMakeSize(16.0, 16.0) flipped:NO drawingHandler:^(NSRect rect){
            [[NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate] drawInRect:NSInsetRect(rect, 1.0, 1.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationAtop fraction:1.0];
            return YES;
        }];
        [cancelImage setTemplate:YES];
        [cancelImage setAccessibilityDescription:NSLocalizedString(@"cancel", @"Accessibility description")];
    }
    return cancelImage;
}

+ (NSImage *)resumeImage {
    static NSImage *resumeImage = nil;
    if (resumeImage == nil) {
        resumeImage = [NSImage imageWithSize:NSMakeSize(16.0, 16.0) flipped:NO drawingHandler:^(NSRect rect){
            [[NSImage imageNamed:NSImageNameRefreshFreestandingTemplate] drawInRect:NSInsetRect(rect, 1.0, 1.0) fromRect:NSZeroRect operation:NSCompositingOperationDestinationAtop fraction:1.0];
            return YES;
        }];
        [resumeImage setTemplate:YES];
        [resumeImage setAccessibilityDescription:NSLocalizedString(@"resume", @"Accessibility description")];
    }
    return resumeImage;
}

- (instancetype)initWithURL:(NSURL *)aURL {
    self = [super init];
    if (self) {
        URL = aURL;
        downloadTask = nil;
        fileURL = nil;
        fileIcon = nil;
        expectedContentLength = NSURLResponseUnknownLength;
        receivedContentLength = 0;
        status = SKDownloadStatusUndefined;
        receivedResponse = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillTerminateNotification:)
                                                     name:NSApplicationWillTerminateNotification object:NSApp];
    }
    return self;
}

- (instancetype)initWithProperties:(NSDictionary *)properties {
    NSString *URLString = [properties objectForKey:@"URL"];
    self = [self initWithURL:URLString ? [NSURL URLWithString:URLString] : nil];
    if (self) {
        NSString *fileURLPath = [properties objectForKey:@"file"];
        downloadTask = nil;
        if (fileURLPath)
            fileURL = [[NSURL alloc] initFileURLWithPath:fileURLPath];
        fileIcon = fileURL ? [[NSWorkspace sharedWorkspace] iconForFileType:[fileURL pathExtension]] : nil;
        expectedContentLength = [[properties objectForKey:@"expectedContentLength"] longLongValue];
        receivedContentLength = [[properties objectForKey:@"receivedContentLength"] longLongValue];
        status = [[properties objectForKey:@"status"] integerValue];
        resumeData = nil;
        if (fileURL == nil)
            resumeData = [properties objectForKey:@"resumeData"];
    }
    return self;
}

- (instancetype)init {
    return [self initWithURL:nil];
}

- (void)dealloc {
    if ([self canCancel])
        [downloadTask cancel];
    downloadTask = nil;
}

- (void)handleApplicationWillTerminateNotification:(NSNotification *)notification {
    [self cancel];
}

#pragma mark Accessors

- (NSDictionary *)properties {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[[self URL] absoluteString] forKey:@"URL"];
    [dict setValue:[NSNumber numberWithInteger:status] forKey:@"status"];
    [dict setValue:[NSNumber numberWithLongLong:expectedContentLength] forKey:@"expectedContentLength"];
    [dict setValue:[NSNumber numberWithLongLong:receivedContentLength] forKey:@"receivedContentLength"];
    [dict setValue:[[self fileURL] path] forKey:@"file"];
    if ([self status] == SKDownloadStatusCanceled || [self status] == SKDownloadStatusFailed)
        [dict setValue:resumeData forKey:@"resumeData"];
    return dict;
}

- (NSString *)fileName {
    NSString *fileName = nil;
    [fileURL getResourceValue:&fileName forKey:NSURLLocalizedNameKey error:NULL];
    if (fileName == nil) {
        if ([[URL path] length] > 1) {
            fileName = [[URL path] lastPathComponent];
        } else {
            fileName = [URL host];
            if (fileName == nil)
                fileName = [[[URL resourceSpecifier] lastPathComponent] stringByRemovingPercentEncoding];
        }
    }
    return fileName;
}

- (void)setFileURL:(NSURL *)newFileURL {
    if (fileURL != newFileURL) {
        fileURL = newFileURL;
        
        if (fileIcon == nil && fileURL) {
            fileIcon = [[NSWorkspace sharedWorkspace] iconForFileType:[fileURL pathExtension]];
        }
    }
}

- (NSImage *)fileIcon {
    if (fileIcon == nil && URL)
        return [[NSWorkspace sharedWorkspace] iconForFileType:[[[self URL] path] pathExtension]];
    return fileIcon;
}

- (NSString *)statusDescription {
    switch ([self status]) {
        case SKDownloadStatusStarting:
            return [NSLocalizedString(@"Starting", @"Download status message") stringByAppendingEllipsis];
        case SKDownloadStatusDownloading:
            return [NSLocalizedString(@"Downloading", @"Download status message") stringByAppendingEllipsis];
        case SKDownloadStatusFinished:
            return NSLocalizedString(@"Finished", @"Download status message");
        case SKDownloadStatusFailed:
            return NSLocalizedString(@"Failed", @"Download status message");
        case SKDownloadStatusCanceled:
            return NSLocalizedString(@"Canceled", @"Download status message");
        default:
            return @"";
    }
}

- (BOOL)isDownloading {
    return [self status] == SKDownloadStatusDownloading;
}

- (BOOL)hasExpectedContentLength {
    return [self expectedContentLength] > 0;
}

- (NSScriptObjectSpecifier *)objectSpecifier {
    NSUInteger idx = [[[SKDownloadController sharedDownloadController] downloads] indexOfObjectIdenticalTo:self];
    if (idx != NSNotFound) {
        NSScriptClassDescription *containerClassDescription = [NSScriptClassDescription classDescriptionForClass:[NSApp class]];
        return [[NSIndexSpecifier alloc] initWithContainerClassDescription:containerClassDescription containerSpecifier:nil key:@"downloads" index:idx];
    } else {
        return nil;
    }
}

- (NSString *)scriptingURL {
    return [[self URL] absoluteString];
}

- (SKDownloadStatus)scriptingStatus {
    return [self status];
}

- (void)setScriptingStatus:(SKDownloadStatus)newStatus {
    if (newStatus != status) {
        if (newStatus == SKDownloadStatusCanceled && [self canCancel])
            [self cancel];
        else if ((newStatus == SKDownloadStatusStarting || newStatus == SKDownloadStatusDownloading) && [self canResume])
            [self resume];
    }
}

#pragma mark Actions

- (void)start {
    if (downloadTask || URL == nil) {
        NSBeep();
        return;
    }
    
    [self setExpectedContentLength:NSURLResponseUnknownLength];
    [self setReceivedContentLength:0];
    receivedResponse = NO;
    downloadTask = [[SKDownloadController sharedDownloadController] newDownloadTaskForDownload:self];
    [self setStatus:SKDownloadStatusDownloading];
}

- (void)cancel {
    if ([self canCancel]) {
        
        [downloadTask cancelByProducingResumeData:^(NSData *data){ [self setResumeData:data]; }];
        [[SKDownloadController sharedDownloadController] removeDownloadTask:downloadTask];
        downloadTask = nil;
        [self setStatus:SKDownloadStatusCanceled];
    }
}

- (void)resume {
    if ([self canResume]) {
        
        if (resumeData) {
            
            receivedResponse = NO;
            downloadTask = [[SKDownloadController sharedDownloadController] newDownloadTaskForDownload:self];
            resumeData = nil;
            [self setStatus:SKDownloadStatusDownloading];
            
        } else {
            
            [self cleanup];
            [self setFileURL:nil];
            if (downloadTask) {
                if ([downloadTask state] < NSURLSessionTaskStateCanceling)
                    [downloadTask cancel];
                [[SKDownloadController sharedDownloadController] removeDownloadTask:downloadTask];
                downloadTask = nil;
            }
            [self start];
            
        }
    }
}

- (void)cleanup {
    [self cancel];
    if (fileURL)
        [[NSFileManager defaultManager] removeItemAtURL:[fileURL URLByDeletingLastPathComponent] error:NULL];
    resumeData = nil;
}

- (void)moveToTrash {
    if ([self canRemove] && fileURL)
        [[NSWorkspace sharedWorkspace] recycleURLs:@[fileURL] completionHandler:NULL];
}

- (BOOL)canCancel {
    return [self status] == SKDownloadStatusStarting || [self status] == SKDownloadStatusDownloading;
}

- (BOOL)canRemove {
    return [self status] == SKDownloadStatusFinished || [self status] == SKDownloadStatusFailed || [self status] == SKDownloadStatusCanceled;
}

- (BOOL)canResume {
    return ([self status] == SKDownloadStatusCanceled || [self status] == SKDownloadStatusFailed) && [self URL];
}

- (void)resume:(id)sender {
    if ([self canResume])
        [self resume];
}

- (void)cancelOrRemove:(id)sender {
    if ([self canCancel])
        [self cancel];
    else if ([self canRemove])
        [[SKDownloadController sharedDownloadController] removeObjectFromDownloads:self];
}

- (NSImage *)cancelImage {
    if ([self canCancel])
        return [[self class] cancelImage];
    else if ([self canRemove])
        return [[self class] deleteImage];
    else
        return nil;
}

- (NSImage *)resumeImage {
    if ([self canResume])
        return [[self class] resumeImage];
    else
        return nil;
}

- (NSString *)cancelToolTip {
    if ([self canCancel])
        return NSLocalizedString(@"Cancel download", @"Tool tip message");
    else if ([self canRemove])
        return NSLocalizedString(@"Remove download", @"Tool tip message");
    else
        return nil;
}

- (NSString *)resumeToolTip {
    if ([self canResume])
        return NSLocalizedString(@"Resume download", @"Tool tip message");
    else
        return nil;
}

#pragma mark SKURLDownloadTaskDelegate

- (void)downloadDidWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if ([downloadTask response] && receivedResponse == NO) {
        receivedResponse = YES;
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)[[downloadTask response] MIMEType], kUTTypeData);
        if (UTI) {
            NSString *type = [[NSWorkspace sharedWorkspace] preferredFilenameExtensionForType:CFBridgingRelease(UTI)];
            if (type)
                [self setFileIcon:[[NSWorkspace sharedWorkspace] iconForFileType:type]];
        }
    }
    
    if ([self expectedContentLength] < totalBytesExpectedToWrite)
        [self setExpectedContentLength:totalBytesExpectedToWrite];
    if (totalBytesExpectedToWrite > 0)
        [self setReceivedContentLength:totalBytesWritten];
}

- (void)downloadDidFinishDownloadingToURL:(NSURL *)location {
    NSString *filename = [[downloadTask response] suggestedFilename] ?: [location lastPathComponent];
    NSString *downloadDir = [[[NSUserDefaults standardUserDefaults] stringForKey:SKDownloadsDirectoryKey] stringByExpandingTildeInPath];
    NSURL *downloadURL = nil;
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadDir isDirectory:&isDir] && isDir)
        downloadURL = [NSURL fileURLWithPath:downloadDir isDirectory:NO];
    else
        downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSURL *destinationURL = [[downloadURL URLByAppendingPathComponent:filename isDirectory:NO] uniqueFileURL];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([[destinationURL URLByDeletingLastPathComponent] checkResourceIsReachableAndReturnError:NULL] == NO)
        [fm createDirectoryAtPath:[[destinationURL URLByDeletingLastPathComponent] path] withIntermediateDirectories:YES attributes:nil error:NULL];
    BOOL success = [fm moveItemAtURL:location toURL:destinationURL error:&error];
    [self setFileURL:success ? destinationURL : nil];
    downloadTask = nil;
    [self setStatus:success ? SKDownloadStatusFinished : SKDownloadStatusFailed];
}

- (void)downloadDidFailWithError:(NSError *)error {
    downloadTask = nil;
    [self setFileURL:nil];
    [self setStatus:SKDownloadStatusFailed];
}

#pragma mark Quick Look Panel Support

- (NSURL *)previewItemURL {
    return [self fileURL];
}

- (NSString *)previewItemTitle {
    return [[self URL] absoluteString];
}

@end
