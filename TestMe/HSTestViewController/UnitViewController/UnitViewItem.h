//
//  MyViewItem.h
//  CNGridView Example
//
//  Created by WeidongCao on 2020/4/13.
//  Copyright © 2020 cocoa:naut. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CNGridViewItem.h"
#import "UnitBox.h"
#import "UnitViewItemDelegate.h"
#import "HSUnit.h"
#import "HSTestDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnitViewItem : NSViewController
{
    IBOutlet UnitBox *box;
    IBOutlet NSButton *selectBtn;
    IBOutlet NSTextField *titleLabel;
    IBOutlet NSTextField *snLabel;
    IBOutlet NSTextField *stateLabel;
    IBOutlet NSTextField *testStatusLabel;
    IBOutlet NSTextField *msgLabel;
    IBOutlet NSButton *settingBtn;
    IBOutlet NSTextField *timerLabel;
    
}

@property (weak) id <UnitViewItemDelegate> delegate;
@property (nonatomic,assign) int index;
@property (retain, nonatomic) HSUnit *unit;

-(IBAction)settingBtnAction:(id)sender;
-(IBAction)selectBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
