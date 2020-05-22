//
//  DBRecord.m
//  TestMe
//
//  Created by WeidongCao on 2020/5/6.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "DBRecord.h"

@implementation DBRecord

+ (id)recordWithContext:(NSManagedObjectContext *)context{
    NSString *name = [self entityName];
    DBRecord *record = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
    return record;
}
+ (NSString *)entityName{
    return @"DBRecord";
}
- (id)duration{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.minimumIntegerDigits = 1;
    formatter.minimumFractionDigits = 3;
    formatter.maximumFractionDigits = 5;
    if (self.end != nil) {
        NSTimeInterval interval = [self.end timeIntervalSinceDate:self.start];
        if (interval > 0) {
            return [formatter stringFromNumber:[NSNumber numberWithDouble:interval]];
        }
    }else{
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.start];
        if (interval > 0) {
            return [formatter stringFromNumber:[NSNumber numberWithDouble:interval]];
        }
    }
    return nil;
}
- (id)name{
    return nil;
}

@dynamic end,start,status,failureInfo,lowerLimit,upperLimit,limitUnits,measurement,number,priority,testid,testName,unit,uuid;

@end
