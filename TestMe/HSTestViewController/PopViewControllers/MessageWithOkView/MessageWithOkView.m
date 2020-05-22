//
//  MessageWithOkView.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "MessageWithOkView.h"

@interface MessageWithOkView ()

@end

@implementation MessageWithOkView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [titleLabel setStringValue:self.titleName];
    [messageLabel setStringValue:self.message];
}

-(IBAction)okBtnAction:(id)sender{
    [self dismissController:self];
    dispatch_semaphore_signal(self.dismissSemaphore);
}
@end
