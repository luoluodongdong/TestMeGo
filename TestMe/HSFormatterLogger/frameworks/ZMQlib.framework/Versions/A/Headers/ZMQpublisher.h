//
//  ZMQpublisher.h
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMQObjC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMQpublisher : NSObject

-(BOOL)initPublisherWithUrl:(NSString *)url;
-(void)publishMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
