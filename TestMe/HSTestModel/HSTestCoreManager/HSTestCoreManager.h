//
//  HSTestCoreManager.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSTestSequencer.h"
#import "HSUnit.h"
#import "HSStationSetting.h"
#import "UnitCallStationTaskProtocol.h"
#import "StationUITaskProtocol.h"
#import "HSTestSequencerProtocol.h"
#import "CoreDataInjection.h"
#import "CoreDataInserter.h"
#import "CoreDataInserterDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSTestCoreManager : NSObject<UnitCallStationTaskDelegate,HSTestSequencerDelegate,CoreDataInserterDelegate>
+ (id)sharedInstance;
@property (weak) id<StationUITaskDelegate> stationUITaskDelegate;

@property (retain, nonatomic) NSDictionary *stationTopology;
@property (retain, nonatomic) HSStationSetting *stationSetting;
@property (assign) HSTestCoreState state;
//@property (retain, nonatomic) NSMutableArray *unitSet;
@property (assign) long selectedUnitsCount;
//@property (retain, nonatomic) NSMutableArray *unitsSelectedState;
@property (assign) long numberOfUnitsTesting;
@property NSMutableArray *sequencerSet;
@property NSMutableArray *testplanData;
@property NSString *operateMode;
@property NSString *softwareName;
@property NSString *softwareVersion;
@property NSString *showMessageInfo;
@property (retain, nonatomic) NSDictionary *stationConfigDict;
@property CoreDataInserter *inserter;

-(void)initTestCore;
-(void)updateStationConfigs;
-(void)scanSNRequest:(NSString *)firstSN;
-(void)updateUnitSelectedState:(BOOL )state index:(int )index;
-(BOOL)start;
-(BOOL)startWithScnSNs:(NSArray *)snArr;
-(void)abort;

@end

NS_ASSUME_NONNULL_END
