//
//  HSTestSequencer.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSTestSequencer.h"
#import "HSTestDefines.h"
#import "HSTestplanItem.h"
#import "HSTestCoreManager.h"
#import "HSLogger.h"

@interface HSTestSequencer()
@property HSTestCoreManager *testCoreManager;
@property NSString *identifier;

@property NSMutableDictionary *testFOMs;
@end

@implementation HSTestSequencer

-(void)initSequencer{
    self.testFailureSet = [NSMutableArray array];
    self.testRecords = [[NSMutableArray alloc] initWithCapacity:0];
    self.identifier = [NSString stringWithFormat:@"Group-1 : Unit-%d",self.index+1];
    self.testCoreManager = [HSTestCoreManager sharedInstance];
}

-(BOOL)startTest{
    self.testResult = HSTestStatusNotSet;
    [self.testFailureSet removeAllObjects];
    [self.testRecords removeAllObjects];
    [self printLog:@"start"];
    
    self.testFOMs = [NSMutableDictionary dictionary];
    [self.testFOMs setObject:@"12" forKey:@"channel"];
    [self.testFOMs setObject:@"ITKS" forKey:@"factory_name"];
    [self.testFOMs setObject:@"SMT-SENSOR" forKey:@"line_number"];
    [self.testFOMs setObject:@"th" forKey:@"test_str"];
    
    for (int i=0; i<self.testplanData.count; i++) {
        HSTestplanItem *thisItem = [self.testplanData objectAtIndex:i];
        NSString *group = thisItem.group;
        NSString *description = thisItem.testdescription;
        NSString *testid = thisItem.testid;
        NSString *function = thisItem.function;
        NSString *param1 = thisItem.param1;
        NSString *param2 = thisItem.param2;
        NSString *low = thisItem.low;
        NSString *high = thisItem.up;
        NSString *limitunit = thisItem.unit;
        int timeout = thisItem.timeout;
        NSString *tp_key = thisItem.testKEY;
        NSString *tp_value = thisItem.testVAL;
        int fail_count  = thisItem.fail_count;
        [self printLog:@"------------------------------------"];
        NSString *log=[NSString stringWithFormat:@"(%d)%@ -> %@(%@,%@) - [%@,%@] - %@",i+1,description,function,param1,param2,low,high,limitunit];
        [self printLog:log];
        //判断是否跳过此测试项目
        BOOL skipFlag = [self confirmWillSkip:tp_key val:tp_value];
        //生成limit
        HSTestLimit *limit = [HSTestLimit initWithUnit:limitunit low:low up:high];
        //初始化record
        HSTestRecord *record = [HSTestRecord initWithResult:HSTestStatusNotSet
                                                      start:[NSDate date]
                                                        end:nil
                                                   duration:0
                                                measurement:@""
                                                      limit:limit
                                                failureInfo:nil];
        
        //database event
        NSUUID *testItemUUID = [NSUUID UUID];
        NSString *eventName = [NSString stringWithFormat:@"test (%@) start",description];
        NSDictionary *userInfo = @{HSEventTestNumberKey:@(i+1),
                                   HSEventTestNameKey:description,
                                   HSEventTestIDKey:testid,
                                   HSEventTestRecordKey:record,
                                   HSEventTestRecordUUIDKey:testItemUUID,
                                   HSEventTestPriorityKey:@(0x01),
                                   HSEventHSUnitKey:self.unit,
        };
        HSEvent *event = [[HSEvent alloc] initWithName:eventName userInfo:userInfo];
        [self.testCoreManager.inserter testItemStart:event];
        
        if (skipFlag == YES) {
            //skip this item
            [self printLog:@"*skipped*"];
            record.result = HSTestStatusSkipped;
            
        }else{
            //execute this item
            //替换param1中的变量
            param1 = [self replaceParam1:param1];
            //生成测试请求
            HSTestRequest *request = [HSTestRequest initWithLimit:limit
                                                             index:i
                                                        identifier:self.identifier
                                                              name:description
                                                            action:@{@"function":function}
                                                            params:@{@"param1":param1,@"param2":param2}];
            //发送给engine进行测试
            HSTestRecord *theRecord = [self.engine executeTestRequest:request];
            //赋值测试结果
            record.measurement = theRecord.measurement;
            record.result = theRecord.result;
            record.failureInfo = theRecord.failureInfo;
            //根据param2中的变量名储存测试值
            [self saveValToFOMs:record.measurement param2:param2];
            //根据测试项目结果储存fail项目
            if (record.result != HSTestStatusPass) {
                [self.testFailureSet addObject:@{@"record":record,@"name":description}];
            }
        }
        record.end = [NSDate date];
        record.duration = [record.end timeIntervalSinceDate:record.start];
        
        [self.testRecords addObject:record];
        
        //database event
        eventName = [NSString stringWithFormat:@"test (%@) end",description];
        userInfo = @{
                    HSEventTestRecordKey:record,
                    HSEventTestRecordUUIDKey:testItemUUID,
                    HSEventHSUnitKey:self.unit,
        };
        event = [[HSEvent alloc] initWithName:eventName userInfo:userInfo];
        [self.testCoreManager.inserter testItemFinished:event];
        [NSThread sleepForTimeInterval:0.02];
        NSString *recordLog=[NSString stringWithFormat:@"value:%@ result:%d duration:%fs error:%@",record.measurement,record.result,record.duration,[record.failureInfo localizedDescription]];
        [self printLog:recordLog];
    }
    [self printLog:@"------------------------------------"];
    [self printLog:[self.testFOMs description]];
    //self.unit.serialnumber = [NSString stringWithFormat:@"SN-%d",self.index + 1];

    if ([self.testFailureSet count] > 0) {
        self.testResult = HSTestStatusFail;
    }else{
        self.testResult = HSTestStatusPass;
    }
    [self printLog:[NSString stringWithFormat:@"test result:%d failure set:%@",self.testResult,[self.testFailureSet description]]];
    self.unit.testStatus = self.testResult;
    self.unit.errorMessage = [self.testFailureSet description];
    //database event
    NSString *eventName = [NSString stringWithFormat:@"unit (%@) end",self.unit.identifier];
    NSDictionary *userInfo = @{
                               HSEventHSUnitKey:self.unit,
    };
    HSEvent *event = [[HSEvent alloc] initWithName:eventName userInfo:userInfo];
    [self.testCoreManager.inserter unitFinished:event];
    
    [self printLog:@"end"];
    
    NSDictionary *endEvent = @{@"type":@"end",@"content":self};
    [self.delegate event:endEvent fromTestSequencer:self.index];
    return YES;
}
-(BOOL)confirmWillSkip:(NSString *)key val:(NSString *)value{
    if ([value isEqualToString:@"not work"]) {
        return YES;
    }
    if ([key isEqualToString:@""]) {
        return NO;
    }
    if ([key containsString:@"{{"]) {
        NSArray *matchStrArr = [self arrayForRegex:@"(?<=\\{\\{).*?(?=\\}\\})" string:key];
        if ([matchStrArr count] > 0) {
            NSString *key2 = [matchStrArr objectAtIndex:0];
            NSString *fom_val = [self.testFOMs objectForKey:key2];
            if ([fom_val isEqualTo:value]) {
                return YES;
            }
        }
    }else{
        NSString *fom_val = [self.testFOMs objectForKey:key];
        if ([fom_val isEqualTo:value]) {
            return YES;
        }
    }
    return NO;
}
-(NSString *)replaceParam1:(NSString *)param1{
    if ([param1 containsString:@"[["] == NO) {
        return param1;
    }
    NSArray *matchStrArr = [self arrayForRegex:@"(?<=\\[\\[).*?(?=\\]\\])" string:param1];
    if ([matchStrArr count] > 0) {
        for (NSString *str in matchStrArr) {
            NSString *replaceStr = [self.testFOMs objectForKey:str];
            NSString *originalStr = [NSString stringWithFormat:@"[[%@]]",str];
            if (replaceStr != nil) {
                param1 = [param1 stringByReplacingOccurrencesOfString:originalStr withString:replaceStr];
            }
        }
    }
    return param1;
}
-(NSMutableArray *)arrayForRegex:(NSString *)regexString string:(NSString *)str
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0; i < [match numberOfRanges]; i++) {
            NSString *component = [str substringWithRange:[match rangeAtIndex:i]];
            [array addObject:component];
        }
    }
    return array;
}
-(void)saveValToFOMs:(NSString *)value param2:(NSString *)param2{
    NSArray *matchStrArr = [NSArray array];
    if ([param2 containsString:@"{{"]) {
        matchStrArr = [self arrayForRegex:@"(?<=\\{\\{).*?(?=\\}\\})" string:param2];
    }
    else if([param2 containsString:@"<<"]){
        matchStrArr = [self arrayForRegex:@"(?<=\\<\\<).*?(?=\\>\\>)" string:param2];
    }
    else{
        return;
    }
    if ([matchStrArr count] > 0) {
       [self.testFOMs setObject:value forKey:[matchStrArr objectAtIndex:0]];
    }
}
-(void)abortTest{
    
}

-(void)printLog:(NSString *)log{
    HSLogInfo(@"- <sequencer %d> - %@",self.index,log);
    //NSLog(@"[HSTS] - <sequencer %d> - %@",self.index,log);
}

@end
