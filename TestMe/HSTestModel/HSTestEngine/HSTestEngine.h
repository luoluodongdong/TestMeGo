//
//  HSTestEngine.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UnitNonUITaskProtocol.h"
#import "UnitCallStationTaskProtocol.h"
#import "HSTest.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSTestEngine : NSObject

@property (assign) int index;
@property (assign) short state;
@property (retain, nonatomic) HSUnitSetting *setting;
@property (weak) id<UnitCallStationTaskDelegate> unitCallStationTaskDelegate;

-(HSTestRecord *)executeTestRequest:(HSTestRequest *)request;

-(void)releaseSyncSignal:(NSDictionary *)response;

@end

NS_ASSUME_NONNULL_END
