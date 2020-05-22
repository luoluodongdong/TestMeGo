//
//  HSTestplan.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/5.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSTestplan : NSObject

+(NSMutableArray *)loadTestplan:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
