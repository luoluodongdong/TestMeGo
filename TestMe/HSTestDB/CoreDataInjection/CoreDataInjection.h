//
//  CoreDataInjection.h
//  ATConsoleTest
//
//  Created by WeidongCao on 2020/3/16.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataInjection : NSObject
+ (id)sharedInstance;
@property(retain, nonatomic) NSManagedObjectContext *importerContext;
@property(retain, nonatomic) NSManagedObjectContext *uiContext;
@property(retain, nonatomic) NSManagedObjectContext *baseContext;
@property(retain, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (id)initWithURL:(NSURL *)arg1;
@end

NS_ASSUME_NONNULL_END
