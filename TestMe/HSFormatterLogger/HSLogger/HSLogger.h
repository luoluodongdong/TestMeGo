//
//  HSLogger.h
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/11.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "HSFileLogger.h"

extern DDLogLevel ddLogLevel;


NS_ASSUME_NONNULL_BEGIN

// Now define everything how we want it

#define LOG_FLAG_FATAL   (1 << 0)  // 0...000001
#define LOG_FLAG_ERROR   (1 << 1)  // 0...000010
#define LOG_FLAG_WARN    (1 << 2)  // 0...000100
#define LOG_FLAG_NOTICE  (1 << 3)  // 0...001000
#define LOG_FLAG_INFO    (1 << 4)  // 0...010000
#define LOG_FLAG_DEBUG   (1 << 5)  // 0...100000

#define LOG_LEVEL_FATAL   (LOG_FLAG_FATAL)                     // 0...000001
#define LOG_LEVEL_ERROR   (LOG_FLAG_ERROR  | LOG_LEVEL_FATAL ) // 0...000011
#define LOG_LEVEL_WARN    (LOG_FLAG_WARN   | LOG_LEVEL_ERROR ) // 0...000111
#define LOG_LEVEL_NOTICE  (LOG_FLAG_NOTICE | LOG_LEVEL_WARN  ) // 0...001111
#define LOG_LEVEL_INFO    (LOG_FLAG_INFO   | LOG_LEVEL_NOTICE) // 0...011111
#define LOG_LEVEL_DEBUG   (LOG_FLAG_DEBUG  | LOG_LEVEL_INFO  ) // 0...111111

#define HSLogFatal(frmt, ...)   LOG_MAYBE(NO,  ddLogLevel, LOG_FLAG_FATAL,  0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HSLogError(frmt, ...)   LOG_MAYBE(NO,  ddLogLevel, LOG_FLAG_ERROR,  0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HSLogWarn(frmt, ...)    LOG_MAYBE(YES, ddLogLevel, LOG_FLAG_WARN,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HSLogNotice(frmt, ...)  LOG_MAYBE(YES, ddLogLevel, LOG_FLAG_NOTICE, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HSLogInfo(frmt, ...)    LOG_MAYBE(YES, ddLogLevel, LOG_FLAG_INFO,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HSLogDebug(frmt, ...)   LOG_MAYBE(YES, ddLogLevel, LOG_FLAG_DEBUG,  0, nil, __PRETTY_FUNCTION__, frmt,##__VA_ARGS__)

// Log levels: 0-off, 1-error, 2-warn, 3-info, 4-debug, 5-verbose
//static const DDLogLevel ddLogLevel = LOG_LEVEL_DEBUG;

@interface HSLogger : NSObject

//输出到文件/zmq
+(void)initWithFile:(BOOL )fFlag zmq:(NSString *__nullable)url level:(NSUInteger )lev;

//输出到终端
+(void)initConsoleLogger;
//输出到终端/文件
+(void)initFileLoggerWithLevel:(NSUInteger )level;
//输出到终端/文件/zmq
+(void)initZMQLoggerWithLevel:(NSUInteger )level url:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
