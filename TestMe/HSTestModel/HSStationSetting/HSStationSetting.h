//
//  HSSetting.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StationNonUITaskProtocol.h"
//@class HSStationSetting;
NS_ASSUME_NONNULL_BEGIN

@interface HSStationSetting : NSObject

@property NSDictionary *loadedDevices;
@property NSDictionary *paramsList;

@property (weak) id<StationNonUITaskDelegate> delegate;

-(NSDictionary *)executeNonUITaskRequest:(HSTestRequest *)request;

@end

NS_ASSUME_NONNULL_END
