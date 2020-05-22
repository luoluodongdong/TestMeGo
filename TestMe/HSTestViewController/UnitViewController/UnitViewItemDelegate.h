//
//  UnitViewItemDelegate.h
//  CNGridView Example
//
//  Created by WeidongCao on 2020/4/13.
//  Copyright © 2020 cocoa:naut. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol UnitViewItemDelegate <NSObject>

-(void)clickOnUnit:(int )index;
-(void)clickOnSettingBtn:(int )index;
-(void)clickOnSelectBtn:(int )index state:(BOOL )state;

@end
