//
//  SKFullScreenWindow.m
//  Skim
//
//  Created by Christiaan Hofman on 2/16/07.
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

#import "SKFullScreenWindow.h"

@implementation SKFullScreenWindow

- (instancetype)initWithScreen:(NSScreen *)screen {
    NSRect screenFrame = [(screen ?: [NSScreen mainScreen]) frame];
    self = [self initWithContentRect:screenFrame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    if (self) {
        [self setBackgroundColor:[NSColor blackColor]];
        [self setLevel:NSPopUpMenuWindowLevel];
        [self setReleasedWhenClosed:NO];
        [self setDisplaysWhenScreenProfileChanges:YES];
        [self setExcludedFromWindowsMenu:NO];
        // appartently this is needed for secondary screens
        [self setFrame:screenFrame display:NO];
        [self setAnimationBehavior:NSWindowAnimationBehaviorNone];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow { return YES; }

- (BOOL)canBecomeMainWindow { return YES; }

- (void)sendEvent:(NSEvent *)theEvent {
    if ([theEvent type] == NSEventTypeRightMouseDown || ([theEvent type] == NSEventTypeLeftMouseDown && ([theEvent modifierFlags] & NSEventModifierFlagControl))) {
        if ([[self windowController] respondsToSelector:@selector(handleRightMouseDown:)] && [[self windowController] handleRightMouseDown:theEvent])
            return;
    }
    [super sendEvent:theEvent];
}

- (void)cancelOperation:(id)sender {
    // for some reason this action method is not passed on to the window controller, so we do this ourselves
    if ([[self windowController] respondsToSelector:@selector(cancelOperation:)])
        [[self windowController] cancelOperation:self];
}

@end

