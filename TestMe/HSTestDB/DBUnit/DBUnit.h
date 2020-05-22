//
//  DBUnit.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/6.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBUnit : NSManagedObject

+ (DBUnit *)unitWithContext:(NSManagedObjectContext *)context;
+ (NSString *)entityName;

@property(nonatomic) BOOL archived;
@property(retain, nonatomic) NSString *identifier;
@property(retain, nonatomic) NSString *uuid;
@property(retain, nonatomic) NSDate *created;
@property(retain, nonatomic) NSDate *start;
@property(retain, nonatomic) NSDate *end;
@property(nonatomic) short overallStatus;
//state 0x00--Idle 0x01--Testing 0x02--Finished 0x03--Abort
@property(nonatomic) short state;
@property(retain, nonatomic) NSMutableSet *records;
@property(retain, nonatomic) NSString *errorMessage;

//@property(retain, nonatomic) NSSet *attributes;
//@property(nonatomic) BOOL detailedViewAllowed;
//@property(retain, nonatomic) Group *_Nullable group;
//@property(retain, nonatomic) NSString *sequence;
//@property(retain, nonatomic) NSString *serialNumber;

//@property(retain, nonatomic) NSOrderedSet *tests;
//@property(retain, nonatomic) NSArray *unitTransports;
//@property(retain, nonatomic) NSDictionary *userInfo;


@end

NS_ASSUME_NONNULL_END
