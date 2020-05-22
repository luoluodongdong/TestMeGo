//
//  HSTestEngine.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSTestEngine.h"
#import "HSTestFunctionDefines.h"
#import "HSLogger.h"

@interface HSTestEngine()

@property dispatch_semaphore_t syncSemaphore;
@property NSDictionary *syncTaskResponseDict;

@end

@implementation HSTestEngine

-(HSTestRecord *)executeTestRequest:(HSTestRequest *)request{
    HSTestRecord *record = [HSTestRecord initWithResult:HSTestStatusNotSet
                                                  start:[NSDate date]
                                                    end:nil
                                               duration:0
                                            measurement:@""
                                                  limit:request.limit
                                            failureInfo:nil];
    NSString *function = [request.action objectForKey:@"function"];
    NSString *param1 = [request.params objectForKey:@"param1"];
    if ([function isEqualToString:HSTestFunction_asyncDialog]) {
        //async UI task
        NSDictionary *response = [self.unitCallStationTaskDelegate unitCallStationTaskRequest:request];
        if ([[response objectForKey:@"status"] boolValue] == YES) {
            record.result = HSTestStatusPass;
            record.measurement = [response objectForKey:@"data"];
        }else{
            NSError *error = HSError(@"com.testEngine.dialog", 0x64, [response objectForKey:@"msg"]);
            record.result = HSTestStatusFail;
            record.failureInfo = error;
        }
    }
    else if([function isEqualToString:HSTestFunction_syncDialog]){
        //station sync task
        [self executeSyncRequest:request record:&record];
    }
    else if([function isEqualToString:HSTestFunction_calculate]){
        NSString *cmd = [request.params objectForKey:@"param1"];
        NSString *response = @"";
        NSError *err = NULL;
        if ([self executePyCmd:cmd response:&response error:&err]) {
            record.result = [self getTestResult:response limit:record.limit];
            if (record.result != HSTestStatusPass) {
                record.failureInfo = HSError(@"com.testEngine.syncRequest", 0x64, @"fail out of limit");
            }
            record.measurement = response;
        }else{
            record.result = HSTestStatusError;
        }
        record.failureInfo = err;
    }
    else if([function isEqualToString:HSTestFunction_fixture]){
        //station sync task
        [self executeSyncRequest:request record:&record];
    }
    else if([function isEqualToString:HSTestFunction_dmm]){
        //unit async NonUI task
        NSDictionary *response = [self.setting executeNonUITaskRequest:request];
        record.measurement = [response objectForKey:@"data"];
        if ([[response objectForKey:@"status"] boolValue] == YES) {
            record.result = [self getTestResult:record.measurement limit:record.limit];
            if (record.result != HSTestStatusPass) {
                record.failureInfo = HSError(@"com.testEngine.syncRequest", 0x64, @"fail out of limit");
            }
        }else{
            NSError *error = HSError(@"com.testEngine.dmm", 0x64, @"execute nonUI task request fail");
            record.result = HSTestStatusFail;
            record.failureInfo = error;
        }
        
    }else{
        record.result = HSTestStatusError;
        NSError *error = HSError(@"com.testEngine.functionError", 0x64, [NSString stringWithFormat:@"unknown function<%@>",function]);
        record.failureInfo = error;
    }
    
    record.end = [NSDate date];
    record.duration = [record.end timeIntervalSinceDate:record.start];
    [self printLog:[NSString stringWithFormat:@"func:%@ value:%@ result:%d",function,record.measurement,record.result]];
    return record;
}
-(void)executeSyncRequest:(HSTestRequest *)request record:(HSTestRecord **)record{
    //sync task
    self.syncTaskResponseDict = nil;
    self.syncSemaphore = dispatch_semaphore_create(0x0);
    [NSThread detachNewThreadWithBlock:^{
        [self.unitCallStationTaskDelegate unitCallStationTaskRequest:request];
    }];
    [self printLog:@"dispatch_semaphore_wait"];
    //wait sync signal
    dispatch_semaphore_wait(self.syncSemaphore, DISPATCH_TIME_FOREVER);
    
    if ([[self.syncTaskResponseDict objectForKey:@"status"] boolValue] == YES) {
        (*record).measurement = [self.syncTaskResponseDict objectForKey:@"data"];
        (*record).result = [self getTestResult:(*record).measurement limit:(*record).limit];
        if ((*record).result != HSTestStatusPass) {
            (*record).failureInfo = HSError(@"com.testEngine.syncRequest", 0x64, @"fail out of limit");
        }
    }else{
        NSError *error = HSError(@"com.testEngine.syncRequest", 0x64, [self.syncTaskResponseDict objectForKey:@"msg"]);
        (*record).result = HSTestStatusFail;
        (*record).failureInfo = error;
    }
}
-(HSTestStatus)getTestResult:(NSString *)value limit:(HSTestLimit *)limit{
    //NSString *msg = [NSString stringWithFormat:@"[getTestResult]value:%@ low:%@ up:%@ unit:%@",value,limit.low,limit.up,limit.unit];
    //[self printLog:msg];
    BOOL limit_low_is_empty = [limit.low isEqualToString:@""];
    BOOL limit_up_is_empty = [limit.up isEqualToString:@""];
    if (limit_low_is_empty && limit_up_is_empty) {
        return HSTestStatusPass;
    }
    BOOL limit_low_is_string = [self isStringVal:limit.low];
    BOOL limit_up_is_string = [self isStringVal:limit.up];
    if (limit_low_is_empty && limit_up_is_empty == NO) {
        if (limit_up_is_string == YES) {
            if([value isEqualToString:limit.up] == YES){
                return HSTestStatusPass;
            }else{
                return HSTestStatusFail;
            }
        }else{
            if ([self isStringVal:value]) {
                return HSTestStatusFail;
            }
            double limit_up = [limit.up doubleValue];
            double value_double = [value doubleValue];
            return value_double <= limit_up ? HSTestStatusPass : HSTestStatusFail;
        }
    }
    if (limit_low_is_empty == NO && limit_up_is_empty) {
        if (limit_low_is_string) {
            if([value isEqualToString:limit.low] == YES){
                return HSTestStatusPass;
            }else{
                return HSTestStatusFail;
            }
        }else{
            if ([self isStringVal:value]) {
                return HSTestStatusFail;
            }
            double limit_low = [limit.low doubleValue];
            double value_double = [value doubleValue];
            return value_double >= limit_low ? HSTestStatusPass : HSTestStatusFail;
        }
    }
    if (limit_low_is_empty == NO && limit_up_is_empty == NO) {
        if (limit_low_is_string || limit_up_is_string) {
            if([value isEqualToString:limit.low] == YES){
                return HSTestStatusPass;
            }else{
                return HSTestStatusFail;
            }
        }
        if (limit_low_is_string == NO && limit_up_is_string == NO) {
            if ([self isStringVal:value]) {
                return HSTestStatusFail;
            }
            double limit_low = [limit.low doubleValue];
            double limit_up = [limit.up doubleValue];
            double value_double = [value doubleValue];
            if (value_double >= limit_low && value_double <=limit_up) {
                return HSTestStatusPass;
            }else{
                return HSTestStatusFail;
            }
        }
    }
    
    return HSTestStatusFail;
}
-(BOOL)isStringVal:(NSString *)aString{
    NSString *regex = @"^[A-Za-z]+$";
    // 创建谓词对象并设定条件表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    // 字符串判断，然后BOOL值
    return [predicate evaluateWithObject:aString];
}
//realease sync signal
-(void)releaseSyncSignal:(NSDictionary *)response{
    self.syncTaskResponseDict = response;
    dispatch_semaphore_signal(self.syncSemaphore);
}

-(BOOL)executePyCmd:(NSString *)cmd response:(NSString **)resp error:(NSError **)err{
    NSString *cmd2=[NSString stringWithFormat:@"%@/scripts/ExePyCmd -c ",[[NSBundle mainBundle] resourcePath]];
    //NSString *cmd1 = @"/Users/weidongcao/Desktop/ExePyCmd/dist/ExePyCmd -c ";
    NSString *command = [NSString stringWithFormat:@"%@%@",cmd2,cmd];
    //[self printLog:command];
    NSString *response = [self cmdExe:command];
    NSArray *resArr = [response componentsSeparatedByString:@"\n"];
    NSLog(@"%@",resArr);
    if ([resArr containsObject:@"[ACK]"]) {
        *resp = [resArr firstObject];
        return YES;
    }
    *err = HSError(@"com.executePyCmd", 0x64, @"execute py command failure");
    return NO;
}
- (NSString *)cmdExe:(NSString *)cmd
{
    // 初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    // "/Users/weidongcao/Desktop/ExePyCmd/dist/ExePyCmd"
    //[task setLaunchPath:@"/Users/weidongcao/Desktop/ExePyCmd/dist/ExePyCmd"];
    // -c 用来执行string-commands（命令字符串），也就说不管后面的字符串里是什么都会被当做shellcode来执行
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments: arguments];
    
    // 新建输出管道作为Task的输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSPipe *pipe2=[NSPipe pipe];
    [task setStandardError:pipe2];
    
    // 开始task
    NSFileHandle *file = [pipe fileHandleForReading];
    NSFileHandle *file2 = [pipe2 fileHandleForReading];
    [task launch];
    [task waitUntilExit]; //执行结束后,得到执行的结果字符串++++++
    NSData *data;
    data = [file readDataToEndOfFile];
    NSString *result_str;
    NSString *error_str=[[NSString alloc] initWithData:[file2 readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    if(![error_str isEqualToString:@""]){
        NSLog(@"error:%@",error_str);
        return @"[ERROR]";
    }
    result_str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding]; //---------------------------------
    //result_str=[result_str stringByAppendingString:error_str];
    return result_str;
}

-(void)printLog:(NSString *)log{
    HSLogInfo(@"- <engine %d> - %@",self.index,log);
}

@end
