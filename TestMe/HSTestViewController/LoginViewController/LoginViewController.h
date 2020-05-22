//
//  LoginViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : NSViewController
{
    IBOutlet NSBox *loginBox;
    IBOutlet NSTextField *userTextField;
    IBOutlet NSTextField *keyTextField;
    IBOutlet NSTextField *msgLabel;
    IBOutlet NSButton *loginBtn;
}

-(IBAction)loginBtnAction:(id)sender;

@property (weak) id<SubViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
