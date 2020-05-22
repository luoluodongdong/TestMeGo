//
//  UnitBox.m
//  ATConsoleTest
//
//  Created by WeidongCao on 2020/3/26.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "UnitBox.h"

@implementation UnitBox

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
}
- (void)setFillColor:(NSColor *)color{
    [self setCurrentFillColor:color];
    if (self.isHighlighting == YES) {
        NSColor *color = [self.currentFillColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        CGFloat redValue = [color redComponent];
        CGFloat greenValue = [color greenComponent];
        CGFloat blueValue = [color blueComponent];
        NSColor *highLightColor = [NSColor colorWithRed:redValue green:greenValue blue:blueValue alpha:0.9];
        [super setFillColor:highLightColor];
    }else{
        [super setFillColor:color];
    }
}
- (void)updateTrackingAreas{
    [super updateTrackingAreas];
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds] options:0x21 owner:self userInfo:nil];
    [self setTrackingArea:area];
    [self addTrackingArea:area];
    NSPoint point = [[self window] mouseLocationOutsideOfEventStream];
    [self convertPoint:point fromView:self];
    if(CGRectContainsPoint([self bounds], point) != 0x0){
        [self mouseEntered:[NSEvent new]];
    }else{
        [self mouseExited:[NSEvent new]];
    }
}
- (void)mouseExited:(NSEvent *)event{
    self->_isHighlighting = NO;
    [self setFillColor:self.currentFillColor];
}
- (void)mouseEntered:(NSEvent *)event{
    NSColor *color = [self.currentFillColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat redValue = [color redComponent];
    CGFloat greenValue = [color greenComponent];
    CGFloat blueValue = [color blueComponent];
    NSColor *highLightColor = [NSColor colorWithRed:redValue green:greenValue blue:blueValue alpha:0.9];
    self->_isHighlighting = YES;
    [super setFillColor:highLightColor];
}

@end
