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
#import "HSIPWrapper.h"

@interface HSTestSequencer()
@property HSTestCoreManager *testCoreManager;
@property NSString *identifier;
@property NSMutableDictionary *testFOMs;
//for PDCA
@property HSIPWrapper *pdca;
@end

@implementation HSTestSequencer

-(void)initSequencer{
    self.testFailureSet = [NSMutableArray array];
    self.testRecords = [[NSMutableArray alloc] initWithCapacity:0];
    self.identifier = [NSString stringWithFormat:@"Group-1 : Unit-%d",self.index+1];
    self.testCoreManager = [HSTestCoreManager sharedInstance];
    self.pdca = [[HSIPWrapper alloc] init];
}

-(BOOL)startTest{
    //PDCA setting
    BOOL PDCAEnableFlag = [[self.testCoreManager.stationConfigDict objectForKey:@"PDCA"] boolValue];
    NSString *softwareVersion = self.testCoreManager.softwareVersion;
    if ([self.testCoreManager.operateMode isEqualToString:@"Production"]) {
        //PDCAEnableFlag = YES;
    }else if([self.testCoreManager.operateMode isEqualToString:@"Audit"]){
        softwareVersion = [softwareVersion stringByAppendingString:@"-Audit"];
        //PDCAEnableFlag = YES;
    }
    //DEBUG DISENABLE PDCA
    //PDCAEnableFlag = NO;
    [self printLog:[NSString stringWithFormat:@"PDCA Enable Flag:%hhd",PDCAEnableFlag]];
    
    //initial setting
    self.testResult = HSTestStatusNotSet;
    [self.testFailureSet removeAllObjects];
    [self.testRecords removeAllObjects];
    [self printLog:@"start"];
    //dummy test setting
    self.testFOMs = [NSMutableDictionary dictionary];
    [self.testFOMs setObject:@"12" forKey:@"channel"];
    [self.testFOMs setObject:@"ITKS" forKey:@"factory_name"];
    [self.testFOMs setObject:@"SMT-SENSOR" forKey:@"line_number"];
    [self.testFOMs setObject:@"th" forKey:@"test_str"];
    
    //CSV DATA
    NSString *dut_sn = self.unit.serialnumber;
    NSString *dut_result = @"NA";
    NSString *dut_faillist = @"";
    NSString *dut_stationid = @"station-ID";
    NSString *dut_slotid = [NSString stringWithFormat:@"%d",self.index + 1];
    NSString *dut_starttime = [self getCurrentTime];
    NSString *dut_endtime = @"";
    NSString *dut_softwareversion = self.testCoreManager.softwareVersion;
    NSMutableArray *itemValuesArr = [NSMutableArray array];
    
    
    //main test process
    NSError *error = NULL;
    if (PDCAEnableFlag == YES) {
        NSString *dutSN = self.unit.serialnumber;
        
        BOOL startPDCA = [self.pdca startIPWithSn:dutSN //@"YM123456789"
                                           swName:self.testCoreManager.softwareName
                                        swVersion:softwareVersion
                                            error:&error];
        
        if (startPDCA == NO) {
            HSTestRecord *record = [HSTestRecord initWithResult:HSTestStatusError
                                                          start:[NSDate date]
                                                            end:nil
                                                       duration:0
                                                    measurement:@""
                                                          limit:nil
                                                    failureInfo:error];
            [self.testFailureSet addObject:@{@"record":record,@"name":@"start InstandPudding FAIL"}];
        }
        HSLogInfo(@"start PDCA sn:%@ swName:%@ swVersion:%@ status:%hhd",dutSN,self.testCoreManager.softwareName,softwareVersion,startPDCA);
    }
    for (int i=0; i<self.testplanData.count; i++) {
        HSTestplanItem *thisItem = [self.testplanData objectAtIndex:i];
        NSString *group = thisItem.group;
        NSString *itemDescription = thisItem.testdescription;
        NSString *testid = thisItem.testid;
        NSString *function = thisItem.function;
        NSString *param1 = thisItem.param1;
        NSString *param2 = thisItem.param2;
        NSString *low = thisItem.low;
        NSString *high = thisItem.up;
        NSString *limitunit = thisItem.unit;
        double timeout = thisItem.timeout;
        NSString *tp_key = thisItem.testKEY;
        NSString *tp_value = thisItem.testVAL;
        int fail_count  = thisItem.fail_count;
        [self printLog:@"------------------------------------"];
        NSString *log=[NSString stringWithFormat:@"(%d)%@ -> %@(%@,%@) - [%@,%@] - %@",i+1,itemDescription,function,param1,param2,low,high,limitunit];
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
        NSString *eventName = [NSString stringWithFormat:@"test (%@) start",itemDescription];
        NSDictionary *userInfo = @{HSEventTestNumberKey:@(i+1),
                                   HSEventTestNameKey:itemDescription,
                                   HSEventTestIDKey:testid,
                                   HSEventTestRecordKey:record,
                                   HSEventTestRecordUUIDKey:testItemUUID,
                                   HSEventTestPriorityKey:@(0x01),
                                   HSEventHSUnitKey:self.unit,
        };
        HSEvent *event = [[HSEvent alloc] initWithName:eventName userInfo:userInfo];
        [self.dbInserterDelegate testItemStart:event];
        //[self.testCoreManager.inserter testItemStart:event];
        
        if (skipFlag == YES) {
            //skip this item
            [self printLog:@"*skipped*"];
            record.result = HSTestStatusSkipped;
            [itemValuesArr addObject:@"*skipped"];
        }else{
            //execute this item
            //替换param1中的变量
            param1 = [self replaceParam1:param1];
            //生成测试请求
            HSTestRequest *request = [HSTestRequest initWithLimit:limit
                                                            index:i
                                                       identifier:self.identifier
                                                             name:itemDescription
                                                           action:@{@"function":function,@"timeout":@(timeout)}
                                                           params:@{@"param1":param1,@"param2":param2}];
            //发送给engine进行测试
            HSTestRecord *theRecord = [self.engine executeTestRequest:request];
            //赋值测试结果
            record.measurement = theRecord.measurement;
            record.result = theRecord.result;
            record.failureInfo = theRecord.failureInfo;
            //根据param2中的变量名储存测试值
            [self saveValToFOMs:record.measurement param2:param2 pdcaEnable:PDCAEnableFlag];
            //根据测试项目结果储存fail项目
            if (record.result != HSTestStatusPass) {
                [self.testFailureSet addObject:@{@"record":record,@"name":itemDescription}];
            }
            NSString *csvValue = [record.measurement stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            csvValue = [csvValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            csvValue = [csvValue stringByReplacingOccurrencesOfString:@"," withString:@"@"];
            [itemValuesArr addObject:csvValue];
        }
        record.end = [NSDate date];
        record.duration = [record.end timeIntervalSinceDate:record.start];
        
        [self.testRecords addObject:record];
        
        //database event
        eventName = [NSString stringWithFormat:@"test (%@) end",itemDescription];
        userInfo = @{
            HSEventTestRecordKey:record,
            HSEventTestRecordUUIDKey:testItemUUID,
            HSEventHSUnitKey:self.unit,
        };
        event = [[HSEvent alloc] initWithName:eventName userInfo:userInfo];
        [self.dbInserterDelegate testItemFinished:event];
        //[self.testCoreManager.inserter testItemFinished:event];
        //[NSThread sleepForTimeInterval:0.05];
        //update record to PDCA
        if (PDCAEnableFlag == YES && [self thisItem2PDCA:testid]) {
            NSArray *tempArr = [testid componentsSeparatedByString:@" | "];
            NSError *error = NULL;
            BOOL status = [self.pdca addTestItem:tempArr[0]
                                           value:record.measurement
                                        limitLow:limit.low
                                         limitUp:limit.up
                                           units:limit.unit
                                           error:&error];
            HSLogInfo(@"update PDCA : %@ status : %hhd",tempArr[0],status);
            if (status == NO) {
                HSTestRecord *record = [HSTestRecord initWithResult:HSTestStatusError
                                                              start:[NSDate date]
                                                                end:nil
                                                           duration:0
                                                        measurement:@""
                                                              limit:nil
                                                        failureInfo:error];
                [self.testFailureSet addObject:@{@"record":record,@"name":itemDescription}];
            }
        }
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
    if (PDCAEnableFlag == YES) {
        NSError *error = NULL;
        BOOL status = [self.pdca finishIPError:&error];
        if (status == NO) {
            HSTestRecord *record = [HSTestRecord initWithResult:HSTestStatusError
                                                          start:[NSDate date]
                                                            end:nil
                                                       duration:0
                                                    measurement:@""
                                                          limit:nil
                                                    failureInfo:error];
            [self.testFailureSet addObject:@{@"record":record,@"name":@"pdca finish FAIL"}];
            self.testResult = HSTestStatusFail;
        }
        HSLogInfo(@"pdca finish status:%hhd",status);
    }
    [self printLog:[NSString stringWithFormat:@"test result:%d failure set:%@",self.testResult,[self.testFailureSet description]]];
    self.unit.testStatus = self.testResult;
    self.unit.errorMessage = [self.testFailureSet description];
    //database event
    dut_result = self.testResult == HSTestStatusPass ? @"PASS" : @"FAIL";
    dut_endtime = [self getCurrentTime];
    for (NSDictionary *failItem in self.testFailureSet) {
        dut_faillist = [dut_faillist stringByAppendingFormat:@"@%@",[failItem objectForKey:@"name"]];
    }
    NSMutableArray *csvdataSet = [NSMutableArray arrayWithArray:@[dut_sn,dut_result,dut_faillist,dut_stationid,dut_slotid,dut_starttime,dut_endtime,dut_softwareversion]];
    [csvdataSet addObjectsFromArray:itemValuesArr];
    NSString *eventName = [NSString stringWithFormat:@"unit (%@) end",self.unit.identifier];
    NSDictionary *userInfo = @{
        HSEventHSUnitKey:self.unit,
        HSEventCSVdataKey:csvdataSet,
    };
    HSEvent *event = [[HSEvent alloc] initWithName:eventName userInfo:userInfo];
    [self.dbInserterDelegate unitFinished:event];
    //[self.testCoreManager.inserter unitFinished:event];
    
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
-(void)saveValToFOMs:(NSString *)value param2:(NSString *)param2 pdcaEnable:(BOOL )pdca{
    NSArray *matchStrArr = [NSArray array];
    BOOL update2PDCAflag = NO;
    if ([param2 containsString:@"{{"]) {
        matchStrArr = [self arrayForRegex:@"(?<=\\{\\{).*?(?=\\}\\})" string:param2];
    }
    else if([param2 containsString:@"<<"]){
        matchStrArr = [self arrayForRegex:@"(?<=\\<\\<).*?(?=\\>\\>)" string:param2];
        update2PDCAflag = YES;
    }
    else{
        return;
    }
    if ([matchStrArr count] > 0) {
        [self.testFOMs setObject:value forKey:[matchStrArr objectAtIndex:0]];
        if (pdca && update2PDCAflag) {
            NSError *error = NULL;
            BOOL status = [self.pdca addAttribute:value
                                            value:[matchStrArr objectAtIndex:0]
                                            error:&error];
            HSLogInfo(@"add attribute to PDCA : (%@,%@) status : %hhd",[matchStrArr objectAtIndex:0],value,status);
            if (status == NO) {
                HSTestRecord *record = [HSTestRecord initWithResult:HSTestStatusError
                                                              start:[NSDate date]
                                                                end:nil
                                                           duration:0
                                                        measurement:@""
                                                              limit:nil
                                                        failureInfo:error];
                [self.testFailureSet addObject:@{@"record":record,@"name":[matchStrArr objectAtIndex:0]}];
            }
        }
    }
}
-(void)abortTest{
    
}
-(BOOL)thisItem2PDCA:(NSString *)itemID{
    if ([itemID containsString:@"|"] == NO) {
        return NO;
    }
    NSArray *tempArr = [itemID componentsSeparatedByString:@" | "];
    if ([tempArr count] < 2) {
        return NO;
    }
    if ([tempArr[1] isEqualToString:@"PDCA"]) {
        return YES;
    }
    return NO;
}
-(NSString *)getCurrentTime{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS"];
    return [dateFormat stringFromDate:[NSDate date]];
}
-(void)printLog:(NSString *)log{
    HSLogInfo(@"- <sequencer %d> - %@",self.index,log);
    //NSLog(@"[HSTS] - <sequencer %d> - %@",self.index,log);
}

@end
