//
//  mySocketPanel.h
//  LibTest
//
//  Created by Weidong Cao on 2019/6/21.
//  Copyright © 2019 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"

@protocol SocketPanelDelegate<NSObject>

-(void)receivedFromSocketPanel:(NSString *)data identifier:(NSString *)identifier;
-(void)eventFromSocketPanel:(NSDictionary *)event identifier:(NSString *)identifier;

@end

@interface MySocketPanel : NSViewController<GCDAsyncSocketDelegate,SocketPanelDelegate>
{
    IBOutlet NSTextField *descriptionTF;
    IBOutlet NSPopUpButton *modeBtn;
    IBOutlet NSTextField *ipTF;
    IBOutlet NSTextField *portTF;
    IBOutlet NSButton *startBtn;
}

@property (nonatomic,weak) id<SocketPanelDelegate> delegate;

@property (nonatomic, assign) int device_index;
@property (nonatomic, strong) NSString *socket_identifier;
@property (nonatomic, strong) NSString *socket_description;
@property (nonatomic, strong) NSString *socket_mode;
@property (nonatomic, strong) NSString *socket_ip;
@property (nonatomic, assign) int socket_port;
@property (nonatomic, assign) double socket_timeout;

/*!
 *Client & Server mode public func
 */
//init socket pannel
-(void)initView;
-(BOOL)autoStartSocket;
-(BOOL)startSocket;
-(void)stopSocket;
-(BOOL)sendCommand:(NSString *)msg;

/*!
 *just for server mode
 */
//get connected clients
-(NSArray *)getClientList;

/*!
 *just for client mode
 */
//*client mode* send a query to server
//!this func don't in main thread!
-(NSString *)query:(NSString *)request;

-(IBAction)modeBtnAction:(id)sender;
-(IBAction)startBtnAction:(id)sender;

@end

