//
//  HSTestRequest.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSTestLimit.h"
NS_ASSUME_NONNULL_BEGIN

@interface HSTestRequest : NSObject

@property HSTestLimit *limit;
@property int index;
@property NSString *identifier;
@property NSString *name;
@property NSDictionary *action;
@property NSDictionary *params;

+(HSTestRequest *)initWithLimit:(HSTestLimit *__nullable)limit index:(int )index identifier:(NSString *__nullable)identifier name:(NSString *__nullable)name action:(NSDictionary *__nullable)action params:(NSDictionary *__nullable)params;

@end

NS_ASSUME_NONNULL_END
