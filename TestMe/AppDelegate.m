//
//  AppDelegate.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "AppDelegate.h"
#import "HSLogger.h"
#import "AboutWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property ContainerViewController *containerVC;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //[HSLogger initWithFile:YES zmq:nil level:LOG_LEVEL_INFO];
    NSLog(@"launch...");
    [infoLabel setHidden:YES];
    // 设置标题隐藏
    self.window.titleVisibility = NSWindowTitleHidden;
    // 设置标题栏透明
    self.window.titlebarAppearsTransparent = YES;
    // 设置contentview与titlebar融合到一起（此时设置背景颜色也将影响titlebar的颜色）
    self.window.styleMask = self.window.styleMask | NSWindowStyleMaskFullSizeContentView;
    //[self.window setOpaque:NO];
    //[self.window setBackgroundColor:[NSColor colorWithCalibratedRed:0.5f green:0.8f blue:0.9f alpha:0.9]];  //背景色
    //[self.window setBackgroundColor:[NSColor windowBackgroundColor]];
    //[[self.window standardWindowButton:NSWindowZoomButton] setEnabled:NO];
    //[[self.window standardWindowButton:NSWindowMiniaturizeButton] setEnabled:NO];
    //self.window.alphaValue = 0.98;
    //毛玻璃效果
    NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.window.contentView.bounds];
    visualEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    visualEffectView.material = 0x0;
    visualEffectView.blendingMode = 0x0;
    //visualEffectView.state = NSVisualEffectStateActive;
    [self.window.contentView addSubview:visualEffectView];
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    NSString *filePath=[rawfilePath stringByAppendingPathComponent:@"Station.plist"];
    NSDictionary *rootDict=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSDictionary *stationConfig =[rootDict objectForKey:@"Config"];
    BOOL loginFlag = [[stationConfig objectForKey:@"LoginFlag"] boolValue];
    self.containerVC = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
    self.containerVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.containerVC.loginFlag = loginFlag;
    NSLog(@"login flag:%hhd",loginFlag);

    [self.window.contentView addSubview:self.containerVC.view];
    NSLog(@"launch done");
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)aboutMenuBtnAction:(id)sender{
    NSLog(@"click about menu...");
    AboutWindowController *aboutWindow = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    [[NSApplication sharedApplication] runModalForWindow:aboutWindow.window];
}

- (BOOL)windowShouldClose:(NSWindow *)sender{
    NSLog(@"window should close...");
    //[NSApp terminate:self];
    [self.containerVC switchToExitView];
    return NO;
}

@end
