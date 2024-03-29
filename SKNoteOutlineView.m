//
//  SKNoteOutlineView.m
//  Skim
//
//  Created by Christiaan Hofman on 2/25/07.
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

#import "SKNoteOutlineView.h"
#import "SKTypeSelectHelper.h"
#import "NSEvent_SKExtensions.h"
#import "SKApplication.h"
#import "NSGeometry_SKExtensions.h"
#import "NSMenu_SKExtensions.h"

#define NUMBER_OF_TYPES 9

#define PAGE_COLUMNID   @"page"
#define NOTE_COLUMNID   @"note"
#define TYPE_COLUMNID   @"type"
#define COLOR_COLUMNID  @"color"
#define AUTHOR_COLUMNID @"author"
#define DATE_COLUMNID   @"date"

#define SMALL_COLUMN_WIDTH 32.0

#define RESIZE_EDGE_HEIGHT 5.0

@interface SKNoteOutlineView (SKPrivate)
@end

@implementation SKNoteOutlineView

@dynamic fullWidthCellWidth, outlineIndentation, delegate;

static inline NSString *titleForTableColumnIdentifier(NSString *identifier) {
    if ([identifier isEqualToString:NOTE_COLUMNID])
        return NSLocalizedString(@"Note", @"Table header title");
    else if ([identifier isEqualToString:TYPE_COLUMNID])
        return NSLocalizedString(@"Type", @"Table header title");
    else if ([identifier isEqualToString:COLOR_COLUMNID])
        return NSLocalizedString(@"Color", @"Table header title");
    else if ([identifier isEqualToString:PAGE_COLUMNID])
        return NSLocalizedString(@"Page", @"Table header title");
    else if ([identifier isEqualToString:AUTHOR_COLUMNID])
        return NSLocalizedString(@"Author", @"Table header title");
    else if ([identifier isEqualToString:DATE_COLUMNID])
        return NSLocalizedString(@"Date", @"Table header title");
    else
        return nil;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        NSMenu *menu = [NSMenu menu];
        
        for (NSTableColumn *tc in [self tableColumns]) {
            NSString *identifier = [tc identifier];
            NSString *title = titleForTableColumnIdentifier(identifier);
            NSMenuItem *menuItem = [menu addItemWithTitle:title action:@selector(toggleTableColumn:) target:self];
            [menuItem setRepresentedObject:identifier];
            if ([tc maxWidth] >= SMALL_COLUMN_WIDTH)
                [[tc headerCell] setTitle:title];
        }
        
        [[self headerView] setMenu:menu];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if ([theEvent clickCount] == 1 && [[self delegate] respondsToSelector:@selector(outlineView:heightOfRowByItem:)] && [[self delegate] respondsToSelector:@selector(outlineView:setHeight:ofRowByItem:)]) {
        NSPoint mouseLoc = [theEvent locationInView:self];
        NSInteger row = [self rowAtPoint:mouseLoc];
        id item = row != -1 ? [self itemAtRow:row] : nil;
        
        if (item) {
            NSRect rect = SKSliceRect([self rectOfRow:row], RESIZE_EDGE_HEIGHT, [self isFlipped] ? NSMaxYEdge : NSMinYEdge);
            if (NSMouseInRect(mouseLoc, rect, [self isFlipped]) && [NSApp willDragMouse]) {
                CGFloat startHeight = [[self delegate] outlineView:self heightOfRowByItem:item];
                
                [[NSCursor resizeUpDownCursor] push];
                
                while ([theEvent type] != NSEventTypeLeftMouseUp) {
                    theEvent = [[self window] nextEventMatchingMask: NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
                    if ([theEvent type] == NSEventTypeLeftMouseDragged) {
                        CGFloat currentHeight = fmax([self rowHeight], round(startHeight + [theEvent locationInView:self].y - mouseLoc.y));
                        [[self delegate] outlineView:self setHeight:currentHeight ofRowByItem:item];
                        [self noteHeightOfRowChanged:row animating:NO];
                    }
                }
                
                [NSCursor pop];
                return;
            }
        }
    }
    [super mouseDown:theEvent];
}

- (void)toggleTableColumn:(id)sender {
    NSTableColumn *tc = [self tableColumnWithIdentifier:[sender representedObject]];
    [tc setHidden:[tc isHidden] == NO];
    if ([self outlineTableColumn] == tc && [tc isHidden])
        [self collapseItem:nil collapseChildren:YES];
    if ([[self delegate] respondsToSelector:@selector(outlineView:didChangeHiddenOfTableColumn:)])
        [[self delegate] outlineView:self didChangeHiddenOfTableColumn:tc];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([menuItem action] == @selector(toggleTableColumn:)) {
        [menuItem setState:[[self tableColumnWithIdentifier:[menuItem representedObject]] isHidden] ? NSOffState : NSOnState];
        return YES;
    } else if ([[SKNoteOutlineView superclass] instancesRespondToSelector:_cmd]) {
        return [super validateMenuItem:menuItem];
    }
    return YES;
}

- (BOOL)outlineColumnIsFirst {
    for (NSTableColumn *tc in [self tableColumns]) {
        if ([tc isHidden] == NO)
            return tc == [self outlineTableColumn];
    }
    return NO;
}

- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row {
    if (column == -1 || ([self levelForRow:row] > 0 && [[self tableColumns] objectAtIndex:column] == [self outlineTableColumn])) {
        NSRect frame = NSZeroRect;
        NSInteger numColumns = [self numberOfColumns];
        NSArray *tcs = [self tableColumns];
        for (column = 0; column < numColumns; column++) {
            if ([[tcs objectAtIndex:column] isHidden] == NO)
                frame = NSUnionRect(frame, [super frameOfCellAtColumn:column row:row]);
        }
        NSInteger level = [self levelForRow:row];
        if (level > 0 && [self outlineColumnIsFirst])
            frame = SKShrinkRect(frame, -[self indentationPerLevel] * level, NSMinXEdge);
        return frame;
    }
    return [super frameOfCellAtColumn:column row:row];
}

- (CGFloat)fullWidthCellWidth {
    CGFloat spacing = [self intercellSpacing].width;
    CGFloat width = -spacing;
    NSInteger outlineIsFirst = -1;
    for (NSTableColumn *tc in [self tableColumns]) {
        if ([tc isHidden] == NO) {
            if (outlineIsFirst == -1)
                outlineIsFirst = tc == [self outlineTableColumn];
            width += [tc width] + spacing;
        }
    }
    if (outlineIsFirst == 1)
        width -= [self outlineIndentation];
    return width;
}

- (CGFloat)outlineIndentation {
    if (@available(macOS 11.0, *)) {
        if ([self style] == NSTableViewStylePlain)
            return 18.0;
        else if ([self outlineColumnIsFirst])
            return 9.0;
        else
            return 15.0 - floor(0.5 * [self intercellSpacing].width);
    } else {
        return 16.0;
    }
}

#pragma mark Delegate

- (id <SKNoteOutlineViewDelegate>)delegate { return (id <SKNoteOutlineViewDelegate>)[super delegate]; }
- (void)setDelegate:(id <SKNoteOutlineViewDelegate>)newDelegate { [super setDelegate:newDelegate]; }

@end
