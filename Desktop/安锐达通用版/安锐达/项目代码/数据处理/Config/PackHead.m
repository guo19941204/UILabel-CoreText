//
//  PackHead.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/8.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "PackHead.h"
#import "Contains.h"
#import "YMSocketUtils.h"


@implementation PackHead

- (instancetype)init {
    if (self = [super init]) {
        _uiPackageLen = 0;
        _uiPackageID = 0;
        _uiAllLen = 0;
        _uiIDCount = 0;
        _uiDataID = 0;
        _ucDataType = 0;
        _packHeadLen = 17;
    }
    return self;
}

#pragma mark -- 封包 --
//默认只有一个包时 可以掉这个方法
- (NSMutableData *)packet:(NSMutableData *)sendBuf {
    /*** 当前数据包的长度 包头+包体***/
    self.uiPackageLen = self.packHeadLen + sendBuf.length;
    /*** 包体的长度 ***/
    self.uiAllLen = sendBuf.length;
    
    /*** 初始化一个17字节的包头缓冲区 ***/
    self.data = [[NSMutableData alloc] initWithLength:self.packHeadLen];
    /*** 初始化数据包缓冲区 ***/
    self.dataBuff = [[NSMutableData alloc] initWithLength:self.uiPackageLen];
    
    //封包
    [self.data appendBytes:(__bridge const void * _Nonnull)([YMSocketUtils bytesFromUInt32:(int)self.uiPackageLen]) length:4];
    [self.data appendBytes:(__bridge const void * _Nonnull)([YMSocketUtils bytesFromUInt32:(int)self.uiPackageID]) length:4];
    [self.data appendBytes:(__bridge const void * _Nonnull)([YMSocketUtils bytesFromUInt32:(int)self.uiAllLen]) length:4];
    [self.data appendBytes:(__bridge const void * _Nonnull)([YMSocketUtils bytesFromUInt16:(int)self.uiIDCount]) length:2];
    [self.data appendBytes:(__bridge const void * _Nonnull)([YMSocketUtils bytesFromUInt16:(int)self.uiDataID]) length:2];
    [self.data appendBytes:(__bridge const void * _Nonnull)([YMSocketUtils byteFromUInt8:(int)self.ucDataType]) length:1];
    
    [self.dataBuff appendData:self.data];
    [self.dataBuff appendData:sendBuf];
    
    return self.dataBuff;
}

- (NSMutableData *)pack {
    /*** 初始化一个17字节的包头缓冲区 ***/
    /*** 初始化数据包缓冲区 ***/
    self.dataBuff = [[NSMutableData alloc] init];
    //封包
    
    [self.dataBuff appendData:[YMSocketUtils bytesFromUInt32:self.uiPackageLen]];
    [self.dataBuff appendData:[YMSocketUtils bytesFromUInt32:self.uiPackageID]];
    [self.dataBuff appendData:[YMSocketUtils bytesFromUInt32:self.uiAllLen]];
    [self.dataBuff appendData:[YMSocketUtils bytesFromUInt16:self.uiIDCount]];
    [self.dataBuff appendData:[YMSocketUtils bytesFromUInt16:self.uiDataID]];
    [self.dataBuff appendData:[YMSocketUtils byteFromUInt8:self.ucDataType]];


    return self.dataBuff;
}

#pragma mark -- 拆包 --
+ (PackHead *)getObject:(NSData *)buff lenth:(int)len {
    
    PackHead *packHead = [[PackHead alloc] init];
    
    packHead.uiPackageLen = (uint32_t)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(0, 4)]];
    packHead.uiPackageID = (uint32_t)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(4, 4)]];
    packHead.uiAllLen = (uint32_t)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(8, 4)]];
    packHead.uiIDCount = (uint16_t)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(12, 2)]];
    packHead.uiDataID = (uint16_t)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(14, 2)]];
    packHead.ucDataType = (uint8_t)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(16, 1)]];

    return packHead;
}









@end
