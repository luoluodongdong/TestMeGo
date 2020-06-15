//
//  SecurityManager.h
//  TestMe
//
//  Created by WeidongCao on 2020/6/8.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaSecurity.h"

NS_ASSUME_NONNULL_BEGIN

@interface SecurityManager : NSObject

+(BOOL)CheckSecurityFolder:(NSString *)folder error:(NSError **)err;

@end

NS_ASSUME_NONNULL_END
