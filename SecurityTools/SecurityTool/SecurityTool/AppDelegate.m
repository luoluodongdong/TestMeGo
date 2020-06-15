//
//  AppDelegate.m
//  SecurityTool
//
//  Created by Weidong Cao on 2019/9/24.
//  Copyright © 2019 Weidong Cao. All rights reserved.
//

#import "AppDelegate.h"

#define mainKey @"280f8bb8c43d532f389ef0e2a5321220b0782b065205dcdfcb8d8f02ed5115b9"
#define subKey @"CC0A69779E15780ADAE46C45EB451A23"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    // 字符串MD5加密
//    CocoaSecurityResult *result_md5 = [CocoaSecurity md5:@"123456_md5"];
//
//    NSLog(@"%@", [result_md5 hex]);
    [_window setTitle:@"SecurityTool_v1.0.2"];
}

-(IBAction)signBtnAction:(id)sender{
    NSString *folderPath=[folderTF stringValue];
    NSLog(@"Folder path:%@",folderPath);
    if ([folderPath isEqualToString:@""]) {
        [self showDialog:@"folder path is empty!"];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 取得一个目录下得所有文件名
    NSArray *files = [fileManager subpathsAtPath:folderPath];
    NSLog(@"files:%@",files);
    for (NSString *fileName in files) {
        if ([fileName hasSuffix:@".signed"]) {
//            NSString *file = [folderPath stringByAppendingString:@"/"];
//            file = [file stringByAppendingString:fileName];
//            [self fileAttriutes:file];
            
            continue;
        }
        NSString *file = [folderPath stringByAppendingString:@"/"];
        file = [file stringByAppendingString:fileName];
        NSLog(@"\n==>%@",file);
        NSString *readStr = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"读取文件-字符串： %@", readStr);
        CocoaSecurityResult *result_md5 = [CocoaSecurity md5:readStr];
        
        NSString *md5_val=[result_md5 base64];
        NSLog(@"md5 value:%@", md5_val);
        //encrypt md5 val
        CocoaSecurityResult *aes256 = [CocoaSecurity aesEncrypt:md5_val hexKey:mainKey hexIv:subKey];
        // aes256.base64 = 'WQYg5qvcGyCBY3IF0hPsoQ=='
        NSString *encrypt_val=[aes256 base64];
        NSLog(@"Encrypt val:%@",encrypt_val);
        
        NSString *signedFile= [file stringByAppendingString:@".signed"];
        [encrypt_val writeToFile:signedFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *cmd = [NSString stringWithFormat:@"chflags hidden %@",signedFile];
        [self cmdExe:cmd];
        //        NSDictionary *attTemp = [fileManager attributesOfItemAtPath:signedFile error:nil];
//        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:attTemp];
//        [attributes setObject:@(1) forKey:NSFileExtensionHidden];
//        [fileManager setAttributes:attributes ofItemAtPath:signedFile error:nil];
        
//        readStr = [NSString stringWithContentsOfFile:signedFile encoding:NSUTF8StringEncoding error:nil];
//
//        //decrypt md5 val
//        CocoaSecurityResult *aes256Decrypt =
//        [CocoaSecurity aesDecryptWithBase64:readStr
//                                     hexKey:@"280f8bb8c43d532f389ef0e2a5321220b0782b065205dcdfcb8d8f02ed5115b9"
//                                      hexIv:@"CC0A69779E15780ADAE46C45EB451A23"];
//        // aes256Decrypt.utf8String = 'kelp'
//        NSString *decrypt_val=[aes256Decrypt utf8String];
//        NSLog(@"Decrypt val:%@",decrypt_val);
//
//        if ([decrypt_val isEqualToString:md5_val]) {
//            NSLog(@"Check security result:OK");
//        }else{
//            NSLog(@"Check security result:NG");
//        }
    }
    [self showDialog:@"Entrypt finished!"];
}
- (NSString *)cmdExe:(NSString *)cmd
{
    // 初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    // "/Users/weidongcao/Desktop/ExePyCmd/dist/ExePyCmd"
    //[task setLaunchPath:@"/Users/weidongcao/Desktop/ExePyCmd/dist/ExePyCmd"];
    // -c 用来执行string-commands（命令字符串），也就说不管后面的字符串里是什么都会被当做shellcode来执行
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments: arguments];
    
    // 新建输出管道作为Task的输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSPipe *pipe2=[NSPipe pipe];
    [task setStandardError:pipe2];
    
    // 开始task
    NSFileHandle *file = [pipe fileHandleForReading];
    NSFileHandle *file2 = [pipe2 fileHandleForReading];
    [task launch];
    [task waitUntilExit]; //执行结束后,得到执行的结果字符串++++++
    NSData *data;
    data = [file readDataToEndOfFile];
    NSString *result_str;
    NSString *error_str=[[NSString alloc] initWithData:[file2 readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    [file closeFile];
    [file2 closeFile];
    if(![error_str isEqualToString:@""]){
        NSLog(@"error:%@",error_str);
        return @"[ERROR]";
    }
    result_str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding]; //---------------------------------
    //result_str=[result_str stringByAppendingString:error_str];
    return result_str;
}

-(void)fileAttriutes:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    NSArray *keys;
    id key, value;
    keys = [fileAttributes allKeys];
    NSUInteger count = [keys count];
    for (int i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];  //获取文件名
        value = [fileAttributes objectForKey: key];  //获取文件属性
        NSLog(@"file attribute key:%@ value:%@",key,value);
    }
}
-(IBAction)verifyBtnAction:(id)sender{
    NSString *folderPath=[folderTF stringValue];
    NSLog(@"Folder path:%@",folderPath);
    if ([folderPath isEqualToString:@""]) {
        [self showDialog:@"folder path is empty!"];
        return;
    }
    BOOL isSecure= [self CheckSecurityFolder:folderPath];
    NSLog(@"Security folder check result:%hhd",isSecure);
    if (YES == isSecure) {
        [self showDialog:@"Verify secure OK!"];
    }else{
        [self showDialog:@"Verify secure NG!"];
    }
}
-(BOOL)CheckSecurityFolder:(NSString *)folder{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 取得一个目录下得所有文件名
    NSArray *files = [fileManager subpathsAtPath:folder];
    NSLog(@"files:%@",files);
    
    for (NSString *fileName in files) {
        if ([fileName hasSuffix:@".signed"]) {
            continue;
        }
        NSString *file = [folder stringByAppendingString:@"/"];
        file = [file stringByAppendingString:fileName];
        NSLog(@"\n==>%@",file);
        NSString *readStr = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"读取文件-字符串： %@", readStr);
        CocoaSecurityResult *result_md5 = [CocoaSecurity md5:readStr];
        
        NSString *md5_val=[result_md5 base64];
        NSLog(@"md5 value:%@", md5_val);
        
        NSString *signed_file=[file stringByAppendingString:@".signed"];
        if (![fileManager fileExistsAtPath:signed_file]) {
            NSLog(@"Signed file not exist!");
            return NO;
        }
        NSString *encrypt_val=[NSString stringWithContentsOfFile:signed_file encoding:NSUTF8StringEncoding error:nil];
        //decrypt md5 val
        CocoaSecurityResult *aes256Decrypt =
        [CocoaSecurity aesDecryptWithBase64:encrypt_val hexKey:mainKey hexIv:subKey];
        // aes256Decrypt.utf8String = 'kelp'
        NSString *decrypt_val=[aes256Decrypt utf8String];
        NSLog(@"Decrypt val:%@",decrypt_val);
        
        if ([decrypt_val isEqualToString:md5_val]) {
            NSLog(@"Check security result:OK");
        }else{
            NSLog(@"Check security result:NG");
            return NO;
        }
    }
    
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
}

//show question dialog
-(long)showDialog:(NSString *)question{
    //NSString *msg=[NSString stringWithFormat:@"dialog question:%@",question];
    //[self myPrintf:msg];
    NSLog(@"start run dialog window");
    NSAlert *theAlert=[[NSAlert alloc] init];
    [theAlert addButtonWithTitle:@"OK"]; //1000
    //NSString *title=[NSString stringWithFormat:@"[Slot-%d]Question:",self._id];
    [theAlert setMessageText:@"Question:"];
    [theAlert setInformativeText:question];
    [theAlert setAlertStyle:0];
    //[theAlert setIcon:[NSImage imageNamed:@"question1.png"]];
    NSLog(@"End run dialog window");
    return [theAlert runModal];
}

- (void)windowShouldClose:(id)sender{
    NSLog(@"windows will close...");
    [NSApp terminate:self];
}

@end
