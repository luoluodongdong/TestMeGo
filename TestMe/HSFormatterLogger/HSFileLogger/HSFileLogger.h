//
//  HSFileLogger.h
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/11.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSFileLogger : DDFileLogger

@property (retain, nonatomic) NSString *filePathPrefix;
@property (retain, nonatomic) NSString *folderName;
@property (retain, nonatomic) NSString *logName;
//@property (assign, nonatomic) NSUInteger logFlag;

- (instancetype)initWithFilePathPrefix:(NSString *)filePathPrefix
                        FileFolderName:(NSString *)folderName
                              fileName:(NSString *)logName
                              withFlag:(NSUInteger)flag;

@end


NS_ASSUME_NONNULL_END
