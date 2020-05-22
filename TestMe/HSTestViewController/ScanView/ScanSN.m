//
//  ScanSN.m
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/22.
//  Copyright © 2018年 曹伟东. All rights reserved.
//
#import "ScanSN.h"
#import "HSLogger.h"

@interface ScanSN ()
@property (nonatomic,strong) NSMutableArray *_snArr;
@property (nonatomic,strong) NSMutableString *showSNs;
@property (nonatomic,assign) int snCount;
@property (nonatomic,assign) BOOL ENTER_ESC;
@property (nonatomic, strong) HSCheckSN *checkSN;
@end

@implementation ScanSN

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
-(void)viewWillAppear{
    [_inputSN_TF setStringValue:@""];
    [_errMsgLabel setStringValue:@""];
    _ENTER_ESC=NO;
    [self printLog:self._firstSN];
    _showSNs=[[NSMutableString alloc]initWithCapacity:1024];
    self._snArr =[[NSMutableArray alloc]initWithCapacity:1];
    _snCount=0;
    for (NSString *item in self._select_Slot_BoolArr) {
        _snCount+=1;
        [self printLog:item];
        if([item  isEqual: @"YES"]){
            [self._snArr addObject:self._firstSN];
            NSString *tempStr=[NSString stringWithFormat:@"%d.%@",_snCount,self._firstSN];
            [_showSNs appendString:tempStr];
            [_showSNs appendString:@"\r\n"];
            break;
        }
        [self._snArr addObject:@""];
        NSString *tempStr=[NSString stringWithFormat:@"%d.%@",_snCount,@"SKIP"];
        [_showSNs appendString:tempStr];
        [_showSNs appendString:@"\r\n"];
        
    }
    
    [_showSN_TF setStringValue:_showSNs];
    NSLog(@"%ld",[self._snArr count]);
}
-(void)initScanSnView{
    self.checkSN = [[HSCheckSN alloc] init];
}
-(IBAction)inputSNAction:(id)sender{
    if(_ENTER_ESC == YES) return;
    NSString *inputSN=[[_inputSN_TF stringValue] uppercaseString];
    [_errMsgLabel setStringValue:@""];
    [_inputSN_TF setStringValue:@""];
    [_inputSN_TF setEnabled:NO];
    if(![self SNisOK:inputSN]){
        [_inputSN_TF setEnabled:YES];
        [_inputSN_TF becomeFirstResponder];
        return;
    }
    NSString *tempStr=@"";
    //#1 selected slot "YES" ==>>inputSN
    bool find_YES_select=false;
    for (int i=_snCount; i<_UNIT_COUNT; i++) {
        if ([[self._select_Slot_BoolArr objectAtIndex:i] isEqual:@"YES"]) {
            if(find_YES_select) break;
            tempStr=[NSString stringWithFormat:@"%d.%@",_snCount+1,inputSN];
            [self._snArr addObject:inputSN];
            find_YES_select=true;
            _snCount+=1;
            //break;
        }else{
            tempStr=[NSString stringWithFormat:@"%d.%@",_snCount+1,@"SKIP"];
            [self._snArr addObject:@""];
            _snCount+=1;
        }
        
        [_showSNs appendString:tempStr];
        [_showSNs appendString:@"\r\n"];
        [_showSN_TF setStringValue:_showSNs];
        NSLog(@"snCount:%d",_snCount);
    }

    //_UNIT_COUNT=4
    if (_snCount == _UNIT_COUNT) {
        //[self.delegate msgFromScanSnView:self._snArr];
        [self dismissViewController:self];
        [self.delegate event:@{@"type":@"OK",@"content":self._snArr} fromSubView:@"ScanSNView"];
    }
    
    [_inputSN_TF setEnabled:YES];
    [_inputSN_TF becomeFirstResponder];
}
//check SN is OK?
-(BOOL)SNisOK:(NSString *)sn{
    //check sn empty error
    if ([sn length] ==0) {
        [self printLog:@"SN is empty!"];
        [_errMsgLabel setStringValue:@"SN is empty!"];
        //[self alarmPanel:@"SN Empty Error!"];
        return NO;
    }
    //check sn repeat error
    if(self._snArr != nil && [self._snArr count]>0){
        for(NSString *item in self._snArr){
            if ([item isEqualToString:sn]){
                [self printLog:@"SN repeat!"];
                [_errMsgLabel setStringValue:@"SN repeat!"];
                //[self alarmPanel:@"SN Repeat Error!"];
                return NO;
            }
        }
    }
    //check sn from HSCheckSN method
    NSError *err = NULL;
    if ([self.checkSN snIsOk:sn error:&err] == NO) {
        [self printLog:@"SN check result is NG!"];
        [_errMsgLabel setStringValue:[err localizedDescription]];
        return NO;
    }
    //no error
    return YES;
}

-(IBAction)backBtnAction:(id)sender{
    _ENTER_ESC=YES;
    [self dismissViewController:self];
    [self.delegate event:@{@"type":@"NG",@"content":@[]} fromSubView:@"ScanSNView"];
}
-(void)printLog:(NSString *)log{
    HSLogInfo(@"%@",log);
    //NSLog(@"[ScanSN] - %@",log);
}
@end
