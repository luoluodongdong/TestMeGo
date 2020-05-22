//
//  HSTestDefines.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/22.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (short, HSTestCoreState)
{
    HSTestCoreInit = 0,
    HSTestCoreTesting = 1,
    HSTestCoreFinished = 2,
};

typedef NS_ENUM (short, HSUnitState)
{
    HSUnitDisable = -2,
    HSUnitIdle = -1,
    HSUnitAppeared = 0,
    HSUnitTesting = 1,
    HSUnitFinished = 2,
};

typedef NS_ENUM (short, HSTestStatus)
{
    HSTestStatusSkipped = 2,
    HSTestStatusPass = 1,
    HSTestStatusNotSet = 0,
    HSTestStatusFail = -1,
    HSTestStatusError = -2,
    HSTestStatusPanic = -3,
};

#ifdef __cplusplus
extern "C" {
#endif

NSError* HSError(NSString *domain, NSUInteger code, NSString *message);


#ifdef __cplusplus
}
#endif

//testplan.csv
#define TP_GROUP_INDEX            0
#define TP_DESCRIPTION_INDEX      1
#define TP_TID_INDEX              2
#define TP_FUNCTION_INDEX         3
#define TP_PARAM1_INDEX           4
#define TP_PARAM2_INDEX           5
#define TP_LOW_INDEX              6
#define TP_HIGH_INDEX             7
#define TP_UNIT_INDEX             8
#define TP_TIMEOUT_INDEX          9
#define TP_KEY_INDEX              10
#define TP_VAL_INDEX              11
#define TP_FAIL_COUNT_INDEX       12

