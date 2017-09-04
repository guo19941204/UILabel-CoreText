//
//  NSString+AES.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/5.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "NSString+AES.h"
#import "Contains.h"
NSString *const kInitVector = @"cnambition654321";
size_t const kKeySize = kCCKeySizeAES128;
@implementation NSString (AES)
+ (NSString *)encryptAES:(NSString *)content key:(NSString *)key {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

    NSData *contentData = [content dataUsingEncoding:enc];
    NSUInteger dataLength = contentData.length;
    // 为结束符'\\0' +1
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:enc];
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [kInitVector dataUsingEncoding:enc];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        // 对加密后的数据进行 base64 编码
        return [[NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    free(encryptedBytes);
    return nil;
}


+ (NSString *)decryptAES:(NSString *)content key:(NSString *)key {
    // 把 base64 String 转换成 Data
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger dataLength = contentData.length;
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:enc];
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [kInitVector dataUsingEncoding:enc];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize] encoding:enc];
    }
    free(decryptedBytes);
    return nil;
}

#pragma mark -- 中文GBK转字符串
- (NSString *)GBKtranscoding
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //GBK转码
    NSString *first=[self stringByAddingPercentEscapesUsingEncoding:enc];
    return first;
}
@end
