//
//  HSTestLimit.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSTestLimit.h"

@implementation HSTestLimit

+(HSTestLimit *)initWithUnit:(NSString *__nullable)unit low:(NSString *__nullable)low up:(NSString *__nullable)up{
    HSTestLimit *limit = [[HSTestLimit alloc] init];
    limit.unit = unit;
    limit.low = low;
    limit.up = up;
    return limit;
}

@end
