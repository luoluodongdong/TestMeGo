//
//  HSTestRecord.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSTestRecord.h"

@implementation HSTestRecord

+(HSTestRecord *)initWithResult:(HSTestStatus )result start:(NSDate *__nullable)start end:(NSDate *__nullable)end duration:(NSTimeInterval )duration measurement:(NSString *__nullable)value limit:(HSTestLimit *__nullable)limit failureInfo:(NSError *__nullable)err{
    HSTestRecord *record = [[HSTestRecord alloc] init];
    record.start = start;
    record.end = end;
    record.duration = duration;
    record.failureInfo = err;
    record.result = result;
    record.measurement = value;
    record.limit = limit;
    return record;
}

@end
