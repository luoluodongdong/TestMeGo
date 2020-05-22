//
//  PasswordViewController.h
//  BurninViews
//
//  Created by WeidongCao on 2020/3/24.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PasswordViewDelegate <NSObject>

-(void)messageFromPasswordView:(NSDictionary *)msg;

@end
@interface PasswordViewController : NSViewController
{
    IBOutlet NSButton *backBtn;
    IBOutlet NSTextField *inputPasswordTF;
    IBOutlet NSTextField *errmsgTF;
    IBOutlet NSButton *okBtn;
}
@property (strong, nonatomic) NSString *rawPasswordStr;
@property (weak) id<PasswordViewDelegate> delegate;

-(IBAction)backBtnAction:(id)sender;
-(IBAction)okBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
