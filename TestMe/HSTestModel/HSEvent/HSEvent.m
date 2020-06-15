//
//  HSEvent.m
//  TestMe
//
//  Created by WeidongCao on 2020/5/6.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSEvent.h"

NSString * const HSEventHSUnitKey = @"com.HSEvent.Unit.Key";
NSString * const HSEventCSVdataKey = @"com.HSEvent.CSVdata.Key";

NSString * const HSEventTestNumberKey = @"com.HSEvent.TestNumber.Key";
NSString * const HSEventTestNameKey = @"com.HSEvent.TestName.Key";
NSString * const HSEventTestIDKey = @"com.HSEvent.TestID.key";
NSString * const HSEventTestRecordKey = @"com.HSEvent.TestRecord.Key";
NSString * const HSEventTestRecordUUIDKey = @"com.HSEvent.RecordUUID.Key";
NSString * const HSEventTestPriorityKey = @"com.HSEevent.TestPriority.Key";


@implementation HSEvent

- (instancetype)initWithName:(NSString *)name userInfo:(NSDictionary *)userInfo{
    if (self == [super init]) {
        _name = name;
        _userInfo = userInfo;
        _creationDate = [NSDate date];
    }
    return self;
}

- (HSUnit *)getUnit{
    HSUnit *unit = [_userInfo objectForKey:HSEventHSUnitKey];
    return unit;
}

@end
