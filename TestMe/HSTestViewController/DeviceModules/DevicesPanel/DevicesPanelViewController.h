//
//  DevicesPanelViewController.h
//  DeviceModuleDevelopment
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "mySerialPanel.h"
#import "myVisaPanel.h"
#import "mySocketPanel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol DevicePanelDelegate <NSObject>

-(void)receivedFromDevicePanel:(NSString *)data identifier:(NSString *)identifier;
-(void)eventFromDevicePanel:(NSDictionary *)event identifier:(NSString *)identifier;

@end


@interface DevicesPanelViewController : NSViewController<SerialPanelDelegate,VisaPanelDelegate,SocketPanelDelegate>

@property (weak) id<DevicePanelDelegate> delegate;
@property NSString *configFile;
@property NSString *panelIdentifier;
@property int index;
//@property NSArray *devicesList;
@property NSMutableDictionary *loadDevicesDict;

@end

NS_ASSUME_NONNULL_END
