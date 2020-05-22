//
//  ContainerViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ContainerViewController.h"
#import "HSTestFunctionDefines.h"
#import "HSLogger.h"

@interface ContainerViewController ()
@property ScanSN *scanSnVC;
@property LoadViewController *loadVC;
@property DashboardViewController *dashboardVC;
@property HSTestCoreManager *testCoreManager;
@property StationSettingViewController *stationSettingVC;
//@property UnitSettingViewController *unitSettingVC;
@property UnitDetailViewController *unitDetailVC;
@property MessageWithOkView *messageWithOkView;
@property DialogWithOkViewController *dialogWithOkView;
@property NSViewController *currentVC;

@property NSMutableArray *unitSettingArr;

@property (retain, nonatomic) dispatch_semaphore_t popoverSemaphore;
@property NSLock *threadLock;
@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.currentVC = nil;
    self.popoverSemaphore = dispatch_semaphore_create(0x0);
    self.threadLock = [[NSLock alloc] init];
    self.unitSettingArr = [NSMutableArray array];

    //[self presentViewControllerAsSheet:self.dashboardVC];
}
-(void)viewWillAppear{
    [self printLog:[NSString stringWithFormat:@"self.loginFlag:%hhd",self.loginFlag]];
    if (self.loginFlag == YES) {
        [self switchToLoginView];
    }else{
        [self switchToLoadView];
    }
}
-(void)viewWillDisappear{
    
}
-(void)switchToLoginView{
    LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    lvc.delegate = self;
    
    lvc.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    [lvc.view setFrameSize:self.view.frame.size];
    [self.view addSubview:lvc.view];
    [self addChildViewController:lvc];
    self.currentVC = lvc;
}
-(void)switchToLoadView{
    self.loadVC= [[LoadViewController alloc] initWithNibName:@"LoadViewController" bundle:nil];
    self.loadVC.delegate = self;
    
    self.loadVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    [self.loadVC.view setFrameSize:self.view.frame.size];
    [self.view addSubview:self.loadVC.view];
    [self addChildViewController:self.loadVC];
    self.currentVC = self.loadVC;

    [NSThread detachNewThreadWithBlock:^{
        [NSThread sleepForTimeInterval:0.2];
        [self.loadVC updateProgressMsg:@"Init...test core manager..." indicatorValue:20];
        [self loadTestCoreManager];
        [NSThread sleepForTimeInterval:0.1];
        [self.loadVC updateProgressMsg:@"Init...station setting view..." indicatorValue:40];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self loadStationSettingView];
        });
        [NSThread sleepForTimeInterval:0.1];
        [self.loadVC updateProgressMsg:@"Init...dashboard view..." indicatorValue:60];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self loadDashboardView];
        });
        [NSThread sleepForTimeInterval:0.1];
        [self.loadVC updateProgressMsg:@"Init...all unit setting views..." indicatorValue:70];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self loadUnitSettingViews];
        });
        [NSThread sleepForTimeInterval:0.1];
        [self.loadVC updateProgressMsg:@"Init...all unit detail views..." indicatorValue:80];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self loadUnitDetailView];
        });
        [NSThread sleepForTimeInterval:0.1];
        [self.loadVC updateProgressMsg:@"Init...scan view..." indicatorValue:90];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self loadScanSnView];
        });
        [NSThread sleepForTimeInterval:0.1];
        [self.loadVC updateProgressMsg:@"Done...all progress finished" indicatorValue:100];
        [NSThread sleepForTimeInterval:0.5];
    }];
    
}
-(void)loadTestCoreManager{
    self.testCoreManager = [[HSTestCoreManager alloc] init];
    self.testCoreManager.stationUITaskDelegate = self;
    [self.testCoreManager initTestCore];
}
-(void)loadStationSettingView{
    self.stationSettingVC = [[StationSettingViewController alloc] init];
    self.stationSettingVC.stationUITaskDelegate = self;
    [self.stationSettingVC initView];
    //StationSetting - delegate -> StationNonUITaskDelegate -> StationSettingViewController
    self.testCoreManager.stationSetting.delegate = self.stationSettingVC;
    //[NSThread sleepForTimeInterval:2.0];
    [self printLog:@"load station setting view done"];
}
-(void)loadDashboardView{
    self.dashboardVC = [[DashboardViewController alloc] init];
    [self.dashboardVC initView];
    [self printLog:@"load dashboard view done"];
}
-(void)loadUnitDetailView{
    self.unitDetailVC = [[UnitDetailViewController alloc] init];
    self.unitDetailVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.unitDetailVC.context = [[CoreDataInjection sharedInstance] uiContext];
    self.unitDetailVC.testplanArray = self.testCoreManager.testplanData;
    [self.unitDetailVC initView];
    [self printLog:@"load unit detail view done"];
}
-(void)loadUnitSettingViews{
    NSArray *sequencerArr = self.testCoreManager.sequencerSet;
    for (int i = 0; i < [sequencerArr count]; i++){
        HSTestSequencer *sequencer = [self.testCoreManager.sequencerSet objectAtIndex:i];
        UnitSettingViewController *usvc = [[UnitSettingViewController alloc] init];
        usvc.index = i;
        usvc.stationUITaskDelegate = self;
        [usvc initView];
        //UnitSetting - delegate UnitNonUITaskDelegate -> UnitSettingViewController
        sequencer.unit.setting.delegate = usvc;
        [self.unitSettingArr addObject:usvc];
    }
    [self printLog:@"load unit setting views done"];
}
-(void)loadScanSnView{
    self.scanSnVC = [[ScanSN alloc] init];
    [self.scanSnVC initScanSnView];
    self.scanSnVC.delegate = self;
}
-(void)switchToDashboardView{
    
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    self.dashboardVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.dashboardVC.view setFrameSize:self.view.frame.size];
    [self.view addSubview:self.dashboardVC.view];
    [self addChildViewController:self.dashboardVC];
    self.currentVC = self.dashboardVC;
}
-(void)switchToUnitDetailView:(int )index{
    //UnitDetailViewController *udvc = [[UnitDetailViewController alloc] initWithNibName:@"UnitDetailViewController" bundle:nil];
    //self.unitDetailVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    //self.unitDetailVC.index = index;
    //NSString *identifier = [NSString stringWithFormat:@"Group-1 : Unit-%d",index+1];
    HSTestSequencer *sequencer = [self.testCoreManager.sequencerSet objectAtIndex:index];
    if (sequencer.unit.state == HSUnitIdle || sequencer.unit.state == HSUnitDisable) {
        return;
    }
    DBUnit *unit = [self.testCoreManager.inserter _fetchUnitWithUUID:sequencer.unit.uuid];
    [self.unitDetailVC setUnit:unit];
    self.unitDetailVC.index = sequencer.index;
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    [self.unitDetailVC.view setFrameSize:self.view.frame.size];
    [self.view addSubview:self.unitDetailVC.view];
    [self addChildViewController:self.unitDetailVC];
    self.currentVC = self.unitDetailVC;
}
-(void)switchToUnitSettingView:(HSUnit *)unit{
    UnitSettingViewController *usvc = [self.unitSettingArr objectAtIndex:unit.index];
    //usvc.index = index;
    
    usvc.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    [usvc.view setFrameSize:self.view.frame.size];
    [self.view addSubview:usvc.view];
    [self addChildViewController:usvc];
    self.currentVC = usvc;
}
-(void)switchToStationSettingView{
    self.stationSettingVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    [self.stationSettingVC.view setFrameSize:self.view.frame.size];
    [self.view addSubview:self.stationSettingVC.view];
    [self addChildViewController:self.stationSettingVC];
    self.currentVC = self.stationSettingVC;
}
-(void)showPasswordView{
    dispatch_async(dispatch_get_main_queue(), ^{
        PasswordViewController *passwordVC = [[PasswordViewController alloc] init];
        passwordVC.rawPasswordStr = @"LuxshareTE";
        passwordVC.delegate = self;
        [self presentViewControllerAsSheet:passwordVC];
    });
}
#pragma mark -- Delegate - PasswordViewController
-(void)messageFromPasswordView:(NSDictionary *)msg{
    NSString *state = [msg objectForKey:@"state"];
    if ([state isEqualToString:@"OK"]) {
        [self.dashboardVC passwrodVerifyResult:YES];
    }else{
        [self.dashboardVC passwrodVerifyResult:NO];
    }
}
#pragma mark -- Delegate - SubViewController
-(void)event:(NSDictionary *)event fromSubView:(NSString *)name{
    NSLog(@"[CVC]event:%@ from:%@",event,name);
    if ([name isEqualToString:@"LoadView"]) { //load view finish progress
        dispatch_async(dispatch_get_main_queue(), ^{
            [self switchToDashboardView];
        });
    }
    else if([name isEqualToString:@"LoginView"]){ //login operate successful
        dispatch_async(dispatch_get_main_queue(), ^{
            [self switchToLoadView];
        });
    }
    else if([name isEqualToString:@"ScanSNView"]){
        NSString *type = [event objectForKey:@"type"];
        if ([type isEqualToString:@"OK"]) {
            [self.testCoreManager startWithScnSNs:[event objectForKey:@"content"]];
        }
    }
}

-(void)showMessageWithOK:(NSDictionary *)config{
    @synchronized (self.popoverSemaphore) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.messageWithOkView = [[MessageWithOkView alloc] init];
            self.messageWithOkView.dismissSemaphore = self.popoverSemaphore;
            self.messageWithOkView.titleName = [config objectForKey:@"title"];
            self.messageWithOkView.message = [config objectForKey:@"message"];
            //self.currentPopOverController = self.customFormVC;
            [self presentViewControllerAsSheet:self.messageWithOkView];
        });
        [self printLog:@"present messageWithOK viewcontroller"];
        dispatch_semaphore_wait(self.popoverSemaphore, DISPATCH_TIME_FOREVER);
        //NSLog(@"cfv.outputPointer:%@",self.customFormVC.outputPointer);
        //self.currentPopOverController = nil;
    }
}

-(void)showDialogWithOK:(NSDictionary *)config{
    @synchronized (self.popoverSemaphore) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dialogWithOkView = [[DialogWithOkViewController alloc] init];
            self.dialogWithOkView.dismissSemaphore = self.popoverSemaphore;
            self.dialogWithOkView.type = [config objectForKey:@"type"];
            self.dialogWithOkView.titleStr = [config objectForKey:@"title"];
            self.dialogWithOkView.messageStr = [config objectForKey:@"message"];
            //self.currentPopOverController = self.customFormVC;
            [self presentViewControllerAsSheet:self.dialogWithOkView];
        });
        [self printLog:@"present dialogWithOK viewcontroller"];
        dispatch_semaphore_wait(self.popoverSemaphore, DISPATCH_TIME_FOREVER);
        //NSLog(@"cfv.outputPointer:%@",self.customFormVC.outputPointer);
        //self.currentPopOverController = nil;
    }
}
-(void)showScanSnView:(NSDictionary *)param{
    dispatch_async(dispatch_get_main_queue(), ^{
        int unitCount = [[param objectForKey:@"unitCount"] intValue];
        NSString *firstSN = [param objectForKey:@"firstSN"];
        NSArray *unitSelectedBoolArr = [param objectForKey:@"unitSelectedBoolArr"];
        self.scanSnVC.UNIT_COUNT = unitCount;
        self.scanSnVC._firstSN = firstSN;
        self.scanSnVC._select_Slot_BoolArr = unitSelectedBoolArr;
        [self presentViewControllerAsSheet:self.scanSnVC];
    });
}
#pragma mark -- Delegate - StationUITaskDelegate
-(NSDictionary *)stationUITaskRequest:(HSTestRequest *)request{
    [self.threadLock lock];
    NSDictionary *response = nil;
    NSString *function = [request.action objectForKey:@"function"];
    NSString *name = [request name];
    [self printLog:[NSString stringWithFormat:@"[%@] - name:%@",function,name]];
    NSString *param1 = [request.params objectForKey:@"param1"];
    NSString *param2 = [request.params objectForKey:@"param2"];
    if ([function isEqualToString:HSTestFunction_asyncDialog]) {
        [self showMessageWithOK:@{@"title":request.identifier,@"message":param1}];
        response = @{@"status":@(1),@"data":@"OK",@"msg":@""};
    }
    else if([function isEqualToString:HSTestFunction_syncDialog]){
        [self showMessageWithOK:@{@"title":@"Sync Dialog",@"message":param1}];
        response = @{@"status":@(1),@"data":@"OK",@"msg":@""};
    }
    else if ([function isEqualToString:HSTestFunction_stationSettingDialog]) {
        NSString *type = [request.params objectForKey:@"Type"];
        NSString *identifierEvent = [request.params objectForKey:@"Identifier"];
        NSString *description = [request.params objectForKey:@"Description"];
        NSString *msg = [NSString stringWithFormat:@"[Type]:%@\n[Identifier]:%@\n[Description]:%@",type,identifierEvent,description];
        NSDictionary *config = @{@"title":@"StationSetting",@"message":msg,@"type":name};
        [NSThread detachNewThreadWithBlock:^{
            [self showDialogWithOK:config];
        }];
    }
    else if ([function isEqualToString:HSTestFunction_unitSettingDialog]) {
        NSString *type = [request.params objectForKey:@"Type"];
        NSString *identifierEvent = [request.params objectForKey:@"Identifier"];
        NSString *description = [request.params objectForKey:@"Description"];
        NSString *msg = [NSString stringWithFormat:@"[Type]:%@\n[Identifier]:%@\n[Description]:%@",type,identifierEvent,description];
        NSString *dialogTitle = [NSString stringWithFormat:@"Unit-%d Setting",request.index+1];
        NSDictionary *config = @{@"title":dialogTitle,@"message":msg,@"type":name};
        [NSThread detachNewThreadWithBlock:^{
            [self showDialogWithOK:config];
        }];
    }
    else if([function isEqualToString:HSTestFunction_scanSN]){
        NSDictionary *param = [request params];
        [self showScanSnView:param];
    }
    
    [self.threadLock unlock];
    return response;
}

-(void)printLog:(NSString *)log{
    HSLogInfo(@"[CVC] > - %@",log);
    //NSLog(@"[CVC] > - %@",log);
}
@end
