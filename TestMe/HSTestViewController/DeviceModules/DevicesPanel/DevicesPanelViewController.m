//
//  DevicesPanelViewController.m
//  DeviceModuleDevelopment
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "DevicesPanelViewController.h"

@interface DevicesPanelViewController ()
@property IBOutlet NSScrollView *scrollView;

@property NSMutableDictionary *rootDict;
@property NSMutableArray *devicesList;
@end

@implementation DevicesPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    //self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    NSString *filePath=[rawfilePath stringByAppendingPathComponent:self.configFile];
    self.rootDict=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    self.devicesList = [NSMutableArray array];
    if ([self.panelIdentifier isEqualToString:@"unit"]) {
        NSArray *group = [self.rootDict objectForKey:@"Group-1"];
        self.devicesList = [[group objectAtIndex:self.index] objectForKey:@"Devices"];
    }else{
        self.devicesList = [self.rootDict objectForKey:@"Devices"];
    }
   
    if (self.devicesList == nil || [self.devicesList count] == 0) {
        return;
    }
    self.loadDevicesDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    unsigned long devCount = self.devicesList.count;
    int x=0;
    unsigned long y= 100 * (devCount-1);
    NSView *contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 100*devCount)];
    //self.scrollView.contentSize = NSMakeSize(500, 400);
    int dev_index = -1;
    for (NSDictionary *devCfg in self.devicesList) {
        BOOL enable = [[devCfg objectForKey:@"Enable"] boolValue];
        dev_index +=1;
        if (enable == NO) {
            continue;
        }
        
        NSString *type = [devCfg objectForKey:@"Type"];
        NSString *description = [devCfg objectForKey:@"Description"];
        NSString *devName = [devCfg objectForKey:@"Name"];
        BOOL autoOpenFlag = [[devCfg objectForKey:@"AutoOpen"] boolValue];
        if ([type isEqualToString:@"SERIAL"]) {
            NSString *portName = [devCfg objectForKey:@"PortName"];
            int baudrate = [[devCfg objectForKey:@"Baudrate"] intValue];
            BOOL RTS = [[devCfg objectForKey:@"RTS"] boolValue];
            BOOL DTR = [[devCfg objectForKey:@"DTR"] boolValue];
            BOOL DTRDSRFlowControl = [[devCfg objectForKey:@"DTRDSRFlowControl"] boolValue];
            BOOL RTSCTSFlowControl = [[devCfg objectForKey:@"RTSCTSFlowControl"] boolValue];
            BOOL DCDOutputFlowControl = [[devCfg objectForKey:@"DCDOutputFlowControl"] boolValue];
            MySerialPanel *serialPanel = [[MySerialPanel alloc] initWithNibName:@"mySerialPanel" bundle:nil];
            serialPanel.device_index = dev_index;
            serialPanel.serial_identifier = devName;
            serialPanel.serial_description = description;
            serialPanel.RTS = RTS;
            serialPanel.DTR = DTR;
            serialPanel.usesDTRDSRFlowControl = DTRDSRFlowControl;
            serialPanel.usesRTSCTSFlowControl = RTSCTSFlowControl;
            serialPanel.usesDCDOutputFlowControl = DCDOutputFlowControl;
            serialPanel.serial_name = portName;
            serialPanel.serial_baud = baudrate;
            serialPanel.delegate = self;
            
            [serialPanel initView];
            if (autoOpenFlag) {
                BOOL status = [serialPanel autoOpenSerial];
                NSLog(@"[DPVC]-auto open:%@ status:%hhd",devName,status);
            }
            [serialPanel.view setFrame:NSMakeRect(x, y, 500, 100)];
            [contentView addSubview:serialPanel.view];
            
            [self.loadDevicesDict setObject:serialPanel forKey:devName];
            
        }
        else if([type isEqualToString:@"NIVISA"]){
            NSString *address = [devCfg objectForKey:@"Address"];
            int baudrate = [[devCfg objectForKey:@"Baudrate"] intValue];
            int timeout = [[devCfg objectForKey:@"Timeout"] intValue];
            MyVisaPanel *visaPanel = [[MyVisaPanel alloc] initWithNibName:@"myVisaPanel" bundle:nil];
            visaPanel.device_index = dev_index;
            visaPanel.visa_identifier = devName;
            visaPanel.visa_description = description;
            visaPanel.visa_addr = address;
            visaPanel.visa_baud = baudrate;
            visaPanel.visa_timeout = timeout;
            visaPanel.delegate = self;
            
            [visaPanel initView];
            if (autoOpenFlag) {
                BOOL status = [visaPanel autoOpenInstrument];
                NSLog(@"[DPVC]-auto open:%@ status:%hhd",devName,status);
            }
            [visaPanel.view setFrame:NSMakeRect(x, y, 500, 100)];
            [contentView addSubview:visaPanel.view];
            
            [self.loadDevicesDict setObject:visaPanel forKey:devName];
        }
        else if([type isEqualToString:@"SOCKET"]){
            NSString *mode = [devCfg objectForKey:@"Mode"];
            NSString *ip = [devCfg objectForKey:@"IP"];
            int port = [[devCfg objectForKey:@"Port"] intValue];
            double timeout = [[devCfg objectForKey:@"Timeout"] intValue] / 1000;
            MySocketPanel *socketPanel = [[MySocketPanel alloc] initWithNibName:@"mySocketPanel" bundle:nil];
            socketPanel.device_index = dev_index;
            socketPanel.socket_identifier = devName;
            socketPanel.socket_description = description;
            socketPanel.socket_mode = mode;
            socketPanel.socket_ip = ip;
            socketPanel.socket_port = port;
            socketPanel.socket_timeout = timeout;
            socketPanel.delegate = self;
            
            [socketPanel initView];
            
            if (autoOpenFlag) {
                BOOL status = [socketPanel autoStartSocket];
                NSLog(@"[DPVC]-auto open:%@ status:%hhd",devName,status);
            }
            [socketPanel.view setFrame:NSMakeRect(x, y, 500, 100)];
            [contentView addSubview:socketPanel.view];
            
            [self.loadDevicesDict setObject:socketPanel forKey:devName];
        }
        y=y - 100;
    }
    [self.scrollView setDocumentView:contentView];
}
-(void)saveConfig:(NSDictionary *)config{
    int index = [[config objectForKey:@"Index"] intValue];

    NSMutableDictionary *theDeviceDict = [self.devicesList objectAtIndex:index];
    NSString *type = [config objectForKey:@"Type"];
    if ([type isEqualToString:@"SERIAL"]) {
        NSString *portName = [config objectForKey:@"PortName"];
        [theDeviceDict setValue:portName forKey:@"PortName"];
    }
    else if([type isEqualToString:@"NIVISA"]){
        NSString *address = [config objectForKey:@"Addr"];
        [theDeviceDict setValue:address forKey:@"Address"];
    }
    else if([type isEqualToString:@"SOCKET"]){
        NSString *ip = [config objectForKey:@"Ip"];
        NSNumber *port = [config objectForKey:@"Port"];
        NSString *mode = [config objectForKey:@"Mode"];
        [theDeviceDict setValue:ip forKey:@"IP"];
        [theDeviceDict setValue:port forKey:@"Port"];
        [theDeviceDict setValue:mode forKey:@"Mode"];
    }
    [self.devicesList replaceObjectAtIndex:index withObject:theDeviceDict];
    if ([self.panelIdentifier isEqualToString:@"unit"]) {
        NSMutableArray *group = [self.rootDict objectForKey:@"Group-1"];
        [group replaceObjectAtIndex:self.index withObject:self.devicesList];
        [self.rootDict setObject:group forKey:@"Group-1"];
    }else{
        [self.rootDict setObject:self.devicesList forKey:@"Devices"];
    }
    NSString *portFilePath=[[NSBundle mainBundle] resourcePath];
    portFilePath =[portFilePath stringByAppendingPathComponent:self.configFile];
    [self.rootDict writeToFile:portFilePath atomically:NO];
}
//serial
-(void)receivedFromSerialPanel:(NSString *)data identifier:(NSString *)identifier{
    [self.delegate receivedFromDevicePanel:data identifier:identifier];
}
-(void)eventFromSerialPanel:(NSDictionary *)event identifier:(NSString *)identifier{
    [self.delegate eventFromDevicePanel:event identifier:identifier];
    NSString *eventName = [event objectForKey:@"event"];
    if ([eventName isEqualToString:@"config"]) {
        [self saveConfig:[event objectForKey:@"content"]];
    }
}
//visa
-(void)eventFromVisaPanel:(NSDictionary *)event identifier:(NSString *)identifier{
    [self.delegate eventFromDevicePanel:event identifier:identifier];
    NSString *eventName = [event objectForKey:@"event"];
    if ([eventName isEqualToString:@"config"]) {
        [self saveConfig:[event objectForKey:@"content"]];
    }
}
//socket
-(void)receivedFromSocketPanel:(NSString *)data identifier:(NSString *)identifier{
    [self.delegate receivedFromDevicePanel:data identifier:identifier];
}
-(void)eventFromSocketPanel:(NSDictionary *)event identifier:(NSString *)identifier{
    [self.delegate eventFromDevicePanel:event identifier:identifier];
    NSString *eventName = [event objectForKey:@"event"];
    if ([eventName isEqualToString:@"config"]) {
        [self saveConfig:[event objectForKey:@"content"]];
    }
}
@end
