//
//  mySerialPanel.h
//  SoftwareApp
//
//  Created by 曹伟东 on 2019/4/15.
//  Copyright © 2019 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol VisaPanelDelegate<NSObject>
-(void)eventFromVisaPanel:(NSDictionary *)event identifier:(NSString *)identifier;
@end


@interface MyVisaPanel: NSViewController<VisaPanelDelegate>
{
    IBOutlet NSPopUpButton *_portBtn;
    IBOutlet NSButton *_openBtn;
    IBOutlet NSButton *_scanBtn;
    IBOutlet NSTextField *_descriptionLB;
}

@property (nonatomic,weak) id<VisaPanelDelegate> delegate;

@property (nonatomic, assign) int device_index;
@property (nonatomic, strong) NSString *visa_identifier;
@property (nonatomic, strong) NSString *visa_description;
@property (nonatomic, strong) NSString *visa_name;
@property (nonatomic, strong) NSString *visa_addr;
@property (nonatomic, assign) int visa_baud;
@property (nonatomic, assign) int visa_timeout;

-(void)initView;
-(BOOL)autoOpenInstrument;
-(void)closeDevice;
-(BOOL)sendCommand:(NSString *)cmd;
-(BOOL)sendCmd:(NSString *)cmd received:(NSString **)data withTimeOut:(double )to;

-(IBAction)openBtnAction:(id)sender;
-(IBAction)scanBtnAction:(id)sender;

@end
