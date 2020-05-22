//
//  HSTestDefines.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/22.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSTestDefines.h"

NSError* HSError(NSString *domain, NSUInteger code, NSString *message){
    return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}
