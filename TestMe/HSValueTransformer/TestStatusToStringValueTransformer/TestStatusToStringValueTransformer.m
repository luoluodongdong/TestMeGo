//
//  TestStatusToStringValueTransformer.m
//  TestMe
//
//  Created by WeidongCao on 2020/5/7.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "TestStatusToStringValueTransformer.h"

@implementation TestStatusToStringValueTransformer

+ (BOOL)allowsReverseTransformation{
    return YES;
}
+ (Class)transformedValueClass{
    return [NSString class];
}
- (nullable NSString *)transformedValue:(nullable id)value{
    NSString *stateStr = @"";
    if (value != nil) {
        if ([value respondsToSelector:@selector(integerValue)]) {
            NSInteger stateValue = [value integerValue] + 0x03;
            switch (stateValue) {
                case 0: //-3
                    stateStr = @"Panic";
                    break;
                case 1: // -2
                    stateStr = @"Error";
                    break;
                case 2: //-1
                    stateStr = @"Fail";
                    break;
                case 3: //0
                    stateStr = @"Testing...";
                    break;
                case 4: //1
                    stateStr = @"Pass";
                    break;
                case 5: //2
                    stateStr = @"Skipped";
                break;
                
                default:
                    stateStr = @"Unknown";
                    break;
            }
        }else{
            [NSException raise:NSInternalInconsistencyException format:@"Value (%@) is not number",value];
        }
    }
    
    if (self.uppercase == YES) {
        return [stateStr uppercaseString];
    }else{
        return stateStr;
    }
}

@end
