//
//  UnitSettingViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UnitNonUITaskProtocol.h"
#import "DevicesPanelViewController.h"
#import "StationUITaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnitSettingViewController : NSViewController<UnitNonUITaskDelegate,DevicePanelDelegate>
{
    IBOutlet NSButton *backBtn;
    IBOutlet NSTextField *titleLabel;
}
@property (weak) id<StationUITaskDelegate> stationUITaskDelegate;
@property int index;

-(void)initView;
-(void)closeAllLoadDevices;
-(IBAction)backBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
