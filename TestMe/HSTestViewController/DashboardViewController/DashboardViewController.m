//
//  DashboardViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "DashboardViewController.h"
#import "CNGridViewItem.h"
#import "CNGridViewItemLayout.h"
#import "ContainerViewController.h"
#import "HSCheckSN.h"
#import "ConfigurationEngine.h"
#import "HSLogger.h"

@interface DashboardViewController ()

@property (strong) CNGridViewItemLayout *defaultLayout;
@property (strong) CNGridViewItemLayout *hoverLayout;
@property (strong) CNGridViewItemLayout *selectionLayout;
@property HSTestCoreManager *testCoreManager;
@property HSCheckSN *checkSN;
@property NSMutableArray *unitViewItems;
//@property NSMutableArray *unitSettingViewArr;
//@property NSMutableArray *hsUnitArr;
@property (retain, nonatomic) NSUserDefaults *userDefaults;
@end

@implementation DashboardViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [fixtureSetBtn setHidden:YES];
    [alertLabel setHidden:YES];
    self.hoverLayout.backgroundColor = [[NSColor grayColor] colorWithAlphaComponent:0.42];
    self.selectionLayout.backgroundColor = [NSColor colorWithCalibratedRed:0.542 green:0.699 blue:0.807 alpha:0.420];
    gridView.itemSize = NSMakeSize(300, 350);
    //self.gridView.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"BackgroundDust"]];
    gridView.backgroundColor = [NSColor clearColor];
    gridView.scrollElasticity = YES;    
    [gridView reloadData];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    double inputCount = [self.userDefaults doubleForKey:@"InputCountKey"];
    if (inputCount == 0) {
        [self.userDefaults setDouble:99 forKey:@"InputCountKey"];
        [self.userDefaults setDouble:83 forKey:@"PassCountKey"];
        [self.userDefaults synchronize];
    }
    [self updateYield];
}
-(void)initView{
    self.testCoreManager= [HSTestCoreManager sharedInstance];
    self.checkSN = [[HSCheckSN alloc] init];
    //self.unitSettingViewArr = [NSMutableArray array];
    self.unitViewItems = [[NSMutableArray alloc] init];
    //self.hsUnitArr = [NSMutableArray array];
    NSArray *unitArr = self.testCoreManager.sequencerSet;
    for (int i = 0; i < [unitArr count]; i++) {
        UnitViewItem *viewItem = [[UnitViewItem alloc] initWithNibName:@"UnitViewItem" bundle:nil];
        HSTestSequencer *sequencer = [self.testCoreManager.sequencerSet objectAtIndex:i];
        [viewItem setUnit:sequencer.unit];
        [viewItem setIndex:i];
        [viewItem setDelegate:self];
        [self.unitViewItems addObject:viewItem];
        
        
        //[self.hsUnitArr addObject:unit];
        //[self.unitSettingViewArr addObject:usvc];
    }
    [self.testCoreManager addObserver:self forKeyPath:@"state" options:0x01 context:0x0];
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"state"]) {
        if (self.testCoreManager.state == HSTestCoreTesting) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self changeEnableState:NO];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self changeEnableState:YES];
                [self->inputSnTF becomeFirstResponder];
                [self updateYield];
            });
        }
    }
}
-(void)changeEnableState:(BOOL )state{
    [self->testModeBtn setEnabled:state];
    [self->inputSnTF setEnabled:state];
    [self->startBtn setEnabled:state];
    [self->fixtureSetBtn setEnabled:state];
    [self->clearYieldBtn setEnabled:state];
}
-(void)updateYield{
    double inputCount = [self.userDefaults doubleForKey:@"InputCountKey"];
    double passCount = [self.userDefaults doubleForKey:@"PassCountKey"];
    for (HSTestSequencer *sequencer in self.testCoreManager.sequencerSet) {
        HSUnit *unit = sequencer.unit;
        if (unit.state == HSUnitFinished) {
            inputCount += 1;
            if (unit.testStatus == HSTestStatusPass) {
                passCount += 1;
            }
        }
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.minimumIntegerDigits = 1;
    formatter.maximumIntegerDigits = 3;
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    NSString *yieldStr = @"0.00%";
    if (inputCount != 0) {
        yieldStr =[formatter stringFromNumber:[NSNumber numberWithDouble:(passCount / inputCount)]];
    }
    [self printLog:[NSString stringWithFormat:@"input:%.0f pass:%.0f yield:%@",inputCount,passCount,yieldStr]];
    [inputCountLabel setStringValue:[NSString stringWithFormat:@"%.0f",inputCount]];
    [passCountLabel setStringValue:[NSString stringWithFormat:@"%.0f",passCount]];
    [yieldLabel setStringValue:yieldStr];
    [self.userDefaults setDouble:inputCount forKey:@"InputCountKey"];
    [self.userDefaults setDouble:passCount forKey:@"PassCountKey"];
    [self.userDefaults synchronize];
}
-(void)viewWillAppear{
    
}
-(void)viewDidAppear{
    [inputSnTF becomeFirstResponder];
}
-(void)dealloc{
    [self.testCoreManager removeObserver:self forKeyPath:@"state"];
}
-(IBAction)clearYieldBtnAction:(id)sender{
    [self.userDefaults setDouble:0 forKey:@"InputCountKey"];
    [self.userDefaults setDouble:0 forKey:@"PassCountKey"];
    [self.userDefaults synchronize];
    [self updateYield];
}
-(IBAction)testModeBtnAction:(id)sender{
    if (self.testCoreManager.state == HSTestCoreTesting) {
        return;
    }
    NSString *selectedMode = [[testModeBtn selectedItem] title];
    [self printLog:[NSString stringWithFormat:@"click testmodebtn:%@",selectedMode]];
    NSString *currentMode = self.testCoreManager.operateMode;
    if ([selectedMode isEqualToString:currentMode] == NO) {
        if ([selectedMode isEqualToString:@"Production"]) {
            self.testCoreManager.operateMode = selectedMode;
            [self.parentViewController.view setWantsLayer:YES];
            NSColor *color = [NSColor clearColor];
            [self.parentViewController.view.layer setBackgroundColor:color.CGColor];
            [fixtureSetBtn setHidden:YES];
        }
        else if([selectedMode isEqualToString:@"Audit"]){
            self.testCoreManager.operateMode = selectedMode;
            [self.parentViewController.view setWantsLayer:YES];
            NSColor *color = [ConfigurationEngine auditModeBackgroundColor];
            [self.parentViewController.view.layer setBackgroundColor:color.CGColor];
            [fixtureSetBtn setHidden:YES];
        }
        else if([selectedMode isEqualToString:@"Engineer"]){
            id cvc = self.parentViewController;
            [cvc showPasswordView];
        }
        
    }
}
-(void)passwrodVerifyResult:(BOOL )result{
    if (result == YES) {
        self.testCoreManager.operateMode = @"Engineer";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->fixtureSetBtn setHidden:NO];
            [self.parentViewController.view setWantsLayer:YES];
            NSColor *color = [ConfigurationEngine engineerModeBackgroundColor];
            [self.parentViewController.view.layer setBackgroundColor:color.CGColor];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->testModeBtn selectItemWithTitle:self.testCoreManager.operateMode];
        });
    }
}
-(IBAction)inputSnTFAction:(id)sender{
    NSString *sn = [[inputSnTF stringValue] uppercaseString];
    if ([sn length] == 0) {
        return;
    }
    [self printLog:sn];
    if ([self.testCoreManager selectedUnitsCount] == 0) {
        id cvc = self.parentViewController;
        NSString *msg = [NSString stringWithFormat:@"[Domain]:%@\n[Description]:%@",@"SelectedUnits",@"No units selected!"];
        NSDictionary *config =@{@"type":@"error",@"title":@"ScanSN",@"message":msg};
        [NSThread detachNewThreadWithBlock:^{
            [cvc showDialogWithOK:config];
        }];
        [inputSnTF setStringValue:@""];
        [self printLog:@"No units selected!"];
        return;
    }
    NSError *err = NULL;
    if ([self.checkSN snIsOk:sn error:&err] == NO) {
        id cvc = self.parentViewController;
        NSString *msg = [NSString stringWithFormat:@"[Domain]:%@\n[SN]:%@\n[Description]:%@",[err domain],sn,[err localizedDescription]];
        NSDictionary *config =@{@"type":@"error",@"title":@"ScanSN",@"message":msg};
        [NSThread detachNewThreadWithBlock:^{
            [cvc showDialogWithOK:config];
        }];
        [inputSnTF setStringValue:@""];
        [self printLog:[NSString stringWithFormat:@"first sn:[%@] is NG",sn]];
        return;
    }
    [self printLog:[NSString stringWithFormat:@"first sn:[%@] is OK",sn]];
    [inputSnTF setStringValue:@""];
    [NSThread detachNewThreadWithBlock:^{
        [self.testCoreManager scanSNRequest:sn];
    }];
}
-(IBAction)fixtureSetBtnAction:(id)sender{
    NSLog(@"Click on fixture setting btn");
    id cvc = self.parentViewController;
    [cvc switchToStationSettingView];
}
-(IBAction)startBtnAction:(id)sender{
    if([self.testCoreManager start] == NO){
        id cvc = self.parentViewController;
        NSDictionary *config =@{@"type":@"error",@"title":@"ScanSN",@"message":@"[Domain]:Start Button\n[Description]:TestCore start test failure!"};
        [NSThread detachNewThreadWithBlock:^{
            [cvc showDialogWithOK:config];
        }];
    }
}
#pragma mark - CNGridView DataSource

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"self.item.count:%ld",self.unitViewItems.count);
    return self.unitViewItems.count;
}

- (id)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section {
    
    UnitViewItem *viewItem = [self.unitViewItems objectAtIndex:index];
    return viewItem.view;
}

#pragma mark -- Unit View Item Delegate
-(void)clickOnUnit:(int )index{
    NSLog(@"Click on unit:%d",index);
    id cvc = self.parentViewController;
    [cvc switchToUnitDetailView:index];
}
-(void)clickOnSettingBtn:(int )index{
    [self printLog:[NSString stringWithFormat:@"Click on unit setting:%d",index]];
    id cvc = self.parentViewController;
    HSTestSequencer *sequencer = [self.testCoreManager.sequencerSet objectAtIndex:index];
    [cvc switchToUnitSettingView:sequencer.unit];
}
-(void)clickOnSelectBtn:(int )index state:(BOOL )state{
    [self printLog:[NSString stringWithFormat:@"unit index:%d state:%hhd",index,state]];
    [self.testCoreManager updateUnitSelectedState:state index:index];
    
}

-(void)printLog:(NSString *)log{
    HSLogInfo(@"[DVC] > - %@",log);
    //NSLog(@"[DVC] > - %@",log);
}
@end
