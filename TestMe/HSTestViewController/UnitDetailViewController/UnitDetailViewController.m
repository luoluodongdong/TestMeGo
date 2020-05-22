//
//  UnitDetailViewController.m
//  TestMe
//
//  Created by WeidongCao on 2020/4/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "UnitDetailViewController.h"
#import "ContainerViewController.h"
#import "HSTestplanItem.h"
#import "HSLogger.h"

@interface UnitDetailViewController ()

@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSDateComponentsFormatter *timeFormatter;

@end

@implementation UnitDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSSearchFieldCell *searchCell=searchField.cell;
    NSButtonCell *searchBtnCell = [searchCell searchButtonCell];
    [searchBtnCell setTarget:self];
    [searchBtnCell setAction:@selector(searchBtnSearchAction:)];
    NSButtonCell *cancelBtnCell = [searchCell cancelButtonCell];
    [cancelBtnCell setTarget:self];
    [cancelBtnCell setAction:@selector(searchBtnCancelAction:)];
    
    [self setTimeFormatter:[NSDateComponentsFormatter new]];
    [self.timeFormatter setAllowedUnits:0xf0];
    [self.timeFormatter setAllowsFractionalUnits:YES];
    [self.timeFormatter setZeroFormattingBehavior:0xe];
    [self.timeFormatter setUnitsStyle:0x1];
    [timerLabel setStringValue:@""];
    
    //[detailTableView reloadData];
    [self printLog:@"view did load done."];
}

-(IBAction)showPassBtnAction:(id)sender{
    if ([showPassBtn state]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unit == %@",self.unit];
        [recordsArrayController setFetchPredicate:predicate];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unit == %@ && status != 1",self.unit];
        [recordsArrayController setFetchPredicate:predicate];
    }
}
-(IBAction)searchBtnCancelAction:(id)sender{
    [self printLog:@"click search-canel btn"];
    [searchField setStringValue:@""];
    if ([showPassBtn state]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unit == %@",self.unit];
        [recordsArrayController setFetchPredicate:predicate];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unit == %@ && status != 1",self.unit];
        [recordsArrayController setFetchPredicate:predicate];
    }
}
-(IBAction)searchBtnSearchAction:(id)sender{
    [self printLog:@"click search-search btn"];
    NSString *searchStr = [searchField stringValue];
    if ([searchStr length] == 0) {
        [self searchBtnCancelAction:searchField];
        return;
    }
    if ([showPassBtn state]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unit == %@ && testName CONTAINS[cd] %@",self.unit,searchStr];
        [recordsArrayController setFetchPredicate:predicate];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unit == %@ && status != 1 && testName CONTAINS[cd] %@",self.unit,searchStr];
        [recordsArrayController setFetchPredicate:predicate];
    }
}

-(void)setUnit:(DBUnit *)unit{
    [self.unit removeObserver:self forKeyPath:@"end"];
    self->_unit = unit;
    [self.unit addObserver:self forKeyPath:@"end" options:0x0 context:0x0];
    if (self.unit.end == nil) {
        if (self.unit.start != nil) {
            self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeTick:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }
    [self timeTick:nil];
}
- (void)timeTick:(nullable id)date{
    NSTimeInterval interval = 0;
    if (self.unit.end != nil) {
        interval = [self.unit.end timeIntervalSinceDate:self.unit.start];
    }else{
        if (self.unit.start != nil) {
            interval = [[NSDate date] timeIntervalSinceDate:self.unit.start];
        }
    }
    NSString *timeStr = [self.timeFormatter stringFromTimeInterval:interval];
    [timerLabel setStringValue:timeStr];
    [self printLog:@"timeTick"];
    //NSLog(@"[UDVC]- test array controller count:%ld",[self.arrayController.arrangedObjects count]);
    
    NSIndexSet *set1 = [NSIndexSet indexSetWithIndex:[detailTableView numberOfRows]-1];
    NSIndexSet *set2 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [detailTableView numberOfColumns])];
    [detailTableView reloadDataForRowIndexes:set1 columnIndexes:set2];
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    if ([keyPath isEqualToString:@"end"]) {
        [self printLog:@"KOV - self.unit.end"];
        if (self.unit.end != nil) {
            [self.timer invalidate];
            [self setTimer:nil];
            [self timeTick:nil];
        }
    }
    
}
- (void)dealloc{
    [self.unit removeObserver:self forKeyPath:@"end"];
}
-(void)viewWillAppear{
    [showPassBtn setState:YES];
    [titleLabel setStringValue:self.unit.identifier];
    [self timeTick:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unit == %@",self.unit];
    [recordsArrayController setFetchPredicate:predicate];
    NSSortDescriptor *sd2=[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES];
    //NSSortDescriptor *sd2=[NSSortDescriptor sortDescriptorWithKey:@"identifier.length" ascending:YES];
    NSArray *sortArr1 = [NSArray arrayWithObjects:sd2,nil];
    [recordsArrayController setSortDescriptors:sortArr1];
    [recordsArrayController setAutomaticallyRearrangesObjects:YES];
    
    [detailTableView scrollRowToVisible:[detailTableView numberOfRows] - 1];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateVerticalScrollerPosition:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [searchField setStringValue:@""];
    [self printLog:@"view will appear"];
}
-(void)viewDidAppear{
    [searchField becomeFirstResponder];
}
- (void)viewWillDisappear{
    [super viewWillDisappear];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [self.timer invalidate];
    [self setTimer:nil];
    
}
-(void)initView{
    //[detailTableView reloadData];
}

-(IBAction)backBtnAction:(id)sender{
    id cvc = self.parentViewController;
    [cvc switchToDashboardView];
}
- (void)updateVerticalScrollerPosition:(NSNotification *)notification{
    //NSLog(@"[UDVC]-updateVerticalScrollerPosition %@",[notification name]);
    if ([[notification name] isEqualToString:NSManagedObjectContextObjectsDidChangeNotification]) {
        if ([[NSThread currentThread] isMainThread]) {
            [self updateRecords:notification];
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self updateRecords:notification];
            });
        }
    }
}
-(void)updateRecords:(NSNotification *)notification{
    //NSDictionary *useInfo = notification.userInfo;
//    NSLog(@"[UDVC]-updatRecords %@",notification.userInfo);
    NSInteger rowsCount = [detailTableView numberOfRows];
    if (0 != rowsCount) {
        NSScrollView *scrollView =  [detailTableView enclosingScrollView];
        if ([scrollView contentView] != nil) {
            NSRange range = [detailTableView rowsInRect:scrollView.contentView.visibleRect];
            if (range.length < rowsCount) {
                [detailTableView scrollRowToVisible:rowsCount-1];
            }
        }
    }
}
-(void)printLog:(NSString *)log{
    HSLogInfo(@"[UDVC] > -%d- %@",self.index,log);
    //NSLog(@"[UDVC] > -%d- %@",self.index,log);
}

@end
