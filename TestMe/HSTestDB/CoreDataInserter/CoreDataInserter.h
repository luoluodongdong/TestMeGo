//
//  CoreDataInserter.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/6.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataInjection.h"
#import "DBUnit.h"
#import "DBRecord.h"
#import "HSUnit.h"
#import "HSEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataInserter : NSObject

@property(retain, nonatomic) NSManagedObjectContext *moc;

-(void)deleteOldData;

-(void)creatDBUnitWithHSUnit:(HSUnit *)hsUnit;

-(void)unitStart:(HSEvent *)event;
-(void)testItemStart:(HSEvent *)event;
-(void)testItemFinished:(HSEvent *)event;
-(void)unitAbort:(HSEvent *)event;
-(void)unitFinished:(HSEvent *)event;

- (id)_fetchUnitWithUUID:(NSUUID *)uuid;
- (id)_fetchUnitWithIdentifier:(NSString *)identifier;
- (id)_fetchRecordWithUUID:(NSUUID *)uuid;
@end

NS_ASSUME_NONNULL_END
