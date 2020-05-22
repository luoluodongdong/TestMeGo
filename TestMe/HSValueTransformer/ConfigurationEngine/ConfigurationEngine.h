//
//  ConfigurationEngine.h
//  ATConsoleTest
//
//  Created by WeidongCao on 2020/3/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigurationEngine : NSObject
+(id)engineerModeBackgroundColor;
+ (id)testModeIdleColor;
+ (id)testModeDisabledColor;
+ (id)nonDefaultProductionModeBackgroundColor;
+ (id)auditModeBackgroundColor;
+ (id)panicColor;
+ (id)testingColor;
+ (id)failColor;
+ (id)relaxedPassColor;
+ (id)passColor;
+ (id)tileClickColor;
+ (id)tileHighlightColor;
+ (id)tileBackgroundColor;
+ (id)secondaryTextColor;
+ (id)primaryTextColor;
+ (id)lightSecondaryTextColor;
+ (id)darkSecondaryTextColor;
+ (id)lightPrimaryTextColor;
+ (id)darkPrimaryTextColor;
@end

NS_ASSUME_NONNULL_END
