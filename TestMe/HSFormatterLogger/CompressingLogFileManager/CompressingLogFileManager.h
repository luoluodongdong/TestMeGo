//
//  CompressingLogFileManager.h
//  LogFileCompressor
//
//  CocoaLumberjack Demos
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface CompressingLogFileManager : DDLogFileManagerDefault
{
    BOOL upToDate;
    BOOL isCompressing;
}

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory
                             fileName:(NSString *)name;

@end
