//
//  ExitViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/25.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN


@interface ExitViewController : NSViewController
{
    IBOutlet NSButton *okBtn;
    IBOutlet NSButton *cancelBtn;
    IBOutlet NSTextField *messageLabel;
    IBOutlet NSProgressIndicator *processIndicator;
}

@property (weak) id<SubViewControllerDelegate> delegate;
-(void)updateProgressMsg:(NSString *)message indicatorValue:(NSInteger )value;

-(IBAction)okBtn:(id)sender;
-(IBAction)cancelBtn:(id)sender;

@end

NS_ASSUME_NONNULL_END
