//
//  MyViewItem.m
//  CNGridView Example
//
//  Created by WeidongCao on 2020/4/13.
//  Copyright © 2020 cocoa:naut. All rights reserved.
//

#import "UnitViewItem.h"
#import "HSTestCoreManager.h"
#import "HSLogger.h"

@interface UnitViewItem ()

@property (retain, nonatomic) NSDateComponentsFormatter *timeFormatter;
@property (retain, nonatomic) NSTimer *__nullable timer;
@property (retain, nonatomic) HSTestCoreManager *testCoreManager;
@end

@implementation UnitViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [settingBtn setHidden:YES];
    box.currentFillColor = [NSColor whiteColor];
    [titleLabel setStringValue:self.unit.identifier];
    [snLabel setStringValue:self.unit.serialnumber];
    [stateLabel setStringValue:@"idle"];
    [testStatusLabel setStringValue:@""];
    [msgLabel setStringValue:@""];
    self.timeFormatter = [[NSDateComponentsFormatter alloc] init];
    [self.timeFormatter setAllowedUnits:0xf0];
    [self.timeFormatter setAllowsFractionalUnits:YES];
    [self.timeFormatter setZeroFormattingBehavior:0xe];
    [self.timeFormatter setUnitsStyle:0x1];
    [timerLabel setStringValue:@""];
    [self.unit addObserver:self forKeyPath:@"state" options:0x01 context:0x0];
    [self.unit addObserver:self forKeyPath:@"serialnumber" options:0x01 context:0x0];
    self.testCoreManager = [HSTestCoreManager sharedInstance];
    [self.testCoreManager addObserver:self forKeyPath:@"operateMode" options:0x0 context:0x0];
    [self.testCoreManager addObserver:self forKeyPath:@"numberOfUnitsTesting" options:0x0 context:0x0];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    HSUnit *unit=object;
    if ([keyPath isEqualToString:@"state"]) {
        [self printLog:[NSString stringWithFormat:@"KOV - %@ : %d",keyPath,unit.state]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (unit.state == HSUnitTesting) {
                [self changeToTestState:HSUnitTesting];
                [self->settingBtn setEnabled:NO];
            }else if(unit.state == HSUnitFinished){
                [self changeToTestState:HSUnitFinished];
                [self->settingBtn setEnabled:YES];
            }
        });
    }
    else if([keyPath isEqualToString:@"serialnumber"]){
        NSString *sn = unit.serialnumber;
        [self printLog:[NSString stringWithFormat:@"KOV - %@ : %@",keyPath,sn]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->snLabel setStringValue:sn];
        });
    }
    else if([keyPath isEqualToString:@"operateMode"]){
        [self printLog:[NSString stringWithFormat:@"KOV - %@ : %@",keyPath,self.testCoreManager.operateMode]];
        if ([self.testCoreManager.operateMode isEqualToString:@"Engineer"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->settingBtn setHidden:NO];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->settingBtn setHidden:YES];
            });
        }
    }
    else if([keyPath isEqualToString:@"numberOfUnitsTesting"]){
        [self printLog:[NSString stringWithFormat:@"KOV - %@ : %lu",keyPath,self.testCoreManager.numberOfUnitsTesting]];
        if (self.testCoreManager.numberOfUnitsTesting == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->selectBtn setEnabled:YES];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->selectBtn setEnabled:NO];
            });
        }
    }
}
-(void)mouseDown:(NSEvent *)event{
    [super mouseDown:event];
    [self mouseClick:event];
}
- (void)mouseClick:(id)arg1{
    NSLog(@"[UCVI]-mouseClick Unit!");
    [self.delegate clickOnUnit:self.index];
    
}
-(void)dealloc{
    [self.unit removeObserver:self forKeyPath:@"state"];
    [self.unit removeObserver:self forKeyPath:@"serialnumber"];
    [self.testCoreManager removeObserver:self forKeyPath:@"operateMode"];
    [self.testCoreManager removeObserver:self forKeyPath:@"numberOfUnitsTesting"];
}
-(void)viewWillAppear{
    [self printLog:@"view will appear "];
    
}

-(void)viewWillDisappear{
    [self printLog:@"view will disappear"];
    
}
-(IBAction)settingBtnAction:(id)sender{
    NSLog(@"[UCVI]-mouseClick Setting Btn!");
    [self.delegate clickOnSettingBtn:self.index];
}
-(IBAction)selectBtnAction:(id)sender{
    BOOL state = [selectBtn state];
    [self printLog:[NSString stringWithFormat:@"unit select index:%d state:%hhd",self.index,state]];
    [self.delegate clickOnSelectBtn:self.index state:state];
    if (state == YES) {
        [self changeToTestState:HSUnitIdle];
    }else{
        [self changeToTestState:HSUnitDisable];
    }
}

//state: Disable = -2, Idle = -1, Appeared = 0, Testing = 1, Finished = 2,
-(void)changeToTestState:(HSUnitState )state{
    if (state == HSUnitDisable) {
        box.currentFillColor = [NSColor grayColor];
        [box setFillColor:[NSColor grayColor]];
        [stateLabel setStringValue:@"Disable"];
        [snLabel setStringValue:@""];
        [testStatusLabel setStringValue:@""];
        [msgLabel setStringValue:@""];
        [timerLabel setStringValue:@""];
    }
    else if(state == HSUnitIdle){
        box.currentFillColor = [NSColor whiteColor];
        [box setFillColor:[NSColor whiteColor]];
        [stateLabel setStringValue:@"idle"];
        [snLabel setStringValue:@""];
        [testStatusLabel setStringValue:@""];
        [msgLabel setStringValue:@""];
    }
    else if(state == HSUnitAppeared){
        
    }
    else if(state == HSUnitTesting){
        box.currentFillColor = [NSColor yellowColor];
        [box setFillColor:[NSColor yellowColor]];
        [stateLabel setStringValue:@"Testing"];
        //[snLabel setStringValue:@""];
        [testStatusLabel setStringValue:@""];
        [msgLabel setStringValue:@""];
        //[selectBtn setEnabled:NO];
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self timeTick];
    }
    else if(state == HSUnitFinished){
        [self.timer invalidate];
        [self setTimer:nil];
        if (self.unit.testStatus == HSTestStatusPass) {
            box.currentFillColor = [NSColor greenColor];
            [box setFillColor:[NSColor greenColor]];
            [stateLabel setStringValue:@"Test finished"];
            //[snLabel setStringValue:@""];
            [testStatusLabel setStringValue:@"PASS"];
            [msgLabel setStringValue:self.unit.errorMessage];
        }
        else if(self.unit.testStatus == HSTestStatusFail){
            box.currentFillColor = [NSColor systemRedColor];
            [box setFillColor:[NSColor systemRedColor]];
            [stateLabel setStringValue:@"Test finished"];
            //[snLabel setStringValue:@""];
            [testStatusLabel setStringValue:@"FAIL"];
            [msgLabel setStringValue:self.unit.errorMessage];
        }
        else{
            box.currentFillColor = [NSColor redColor];
            [box setFillColor:[NSColor redColor]];
            [stateLabel setStringValue:@"Test finished"];
            //[snLabel setStringValue:@""];
            [testStatusLabel setStringValue:@"ERROR"];
            [msgLabel setStringValue:self.unit.errorMessage];
        }
        //[selectBtn setEnabled:YES];
        
    }
}
-(void)timeTick{
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.unit.start];
    NSString *timeStr = [self.timeFormatter stringFromTimeInterval:interval];
    [timerLabel setStringValue:timeStr];
}
-(void)printLog:(NSString *)log{
    HSLogInfo(@"[UVI] > -%d- %@",self.index,log);
    //NSLog(@"[UVI] > -%d- %@",self.index,log);
}

@end
