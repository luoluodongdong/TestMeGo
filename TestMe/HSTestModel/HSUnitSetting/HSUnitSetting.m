//
//  HSUnitSetting.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSUnitSetting.h"

@implementation HSUnitSetting

-(NSDictionary *)executeNonUITaskRequest:(HSTestRequest *)request{
    return [self.delegate unitNonUITaskRequest:request];
}

@end
