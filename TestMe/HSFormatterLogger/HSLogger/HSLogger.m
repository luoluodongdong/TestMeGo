//
//  HSLogger.m
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/11.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSLogger.h"
#import "HSLogFormatter.h"
#import "HSFileFormatter1.h"

DDLogLevel ddLogLevel;

@implementation HSLogger

+(void)initConsoleLogger{
    ddLogLevel = LOG_LEVEL_DEBUG;
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    //[DDLog addLogger:[DDOSLogger sharedInstance]];
}

+(void)initLogger{
    ddLogLevel = LOG_LEVEL_DEBUG;
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    //[DDLog addLogger:[DDOSLogger sharedInstance]];
    HSFileLogger *fileLogger = [[HSFileLogger alloc] initWithFilePathPrefix:@"/vault/HSLog"
                                                             FileFolderName:@"LogFolder"
                                                                   fileName:@"Log"
                                                                   withFlag:0];
    [DDLog addLogger:fileLogger];
}
+(void)initFileLoggerWithLevel:(NSUInteger )level{
    ddLogLevel = level;
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    //[DDLog addLogger:[DDOSLogger sharedInstance]];
    HSFileLogger *fileLogger = [[HSFileLogger alloc] initWithFilePathPrefix:@"/vault/HSLog"
                                                             FileFolderName:@"LogFolder"
                                                                   fileName:@"Log"
                                                                   withFlag:0];
    [DDLog addLogger:fileLogger];
}
+(void)initZMQLoggerWithLevel:(NSUInteger )level url:(nonnull NSString *)url{
    //zmq publisher log formatter
    HSLogFormatter *formatter = [[HSLogFormatter alloc] init];
    if (url == nil) {
        url = @"127.0.0.1:10052";
    }
    BOOL status = [formatter initZmqPub:url];
    [[DDOSLogger sharedInstance] setLogFormatter:formatter];
    ddLogLevel = level;
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    
    HSFileLogger *fileLogger = [[HSFileLogger alloc] initWithFilePathPrefix:@"/vault/HSLog"
                                                             FileFolderName:@"LogFolder"
                                                                   fileName:@"Log"
                                                                   withFlag:0];
    //file log formatter
    HSFileFormatter1 *fileFormat1 = [[HSFileFormatter1 alloc] init];
    [fileLogger setLogFormatter:fileFormat1];
    [DDLog addLogger:fileLogger];
    NSLog(@"zmq publisher init result:%hhd",status);
}
+(void)initWithFile:(BOOL )fFlag zmq:(NSString *__nullable)url level:(NSUInteger )lev{
    ddLogLevel = lev;
    HSLogFormatter *formatter = [[HSLogFormatter alloc] init];
    //xcode console & zmq
    formatter.enableZmqFlag = NO;
    if (url != nil) {
        formatter.enableZmqFlag = YES;
        BOOL status = [formatter initZmqPub:url];
        NSLog(@"zmq publisher init result:%hhd",status);
    }
    [[DDOSLogger sharedInstance] setLogFormatter:formatter];
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    //file logger
    if (fFlag) {
        HSFileLogger *fileLogger = [[HSFileLogger alloc] initWithFilePathPrefix:@"/vault/HSLog"
                                                                 FileFolderName:@"LogFolder"
                                                                       fileName:@"Log"
                                                                       withFlag:0];
        //file log formatter
        HSFileFormatter1 *fileFormat1 = [[HSFileFormatter1 alloc] init];
        [fileLogger setLogFormatter:fileFormat1];
        [DDLog addLogger:fileLogger];
    }
}
@end
