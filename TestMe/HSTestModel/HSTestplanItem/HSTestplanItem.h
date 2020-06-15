//
//  HSTestplanItem.h
//  TestMe
//
//  Created by WeidongCao on 2020/5/5.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSTestplanItem : NSObject

@property (assign, nonatomic) int number;
@property (retain, nonatomic) NSString *group;
@property (retain, nonatomic) NSString *testdescription;
@property (retain, nonatomic) NSString *testid;
@property (retain, nonatomic) NSString *function;
@property (retain, nonatomic) NSString *param1;
@property (retain, nonatomic) NSString *param2;
@property (retain, nonatomic) NSString *low;
@property (retain, nonatomic) NSString *up;
@property (retain, nonatomic) NSString *unit;
@property (assign, nonatomic) double timeout;
@property (retain, nonatomic) NSString *testKEY;
@property (retain, nonatomic) NSString *testVAL;
@property (assign, nonatomic) int fail_count;

@end

NS_ASSUME_NONNULL_END
