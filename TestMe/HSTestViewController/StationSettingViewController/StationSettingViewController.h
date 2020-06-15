//
//  FixtureSettingViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StationNonUITaskProtocol.h"
#import "DevicesPanelViewController.h"
#import "StationUITaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface StationSettingViewController : NSViewController<StationNonUITaskDelegate,DevicePanelDelegate>
{
    IBOutlet NSButton *backBtn;
    IBOutlet NSTextField *titleLabel;
    
    IBOutlet NSButton *loopCountBtn;
    IBOutlet NSTextField *loopValueField;
    
    IBOutlet NSButton *pdcaEnableBtn;
    
}

@property (weak) id<StationUITaskDelegate> stationUITaskDelegate;

-(void)initView;
-(void)closeAllLoadDevices;
-(IBAction)backBtnAction:(id)sender;

-(IBAction)loopCountBtnAction:(id)sender;
-(IBAction)pdcaEnableBtn:(id)sender;

@end

NS_ASSUME_NONNULL_END
