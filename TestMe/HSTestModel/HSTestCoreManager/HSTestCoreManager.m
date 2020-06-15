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
#import "HSTestplanItem.h"

@interface HSTestCoreManager()

@property NSLock *syncLock;
@property NSLock *sequencerEventThreadLock;
@property unsigned long syncRequestCount;
@property (retain, nonatomic) NSMutableArray *unitSnArr;
@property BOOL scanSnIsReady;


//loop
@property BOOL loopEnableFlag;
@property int loopCountNum;
@property int finishedLoopCount;
//@property unsigned long activedUnitCount;

//save csv data
@property dispatch_queue_t collectResultQueue;

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
    self.collectResultQueue = dispatch_queue_create("com.testcoremanager.collectresultqueue", DISPATCH_QUEUE_SERIAL);
    
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
    self.showMessageInfo = @"";
    //loop
    self.loopEnableFlag = NO;
    self.loopCountNum = 1;
    self.finishedLoopCount = 0;
    
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    NSString *filePath=[rawfilePath stringByAppendingPathComponent:@"Station.plist"];
    NSDictionary *rootDict=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    NSArray *groupUnits = [rootDict objectForKey:@"Group-1"];
    
    NSDictionary *stationConfig =[rootDict objectForKey:@"Config"];
    self.testplanData = [HSTestplan loadTestplan:[stationConfig objectForKey:@"TestplanFile"]];
    self.softwareName = [stationConfig objectForKey:@"SoftwareName"];
    self.softwareVersion = [stationConfig objectForKey:@"SoftwareVersion"];
    
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
        sequencer.dbInserterDelegate = self;
        sequencer.delegate = self;
        sequencer.unit = unit;
        sequencer.testplanData = self.testplanData;
        [sequencer initSequencer];
        //unit.sequencer = sequencer;
        [self.sequencerSet addObject:sequencer];
    }

}
-(void)updateStationConfigs{
    HSTestRequest *request = [HSTestRequest initWithLimit:nil
                                                    index:0
                                               identifier:@"testcoremanager"
                                                     name:@"testcoremanager"
                                                   action:@{@"function":HSTestFunction_getStationConfig}
                                                   params:nil];
    NSDictionary *responseDict = [self.stationSetting executeNonUITaskRequest:request];
    self.stationConfigDict = [responseDict objectForKey:@"data"];
    HSLogInfo(@"station config:%@",self.stationConfigDict);
}
-(BOOL)start{
    if (self.state == HSTestCoreTesting || self.selectedUnitsCount == 0) {
        return NO;
    }
    if (self.scanSnIsReady == NO) {
        return NO;
    }
    [self updateShowMessageInfo];
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
            //[self.inserter creatDBUnitWithHSUnit:unit];
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
    self.finishedLoopCount = 0;
    self.showMessageInfo = @"";
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
-(void)updateShowMessageInfo{
    if (self.loopEnableFlag) {
        NSDictionary *loopCountItem = [self.stationConfigDict objectForKey:@"LoopCount"];
        self.loopEnableFlag = [[loopCountItem objectForKey:@"Enable"] boolValue];
        self.loopCountNum = [[loopCountItem objectForKey:@"Value"] intValue];
        self.showMessageInfo = [[NSString alloc] initWithFormat:@"loop: %d/%d",self.loopCountNum,self.finishedLoopCount];
    }else{
        self.showMessageInfo = @"";
    }
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
            if (self.loopEnableFlag == YES) {
                self.finishedLoopCount += 1;
                self.showMessageInfo = [[NSString alloc] initWithFormat:@"loop: %d/%d",self.loopCountNum,self.finishedLoopCount];
                if (self.finishedLoopCount < self.loopCountNum) {
                    self.scanSnIsReady = YES;
                    [NSThread detachNewThreadWithBlock:^{
                        [NSThread sleepForTimeInterval:3.0];
                        [self start];
                    }];
                }
            }else{
                self.scanSnIsReady = NO;
            }
            self.state = HSTestCoreFinished;
            
        }
    }
    [self.sequencerEventThreadLock unlock];
}

#pragma mark -- Delegate - CoreDataInserterDelegate
-(void)unitStart:(HSEvent *)event{
    
}
-(void)testItemStart:(HSEvent *)event{
    [self.inserter testItemStart:event];
}
-(void)testItemFinished:(HSEvent *)event{
    [self.inserter testItemFinished:event];
}
-(void)unitAbort:(HSEvent *)event{
    [self.inserter unitAbort:event];
}
-(void)unitFinished:(HSEvent *)event{
    dispatch_async(self.collectResultQueue, ^{
        [self collectResultAction:event];
        [self.inserter unitFinished:event];
    });
}

-(void)collectResultAction:(HSEvent *)event{
    NSArray *csvdata = [event.userInfo objectForKey:HSEventCSVdataKey];
    //HSLogInfo(@"%@",[csvdata description]);
    NSString *strMonth = [self getCurrentMonth];
    NSString *csvPath = [NSString stringWithFormat:@"/vault/HSLog/%@/%@",self.softwareName,strMonth];
    NSString *strCurrentDate = [self getCurrentDate];
    NSString *strFileName = [NSString stringWithFormat:@"%@_%@.csv", strCurrentDate,self.operateMode];
    
    NSString *strFilePath = [NSString stringWithFormat:@"%@/%@", csvPath, strFileName];
    
    if(YES == [self createCSVFileWithPath:csvPath withFilePath:strFilePath])
    {
        NSMutableString *csvdataString = [NSMutableString string];
        for (NSString *item in csvdata) {
            [csvdataString appendFormat:@"%@,",item];
        }
        [csvdataString appendString:@"\r\n"];
        [self appendDataToFileWithString:csvdataString withFilePath:strFilePath];
    }
}
- (BOOL)appendDataToFileWithString:(NSString *)string withFilePath:(NSString *)strFilePath
{
    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:strFilePath];
    [myHandle seekToEndOfFile];
    [myHandle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [myHandle closeFile];
    
    return YES;
}

-(BOOL)createCSVFileWithPath:(NSString *)path withFilePath:(NSString *)strLogFilePath
{
    BOOL isDir = NO;
    NSError *errMsg;
    
    //1. Get execution tool's folder path
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //2. If bDirExist&isDir are true, the directory exit
    BOOL bDirExist = [fm fileExistsAtPath:path isDirectory:&isDir];
    if (!(bDirExist == YES && isDir == YES))
    {
        if (NO == [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&errMsg])
            return NO;
    }
    
    //4. Check file exist or not
    //5. If file not exist, creat data to file
    //    bDirExist = [fm fileExistsAtPath:_logFilePath isDirectory:&isDir];
    if (NO == [fm fileExistsAtPath:strLogFilePath isDirectory:&isDir])
    {
        if (NO == [fm createFileAtPath:strLogFilePath contents:nil attributes:nil])
        {
            return NO;
        }
        
        NSString *strSum = [[NSString alloc] init];
        if (NO == [strSum writeToFile:strLogFilePath atomically:YES encoding:NSUTF8StringEncoding error:&errMsg])
        {
            return NO;
        }
        NSString *strTitle=[self getCsvTitle];
        [self appendDataToFileWithString:strTitle withFilePath:strLogFilePath];//第一次创建时，增加每一列的标题
    }
    
    return YES;
}

-(NSString *)getCsvTitle{
    
    NSMutableArray *itemsData=[[NSMutableArray alloc] initWithCapacity:1];
    
    NSMutableArray *lowData=[[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *upData=[[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *unitData=[[NSMutableArray alloc] initWithCapacity:1];
    for (int index=0; index<[self.testplanData count]; index++) {
        HSTestplanItem *thisItem = [self.testplanData objectAtIndex:index];
        NSString *testID = thisItem.testid;
        if ([testID containsString:@" | "]) {
            testID = [testID componentsSeparatedByString:@" | "][0];
        }
        //Test Data:     ||      TestPlan:
        [itemsData addObject:testID];
        [lowData addObject:thisItem.low];
        [upData addObject:thisItem.up];
        [unitData addObject:thisItem.unit];
    }
    NSString *csvTitle = @"SN--->,Result,FailureList,StationID,SlotID,StartTime,EndTime,Version,";
    for(NSString *item in itemsData){
        csvTitle = [csvTitle stringByAppendingString:item];
        csvTitle = [csvTitle stringByAppendingString:@","];
    }
    csvTitle = [csvTitle stringByAppendingString:@"\r\n"];
    csvTitle = [csvTitle stringByAppendingString:@"LowerLimit--->,,,,,,,,"];
    for(NSString *item in lowData){
        csvTitle = [csvTitle stringByAppendingString:item];
        csvTitle = [csvTitle stringByAppendingString:@","];
    }
    csvTitle = [csvTitle stringByAppendingString:@"\r\n"];
    csvTitle = [csvTitle stringByAppendingString:@"UpperLimit--->,,,,,,,,"];
    for(NSString *item in upData){
        csvTitle = [csvTitle stringByAppendingString:item];
        csvTitle = [csvTitle stringByAppendingString:@","];
    }
    csvTitle = [csvTitle stringByAppendingString:@"\r\n"];
    csvTitle = [csvTitle stringByAppendingString:@"MeasurementUnit--->,,,,,,,,"];
    for(NSString *item in unitData){
        csvTitle = [csvTitle stringByAppendingString:item];
        csvTitle = [csvTitle stringByAppendingString:@","];
    }
    csvTitle = [csvTitle stringByAppendingString:@"\r\n"];
    
    return csvTitle;
}
//2019.11.12 18:44:35
- (NSString *)getCurrentTime
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"YYYY_MM_dd_HH:mm:ss"];
    [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
//2019/11/12 18:44:35
-(NSString *)getCurrentTimeStr{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"YYYY_MM_dd_HH:mm:ss"];
    [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
//2019_01
- (NSString *) getCurrentMonth
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
//2019_01_21
- (NSString *) getCurrentDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
//20190121101245342
-(NSString *)getCurrentTimeSuffix{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
//2019_01_21_10
-(NSString *)getCurrentHourSuffix{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd_HH"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
@end
