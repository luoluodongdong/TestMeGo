//
//  HSTestplan.m
//  TestMe
//
//  Created by WeidongCao on 2020/5/5.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSTestplan.h"
#import "parseCSV.h"
#import "HSTestplanItem.h"
#import "HSTestDefines.h"

@interface HSTestplan()
@property (retain, nonatomic) NSMutableArray *testplanData;
@end
@implementation HSTestplan

+(NSMutableArray *)loadTestplan:(NSString *)name{
    NSMutableArray *array = [NSMutableArray array];
    HSTestplan *tp = [[HSTestplan alloc] init];
    if ([tp loadTestplan:name] == NO) {
        return array;
    }
    for (int i=0; i<tp.testplanData.count; i++) {
        NSArray *thisLine = [tp.testplanData objectAtIndex:i];
        HSTestplanItem *item = [[HSTestplanItem alloc] init];
        item.number = i+1;
        item.group = [thisLine objectAtIndex:TP_GROUP_INDEX];
        item.testdescription = [thisLine objectAtIndex:TP_DESCRIPTION_INDEX];
        item.testid = [thisLine objectAtIndex:TP_TID_INDEX];
        item.function = [thisLine objectAtIndex:TP_FUNCTION_INDEX];
        item.param1 = [thisLine objectAtIndex:TP_PARAM1_INDEX];
        item.param2 = [thisLine objectAtIndex:TP_PARAM2_INDEX];
        item.low = [thisLine objectAtIndex:TP_LOW_INDEX];
        item.up = [thisLine objectAtIndex:TP_HIGH_INDEX];
        item.unit = [thisLine objectAtIndex:TP_UNIT_INDEX];
        item.timeout = [[thisLine objectAtIndex:TP_TIMEOUT_INDEX] doubleValue];
        item.testKEY = [thisLine objectAtIndex:TP_KEY_INDEX];
        item.testVAL = [thisLine objectAtIndex:TP_VAL_INDEX];
        item.fail_count = [[thisLine objectAtIndex:TP_FAIL_COUNT_INDEX] intValue];
        [array addObject:item];
    }
    return array;
}

-(BOOL)loadTestplan:(NSString *)name{
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    rawfilePath=[rawfilePath stringByAppendingPathComponent:@"/HSArchives/Testplan/"];
    NSString *filePath=[rawfilePath stringByAppendingPathComponent:name];
    [self printLog:filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath] == NO) {
        return NO;
    }
    CSVParser *parser=[CSVParser new];
    [parser openFile:filePath];
    self.testplanData = [parser parseFile];
    //NSLog(@"%@", csvContent);
    [parser closeFile];
    //NSMutableArray *heading = [csvContent objectAtIndex:0];
    if (self.testplanData.count < 1) {
        return NO;
    }
    [self.testplanData removeObjectAtIndex:0];
    return YES;
}
-(void)printLog:(NSString *)log{
    NSLog(@"[HSTestplan] - %@",log);
}
@end
