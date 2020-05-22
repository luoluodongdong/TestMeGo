//
//  DialogWithOkViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "DialogWithOkViewController.h"

@interface DialogWithOkViewController ()

@end

@implementation DialogWithOkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [titleLabel setStringValue:self.titleStr];
    [messageLabel setStringValue:self.messageStr];
    if ([self.type isEqualToString:@"info"]) {
        [imageView setImage:[NSImage imageNamed:NSImageNameInfo]];
    }
    else if([self.type isEqualToString:@"config"]){
        [imageView setImage:[NSImage imageNamed:NSImageNameAdvanced]];
    }
    else if([self.type isEqualToString:@"warning"]){
        [imageView setImage:[NSImage imageNamed:NSImageNameCaution]];
    }
    else if([self.type isEqualToString:@"error"]){
        [imageView setImage:[NSImage imageNamed:NSImageNameCaution]];
        [self.view setWantsLayer:YES];
        [self.view.layer setBackgroundColor:[NSColor systemRedColor].CGColor];
    }
    else {
        [imageView setImage:[NSImage imageNamed:NSImageNameInfo]];
    }
}

-(IBAction)okBtnAction:(id)sender{
    [self dismissController:self];
    dispatch_semaphore_signal(self.dismissSemaphore);
}
@end
