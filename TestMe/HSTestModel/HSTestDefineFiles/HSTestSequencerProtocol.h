//
//  HSTestSequencerProtocol.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/22.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol HSTestSequencerDelegate <NSObject>

-(void)event:(NSDictionary *)event fromTestSequencer:(int )index;

@end
