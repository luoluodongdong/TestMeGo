//
//  DBUnit.m
//  TestMe
//
//  Created by WeidongCao on 2020/5/6.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "DBUnit.h"

@implementation DBUnit

+ (DBUnit *)unitWithContext:(NSManagedObjectContext *)context{
    NSString *name =[self entityName];
    DBUnit *unit =[NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
    return unit;
}
+ (NSString *)entityName{
    return @"DBUnit";
}

@dynamic archived,identifier,uuid,created,start,end,overallStatus,state,records,errorMessage;

@end
