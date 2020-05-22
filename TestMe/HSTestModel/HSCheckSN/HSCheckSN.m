//
//  HSCheckSN.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/22.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSCheckSN.h"
#import "HSTestDefines.h"

@implementation HSCheckSN

-(BOOL)snIsOk:(NSString *)sn error:(NSError **)err{
    if ([sn length] != 6) {
        *err=HSError(@"com.HSCheckSN.snIsOk", 0x64, @"sn length wrong!");
        return NO;
    }
    return YES;
}

@end
