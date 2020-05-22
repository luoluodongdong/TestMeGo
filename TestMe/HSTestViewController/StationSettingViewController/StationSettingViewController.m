//
//  FixtureSettingViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "StationSettingViewController.h"
#import "ContainerViewController.h"
#import "HSTestFunctionDefines.h"
#import "HSLogger.h"

@interface StationSettingViewController ()

@property DevicesPanelViewController *devicePanel;

@end

@implementation StationSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

-(IBAction)backBtnAction:(id)sender{
    id cvc = self.parentViewController;
    [cvc switchToDashboardView];
}
-(void)initView{
    self.devicePanel = [[DevicesPanelViewController alloc] init];
    //self.devicePanel.devicesList = unit_1_cfg;
    self.devicePanel.configFile = @"Station.plist";
    self.devicePanel.panelIdentifier = @"station";
    self.devicePanel.index = 0;
    self.devicePanel.delegate = self;
    [self.devicePanel.view setFrame:NSMakeRect(35, 195, 500, 300)];
    [self.view addSubview:self.devicePanel.view];
}
-(NSDictionary *)stationNonUITaskRequest:(HSTestRequest *)request{
    NSString *name = [request name];
    [self printLog:name];
    NSString *function = [request.action objectForKey:@"function"];
    
    if ([function isEqualToString:HSTestFunction_fixture]) {
        NSString *cmd = [request.params objectForKey:@"param1"];
        if ([cmd isEqualToString:@"reset"]) {
            [NSThread sleepForTimeInterval:0.5];
            return @{@"status":@(1),@"data":@"OK",@"msg":@""};
        }
        else if ([cmd isEqualToString:@"getFixtureID"]){
            return @{@"status":@(1),@"data":@"FIX-002",@"msg":@""};
        }
        else if ([cmd isEqualToString:@"getVendorID"]){
            return @{@"status":@(1),@"data":@"Luxshare-ICT",@"msg":@""};
        }else{
            [NSThread sleepForTimeInterval:0.5];
            return @{@"status":@(1),@"data":@"OK",@"msg":@""};
        }
    }
    return @{@"status":@(0),@"data":@"",@"msg":@"unknown function"};
}

#pragma mark -- Device Panel Delegate
-(void)receivedFromDevicePanel:(NSString *)data identifier:(NSString *)identifier{
    NSString *log = [NSString stringWithFormat:@"received:%@ identifier:%@",data,identifier];
    [self printLog:log];

}
-(void)eventFromDevicePanel:(NSDictionary *)event identifier:(NSString *)identifier{
    NSString *log = [NSString stringWithFormat:@"event:%@ identifier:%@",event,identifier];
    [self printLog:log];
    NSString *type = [event objectForKey:@"event"];
    if ([type isEqualToString:@"config"] ) {
        NSDictionary *action = @{@"function":HSTestFunction_stationSettingDialog,@"type":@"UI",@"async":@(1)};
        HSTestRequest *request = [HSTestRequest initWithLimit:nil
                                                        index:0
                                                   identifier:@"StationSetting"
                                                         name:@"config"
                                                       action:action
                                                       params:[event objectForKey:@"content"]];
        [self.stationUITaskDelegate stationUITaskRequest:request];
    }
    else if([type isEqualToString:@"error"]){
        NSDictionary *action = @{@"function":HSTestFunction_stationSettingDialog,@"type":@"UI",@"async":@(1)};
        HSTestRequest *request = [HSTestRequest initWithLimit:nil
                                                        index:0
                                                   identifier:@"StationSetting"
                                                         name:@"error"
                                                       action:action
                                                       params:[event objectForKey:@"content"]];
        [self.stationUITaskDelegate stationUITaskRequest:request];
    }
    else if([type isEqualToString:@"connect"]){
        
    }
    else if([type isEqualToString:@"disconnect"]){
        
    }
}

-(void)printLog:(NSString *)log{
    HSLogInfo(@"[SSVC] > - %@",log);
    //NSLog(@"[SSVC] > - %@",log);
}
@end
