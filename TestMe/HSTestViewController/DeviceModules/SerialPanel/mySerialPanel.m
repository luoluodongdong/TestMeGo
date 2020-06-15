//
//  mySerialPanel.m
//  SoftwareApp
//
//  Created by 曹伟东 on 2019/4/15.
//  Copyright © 2019 曹伟东. All rights reserved.
//

#import "mySerialPanel.h"
typedef NS_ENUM(NSInteger, ORSSerialRequestType) {
    ORSSerialRequestTypeMatchStr = 1,
    ORSSerialRequestTypeEndStr,
    ORSSerialRequestTypeReceivedStr,
    ORSSerialRequestTypeOther,
};

@interface MySerialPanel ()
{
    NSArray *_comArr;
    NSString *_receivedStr;
    //serial port request/response
    BOOL _SP_RESPONSE_END;
    BOOL _RESPONSE_TIMEOUT;
    BOOL _IS_SHOW;
}
@end

@implementation MySerialPanel
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"serial pannel did load...");
    [_descriptionLB setStringValue:self.serial_description];
    _openBtn.toolTip=@"open or close port";
    _scanBtn.toolTip = @"find all ports";
    
}

-(void)viewDidAppear{
    NSLog(@"serial pannel did appear...");
    _IS_SHOW=YES;
    [self refreshSerialPorts];
    if (self.serialPort.isOpen) {
        NSString *portName=self.serialPort.name;
        [_portBtn selectItemWithTitle:portName];
        _openBtn.title = @"Close";
        [_portBtn setEnabled:NO];
        [_scanBtn setEnabled:NO];

    }
}

-(void)viewWillDisappear{
    _IS_SHOW=NO;
}

-(void)initView{
    //[super viewDidLoad];
    self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
    _receivedStr=@"";
    _SP_RESPONSE_END=NO;
    _RESPONSE_TIMEOUT=NO;
    _IS_SHOW=NO;

}
-(BOOL)openSerial{
    if (self.serialPort.isOpen) {
        return YES;
    }
    return [self autoOpenSerial];
}
-(void)closeDevice{
    if (self.serialPort.isOpen) {
        [self.serialPort close];
    }
    NSLog(@"serial close device");
}
-(IBAction)openBtnAction:(id)sender{
    if (self.serialPort.isOpen) {
        [self.serialPort close];
    }else{
        NSInteger index=[_portBtn indexOfSelectedItem];
        self.serialPort=[_comArr objectAtIndex:index];
        self.serialPort.baudRate = [NSNumber numberWithInt:self.serial_baud];
        self.serialPort.RTS = self.RTS;
        self.serialPort.DTR = self.DTR;
        self.serialPort.usesDTRDSRFlowControl = self.usesDTRDSRFlowControl;
        self.serialPort.usesRTSCTSFlowControl = self.usesRTSCTSFlowControl;
        self.serialPort.usesDCDOutputFlowControl = self.usesDCDOutputFlowControl;
        [self.serialPort open];
        if (self.serialPort.isOpen) {
            [self saveConfig];
        }else{
            //[self showPanel:@"Serial open error!"];
            NSDictionary *cfgDict=@{@"Type":@"SERIAL",
                                    @"Status":@(0),
                                    @"identifier":self.serial_identifier,
                                    @"index":@(self.device_index),
                                    @"Description":@"open failure!",
            };
            [self.delegate eventFromSerialPanel:@{@"event":@"error",@"content":cfgDict} identifier:self.serial_identifier];
        }
        
    }
    
}
-(BOOL)autoOpenSerial{
    [self refreshSerialPorts];
    NSInteger index=0;
    BOOL find_serial = NO;
    for (int i=0; i<[_comArr count]; i++) {
        ORSSerialPort *serial=[_comArr objectAtIndex:index];
        if ([serial.name isEqualToString:self.serial_name]) {
            find_serial = YES;
            break;
        }
        index +=1;
    }
    if(!find_serial) return NO;
    self.serialPort=[_comArr objectAtIndex:index];
    self.serialPort.baudRate=[NSNumber numberWithInt:self.serial_baud];
    self.serialPort.RTS = self.RTS;
    self.serialPort.DTR = self.DTR;
    self.serialPort.usesDTRDSRFlowControl = self.usesDTRDSRFlowControl;
    self.serialPort.usesRTSCTSFlowControl = self.usesRTSCTSFlowControl;
    self.serialPort.usesDCDOutputFlowControl = self.usesDCDOutputFlowControl;
    [self.serialPort open];
    [NSThread sleepForTimeInterval:0.5];
    if (self.serialPort.isOpen) {
        return YES;
    }else{
        return NO;
    }
}
-(IBAction)scanBtnAction:(id)sender{
    [self refreshSerialPorts];
}
-(void)dealloc{
    if (self.serialPort.isOpen) {
        [self.serialPort close];
    }
}
-(void)saveConfig{
    self.serial_name=[_portBtn titleOfSelectedItem];
    //NSString *idStr=[NSString stringWithFormat:@"%d",self.serial_identifier];
    NSDictionary *cfgDict=@{@"Type":@"SERIAL",
                            @"Status":@(1),
                            @"PortName":self.serial_name,
                            @"Identifier":self.serial_identifier,
                            @"Index":@(self.device_index),
                            @"Description":@"save configure successful!",
    };
    [self.delegate eventFromSerialPanel:@{@"event":@"config",@"content":cfgDict} identifier:self.serial_identifier];
    //[self showPanel:@"Save params OK!"];
}
-(void)refreshSerialPorts{
    [_portBtn removeAllItems];
    
    _comArr = self.serialPortManager.availablePorts;
    NSLog(@"_comArr:%@",_comArr);
    
    [_comArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ORSSerialPort *port = (ORSSerialPort *)obj;
        //printf("%lu. %s\n", (unsigned long)idx, [port.name UTF8String]);
        //[self->comPaths addItemWithObjectValue:port.name];
        [self->_portBtn addItemWithTitle:port.name];
        
    }];
    if ([_comArr count]>0) {
        [_portBtn selectItemAtIndex:0];
    }
    NSLog(@"refresh srialport ok");
}
-(BOOL)sendCommand:(NSString *)cmd{
    if(!self.serialPort.isOpen) return NO;
    _receivedStr=@"";
    NSData *command = [cmd dataUsingEncoding:NSASCIIStringEncoding];
    return [self.serialPort sendData:command];
}
-(BOOL)sendCmd:(NSString *)cmd received:(NSString **)data withTimeOut:(double )to{
    if(!self.serialPort.isOpen) return NO;
    _SP_RESPONSE_END=NO;
    _RESPONSE_TIMEOUT=NO;
    _receivedStr=@"";
    [self sendCmdAndReceivedStr:cmd TimeOut:to];
    //waiting for serial port response
    while(!_SP_RESPONSE_END){
        [NSThread sleepForTimeInterval:0.02f];
        
    }
    [NSThread sleepForTimeInterval:0.05f];
    
    *data=_receivedStr;
    return !_RESPONSE_TIMEOUT;
}
#pragma mark - ORSSerialPort request/response Mode
- (void)sendCmdWithTimeOut:(NSString *)cmd TimeOut:(double )kTimeoutDuration MatchStr:(NSString *)checkStr
{
    
    NSData *command = [cmd dataUsingEncoding:NSASCIIStringEncoding];
    ORSSerialPacketDescriptor *responseDescriptor =
    [[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:1024
                                                          userInfo:nil
                                                 responseEvaluator:^BOOL(NSData *inputData) {
                                                     return [self matchString:checkStr withData:inputData] != nil;
                                                 }];
    ORSSerialRequest *request = [ORSSerialRequest requestWithDataToSend:command
                                                               userInfo:@(ORSSerialRequestTypeMatchStr)
                                                        timeoutInterval:kTimeoutDuration
                                                     responseDescriptor:responseDescriptor];
    [self.serialPort sendRequest:request];
}
- (void)sendCmdWithTimeOut:(NSString *)cmd TimeOut:(double )kTimeoutDuration endStr:(NSString *)endStr
{
    NSData *command = [cmd dataUsingEncoding:NSASCIIStringEncoding];
    ORSSerialPacketDescriptor *responseDescriptor =
    [[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:1024
                                                          userInfo:nil
                                                 responseEvaluator:^BOOL(NSData *inputData) {
                                                     return [self endString:endStr withData:inputData] !=nil;
                                                 }];
    ORSSerialRequest *request = [ORSSerialRequest requestWithDataToSend:command
                                                               userInfo:@(ORSSerialRequestTypeEndStr)
                                                        timeoutInterval:kTimeoutDuration
                                                     responseDescriptor:responseDescriptor];
    [self.serialPort sendRequest:request];
}
- (void)sendCmdAndReceivedStr:(NSString *)cmd TimeOut:(double )kTimeoutDuration
{
    NSData *command = [cmd dataUsingEncoding:NSASCIIStringEncoding];
    ORSSerialPacketDescriptor *responseDescriptor =
    [[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:1024
                                                          userInfo:nil
                                                 responseEvaluator:^BOOL(NSData *inputData) {
                                                     return [self receivedStringWithData:inputData] !=nil;
                                                 }];
    ORSSerialRequest *request = [ORSSerialRequest requestWithDataToSend:command
                                                               userInfo:@(ORSSerialRequestTypeReceivedStr)
                                                        timeoutInterval:kTimeoutDuration
                                                     responseDescriptor:responseDescriptor];
    [self.serialPort sendRequest:request];
}


- (void)serialPort:(ORSSerialPort *)serialPort didReceiveResponse:(NSData *)responseData toRequest:(ORSSerialRequest *)request
{
    ORSSerialRequestType requestType = [request.userInfo integerValue];
    switch (requestType) {
        case ORSSerialRequestTypeMatchStr: //1
            //[[self temperatureFromResponsePacket:responseData] integerValue];
            //[self myPrintf:@"matchStr OK"];
            _SP_RESPONSE_END=YES;
            break;
        case ORSSerialRequestTypeReceivedStr:
            
            _SP_RESPONSE_END=YES;
            
            break;
        case ORSSerialRequestTypeEndStr: //3
            // Don't call the setter to avoid continuing to send set commands indefinitely
            //[self willChangeValueForKey:@"LEDOn"];
            //_LEDOn = [[self LEDStateFromResponsePacket:responseData] boolValue];
            //[self didChangeValueForKey:@"LEDOn"];
            //[self myPrintf:@"endStr OK"];
            _SP_RESPONSE_END=YES;
            break;
        case ORSSerialRequestTypeOther: //2
        default:
            break;
    }
}
- (void)serialPort:(ORSSerialPort *)port requestDidTimeout:(ORSSerialRequest *)request
{
    //NSLog(@"command timed out!");
    
    _RESPONSE_TIMEOUT=YES;
    //[self myPrintf:@"Command timed out!"];
    _SP_RESPONSE_END=YES;
}
#pragma mark Parsing Responses

-(NSNumber *)matchString:(NSString *)checkStr withData:(NSData *)data{
    if (![data length]) return nil;
    NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if(![dataAsString containsString:checkStr]) return nil;
    //NSString *msg=[NSString stringWithFormat:@"MatchStr:responseData:%@ len:%ld",dataAsString,[dataAsString length]];
    //[self myPrintf:msg];
    return @([dataAsString integerValue]);
}
-(NSNumber *)endString:(NSString *)endStr withData:(NSData *)data{
    if (![data length]) return nil;
    NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if(![dataAsString hasSuffix:endStr]) return nil;
    //NSString *msg=[NSString stringWithFormat:@"EndStr:responseData:%@ len:%ld",dataAsString,[dataAsString length]];
    //[self myPrintf:msg];
    return @([dataAsString integerValue]);
}
-(NSString *)receivedStringWithData:(NSData *)data{
    if (![data length]) return nil;
    NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if(![dataAsString containsString:@"\n"]) return nil;
    //NSString *msg=[NSString stringWithFormat:@"RecStr:responseData:%@ len:%ld",dataAsString,[dataAsString length]];
    //[self myPrintf:msg];
    return dataAsString;
}
#pragma mark - ORSSerialPortDelegate Methods

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    _openBtn.title = @"Close";
    [_portBtn setEnabled:NO];
    [_scanBtn setEnabled:NO];
    NSLog(@"serial is opened");
    //save com path/baudrate
    //NSString *data=[NSString stringWithFormat:@"SaveCOM:%d:%@",self._id,self.serialPort.name];
    //[self.delegate send2TTdata:data];
    //[self.delegate eventFromSerialPanel:@{@"event":@"opened"}];
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    self.serialPort=nil;
    _openBtn.title = @"Open";
    [_portBtn setEnabled:YES];
    [_scanBtn setEnabled:YES];
    //[self.delegate eventFromSerialPanel:@{@"event":@"closed",@"content":@{}} identifier:self.serial_identifier];
    NSLog(@"serial is closed");
    
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    if ([data length] == 0) return;
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(string == nil) return;
    _receivedStr=[_receivedStr stringByAppendingString:string];
    if ([_receivedStr hasSuffix:@"\r\n"]) {
        [self.delegate receivedFromSerialPanel:_receivedStr identifier:self.serial_identifier];
        NSString *msg=[NSString stringWithFormat:@"[RX]%@",_receivedStr];
        //[self myPrintf:msg];
        //_SP_RESPONSE_END=YES;
        NSLog(@"%@",msg);
        
    }
    
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
    // After a serial port is removed from the system, it is invalid and we must discard any references to it
    //self.serialPort = nil;
    //self.openCloseButton.title = @"Open";
    NSLog(@"serialport removed:%@",serialPort.name);
    if ([serialPort.name isEqualToString:self.serialPort.name]) {
        NSDictionary *cfgDict=@{@"Type":@"SERIAL",
                                @"Status":@(0),
                                @"PortName":self.serial_name,
                                @"Identifier":self.serial_identifier,
                                @"Index":@(self.device_index),
                                @"Description":@"removed from system!",
        };
        [self.delegate eventFromSerialPanel:@{@"event":@"error",@"content":cfgDict} identifier:self.serial_identifier];
        self.serialPort = nil;
        _openBtn.title = @"Open";
        [_portBtn setEnabled:YES];
        [_scanBtn setEnabled:YES];
    }
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
    NSString *msg=[NSString stringWithFormat:@"Serial port %@ encountered an error: %@", serialPort, error];
    NSLog(@"%@",msg);
    //[self myPrintf:msg];
    if ([serialPort.name isEqualToString:self.serialPort.name]) {
        NSDictionary *cfgDict=@{@"Type":@"SERIAL",
                                @"Status":@(0),
                                @"PortName":self.serial_name,
                                @"Identifier":self.serial_identifier,
                                @"Index":@(self.device_index),
                                @"Description":[error localizedDescription],
        };
        [self.delegate eventFromSerialPanel:@{@"event":@"error",@"content":cfgDict} identifier:self.serial_identifier];
    }
}

#pragma mark - Properties
- (void)setSerialPort:(ORSSerialPort *)port
{
    if (port != _serialPort)
    {
        //[self myPrintf:@"Do serialPort delegate..."];
        NSLog(@"Do serialPort delegate...");
        [_serialPort close];
        _serialPort.delegate = nil;
        _serialPort = port;
        _serialPort.delegate = self;
    }
}
//show information display
-(long)showPanel:(NSString *)thisEnquire{
    NSLog(@"start run showpanel window");
    NSAlert *theAlert=[[NSAlert alloc] init];
    [theAlert addButtonWithTitle:@"OK"]; //1000
    [theAlert setMessageText:@"Info"];
    [theAlert setInformativeText:thisEnquire];
    [theAlert setAlertStyle:0];
    //[theAlert setIcon:[NSImage imageNamed:@"Error_256px_5.png"]];
    NSLog(@"End run showpanel window");
    return [theAlert runModal];
}


- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}

- (void)receivedFromSerialPanel:(NSString *)data identifier:(NSString *)identifier {
    
}

- (void)eventFromSerialPanel:(NSDictionary *)event identifier:(NSString *)identifier{
    
}


- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    return YES;
}

@end
