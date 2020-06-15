//
//  HSIPWrapper.h
//  PDCAtest
//
//  Created by WeidongCao on 2020/5/27.
//  Copyright © 2020 曹伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantPudding_API.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSIPWrapper : NSObject

-(NSString *)getIPVersion;
-(BOOL)startIPWithSn:(NSString *)sn swName:(NSString *)name swVersion:(NSString *)ver error:(NSError **)err;
-(BOOL)addTestItem:(NSString *)item value:(NSString *)val limitLow:(NSString *)low limitUp:(NSString *)up units:(NSString *)units error:(NSError **)err;
-(BOOL)addAttribute:(NSString *)name value:(NSString *)val error:(NSError **)err;
-(BOOL)addBlob:(NSString *)name filePath:(NSString *)path error:(NSError **)err;
-(BOOL)finishIPError:(NSError **)err;

@end

NS_ASSUME_NONNULL_END
