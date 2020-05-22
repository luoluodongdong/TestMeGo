//
//  TestStatusToStringValueTransformer.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/7.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestStatusToStringValueTransformer : NSValueTransformer

@property(nonatomic) BOOL uppercase;

+ (BOOL)allowsReverseTransformation;
+ (Class)transformedValueClass;
- (nullable NSString *)transformedValue:(nullable id)value;

@end

NS_ASSUME_NONNULL_END
