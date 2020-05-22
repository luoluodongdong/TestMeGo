//
//  mySerialPanel.m
//  SoftwareApp
//
//  Created by 曹伟东 on 2019/4/15.
//  Copyright © 2019 曹伟东. All rights reserved.
//

#import "myVisaPanel.h"
#import "NIVISAHelp.h"
@interface MyVisaPanel ()
{
    NSArray *_addrArr;
    NSString *_receivedStr;
    int _instrFD;
    //port request/response

    BOOL _IS_SHOW;
    BOOL _IS_OPENED;
}
@end

@implementation MyVisaPanel
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VISA pannel did load...");
    [_descriptionLB setStringValue:self.visa_description];
   
    
}

-(void)viewDidAppear{
    NSLog(@"VISA pannel did appear...");
    _IS_SHOW=YES;
    [self refreshPorts];
    if (_IS_OPENED) {
        [_portBtn selectItemWithTitle:self.visa_addr];
        _openBtn.title = @"Close";
        [_portBtn setEnabled:NO];
        [_scanBtn setEnabled:NO];

    }
}

-(void)viewWillDisappear{
    _IS_SHOW=NO;
}

-(void)initView{
    openVISArm();
    _receivedStr=@"";
    _IS_OPENED=NO;
    _instrFD = -1;
    _IS_SHOW=NO;
}

-(IBAction)openBtnAction:(id)sender{
    if ([[_openBtn title] isEqualToString:@"Open"]) {
        NSString *address=[_portBtn titleOfSelectedItem];
        _instrFD=openDevice(address, self.visa_baud, self.visa_timeout);
        if (_instrFD != -1) {
            //open successful
            _IS_OPENED=YES;
            _openBtn.title = @"Close";
            [_portBtn setEnabled:NO];
            [_scanBtn setEnabled:NO];
            NSDictionary *cfgDict=@{@"Type":@"NIVISA",
                                    @"Status":@(1),
                                    @"Addr":address,
                                    @"Identifier":self.visa_identifier,
                                    @"Index":@(self.device_index),
                                    @"Description":@"save configure",
            };
            [self.delegate eventFromVisaPanel:@{@"event":@"config",@"content":cfgDict} identifier:self.visa_identifier];
            self.visa_addr = address;
            //[self showPanel:@"Save instrument OK!"];
        }
    }else{
        int closeR=closeDevice(_instrFD);
        if (closeR<0) {
            //close fail
            //[self showPanel:@"Close instrument error!"];
        }else{
            //close successful
            _IS_OPENED=NO;
            _openBtn.title = @"Open";
            [_portBtn setEnabled:YES];
            [_scanBtn setEnabled:YES];
        }
        //NSDictionary *cfgDict=@{@"Type":@"NIVISA",@"Status":@(0),@"identifier":self.visa_identifier};
        //[self.delegate eventFromVisaPanel:@{@"event":@"closed",@"content":cfgDict} identifier:self.visa_identifier];
    }
    
}
-(BOOL)autoOpenInstrument{
    [self refreshPorts];
    BOOL _find_addr=NO;
    for (int i=0; i<[_addrArr count]; i++) {
        NSString *item=[_addrArr objectAtIndex:i];
        if ([item isEqualToString:self.visa_addr]) {
            _find_addr = YES;
            break;
        }
    }
    if(!_find_addr) return NO;
    _instrFD=openDevice(self.visa_addr, self.visa_baud, self.visa_timeout);
    if (_instrFD != -1) {
        //open successful
        _IS_OPENED=YES;
        _openBtn.title = @"Close";
        [_portBtn setEnabled:NO];
        [_scanBtn setEnabled:NO];
    }else{
        //open fail
        return NO;
    }

    return YES;
}
-(IBAction)scanBtnAction:(id)sender{
    [self refreshPorts];
}

-(void)refreshPorts{
    [_portBtn removeAllItems];
    _addrArr=findAllDevices();
    NSLog(@"_addArr:%@",_addrArr);
    [_portBtn addItemsWithTitles:_addrArr];
    
    if ([_addrArr count]>0) {
        [_portBtn selectItemAtIndex:0];
    }
    NSLog(@"refresh ports ok");
}

-(BOOL)sendCommand:(NSString *)cmd{
    int status = writeDevice(_instrFD, cmd);
    NSLog(@"[MyVisaPanel]send cmd status:%d",status);
    if (status != 0) {
        return NO;
    }
    return YES;
}
-(BOOL)sendCmd:(NSString *)cmd received:(NSString **)data withTimeOut:(double )to{
    int status = writeDevice(_instrFD, cmd);
    NSLog(@"[MyVisaPanel]send cmd status:%d",status);
    *data = @"";
    if (status != 0) {
        return NO;
    }
    *data = readDevice(_instrFD);
    return YES;
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



- (void)eventFromVisaPanel:(NSDictionary *)event identifier:(NSString *)identifier {
    
}

- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
}

@end
