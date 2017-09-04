//
//  HandleDataPro.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/20.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "HandleDataPro.h"
#import "MsgEntity.h"
#import "PackHead.h"
#import "SendMessage.h"
#import "Contains.h"
#import "RecivedEntity.h"
#import "DataProcessThread.h"
#import "HandleDataInstance.h"

@implementation HandleDataPro

- (void)didReadData:(NSData *)data {
    /*** 获取当前接收包的包头 ***/
    PackHead *packHead = [PackHead getObject:data lenth:17];
    NSLog(@"\n数据包长度: %u\n大包ID: %u\n消息体长度: %u\n被拆分包的数量: %d\n小包的ID: %d\nucDataType: %d",packHead.uiPackageLen,packHead.uiPackageID,packHead.uiAllLen,packHead.uiIDCount,packHead.uiDataID,packHead.ucDataType);
    
    //1.数据包长度 = 当前接收到的数据长度
    //2.数据包长度 < 当前接收的数据长度
    //3.数据包长度 > 当前接收的数据长度
    
    
    //如果当前接收包的长度小于17 则丢弃
    if (data.length > 17) {
        //先将当前包缓存到全局的字典中  大包ID作为key 包作为Value
        //1.先判断缓存中是否存在 大包IDkey 对应的value 不存在则添加 存在则将data拼接在value后面
        
        //1.数据包长度 = 当前接收到的数据长度

        if ([[HandleDataInstance sharedObject].handleDataDic valueForKey:[Util getString:@(packHead.uiPackageID)]]) {
            NSMutableData *lastData = [[HandleDataInstance sharedObject].handleDataDic valueForKey:[Util getString:@(packHead.uiPackageID)]];
            [lastData appendData:data];
        } else {
            [[HandleDataInstance sharedObject].handleDataDic setValue:[NSMutableData dataWithData:data] forKey:[Util getString:@(packHead.uiPackageID)]];
        }
        
        [self preHandleData:packHead];
    }else {
        //读下一个包
        [[ExchangeSocketServe sharedInstance].socket readDataWithTimeout:-1 tag:[HandleDataInstance sharedObject].tag];
    }
}


//处理包
- (void)preHandleData:(PackHead *)packHead {
    //(1)判断被拆分包的数量
    
    int packCount = packHead.uiIDCount;//被拆分包的数量
    int bigPackId = packHead.uiPackageID;//大包的ID
    
    
    
}







@end
