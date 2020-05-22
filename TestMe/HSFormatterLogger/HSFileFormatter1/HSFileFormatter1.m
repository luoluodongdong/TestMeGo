//
//  HSFileFormatter1.m
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSFileFormatter1.h"

@implementation HSFileFormatter1
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yy/MM/dd HH:mm:ss.SSS"];
    NSString *dateText=[dateFormat stringFromDate:[NSDate date]];
    NSString *formatMsg = [NSString stringWithFormat:@"[%@](%@-%@) : %@",dateText,[logMessage fileName],@(logMessage->_line),logMessage->_message];
    return formatMsg;
    //NSLog(@"%@",logMessage->_message);
    //return [NSString stringWithFormat:@"%@ | %@ @ %@ | %@",
    //        [logMessage fileName], logMessage->_function, @(logMessage->_line), logMessage->_message];
    
}
@end
