//
//  DashboardViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CNGridView.h"
#import "UnitViewItem.h"
#import "HSTestCoreManager.h"
#import "HSUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface DashboardViewController : NSViewController<CNGridViewDataSource, UnitViewItemDelegate>
{
    IBOutlet NSTextField *alertLabel;
    IBOutlet NSTextField *messageLabel;
    IBOutlet NSTextField *titleLabel;
    IBOutlet NSPopUpButton *testModeBtn;
    
    IBOutlet NSTextField *inputCountLabel;
    IBOutlet NSTextField *passCountLabel;
    IBOutlet NSTextField *yieldLabel;
    IBOutlet NSButton *clearYieldBtn;
    
    IBOutlet NSBox *operateBox;
    IBOutlet NSTextField *inputSnTF;
    IBOutlet NSButton *fixtureSetBtn;
    IBOutlet NSButton *startBtn;
    
    IBOutlet  CNGridView *gridView;
}

-(IBAction)clearYieldBtnAction:(id)sender;
-(IBAction)testModeBtnAction:(id)sender;

-(IBAction)inputSnTFAction:(id)sender;
-(IBAction)fixtureSetBtnAction:(id)sender;
-(IBAction)startBtnAction:(id)sender;


-(void)initView;
-(void)passwrodVerifyResult:(BOOL )result;

@end

NS_ASSUME_NONNULL_END
