//
//  CoreDataInserterDelegate.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/30.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSEvent.h"

@protocol CoreDataInserterDelegate <NSObject>

-(void)unitStart:(HSEvent *)event;
-(void)testItemStart:(HSEvent *)event;
-(void)testItemFinished:(HSEvent *)event;
-(void)unitAbort:(HSEvent *)event;
-(void)unitFinished:(HSEvent *)event;

@end
