//
//  ConfigurationEngine.m
//  ATConsoleTest
//
//  Created by WeidongCao on 2020/3/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ConfigurationEngine.h"

@implementation ConfigurationEngine
+ (id)testModeIdleColor{
    //return [NSColor colorWithRed:238.0/255.0 green:160.0/255.0 blue:238.0/255.0 alpha:1.0];
    return [NSColor whiteColor];
}
+ (id)testModeDisabledColor{
    return [NSColor grayColor];
}
+ (id)nonDefaultProductionModeBackgroundColor{
    return [NSColor colorWithRed:255.0/255.0 green:182.0/255.0 blue:193.0/255.0 alpha:1.0];;
}
+ (id)auditModeBackgroundColor{
    return [NSColor colorWithRed:255.0/255.0 green:105.0/255.0 blue:185.0/255.0 alpha:0.8];
}
+(id)engineerModeBackgroundColor{
    return [NSColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.8];
}
+ (id)panicColor{
    return [NSColor colorWithRed:255.0/255.0 green:99.0/255.0 blue:71.0/255.0 alpha:1.0];
}
+ (id)testingColor{
    return [NSColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1.0];
}
+ (id)failColor{
    return [NSColor colorWithRed:255.0/255.0 green:99.0/255.0 blue:71.0/255.0 alpha:1.0];
}
+ (id)relaxedPassColor{
    return [NSColor systemOrangeColor];
}
+ (id)passColor{
    return [NSColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:127.0/255.0 alpha:1.0];
}
+ (id)tileClickColor{
    //紫罗兰
    return [NSColor colorWithRed:238.0/255.0 green:160.0/255.0 blue:238.0/255.0 alpha:1.0];
}
+ (id)tileHighlightColor{
    //热情粉色
    return [NSColor colorWithRed:255.0/255.0 green:105.0/255.0 blue:185.0/255.0 alpha:1.0];
}
+ (id)tileBackgroundColor{
    //苍白的宝石绿
    return [NSColor colorWithRed:175.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
}
+ (id)secondaryTextColor{
    return [NSColor blackColor];
}
+ (id)primaryTextColor{
    return [NSColor blackColor];
}
+ (id)lightSecondaryTextColor{
    return [NSColor blueColor];
}
+ (id)darkSecondaryTextColor{
    return [NSColor blackColor];
}
+ (id)lightPrimaryTextColor{
    return [NSColor blackColor];
}
+ (id)darkPrimaryTextColor{
    return [NSColor blueColor];
}
@end
