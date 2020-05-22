//
//  HSTestRequest.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/17.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "HSTestRequest.h"

@implementation HSTestRequest
+(HSTestRequest *)initWithLimit:(HSTestLimit *__nullable)limit index:(int )index identifier:(NSString *__nullable)identifier name:(NSString *__nullable)name action:(NSDictionary *__nullable)action params:(NSDictionary *__nullable)params{
    HSTestRequest *request = [[HSTestRequest alloc] init];
    request.limit = limit;
    request.index = index;
    request.identifier = identifier;
    request.name = name;
    request.action = action;
    request.params = params;
    return request;
}
@end
