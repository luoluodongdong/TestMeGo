//
//  UnitSettingViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "UnitSettingViewController.h"
#import "ContainerViewController.h"
#import "HSTestFunctionDefines.h"
#import "HSLogger.h"

@interface UnitSettingViewController ()

@property DevicesPanelViewController *devicePanel;

@end

@implementation UnitSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [titleLabel setStringValue:[NSString stringWithFormat:@"Unit-%d Setting",self.index + 1]];
}

-(IBAction)backBtnAction:(id)sender{
    id cvc = self.parentViewController;
    [cvc switchToDashboardView];
}
-(void)initView{
    self.devicePanel = [[DevicesPanelViewController alloc] init];
    //self.devicePanel.devicesList = unit_1_cfg;
    self.devicePanel.configFile = @"Station.plist";
    self.devicePanel.panelIdentifier = @"unit";
    self.devicePanel.index = self.index;
    self.devicePanel.delegate = self;
    [self.devicePanel.view setFrame:NSMakeRect(35, 195, 500, 300)];
    [self.view addSubview:self.devicePanel.view];
}
#pragma mark -- Delegate - UnitNonUITaskDelegate
-(NSDictionary *)unitNonUITaskRequest:(HSTestRequest *)request{
    NSString *name = [request name];
    [self printLog:name];
    NSString *function = [request.action objectForKey:@"function"];
    if ([function isEqualToString:HSTestFunction_dmm]) {
        NSDictionary *response = @{
            @"status":@(1),
            @"data":@"0.05",
            @"msg":@""
        };
        return response;
    }
    return nil;
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
        NSDictionary *action = @{@"function":HSTestFunction_unitSettingDialog,@"type":@"UI",@"async":@(1)};
        HSTestRequest *request = [HSTestRequest initWithLimit:nil
                                                        index:self.index
                                                   identifier:@"UnitSetting"
                                                         name:@"config"
                                                       action:action
                                                       params:[event objectForKey:@"content"]];
        [self.stationUITaskDelegate stationUITaskRequest:request];
    }
    else if([type isEqualToString:@"error"]){
        NSDictionary *action = @{@"function":HSTestFunction_unitSettingDialog,@"type":@"UI",@"async":@(1)};
        HSTestRequest *request = [HSTestRequest initWithLimit:nil
                                                        index:self.index
                                                   identifier:@"UnitSetting"
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
    HSLogInfo(@"- <UnitSetting %d> - %@",self.index,log);
    //NSLog(@"[USVC] - <UnitSetting %d> - %@",self.index,log);
}
@end
