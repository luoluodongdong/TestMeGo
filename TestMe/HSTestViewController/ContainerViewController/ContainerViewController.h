//
//  ContainerViewController.h
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DashboardViewController.h"
#import "UnitDetailViewController.h"
#import "UnitSettingViewController.h"
#import "StationSettingViewController.h"
#import "LoginViewController.h"
#import "LoadViewController.h"
#import "SubViewControllerDelegate.h"
#import "MessageWithOkView.h"
#import "DialogWithOkViewController.h"
#import "PasswordViewController.h"
//#import "HSTestProtocols.h"
#import "HSTestCoreManager.h"
#import "StationUITaskProtocol.h"
#import "ScanSN.h"
#import "DBUnit.h"
#import "ExitViewController.h"
#import "SecurityManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContainerViewController : NSViewController<SubViewControllerDelegate,StationUITaskDelegate,PasswordViewDelegate>

@property (assign, nonatomic) BOOL loginFlag;

-(void)switchToDashboardView;
-(void)switchToUnitDetailView:(int )index;
-(void)switchToUnitSettingView:(HSUnit *)unit;
-(void)switchToStationSettingView;
-(void)switchToExitView;
//config:@{@"title":@"title",@"message":@"message"}
-(void)showMessageWithOK:(NSDictionary *)config;
//config:@{@"type":@"info",@"title":@"title",@"message":@"message"}
//type:info,config,warning,error
-(void)showDialogWithOK:(NSDictionary *)config;
-(void)showPasswordView;
@end

NS_ASSUME_NONNULL_END
