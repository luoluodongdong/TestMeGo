//
//  HSUnitSetting.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSTest.h"
#import "UnitNonUITaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSUnitSetting : NSObject

@property (weak) id<UnitNonUITaskDelegate> delegate;

-(NSDictionary *)executeNonUITaskRequest:(HSTestRequest *)request;

@end

NS_ASSUME_NONNULL_END
