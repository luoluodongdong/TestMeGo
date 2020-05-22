//
//  HSFileLogger.m
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/11.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSFileLogger.h"
#import "CompressingLogFileManager.h"

@implementation HSFileLogger

- (instancetype)initWithFilePathPrefix:(NSString *)filePathPrefix
                        FileFolderName:(NSString *)folderName
                              fileName:(NSString *)logName
                              withFlag:(NSUInteger)flag{
    //新建一个文件夹去保存
    _filePathPrefix = filePathPrefix;//路径前缀
    _folderName = folderName;//文件夹名
    _logName = logName;//log文件名
    
    //_logFlag = flag;//这个就是上下文，为了分文件输出
    
    NSString *logsDirectory = [filePathPrefix stringByAppendingPathComponent:folderName];
    CompressingLogFileManager *defaultLogFileManager = [[CompressingLogFileManager alloc] initWithLogsDirectory:logsDirectory fileName:logName];
    
    HSFileLogger *fileLogger = [self initWithLogFileManager:defaultLogFileManager];
    fileLogger.maximumFileSize = (1024 * 1024 * 100); //  1 Mb * 100
    fileLogger.rollingFrequency = 0;   // disable
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
    
    return fileLogger;
}

@end

