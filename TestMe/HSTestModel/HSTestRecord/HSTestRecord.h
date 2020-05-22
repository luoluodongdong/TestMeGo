//
//  HSTestRecord.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSTestLimit.h"
#import "HSTestDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSTestRecord : NSObject

@property double duration;
@property NSDate *start;
@property NSDate *end;
@property HSTestLimit *limit;
@property NSString *measurement;
@property HSTestStatus result;
@property NSError *failureInfo;

+(HSTestRecord *)initWithResult:(HSTestStatus )result start:(NSDate *__nullable)start end:(NSDate *__nullable)end duration:(NSTimeInterval )duration measurement:(NSString *__nullable)value limit:(HSTestLimit *__nullable)limit failureInfo:(NSError *__nullable)err;

@end

NS_ASSUME_NONNULL_END
