//
//  ScanSN.h
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/22.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubViewControllerDelegate.h"
#import "HSCheckSN.h"

@interface ScanSN: NSViewController
{
    IBOutlet NSTextField *_inputSN_TF;
    IBOutlet NSTextField *_showSN_TF;
    IBOutlet NSButton *_backBtn;
    IBOutlet NSTextField *_errMsgLabel;
}

@property (nonatomic,weak) id<SubViewControllerDelegate> delegate;

@property (nonatomic,assign) int UNIT_COUNT;
@property (nonatomic) NSString *_firstSN;

@property (nonatomic) NSArray *_select_Slot_BoolArr;

-(IBAction)inputSNAction:(id)sender;
-(IBAction)backBtnAction:(id)sender;

-(void)initScanSnView;
@end
