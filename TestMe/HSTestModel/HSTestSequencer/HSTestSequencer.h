//
//  HSTestSequencer.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSTestEngine.h"
#import "HSTest.h"
#import "HSUnit.h"
#import "HSTestSequencerProtocol.h"
#import "HSTestDefines.h"
//#import "DBUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSTestSequencer : NSObject
@property (weak) id<HSTestSequencerDelegate> delegate;
@property (assign) int index;
@property (retain, nonatomic) HSUnit *unit;
@property (retain, nonatomic) HSTestEngine *engine;
@property (retain, nonatomic) NSArray *loadedTestplan;

@property (assign) HSTestStatus testResult;
@property (retain, nonatomic) NSMutableArray *testFailureSet;
@property NSMutableArray *testplanData;
@property (retain,nonatomic) NSMutableArray *testRecords;

-(void)initSequencer;
-(BOOL)startTest;
-(void)abortTest;

@end

NS_ASSUME_NONNULL_END
