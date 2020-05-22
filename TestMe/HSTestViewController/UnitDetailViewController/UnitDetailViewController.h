//
//  UnitDetailViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSTestSequencer.h"
#import "DBUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnitDetailViewController : NSViewController
{
    IBOutlet NSButton *backBtn;
    IBOutlet NSTextField *titleLabel;
    IBOutlet NSTextField *timerLabel;
    IBOutlet NSTableView *detailTableView;
    
    IBOutlet NSArrayController *recordsArrayController;
    
    IBOutlet NSButton *showPassBtn;
    IBOutlet NSSearchField *searchField;
}

@property (assign) int index;
@property (retain, nonatomic) NSArray *testplanArray;
@property(retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) DBUnit *unit;

-(void)initView;

-(IBAction)backBtnAction:(id)sender;
-(IBAction)showPassBtnAction:(id)sender;
-(IBAction)searchBtnCancelAction:(id)sender;
-(IBAction)searchBtnSearchAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
