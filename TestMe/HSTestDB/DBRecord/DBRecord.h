//
//  DBRecord.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/6.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "DBUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBRecord : NSManagedObject
+ (id)recordWithContext:(NSManagedObjectContext *)context;
+ (NSString *)entityName;
- (id)duration;
- (id)name;

//@property(readonly, nonatomic) BOOL isLeaf;

// Remaining properties
@property(retain, nonatomic) NSString *uuid;
@property(nonatomic) NSInteger number;
@property(retain, nonatomic) NSDate *__nullable end;
@property(retain, nonatomic) NSString *failureInfo;
@property(retain, nonatomic) NSString *limitUnits;
@property(retain, nonatomic) NSString *lowerLimit;
@property(retain, nonatomic) NSString *measurement;
@property(nonatomic) short priority;
@property(retain, nonatomic) NSDate *start;
@property(nonatomic) short status;
@property(retain, nonatomic) NSString *testid;
@property(retain, nonatomic) DBUnit *unit;
@property(retain, nonatomic) NSString *testName;
@property(retain, nonatomic) NSString *upperLimit;

@end

NS_ASSUME_NONNULL_END
