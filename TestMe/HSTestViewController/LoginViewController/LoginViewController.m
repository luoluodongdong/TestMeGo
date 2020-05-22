//
//  LoginViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [msgLabel setStringValue:@""];
}
-(void)viewDidAppear{
    [userTextField becomeFirstResponder];
    
}
-(IBAction)loginBtnAction:(id)sender{
    
    NSDictionary *eventDict=@{@"status":@(1)};
    [self.delegate event:eventDict fromSubView:@"LoginView"];
}
@end
