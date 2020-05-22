//
//  MessageWithOkView.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageWithOkView : NSViewController
{
    IBOutlet NSTextField *titleLabel;
    IBOutlet NSTextField *messageLabel;
    IBOutlet NSButton *okBtn;
}

@property (retain, nonatomic) dispatch_semaphore_t dismissSemaphore;
@property (retain, nonatomic) NSString *titleName;
@property (retain, nonatomic) NSString *message;

-(IBAction)okBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
