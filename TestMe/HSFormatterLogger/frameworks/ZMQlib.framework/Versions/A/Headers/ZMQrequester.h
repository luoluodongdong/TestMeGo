//
//  ZMQrequester.h
//  OCZMQTest
//
//  Created by WeidongCao on 2020/5/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMQObjC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMQrequester : NSObject

-(BOOL)initRequesterWithUrl:(NSString *)url;
-(NSString *)queryWithCmd:(NSString *)cmd;
-(NSString *)queryWithCmd:(NSString *)cmd timeout:(NSUInteger )to;
@end

NS_ASSUME_NONNULL_END
