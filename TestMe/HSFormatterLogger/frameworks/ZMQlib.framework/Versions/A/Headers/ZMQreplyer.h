//
//  ZMQreplyer.h
//  OCZMQTest
//
//  Created by WeidongCao on 2020/5/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMQObjC.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ZMQreplerDelegate<NSObject>

-(void)receivedRequestFromZMQreplyer:(NSData *_Nonnull)data;

@end

@interface ZMQreplyer : NSObject

@property (weak) id<ZMQreplerDelegate> delegate;
-(BOOL)initReplyerWithUrl:(NSString *)url;
-(void)sendResponse:(NSString *)response;
@end

NS_ASSUME_NONNULL_END
