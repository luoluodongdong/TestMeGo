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
@property NSMutableDictionary *rootConfigDict;
@property NSMutableDictionary *stationConfigDict;

@end

@implementation StationSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    //loopCount
    NSDictionary *loopCountItem = [self.stationConfigDict objectForKey:@"LoopCount"];
    BOOL loopCountEnable = [[loopCountItem objectForKey:@"Enable"] boolValue];
    NSNumber *loopValue = [loopCountItem objectForKey:@"Value"];
    
    [loopValueField setStringValue:[[NSString alloc] initWithFormat:@"%@",loopValue]];
    if (loopCountEnable) {
        [loopCountBtn setState:YES];
        [loopValueField setEnabled:NO];
    }else{
        [loopCountBtn setState:NO];
        [loopValueField setEnabled:YES];
    }
    //PDCA
    BOOL pdcaEnable = [[self.stationConfigDict objectForKey:@"PDCA"] boolValue];
    [pdcaEnableBtn setState:pdcaEnable];
}

-(IBAction)backBtnAction:(id)sender{
    [self updateConfigToFile];
    id cvc = self.parentViewController;
    [cvc switchToDashboardView];
}
-(void)updateConfigToFile{
    [self.rootConfigDict setObject:self.stationConfigDict forKey:@"Config"];
    NSString *portFilePath=[[NSBundle mainBundle] resourcePath];
    portFilePath =[portFilePath stringByAppendingPathComponent:@"Station.plist"];
    [self.rootConfigDict writeToFile:portFilePath atomically:NO];
}
-(void)initView{
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    NSString *filePath=[rawfilePath stringByAppendingPathComponent:@"Station.plist"];
    self.rootConfigDict=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    self.stationConfigDict = [self.rootConfigDict objectForKey:@"Config"];
    [self printLog:[self.stationConfigDict description]];
    
    self.devicePanel = [[DevicesPanelViewController alloc] init];
    //self.devicePanel.devicesList = unit_1_cfg;
    self.devicePanel.configFile = @"Station.plist";
    self.devicePanel.panelIdentifier = @"station";
    self.devicePanel.index = 0;
    self.devicePanel.delegate = self;
    [self.devicePanel.view setFrame:NSMakeRect(35, 195, 500, 300)];
    [self.view addSubview:self.devicePanel.view];
    
}
-(void)closeAllLoadDevices{
    [self.devicePanel closeAllDevices];
}
-(IBAction)loopCountBtnAction:(id)sender{
    BOOL status = [loopCountBtn state];
    if ([[self getNode:@"LoopCount" key:@"Enable"] boolValue] != status) {
        NSNumber *value = [NSNumber numberWithInt:[loopValueField intValue]];
        NSDictionary *item = @{@"Enable":@(status),@"Value":value};
        [self.stationConfigDict setObject:item forKey:@"LoopCount"];
        [self printLog:[self.stationConfigDict description]];
        [loopValueField setEnabled:!status];
    }
}

-(IBAction)pdcaEnableBtn:(id)sender{
    BOOL status = [pdcaEnableBtn state];
    if ([[self.stationConfigDict objectForKey:@"PDCA"] boolValue] != status) {
        [self.stationConfigDict setObject:@(status) forKey:@"PDCA"];
        [self printLog:[self.stationConfigDict description]];
    }
}

-(id)getNode:(NSString *)node key:(NSString *)key{
    NSDictionary *item = [self.stationConfigDict objectForKey:node];
    return [item objectForKey:key];
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
    else if ([function isEqualToString:HSTestFunction_getStationConfig]){
        return @{@"status":@(1),@"data":self.stationConfigDict,@"msg":@""};
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
