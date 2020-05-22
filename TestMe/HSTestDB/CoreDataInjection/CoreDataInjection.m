//
//  CoreDataInjection.m
//  ATConsoleTest
//
//  Created by WeidongCao on 2020/3/16.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "CoreDataInjection.h"

@implementation CoreDataInjection
static CoreDataInjection* _instance = nil;
+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    }) ;
     
    return _instance ;
}
 
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [CoreDataInjection sharedInstance] ;
}
 
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [CoreDataInjection sharedInstance] ;
}
- (id)initWithURL:(NSURL *)url{
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    if (self.managedObjectModel != nil) {
        self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:0x0 URL:0x0 options:0x0 error:0x0];
        if (self.persistentStoreCoordinator != nil) {
            self.baseContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:0x01]; //sub thread
            [self.baseContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
            [self.baseContext setUndoManager:0x0];
            if (self.baseContext != nil) {
                self.uiContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:0x02]; //main thread
                NSLog(@"[CoreDataInjection]initWithURL on thread:%@",[NSThread currentThread]);
                [self.uiContext setParentContext:self.baseContext];
                [self.uiContext setUndoManager:0x0];
                if (self.uiContext != nil) {
                    NSLog(@"[CoreDataInjection]initWithURL...ok");
                    return self;
                }
            }
            
        }
        
    }
    return nil;
}
@end
