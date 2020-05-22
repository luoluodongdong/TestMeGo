//
//  HSEvent.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/6.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSUnit.h"
NS_ASSUME_NONNULL_BEGIN

extern NSString * const HSEventHSUnitKey;

extern NSString * const HSEventTestNumberKey;
extern NSString * const HSEventTestNameKey;
extern NSString * const HSEventTestIDKey;
extern NSString * const HSEventTestRecordKey;
extern NSString * const HSEventTestRecordUUIDKey;
extern NSString * const HSEventTestPriorityKey;

@interface HSEvent : NSObject

@property (strong, nonatomic, readonly) NSDate *creationDate;
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSDictionary *userInfo;

- (instancetype)initWithName:(NSString *)name userInfo:(NSDictionary *)userInfo;

- (HSUnit *)getUnit;

@end

NS_ASSUME_NONNULL_END
