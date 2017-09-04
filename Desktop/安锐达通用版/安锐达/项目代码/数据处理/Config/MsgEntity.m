//
//  MsgEntity.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/8.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "MsgEntity.h"
#import "PackHead.h"

static uint32_t packCount = 1;
static int dataLen = 1543;
@implementation MsgEntity

+ (NSMutableArray<NSMutableData *> *)getPackArrayWithMessage:(NSMutableData *)data proNum:(int)proNum len:(int)len {
    
    NSMutableArray *sendArray = [NSMutableArray array];
    
    int m = 0;
    if (len % (dataLen) == 0) {
        m = len % (dataLen);
    }else {
        m = len / (dataLen) + 1;
    }
    
    while (true) {
        int k = 0;
        if (len > dataLen) {
            k ++;
            NSMutableData *cacheByte = [[NSMutableData alloc] initWithLength:dataLen+17];
            PackHead *packHead = [[PackHead alloc] init];
            packHead.ucDataType = proNum;
            packHead.uiPackageID = packCount;
            packHead.uiAllLen = dataLen;
            packHead.uiDataID = k;
            packHead.uiIDCount = m;
            packHead.uiPackageLen = packHead.uiAllLen + 17;
            //获取包头
            NSMutableData *head = [packHead pack];
            [cacheByte appendData:[head subdataWithRange:NSMakeRange(0, 17)]];
            NSData *chunkData = [data subdataWithRange:NSMakeRange((k-1)*dataLen, dataLen)];
            [cacheByte appendData:chunkData];
            [sendArray addObject:cacheByte];
            cacheByte = nil;
            packHead = nil;
            chunkData = nil;
            head = nil;
        }else {
            k++;
            NSMutableData *cacheByte = [[NSMutableData alloc] init];
            PackHead *packHead = [[PackHead alloc] init];
            packHead.ucDataType = proNum;
            packHead.uiPackageID = packCount;
            packHead.uiAllLen = len-(k-1)*dataLen;
            packHead.uiDataID = k;
            packHead.uiIDCount = m;
            packHead.uiPackageLen = packHead.uiAllLen+17;
            NSLog(@"发送的数据：\n数据包长度: %u\n大包ID: %u\n消息体长度: %u\n被拆分包的数量: %d\n小包的ID: %d\nucDataType: %d",packHead.uiPackageLen,packHead.uiPackageID,packHead.uiAllLen,packHead.uiIDCount,packHead.uiDataID,packHead.ucDataType);
            
            NSMutableData *head = [packHead pack];
            [cacheByte appendData:[head subdataWithRange:NSMakeRange(0, 17)]];
            NSData *chunkData = [data subdataWithRange:NSMakeRange((k-1)*dataLen,  len - (k - 1) * dataLen)];
            [cacheByte appendData:chunkData];
            [sendArray addObject:cacheByte];
            if (packCount > 10000000) {
                packCount = 0;
            }
            packCount++;
            cacheByte = nil;
            packHead = nil;
            chunkData = nil;
            head = nil;
            break;
        }
    }
    
    return sendArray;
}

@end
