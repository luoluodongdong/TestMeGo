//
//  HSUnit.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnitSettingViewController.h"
//#import "HSTestSequencer.h"
#import "HSTestDefines.h"
#import "HSUnitSetting.h"
NS_ASSUME_NONNULL_BEGIN

@interface HSUnit : NSObject

@property (assign) int index;
//@property (retain, nonatomic) HSTestSequencer *sequencer;
//@property (retain, nonatomic) HSTestEngine *engine;

@property (retain, nonatomic) NSUUID *uuid;
@property (retain, nonatomic) HSUnitSetting *setting;
@property NSDate *start;
@property NSDate *end;
@property (retain, nonatomic) NSString *serialnumber;
@property (retain, nonatomic) NSString *identifier;
@property (assign) HSUnitState state;
@property (assign) HSTestStatus testStatus;
@property (retain, nonatomic) NSString *errorMessage;

@end

NS_ASSUME_NONNULL_END
