//
//  SecurityManager.m
//  TestMe
//
//  Created by WeidongCao on 2020/6/8.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "SecurityManager.h"
//security verify keys
#define mainKey @"280f8bb8c43d532f389ef0e2a5321220b0782b065205dcdfcb8d8f02ed5115b9"
#define subKey @"CC0A69779E15780ADAE46C45EB451A23"

@interface SecurityManager()

@property (retain, nonatomic) NSString *path;

@end

@implementation SecurityManager

+(BOOL)CheckSecurityFolder:(NSString *)folder error:(NSError *__autoreleasing  _Nullable * _Nullable)err{
    *err = NULL;
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
            NSString *errMsg = [NSString stringWithFormat:@"Signed file:(%@) not exist!",signed_file];
            *err = [[NSError alloc] initWithDomain:@"com.securitycheck" code:0x60 userInfo:@{NSLocalizedDescriptionKey:errMsg}];
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
            *err = [[NSError alloc] initWithDomain:@"com.securitycheck" code:0x60 userInfo:@{NSLocalizedDescriptionKey:@"check result failure"}];
            NSLog(@"Check security result:NG");
            return NO;
        }
    }
    
    return YES;
}

@end
