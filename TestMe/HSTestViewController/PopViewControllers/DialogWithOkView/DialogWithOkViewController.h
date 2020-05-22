//
//  DialogWithOkViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DialogWithOkViewController : NSViewController

{
    IBOutlet NSTextField *titleLabel;
    IBOutlet NSTextField *messageLabel;
    IBOutlet NSImageView *imageView;
    IBOutlet NSButton *okBtn;
}
@property (retain, nonatomic) dispatch_semaphore_t dismissSemaphore;
//type:info,config,warning,error
@property NSString *type;
@property NSString *titleStr;
@property NSString *messageStr;

-(IBAction)okBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
