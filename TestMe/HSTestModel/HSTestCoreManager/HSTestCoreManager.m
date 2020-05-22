//
//  HSTestCoreManager.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSTestCoreManager.h"
#import "HSTestDefines.h"
#import "HSTestplan.h"
#import "HSTestFunctionDefines.h"
#import "HSLogger.h"

@interface HSTestCoreManager()

@property NSLock *syncLock;
@property NSLock *sequencerEventThreadLock;
@property unsigned long syncRequestCount;
@property (retain, nonatomic) NSMutableArray *unitSnArr;
@property BOOL scanSnIsReady;
//@property unsigned long activedUnitCount;

@end

@implementation HSTestCoreManager
static HSTestCoreManager* _instance = nil;
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
    return [HSTestCoreManager sharedInstance] ;
}
 
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [HSTestCoreManager sharedInstance] ;
}

-(void)initTestCore{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"HSTestDB" withExtension:@"momd"];
    CoreDataInjection *cdij = [[CoreDataInjection alloc] initWithURL:url];
    
    self.inserter = [[CoreDataInserter alloc] init];
    self.operateMode = @"Production";
    self.state = HSTestCoreInit;
    self.scanSnIsReady = NO;
    self.numberOfUnitsTesting = 0;
    self.syncRequestCount = 0;
    self.syncLock = [[NSLock alloc] init];
    self.sequencerEventThreadLock = [[NSLock alloc] init];
    //self.unitSet = [NSMutableArray array];
    self.unitSnArr = [NSMutableArray array];
    self.sequencerSet = [NSMutableArray array];
    self.stationSetting = [[HSStationSetting alloc] init];
    //self.unitsSelectedState = [NSMutableArray array];
    self.numberOfUnitsTesting = 0;
    self.selectedUnitsCount = 0;
    
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    NSString *filePath=[rawfilePath stringByAppendingPathComponent:@"Station.plist"];
    NSDictionary *rootDict=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    NSArray *groupUnits = [rootDict objectForKey:@"Group-1"];
    
    NSDictionary *stationConfig =[rootDict objectForKey:@"Config"];
    self.testplanData = [HSTestplan loadTestplan:[stationConfig objectForKey:@"TestplanFile"]];
    
    for (int i=0; i<[groupUnits count]; i++) {
        self.numberOfUnitsTesting += 1;
        self.selectedUnitsCount +=1;
        //[self.unitsSelectedState addObject:@(1)];
        
        HSUnit *unit = [[HSUnit alloc] init];
        unit.index = i;
        unit.state = HSUnitIdle;
        unit.identifier = [NSString stringWithFormat:@"Group-1 : Unit-%d",i+1];
        unit.serialnumber = @"";
        
        HSUnitSetting *setting = [[HSUnitSetting alloc] init];
        unit.setting = setting;
        
        HSTestEngine *engine = [[HSTestEngine alloc] init];
        engine.index = i;
        engine.unitCallStationTaskDelegate = self;
        engine.setting = setting;
        //unit.engine = engine;
        
        HSTestSequencer *sequencer = [[HSTestSequencer alloc] init];
        sequencer.index = i;
        sequencer.engine = engine;
        sequencer.delegate = self;
        sequencer.unit = unit;
        sequencer.testplanData = self.testplanData;
        [sequencer initSequencer];
        //unit.sequencer = sequencer;
        [self.sequencerSet addObject:sequencer];
    }

}

-(BOOL)start{
    if (self.state == HSTestCoreTesting || self.selectedUnitsCount == 0) {
        return NO;
    }
    if (self.scanSnIsReady == NO) {
        return NO;
    }
    [self.inserter deleteOldData];
    self.numberOfUnitsTesting = self.selectedUnitsCount;
    self.state = HSTestCoreTesting;
    HSLogInfo(@" <core> start");
    int unitIndex = 0;
    for (HSTestSequencer *sequencer in self.sequencerSet) {
        HSUnit *unit = sequencer.unit;
        if (unit.state == HSUnitIdle || unit.state == HSUnitFinished) {
            unit.identifier = [NSString stringWithFormat:@"Group-1 : Unit-%d",unitIndex+1];
            unit.index = unitIndex;
            unit.uuid = [NSUUID UUID];
            [self.inserter creatDBUnitWithHSUnit:unit];
            unit.start = [NSDate date];
            unit.serialnumber = [self.unitSnArr objectAtIndex:unitIndex];
            unit.errorMessage = @"";
            unit.testStatus = HSTestStatusNotSet;
            unit.state = HSUnitTesting;
            NSString *eventName = [NSString stringWithFormat:@"unit (%@) start",unit.identifier];
            //Database event
            NSDictionary *userInfo=@{HSEventHSUnitKey:unit};
            HSEvent *event = [[HSEvent alloc] initWithName:eventName userInfo:userInfo];
            [self.inserter unitStart:event];
            //sequencer start
            [NSThread detachNewThreadWithBlock:^{
                [sequencer startTest];
            }];
        }
        unitIndex += 1;
    }
    return YES;
}
-(BOOL)startWithScnSNs:(NSArray *)snArr{
    HSLogInfo(@" <core> %@",[snArr description]);
    self.unitSnArr = [NSMutableArray arrayWithArray:snArr];
    self.scanSnIsReady = YES;
    return [self start];
}
-(void)abort{
    
}

-(void)scanSNRequest:(NSString *)firstSN{
    HSLogInfo(@" <core> first sn:%@",firstSN);
    //NSError *error = HSError(@"com.TestDomain", 0x64, @"test error message");
    //[self printLog:[error localizedDescription]];
    if (self.selectedUnitsCount > 1) {
        NSInteger unitCount = [self.sequencerSet count];
        NSMutableArray *unitSelectedBoolArr = [NSMutableArray array];
        for (HSTestSequencer *sequencer in self.sequencerSet) {
            HSUnit *unit = sequencer.unit;
            if (unit.state != HSUnitDisable) {
                [unitSelectedBoolArr addObject:@"YES"];
            }else{
                [unitSelectedBoolArr addObject:@"NO"];
            }
        }
        NSDictionary *param = @{
            @"firstSN":firstSN,
            @"unitCount":@(unitCount),
            @"unitSelectedBoolArr":unitSelectedBoolArr
        };
        HSTestRequest *request = [HSTestRequest initWithLimit:nil
                                                        index:0
                                                   identifier:@"ScanSN"
                                                         name:@"ScanSN"
                                                       action:@{@"function":HSTestFunction_scanSN}
                                                       params:param];
        [self.stationUITaskDelegate stationUITaskRequest:request];
    }else{
        self.unitSnArr = [NSMutableArray array];
        for (HSTestSequencer *sequencer in self.sequencerSet) {
            if (sequencer.unit.state == HSUnitDisable) {
                [self.unitSnArr addObject:@""];
            }else{
                [self.unitSnArr addObject:firstSN];
            }
        }
        self.scanSnIsReady = YES;
        [self start];
    }
}
-(void)updateUnitSelectedState:(BOOL )state index:(int )index{
    HSLogInfo(@" <core> unit selected index:%d state:%hhd",index,state);
    HSTestSequencer *sequencer = [self.sequencerSet objectAtIndex:index];
    if (state == YES) {
        sequencer.unit.state = HSUnitIdle;
        //[self.unitsSelectedState replaceObjectAtIndex:index withObject:@(1)];
        self.selectedUnitsCount += 1;
    }else{
        sequencer.unit.state = HSUnitDisable;
        //[self.unitsSelectedState replaceObjectAtIndex:index withObject:@(0)];
        self.selectedUnitsCount -= 1;
    }
    HSLogInfo(@" <core> selectedUnitCount:%lu",self.selectedUnitsCount);
}

#pragma mark -- Delegate - UnitCallStationTaskDelegate
//deleage station level tast request
-(NSDictionary *)unitCallStationTaskRequest:(HSTestRequest *)request{
    [self.syncLock lock];
    NSDictionary *response=nil;
    NSString *name = [request name];
    HSLogInfo(@" <core> unitCallStationTaskRequest name:%@",name);
    NSString *function = [request.action objectForKey:@"function"];
    
    if ([function isEqualToString:HSTestFunction_asyncDialog]) {
        //station async UI task
        response = [self.stationUITaskDelegate stationUITaskRequest:request];
    }
    else if([function isEqualToString:HSTestFunction_syncDialog]){
        //station sync UI task
        response = [self executeSyncStationRequest:request type:@"UI"];
    }
    else if([function isEqualToString:HSTestFunction_fixture]){
        //station sync NonUI task
        response = [self executeSyncStationRequest:request type:@"NonUI"];
    }
    
    [self.syncLock unlock];
    return response;
}
-(NSDictionary *)executeSyncStationRequest:(HSTestRequest *)request type:(NSString *)type{
    NSDictionary *response  = nil;
    //sync for all actived unit
    self.syncRequestCount += 1;
    if (self.syncRequestCount == self.numberOfUnitsTesting) {
        self.syncRequestCount = 0;
        if ([type isEqualToString:@"UI"]) {
            //UI
            response = [self.stationUITaskDelegate stationUITaskRequest:request];
        }else{
            //NonUI
            response = [self.stationSetting executeNonUITaskRequest:request];
        }
        for (HSTestSequencer *sequencer in self.sequencerSet) {
            if (sequencer.unit.state == HSUnitTesting) {
                [sequencer.engine releaseSyncSignal:response];
            }
        }
    }
    return response;
}
#pragma mark -- Delegate - HSTestSequencerDelegate
//event @{@"type":@"end",@"content":nil}
-(void)event:(NSDictionary *)event fromTestSequencer:(int )index{
    HSLogInfo(@" <core> event:%@ sequencer index:%d",event,index);

    [self.sequencerEventThreadLock lock];
    NSString *type = [event objectForKey:@"type"];
    if ([type isEqualToString:@"end"]) {
        self.numberOfUnitsTesting -= 1;
        HSTestSequencer *sequencer = [self.sequencerSet objectAtIndex:index];
        //fail items TOP3
        int count = 0;
        NSMutableString *failMsg = [NSMutableString string];
        if([sequencer.testFailureSet count]>0){
            for (NSDictionary *item in sequencer.testFailureSet) {
                count += 1;
                [failMsg appendFormat:@"[%d]%@\n",count,[item objectForKey:@"name"]];
                if (count == 3) {
                    break;
                }
            }
        }
        sequencer.unit.errorMessage = failMsg;
        sequencer.unit.testStatus = sequencer.testResult;
        sequencer.unit.end = [NSDate date];
        sequencer.unit.state = HSUnitFinished;
        
        if (self.numberOfUnitsTesting == 0) {
            HSLogInfo(@" <core> all sequencer finished");
            self.state = HSTestCoreFinished;
            self.scanSnIsReady = NO;
        }
    }
    [self.sequencerEventThreadLock unlock];
}

@end
