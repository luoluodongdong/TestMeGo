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


NS_ASSUME_NONNULL_BEGIN

@interface HSTestCoreManager : NSObject<UnitCallStationTaskDelegate,HSTestSequencerDelegate>
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

@property CoreDataInserter *inserter;

-(void)initTestCore;

-(void)scanSNRequest:(NSString *)firstSN;
-(void)updateUnitSelectedState:(BOOL )state index:(int )index;
-(BOOL)start;
-(BOOL)startWithScnSNs:(NSArray *)snArr;
-(void)abort;

@end

NS_ASSUME_NONNULL_END
