//
//  HSCheckSN.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/22.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface HSCheckSN : NSObject

-(BOOL)snIsOk:(NSString *)sn error:(NSError **)err;

@end

NS_ASSUME_NONNULL_END
