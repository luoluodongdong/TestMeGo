//
//  HSSetting.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSStationSetting.h"
@interface HSStationSetting()


@end

@implementation HSStationSetting

-(NSDictionary *)executeNonUITaskRequest:(HSTestRequest *)request{
    return [self.delegate stationNonUITaskRequest:request];
    
}
@end
