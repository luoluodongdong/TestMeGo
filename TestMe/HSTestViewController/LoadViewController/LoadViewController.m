//
//  LogoViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "LoadViewController.h"

@interface LoadViewController ()

@end

@implementation LoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [messageLabel setStringValue:@"Loading..."];
    [progressIndicator setDoubleValue:0.0];
}

-(void)viewDidAppear{
//    [NSThread detachNewThreadWithBlock:^{
//        [NSThread sleepForTimeInterval:5.0];
//        NSDictionary *eventDict = @{@"status":@(1)};
//        [self.delegate event:eventDict fromSubView:@"LoadView"];
//    }];
}

-(void)updateProgressMsg:(NSString *)message indicatorValue:(NSInteger )value{
    [NSThread sleepForTimeInterval:0.2];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->messageLabel setStringValue:message];
        [self->progressIndicator setDoubleValue:value];
    });
    if (value == 100) {
        [NSThread sleepForTimeInterval:0.5];
        NSDictionary *eventDict = @{@"status":@(1)};
        [self.delegate event:eventDict fromSubView:@"LoadView"];
    }
}

@end
