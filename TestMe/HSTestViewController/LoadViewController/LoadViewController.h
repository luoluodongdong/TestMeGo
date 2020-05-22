//
//  LogoViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubViewControllerDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface LoadViewController : NSViewController
{
    IBOutlet NSTextField *messageLabel;
    IBOutlet NSProgressIndicator *progressIndicator;
}

@property (weak) id<SubViewControllerDelegate> delegate;

-(void)updateProgressMsg:(NSString *)message indicatorValue:(NSInteger )value;

@end

NS_ASSUME_NONNULL_END
