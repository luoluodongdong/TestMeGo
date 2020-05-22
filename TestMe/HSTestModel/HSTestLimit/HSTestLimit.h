//
//  HSTestLimit.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSTestLimit : NSObject

@property NSString *low;
@property NSString *up;
@property NSString *unit;

+(HSTestLimit *)initWithUnit:(NSString *__nullable)unit low:(NSString *__nullable)low up:(NSString *__nullable)up;

@end

NS_ASSUME_NONNULL_END
