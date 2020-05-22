//
//  SubViewControllerDelegate.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SubViewControllerDelegate <NSObject>

-(void)event:(NSDictionary *)event fromSubView:(NSString *)name;

@end
