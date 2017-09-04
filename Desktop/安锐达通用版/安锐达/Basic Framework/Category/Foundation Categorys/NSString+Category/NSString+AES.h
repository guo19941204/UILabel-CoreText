//
//  NSString+AES.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/5.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSString (AES)
+ (NSString *)encryptAES:(NSString *)content key:(NSString *)key;
+ (NSString *)decryptAES:(NSString *)content key:(NSString *)key;
- (NSString *)GBKtranscoding;
@end
