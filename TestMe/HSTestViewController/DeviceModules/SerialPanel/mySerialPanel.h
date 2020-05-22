//
//  mySerialPanel.h
//  SoftwareApp
//
//  Created by 曹伟东 on 2019/4/15.
//  Copyright © 2019 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"
#import "ORSSerialRequest.h"
#import "ORSSerialBuffer.h"

@protocol SerialPanelDelegate<NSObject>
-(void)receivedFromSerialPanel:(NSString *)data identifier:(NSString *)identifier;
-(void)eventFromSerialPanel:(NSDictionary *)event identifier:(NSString *)identifier;
@end

@class ORSSerialPortManager;

@interface MySerialPanel: NSViewController<ORSSerialPortDelegate,SerialPanelDelegate>
{
    IBOutlet NSPopUpButton *_portBtn;
    IBOutlet NSButton *_openBtn;
    IBOutlet NSButton *_scanBtn;
    IBOutlet NSTextField *_descriptionLB;

}

@property (nonatomic,weak) id<SerialPanelDelegate> delegate;
@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;

@property (nonatomic, assign) int device_index;
@property (nonatomic, strong) NSString *serial_identifier;
@property (nonatomic, strong) NSString *serial_description;
@property (nonatomic, strong) NSString *serial_name;
@property (nonatomic, assign) int serial_baud;
@property (nonatomic, assign) BOOL RTS;
@property (nonatomic, assign) BOOL DTR;
@property (nonatomic, assign) BOOL usesDTRDSRFlowControl;
@property (nonatomic, assign) BOOL usesRTSCTSFlowControl;
@property (nonatomic, assign) BOOL usesDCDOutputFlowControl;

-(void)initView;
-(BOOL)autoOpenSerial;
-(BOOL)openSerial;
-(void)closeSerial;
-(BOOL)sendCommand:(NSString *)cmd;
-(BOOL)sendCmd:(NSString *)cmd received:(NSString **)data withTimeOut:(double )to;

-(IBAction)openBtnAction:(id)sender;
-(IBAction)scanBtnAction:(id)sender;

@end
