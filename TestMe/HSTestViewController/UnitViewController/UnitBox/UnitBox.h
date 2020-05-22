//
//  UnitBox.h
//  ATConsoleTest
//
//  Created by WeidongCao on 2020/3/26.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnitBox : NSBox

@property(retain, nonatomic) NSTrackingArea *trackingArea; // @synthesize trackingArea=_trackingArea;
@property(retain, nonatomic) NSColor *currentFillColor; // @synthesize currentFillColor=_currentFillColor;
@property(readonly, nonatomic) BOOL isHighlighting; // @synthesize isHighlighting=_isHighlighting;

- (void)setFillColor:(NSColor *)color;
- (void)updateTrackingAreas;
- (void)mouseExited:(NSEvent *)event;
- (void)mouseEntered:(NSEvent *)event;
- (void)drawRect:(NSRect)dirtyRect;

@end

NS_ASSUME_NONNULL_END
