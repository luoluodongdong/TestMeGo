//
//  ExitViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/5/25.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ExitViewController.h"

@interface ExitViewController ()

@end

@implementation ExitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [messageLabel setHidden:YES];
    [processIndicator setHidden:YES];
    [messageLabel setStringValue:@"Waiting..."];
    [processIndicator setDoubleValue:0.0];
}

-(IBAction)okBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(event:fromSubView:)]) {
        [okBtn setHidden:YES];
        [cancelBtn setHidden:YES];
        [messageLabel setHidden:NO];
        [processIndicator setHidden:NO];
        [self.delegate event:@{@"type":@"exit"} fromSubView:@"ExitView"];
    }
}
-(IBAction)cancelBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(event:fromSubView:)]) {
        [self.delegate event:@{@"type":@"cancel"} fromSubView:@"ExitView"];
        [self dismissViewController:self];
    }
}
-(void)updateProgressMsg:(NSString *)message indicatorValue:(NSInteger )value{
    //[NSThread sleepForTimeInterval:0.2];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self->messageLabel setStringValue:message];
        [self->processIndicator setDoubleValue:value];
    });
    if (value == 100) {
        [NSThread sleepForTimeInterval:0.5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewController:self];
        });
        [self.delegate event:@{@"type":@"finish"} fromSubView:@"ExitView"];
    }
}
@end
