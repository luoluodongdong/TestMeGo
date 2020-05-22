//
//  TestStatusToColorValueTransformer.m
//  TestMe
//
//  Created by WeidongCao on 2020/5/7.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "TestStatusToColorValueTransformer.h"


@implementation TestStatusToColorValueTransformer

+ (BOOL)allowsReverseTransformation{
    return YES;
}
+ (Class)transformedValueClass{
    return [NSColor class];
}
- (nullable NSColor *)transformedValue:(nullable id)value{
    id color = NULL;
    if (value != nil) {
        if([value isKindOfClass:[NSNumber class]]){
            short statusValue = [value integerValue] + 0x02;
            switch (statusValue) {
                case 0: //-2 error
                    color = [ConfigurationEngine panicColor];
                    break;
                
                case 1: //-1 fail
                    color = [ConfigurationEngine failColor];
                    break;
                    
                case 2: //0 not set
                    color = [NSColor systemYellowColor];//[ConfigurationEngine tileBackgroundColor];
                    break;
                
                case 3: //1 pass
                    color = [ConfigurationEngine passColor];
                    break;
                
                case 4: //2 skipped
                    color = [ConfigurationEngine relaxedPassColor];
                    break;
                    
                default:
                    color = [ConfigurationEngine failColor];
                    break;
            }
        }else{
            color = [ConfigurationEngine failColor];
            [NSException raise:NSInternalInconsistencyException format:@"Value (%@) is not number",value];
        }
        
    }
    return color;
}

@end
