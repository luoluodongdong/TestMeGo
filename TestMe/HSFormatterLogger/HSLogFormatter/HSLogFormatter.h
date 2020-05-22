//
//  HSLogFormatter.h
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSLogFormatter : NSObject<DDLogFormatter>

@property BOOL enableZmqFlag;

-(BOOL)initZmqPub:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
