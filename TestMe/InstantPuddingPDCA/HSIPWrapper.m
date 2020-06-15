//
//  HSIPWrapper.m
//  PDCAtest
//
//  Created by WeidongCao on 2020/5/27.
//  Copyright © 2020 曹伟东. All rights reserved.
//

#import "HSIPWrapper.h"
@interface HSIPWrapper()

@property (retain, nonatomic) NSString *snString;
@property (assign, nonatomic) int numTestsFailed;
@property IP_UUTHandle UID;

@end

@implementation HSIPWrapper

-(id)init{
    if (self = [super init]) {
        _snString = NULL;
        _numTestsFailed = 0;
    }
    return self;
}

-(NSString *)getIPVersion{
    const char *version=IP_getVersion();
    return [NSString stringWithUTF8String:version];
}

-(BOOL)startIPWithSn:(NSString *)sn swName:(NSString *)name swVersion:(NSString *)ver error:(NSError **)err{
    self.snString = sn;
    IP_API_Reply reply = NULL;
    
    NSLog(@"Before UUSTART");
    reply = IP_UUTStart(&_UID);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        IP_reply_destroy(reply);
        reply = NULL;
        return NO;
    }
    NSLog(@" After UUSTART");
    
    reply = IP_addAttribute(_UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, [ver UTF8String]);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        IP_reply_destroy(reply);
        reply = NULL;
        return NO;
    }
    NSLog(@" After Add Attribute SW version");
    
    reply = IP_addAttribute(_UID, IP_ATTRIBUTE_STATIONSOFTWARENAME, [name UTF8String]);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        IP_reply_destroy(reply);
        reply = NULL;
        return NO;
    }
    NSLog(@" After Add Attribute SW name");

    reply = IP_validateSerialNumber(_UID, [self.snString UTF8String]);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        IP_reply_destroy(reply);
        reply = NULL;
        return NO;
    }
    NSLog(@" After Validate serial number");

    reply = IP_addAttribute(_UID, IP_ATTRIBUTE_SERIALNUMBER, [self.snString UTF8String]);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        IP_reply_destroy(reply);
        reply = NULL;
        return NO;
    }
    NSLog(@" After Add Attribute serial number");
    
    sleep(1); //delay 1s
    if ([self IPamIOkay:self.snString error:err] == NO) {
        return NO;
    }
    NSLog(@" After IP_amIOK after Add Attribute serial number");
    
    return YES;
}

-(BOOL)addTestItem:(NSString *)item value:(NSString *)val limitLow:(NSString *)low limitUp:(NSString *)up units:(NSString *)units error:(NSError **)err{
    IP_TestSpecHandle    testSpec = NULL;
    IP_TestResultHandle testResult = NULL;
    NSString *strErrorInfo = nil;
    
    // create a test spec from the struct contents
    testSpec = IP_testSpec_create();
    if (!testSpec) {
        NSString *errmessage = [NSString stringWithFormat:@"Error from IP_testSpec_create %@",item];
        *err = [NSError errorWithDomain:@"com.HSIPWapper.addTestItem" code:0x20 userInfo:@{NSLocalizedDescriptionKey:errmessage}];
        NSLog (@"%@",errmessage);
        IP_UID_destroy(_UID);
        _UID = NULL;
        return NO;
    }
    
    testResult = IP_testResult_create();
    if (!testResult) {
        NSString *errmessage = [NSString stringWithFormat:@"Error from IP_testResult_create %@",item];
        *err = [NSError errorWithDomain:@"com.HSIPWapper.addTestItem" code:0x20 userInfo:@{NSLocalizedDescriptionKey:errmessage}];
        NSLog (@"%@",errmessage);
        IP_UID_destroy(_UID);
        _UID = NULL;
        IP_testSpec_destroy(testSpec);
        testSpec = NULL;
        return NO;
    }
    
    IP_testSpec_setTestName(testSpec, [item UTF8String], [item length]);
    IP_testSpec_setPriority(testSpec, IP_PRIORITY_REALTIME_WITH_ALARMS); //default priority
    IP_testSpec_setLimits(testSpec, [low UTF8String], [low length],[up UTF8String], [up length]);
    IP_testSpec_setUnits(testSpec, [units UTF8String], [units length]);
    IP_testResult_setValue(testResult, [val UTF8String], [val length]);
    
    //compare test result isPass
    NSInteger iResult = [self compareValue:val withMax:up andMin:low];
    switch (iResult) {
        case 0:
            _numTestsFailed += 1;
            strErrorInfo = @"FAIL";
            IP_testResult_setResult(testResult, IP_FAIL);
            break;
        case 1:
            strErrorInfo = @"PASS";
            IP_testResult_setResult(testResult, IP_PASS);
            break;
        case 2:
            strErrorInfo = @"PASS";
            IP_testResult_setResult(testResult, IP_NA);
            break;
            
        default:
            break;
    }
    IP_testResult_setMessage(testResult, [strErrorInfo UTF8String], [strErrorInfo length]);
    
    BOOL status = NO;
    IP_API_Reply reply = NULL;
    reply = IP_addResult(_UID, testSpec, testResult);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        status = NO;
    }else{
        status = YES;
    }
    IP_reply_destroy(reply);
    reply = NULL;
    
    IP_testSpec_destroy(testSpec);
    testSpec = NULL;
    IP_testResult_destroy(testResult);
    testResult = NULL;
    return status;
}

-(BOOL)addAttribute:(NSString *)name value:(NSString *)val error:(NSError **)err{
    BOOL status = NO;
    IP_API_Reply reply = NULL;
    reply = IP_addAttribute(_UID, [name UTF8String], [val UTF8String]);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        status = NO;
    }else{
        status = YES;
    }
    IP_reply_destroy(reply);
    reply = NULL;
    NSLog(@" After Add Attribute [%@:%@]",name,val);
    return status;
}

-(BOOL)addBlob:(NSString *)name filePath:(NSString *)path error:(NSError **)err{
    BOOL status = NO;
    IP_API_Reply reply = NULL;
    reply = IP_addBlob(_UID,[name UTF8String],[path UTF8String]);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        status = NO;
    }else{
        status = YES;
    }
    IP_reply_destroy(reply);
    reply = NULL;
    NSLog(@" After Add Blob [%@:%@]",name,path);
    return status;
}

-(BOOL)finishIPError:(NSError **)err{
    if ([self IPamIOkay:self.snString error:err] == NO) {
        return NO;
    }
    NSLog(@" After IP_amIOK before IP_UTTDone");
    sleep(1); //delay 1s
    IP_API_Reply doneReply;
    doneReply = IP_UUTDone(_UID);
    if ( !IP_success( doneReply ) )
    {
        if ( IP_reply_isOfClass( doneReply, IP_MSG_CLASS_PROCESS_CONTROL) )
        {
            NSLog (@"IP_reply_isOfClass( doneReply, IP_MSG_CLASS_PROCESS_CONTROL) failed");
            const char *errStr = IP_reply_getError(doneReply);
            NSLog (@"%s", errStr);
            *err = [NSError errorWithDomain:@"com.HSIPWapper.finishIPError" code:0x20 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithCString:errStr encoding:NSUTF8StringEncoding]}];
            IP_reply_destroy(doneReply);
            IP_UID_destroy(_UID);
            doneReply = NULL;
            _UID = NULL;
            return NO;
        }
        else
        {
            if ( IP_reply_isOfClass( doneReply, IP_MSG_CLASS_API_ERROR ) )
            {
                unsigned int doneMessageID = 0;
                doneMessageID = IP_reply_getMessageID( doneReply );
                
                if ( IP_MSG_ERROR_FERRET_NOT_RUNNING == doneMessageID )
                {
                    // if this happens, you are allowed to continue with the UUTCommit without
                    // counting this as a test failure
                    NSLog (@"IP_MSG_ERROR_FERRET_NOT_RUNNING");
                }
            }
            else
            {
                NSLog (@"IP_reply_isOfClass( doneReply, IP_MSG_CLASS_API_ERROR ) failed");
            }
        }
    }
    IP_reply_destroy(doneReply);
    doneReply = NULL;
    
    BOOL status = NO;
    //## required step #4:  IP_UUTCommit()
    IP_API_Reply commitReply;
    commitReply = IP_UUTCommit(_UID, _numTestsFailed > 0 ? 0:1 );
    if ([self checkIPAPIReply:commitReply error:err] == NO) {
        status = NO;
    }else{
        IP_UID_destroy( _UID );
        _UID = NULL;
        status = YES;
    }
    IP_reply_destroy( commitReply );
    commitReply = NULL;
    
    NSLog(@"IP_UUTCommit status : %hhd",status);
    return status;
}

- (BOOL)IPamIOkay:(NSString*)sn error:(NSError **)err
{
    *err = NULL;
    BOOL status = NO;
    IP_API_Reply reply = NULL;
    reply = IP_amIOkay(_UID, [sn UTF8String]);
    if ([self checkIPAPIReply:reply error:err] == NO) {
        status = NO;
    }else{
        status = YES;
    }
    IP_reply_destroy(reply);
    reply = NULL;
    return status;
}

-(BOOL)checkIPAPIReply:(IP_API_Reply )reply error:(NSError **)err{
    *err = NULL;
    BOOL status = NO;
    if (!IP_success(reply)) {
        const char *errStr = IP_reply_getError(reply);
        NSLog(@"IP_API_Reply error: %s",errStr);
        *err = [NSError errorWithDomain:@"com.HSIPWapper.IP_API_Reply" code:0x20 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithCString:errStr encoding:NSUTF8StringEncoding]}];
        IP_UID_destroy(_UID);
        _UID = NULL;
    }else{
        status = YES;
    }
    return status;
}

- (NSInteger)compareValue:(NSString*)value withMax:(NSString *)max andMin:(NSString *)min
{
    NSInteger iRet = 0;
    
    if (([min isEqualToString:@"NA"] || [min isEqualToString:@""])
        && !([max isEqualToString:@"NA"] || [max isEqualToString:@""])) {
        if ([value floatValue] < [max floatValue]) {
            iRet = 1;
        }
    }
    else if (!([min isEqualToString:@"NA"] || [min isEqualToString:@""])
             && ([max isEqualToString:@"NA"] || [max isEqualToString:@""])){
        if ([value floatValue] >= [min floatValue]) {
            iRet = 1;
        }
    }
    else if (([min isEqualToString:@"NA"] || [min isEqualToString:@""])
              && ([max isEqualToString:@"NA"] || [max isEqualToString:@""])){
        iRet = 2;
    }
    else{
        if ([value floatValue] >= [min floatValue] && [value floatValue] <= [max floatValue]) {
            iRet = 1;
        }
    }
    return iRet;
}

@end
