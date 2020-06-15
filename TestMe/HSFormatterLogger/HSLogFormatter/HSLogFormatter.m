//
//  HSLogFormatter.m
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSLogFormatter.h"
#import <ZMQlib/ZMQpublisher.h>

#ifdef DEBUG

#else
#define DEBUG 0

#endif

@interface HSLogFormatter()
@property ZMQpublisher *publisher;
@property dispatch_queue_t printLogQueue;

@end

@implementation HSLogFormatter

-(BOOL)initZmqPub:(NSString *)url{
    self.printLogQueue = dispatch_queue_create("com.hslogformatter.printLogQueue",DISPATCH_QUEUE_SERIAL);
    static BOOL status = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [NSThread detachNewThreadWithBlock:^{
        self.publisher = [[ZMQpublisher alloc] init];
        status = [self.publisher initPublisherWithUrl:url];
        [NSThread sleepForTimeInterval:0.2];
        NSLog(@"zmq bind result:%hhd",status);
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return status;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *formatMsg = [NSString stringWithFormat:@"(%@-%@) : %@",[logMessage fileName],@(logMessage->_line),logMessage->_message];
    if (self.enableZmqFlag) {
        dispatch_async(self.printLogQueue, ^{
            [self.publisher publishMessage:logMessage->_message];
        });
    }
    if(DEBUG){
        return formatMsg;
    }else{
        return nil;
    }
    
    //NSLog(@"%@",logMessage->_message);
    //return [NSString stringWithFormat:@"%@ | %@ @ %@ | %@",
    //        [logMessage fileName], logMessage->_function, @(logMessage->_line), logMessage->_message];
    
}

@end
