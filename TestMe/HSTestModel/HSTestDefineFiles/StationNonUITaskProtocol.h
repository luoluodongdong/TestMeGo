//
//  StationNonUITaskProtocol.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "HSTestRecord.h"
#import "HSTestRequest.h"

@protocol StationNonUITaskDelegate <NSObject>

-(NSDictionary *)stationNonUITaskRequest:(HSTestRequest *)request;

@end
