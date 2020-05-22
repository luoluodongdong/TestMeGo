//
//  TestStatusToColorValueTransformer.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/7.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigurationEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestStatusToColorValueTransformer : NSValueTransformer

+ (BOOL)allowsReverseTransformation;
+ (Class)transformedValueClass;
- (nullable NSColor *)transformedValue:(nullable id)value;

@end

NS_ASSUME_NONNULL_END
