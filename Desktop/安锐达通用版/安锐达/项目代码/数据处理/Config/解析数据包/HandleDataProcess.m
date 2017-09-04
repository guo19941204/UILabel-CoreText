//
//  HandleDataProcess.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/9.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "HandleDataProcess.h"
#import "MsgEntity.h"
#import "PackHead.h"
#import "SendMessage.h"
#import "Contains.h"
#import "RecivedEntity.h"
#import "DataProcessThread.h"
#import "FunctionClass.h"

@interface HandleDataProcess ()

/*** 缓存数据 ***/
@property (nonatomic, strong) NSMutableData *cacheData;
@property (nonatomic, strong) NSMutableDictionary *packDictionary;
@property (nonatomic, strong) NSMutableArray *completeMsgList;

@property (nonatomic, strong) NSData *dataOne;
@property (nonatomic, strong) NSData *dataTwo;
@end
@implementation HandleDataProcess

- (void)didReadData:(NSData *)data {
    if (self.cacheData.length > 0) {
        //这种情况属于 1.上次接收到的数据包长>包头中的数据包长度 把尾巴截下来
        //                       2.上次接收到的数据包长<包头中的数据长度 把整个数据包存下来
        [self.cacheData appendData:data];
        if (self.cacheData.length > 17) {
            PackHead *packHead1 = [PackHead getObject:self.cacheData lenth:17];
            if (self.cacheData.length > packHead1.uiPackageLen && packHead1.uiPackageLen > 17) {
                self.dataOne = [self.cacheData subdataWithRange:NSMakeRange(0, packHead1.uiPackageLen)];
                [self handleTcpResponseData:self.dataOne withPackHead:packHead1 readData:NO];//处理包数据
                //将cacheData制空
                self.dataTwo = [self.cacheData subdataWithRange:NSMakeRange(packHead1.uiPackageLen, self.cacheData.length-packHead1.uiPackageLen)];
                [self.cacheData resetBytesInRange:NSMakeRange(0, self.cacheData.length)];
                [self.cacheData setLength:0];
                [self.cacheData appendData:self.dataTwo];
                [self didReadData:[NSData data]];
            } else if (self.cacheData.length < packHead1.uiPackageLen) {
                [[ExchangeSocketServe sharedInstance].socket readDataWithTimeout:-1 tag:0];//socket读取数据
                return;
            } else if (self.cacheData.length == packHead1.uiPackageLen) {
                [self handleTcpResponseData:self.cacheData withPackHead:packHead1 readData:YES];
                [self resetMutData:self.cacheData];
            } else {
                [[ExchangeSocketServe sharedInstance].socket readDataWithTimeout:-1 tag:0];//socket读取数据
                return;
            }
        }else {
            [[ExchangeSocketServe sharedInstance].socket readDataWithTimeout:-1 tag:0];//socket读取数据
            return;
        }
    }else {
        [self.cacheData appendData:data];
        if (self.cacheData.length > 17) {
            PackHead *packHead = [PackHead getObject:self.cacheData lenth:17];
            if (self.cacheData.length < packHead.uiPackageLen) {
                //如果接收到的数据包长 < 包头的数据长度
                //则将整个包缓存下来 然后重新接收数据
                [[ExchangeSocketServe sharedInstance].socket readDataWithTimeout:-1 tag:0];//socket读取数据
                return;
            }else if (self.cacheData.length > packHead.uiPackageLen) {
                //如果接收到的数据包长 > 包头的数据长度
                //则将接收的数据中 包头的数据包长度的长度截下来去解析 余下的部分放入缓存中
                self.dataOne = [self.cacheData subdataWithRange:NSMakeRange(0, packHead.uiPackageLen)];
                [self handleTcpResponseData:self.dataOne withPackHead:packHead readData:NO];//处理包数据
                //将cacheData制空
                self.dataTwo = [self.cacheData subdataWithRange:NSMakeRange(packHead.uiPackageLen, self.cacheData.length-packHead.uiPackageLen)];
                [self.cacheData resetBytesInRange:NSMakeRange(0, self.cacheData.length)];
                [self.cacheData setLength:0];
                [self.cacheData appendData:self.dataTwo];
                [self didReadData:[NSData data]];
            } else if (self.cacheData.length == packHead.uiPackageLen) {
                //如果接收到的数据包长 = 包头的长度
                [self handleTcpResponseData:self.cacheData withPackHead:packHead readData:YES];//处理包数据
                [self resetMutData:self.cacheData];
            }
        }
    }
}

- (void)resetMutData:(NSMutableData *)data {
    [data resetBytesInRange:NSMakeRange(0, data.length)];
    [data setLength:0];
    if (data.length>0) {
        data = nil;
    }
}

#pragma mark -- 处理数据包 --
- (void)handleTcpResponseData:(NSData *)data withPackHead:(PackHead *)packHead readData:(BOOL)readData {
    //获取到了完整的数据包
    //大包ID
    NSLog(@"\n数据包长度: %u\n大包ID: %u\n消息体长度: %u\n被拆分包的数量: %d\n小包的ID: %d\nucDataType: %d",packHead.uiPackageLen,packHead.uiPackageID,packHead.uiAllLen,packHead.uiIDCount,packHead.uiDataID,packHead.ucDataType);

    @try {
        
        long bId = packHead.uiPackageID;
        //小包的ID
        int sId = packHead.uiDataID;
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"%ld",bId);
        NSLog(@"data.lenght %ld",data.length);
        
        RecivedEntity *entity = [self reHeadWithData:data];
        //先判断字典中是否已经存在对应的key
        
        NSString *oString = [NSString stringWithFormat:@"%ld",bId];
        if ([self.packDictionary.allKeys containsObject:oString]) {
            RecivedEntity *rEntity = [self.packDictionary objectForKey:oString];
            rEntity.count++;
            //        [rEntity.list insertObject:[data subdataWithRange:NSMakeRange(17, entity.packHead.uiPackageLen-17)] atIndex:sId-1];
            [rEntity.list setValue:[data subdataWithRange:NSMakeRange(17, entity.packHead.uiPackageLen-17)] forKey:[NSString stringWithFormat:@"%d",sId-1]];
        }else {
            [self.packDictionary setValue:entity forKey:[NSString stringWithFormat:@"%ld",bId]];
            entity.count++;
            //        [entity.list insertObject:[data subdataWithRange:NSMakeRange(17, entity.packHead.uiPackageLen-17)] atIndex:sId-1];
            [entity.list setValue:[data subdataWithRange:NSMakeRange(17, entity.packHead.uiPackageLen-17)] forKey:[NSString stringWithFormat:@"%d",sId-1]];
        }
        RecivedEntity *rEntity = [self.packDictionary objectForKey:[NSString stringWithFormat:@"%ld",bId]];
        
        //收到数据后判断该包是否接收够了
        if (readData) {
            [[ExchangeSocketServe sharedInstance].socket readDataWithTimeout:-1 tag:0];//socket读取数据
        }
        if (rEntity.count == entity.packHead.uiIDCount && rEntity.packHead.uiPackageID == entity.packHead.uiPackageID) {
            NSLog(@"-------完成包ID：%ld-------",bId);
            @try {
                [[DataProcessThread sharedObject] dealWithInstruction:rEntity];
                
            } @catch (NSException *exception) {
                NSLog(@"完成队列放入数据出现异常%@",exception);
            }
            data = nil;
            [self.packDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld",bId]];
        }else {
            rEntity = nil;
            entity = nil;
            return;
        }
    } @catch (NSException *exception) {
        NSLog(@"报错了！！！！！！！！！！！！！！");
    }
}

- (RecivedEntity *)reHeadWithData:(NSData *)data {
    RecivedEntity *recvEntity = [[RecivedEntity alloc] init];
    recvEntity.packHead = [PackHead getObject:data lenth:17];
    return recvEntity;
}

- (NSMutableData *)cacheData {
    if (!_cacheData) {
        _cacheData = [[NSMutableData alloc] init];
    }
    return _cacheData;
}

- (NSMutableDictionary *)packDictionary {
    if (!_packDictionary) {
        _packDictionary = [[NSMutableDictionary alloc] init];
    }
    return _packDictionary;
}

- (NSMutableArray *)completeMsgList {
    if (!_completeMsgList) {
        _completeMsgList = [[NSMutableArray alloc] init];
    }
    return _completeMsgList;
}

- (NSData *)dataOne {
    if (!_dataOne) {
        _dataOne = [[NSData alloc] init];
    }
    return _dataOne;
}

- (NSData *)dataTwo {
    if (!_dataTwo) {
        _dataTwo = [[NSData alloc] init];
    }
    return _dataTwo;
}
@end
