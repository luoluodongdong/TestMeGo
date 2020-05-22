//
//  CoreDataInserter.m
//  TestMe
//
//  Created by WeidongCao on 2020/5/6.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "CoreDataInserter.h"

@implementation CoreDataInserter

- (id)init{
    CoreDataInjection *cdij = [CoreDataInjection sharedInstance];
    self.moc = cdij.uiContext;
    
    NSLog(@"[CoreDataInserter]init...done");
    return self;
}
- (void)_save{
    NSError *err=NULL;
    if ([self.moc hasChanges]) {
        if ([self.moc save:&err] == NO) {
            NSLog(@"[CoreDataInserter]save failure with err:%@",[err localizedDescription]);
        }
    }
//    //读取
//    // 建立获取数据的请求对象，指明操作的实体为Employee
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    // 执行获取操作，获取所有Employee托管对象
//    NSError *error = nil;
//    NSArray *employees = [self.moc executeFetchRequest:request error:&error];
//    [employees enumerateObjectsUsingBlock:^(Unit * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"Unit identifier : %@, uuid : %@, state :%d userinfo:%@", obj.identifier, obj.uuid, obj.state,obj.userInfo);
//    }];
}
- (NSArray *)_fetchAllUnarchivedObjectsWithEntityName:(NSString *)name{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archived == NO"];
    [request setPredicate:predicate];
    NSError *err =NULL;
    NSArray *resultArr = [self.moc executeFetchRequest:request error:&err];
    if (resultArr == nil) {
        NSLog(@"Error while fetching all %@: %@",name,[err localizedDescription]);
    }
    return resultArr;
}
- (id)_fetchSingleObjectWithRequest:(NSFetchRequest *)request{
    NSError *err = NULL;
    NSArray *resultArr = [self.moc executeFetchRequest:request error:&err];
    id findObj = NULL;
    if (resultArr != nil) {
        if ([resultArr count] <= 1) {
            findObj = [resultArr firstObject];
        }else{
            NSLog(@"ERROR: More than one object found!! %@",resultArr);
        }
    }else{
        NSLog(@"Saw error fetching single object: %@",[err localizedDescription]);
    }
    return findObj;
}

- (id)_fetchUnitWithUUID:(NSUUID *)uuid{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[DBUnit entityName]];
    [request setFetchLimit:0x01];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@",[uuid UUIDString]];
    [request setPredicate:predicate];
    return [self _fetchSingleObjectWithRequest:request];
}
- (id)_fetchUnitWithIdentifier:(NSString *)identifier{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[DBUnit entityName]];
    [request setFetchLimit:0x01];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier == %@) AND (archived == NO)",identifier];
    [request setPredicate:predicate];
    return [self _fetchSingleObjectWithRequest:request];
}
- (id)_fetchRecordWithUUID:(NSUUID *)uuid{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[DBRecord entityName]];
    [request setFetchLimit:0x01];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@",[uuid UUIDString]];
    [request setPredicate:predicate];
    return [self _fetchSingleObjectWithRequest:request];
}

-(void)deleteOldData{
    [self.moc performBlock:^{
        [self printLog:@"Deleting old data start"];
        //units
        NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:[DBUnit entityName]];
//       [request2 setFetchLimit:0x01];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"archived = YES"];
        [request2 setPredicate:predicate2];
        NSError *err2 = NULL;
        NSArray *archivedUnitsArr = [self.moc executeFetchRequest:request2 error:&err2];
        NSLog(@"[CDI]-archivedUnits count:%ld",[archivedUnitsArr count]);
        if (archivedUnitsArr == nil || err2 != nil) {
            NSLog(@"ERROR deleting old group data: %@",[err2 localizedDescription]);
        }else{
            for (DBUnit *unit in archivedUnitsArr) {
                NSLog(@"[CDI]delete unit:%@ uuid:%@",unit.identifier,unit.uuid);
                [self.moc deleteObject:unit];
            }
        }
        [self _save];
        [self printLog:@"Deleting old data finished"];
    }];
}
-(void)creatDBUnitWithHSUnit:(HSUnit *)hsUnit{
    DBUnit *unit = [DBUnit unitWithContext:self.moc];
    unit.archived = NO;
    unit.identifier = hsUnit.identifier;
    unit.uuid = [hsUnit.uuid UUIDString];
    unit.created = [NSDate date];
    unit.overallStatus = HSTestStatusNotSet;
    unit.state = 0x00;
    unit.records = [NSMutableSet set];
    unit.errorMessage = @"";
    [self _save];
}
-(void)unitStart:(HSEvent *)event{
    [self.moc performBlock:^{
        HSUnit *hsUnit = [event getUnit];
        NSLog(@"[CDI]-unitStart identifier:%@",hsUnit.identifier);
        DBUnit *unit = [self _fetchUnitWithUUID:hsUnit.uuid];
        if (unit != nil) {
            [unit setStart:[event creationDate]];
            [unit setState:0x01];
        }
        NSLog(@"unit start uuid:%@",hsUnit.uuid);
    }];
}
-(void)testItemStart:(HSEvent *)event{
    [self.moc performBlock:^{
        NSLog(@"[CDI]testItemStart here");
        HSUnit *hsUnit = [event getUnit];
        int number = [[event.userInfo objectForKey:HSEventTestNumberKey] intValue];
        NSString *testName = [event.userInfo objectForKey:HSEventTestNameKey];
        NSString *testID = [event.userInfo objectForKey:HSEventTestIDKey];
        NSUUID *testUUID = [event.userInfo objectForKey:HSEventTestRecordUUIDKey];
        HSTestRecord *hsRecord = [event.userInfo objectForKey:HSEventTestRecordKey];
        short testPriority = [[event.userInfo objectForKey:HSEventTestPriorityKey] shortValue];
        DBUnit *dbUnit = [self _fetchUnitWithUUID:hsUnit.uuid];
        if (dbUnit != nil) {
            DBRecord *record = [DBRecord recordWithContext:self.moc];
            [record setUuid:[testUUID UUIDString]];
            [record setNumber:number];
            [record setEnd:nil];
            [record setFailureInfo:@""];
            [record setLimitUnits:hsRecord.limit.unit];
            [record setLowerLimit:hsRecord.limit.low];
            [record setUpperLimit:hsRecord.limit.up];
            [record setPriority:testPriority];
            [record setStart:[event creationDate]];
            [record setStatus:HSTestStatusNotSet];
            [record setTestid:testID];
            [record setTestName:testName];
            [record setMeasurement:@""];
            [record setUnit:dbUnit];
        }
    }];
}
-(void)testItemFinished:(HSEvent *)event{
    [self.moc performBlock:^{
        NSLog(@"[CDI]testItemFinished here");
        NSUUID *recordUUID = [event.userInfo objectForKey:HSEventTestRecordUUIDKey];
        HSTestRecord *hsRecord = [event.userInfo objectForKey:HSEventTestRecordKey];
        DBRecord *record = [self _fetchRecordWithUUID:recordUUID];
        if (record == nil) {
            NSLog(@"[CoreDataInserter]ERROR:_fetchRecordWithUUID result nil!");
            //return 0;
            return;
        }
        [record setMeasurement:hsRecord.measurement];
        [record setStatus:hsRecord.result];
        if (hsRecord.result != HSTestStatusPass) {
            [record setFailureInfo:[hsRecord.failureInfo localizedDescription]];
        }
        [record setEnd:[event creationDate]];
    }];
}
-(void)unitAbort:(HSEvent *)event{
    
}
-(void)unitFinished:(HSEvent *)event{
    [self.moc performBlock:^{
        NSLog(@"[CDI]unitFinished here");
        //[self safeDecrement];
        HSUnit *hsUnit = [event getUnit];
        DBUnit *unit = [self _fetchUnitWithUUID:hsUnit.uuid];
        if (unit != nil) {
            [unit setOverallStatus:hsUnit.testStatus];
            [unit setState:0x02];
            [unit setEnd:[event creationDate]];
            [unit setErrorMessage:hsUnit.errorMessage];
            [unit setArchived:YES];
            [self _save];
        }else{
            NSLog(@"[CoreDataInserter]unitFinished ERROR:not fetch Unit with uuid:%@",hsUnit.uuid);
        }
        [self _save];
    }];
}
-(void)printLog:(NSString *)log{
    NSLog(@"[CDI] - %@",log);
}
@end
