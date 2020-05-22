//
//  PasswordViewController.m
//  BurninViews
//
//  Created by WeidongCao on 2020/3/24.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "PasswordViewController.h"

@interface PasswordViewController ()

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [errmsgTF setStringValue:@""];
    [inputPasswordTF setStringValue:@""];
    if (self.rawPasswordStr == nil) {
        self.rawPasswordStr = @"LUXSHARETE";
    }
}
-(IBAction)backBtnAction:(id)sender{
    NSDictionary *msg=@{@"state":@"cancel"};
    [self.delegate messageFromPasswordView:msg];
    [self dismissController:self];
}
-(IBAction)okBtnAction:(id)sender{
    NSString *inputStr = [inputPasswordTF stringValue];
    if ([inputStr isEqualToString:self.rawPasswordStr]) {
        NSDictionary *msg=@{@"state":@"OK"};
        [self.delegate messageFromPasswordView:msg];
        [self dismissController:self];
    }else{
        [inputPasswordTF setStringValue:@""];
        [errmsgTF setStringValue:@"Error:password is wrong!"];
    }
}
@end
