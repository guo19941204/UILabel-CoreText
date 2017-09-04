//
//  ExchangeSocketServe.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "ExchangeSocketServe.h"
#import <UIKit/UIKit.h>
#import "Contains.h"
#import "MsgEntity.h"
#import "PackHead.h"
#import "HandleDataProcess.h"
#import "FunctionClass.h"

@interface ExchangeSocketServe ()

@end
@implementation ExchangeSocketServe
+ (ExchangeSocketServe *)sharedInstance
{
    static ExchangeSocketServe *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstace = [[self alloc] init];
        sharedInstace.handleData = [[HandleDataProcess alloc] init];
    });
    return sharedInstace;
}

- (void)startConnectSocket
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    NSError *error = nil;
    uint16_t port = (self.port?self.port:[FunctionClass sharedInstance].port).intValue;
    NSString *host = self.host?self.host:[FunctionClass sharedInstance].host;
    [self.socket connectToHost:host onPort:port withTimeout:20 error:&error];
}

- (NSInteger)SocketOpen:(NSString*)addr port:(NSInteger)port
{
    
    if (![self.socket isConnected])
    {
        NSError *error = nil;
        [self.socket connectToHost:addr onPort:port withTimeout:20 error:&error];
    }
    
    return 0;
}


-(void)cutOffSocket
{
    self.socket.userData = SocketOffLineByUser;
    [self.socket disconnect];
}


- (void)sendMessage:(id)message
{
    //像服务器发送数据
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    int length = (int)data.length;
    Byte byte[4];
    
    byte[3] =  (Byte) ((length>>24 & 0xFF));
    
    byte[2] =  (Byte) ((length>>16 & 0xFF));
    
    byte[1] =  (Byte) ((length>>8 & 0xFF));
    
    byte[0] =  (Byte) (length & 0xFF);
    NSData *data1 = [NSData dataWithBytes:byte length:4];
    
    NSMutableString *string1 = [[NSMutableString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    NSMutableString *string2 = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [string1 appendString:string2];
    NSData *postData = [string1 dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:postData withTimeout:-1 tag:1];
}

#pragma mark - Delegate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    
    NSLog(@"7878 sorry the connect is failure %ld",sock.userData);
    
    if (sock.userData == ExchangeSocketOffLineBySever) {
        // 服务器掉线，重连
        [self startConnectSocket];
        [[FunctionClass sharedInstance] login];
    }
    else if (sock.userData == ExchangeSocketOffLineByUser) {
        
        // 如果由用户断开，不进行重连
        return;
    }else if (sock.userData == ExchangeSocketOffLineByWifiCut) {
        
        // wifi断开,重连
        [self startConnectSocket];
        [[FunctionClass sharedInstance] login];
    }
    
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSData * unreadData = [sock unreadData]; // ** This gets the current buffer
    if(unreadData.length > 0) {
        [self onSocket:sock didReadData:unreadData withTag:0]; // ** Return as much data that could be collected
    } else {
        
        NSLog(@" willDisconnectWithError %ld   err = %@",sock.userData,[err description]);
        if (err.code == 57) {
            self.socket.userData = SocketOffLineByWifiCut;
        }
    }
    
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket");
}

// 向服务器发送固定消息，检测长连接
-(void)checkLongConnect{
    
    NSString *longConnect = @"connect";
    NSData *data  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:1 tag:1];
}

//接受消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSLog(@"%@",data);
    [self.handleData didReadData:data];
    
//    [self.socket readDataWithTimeout:-1 tag:0];
}

//发送消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //读取消息
//    [self.socket readDataWithTimeout:-1 tag:0];
}

#pragma mark -- 发送消息 --
- (void)sendMessageWithMessage:(NSMutableData *)data proNum:(int)proNum len:(int)len {
    //    //拿到了消息体  现在我们要封包
    //    PackHead *packHead = [[PackHead alloc] init];
    //    NSMutableData *allPackData = [packHead packet:data];
    
    //封包完成之后 我们拿到所有的数据（包头+包体）的包，现在要分包
    //封包完成之后 我们拿到所有的数据（包头+包体）的包，现在要分包
    __block NSMutableArray *packArray = [MsgEntity getPackArrayWithMessage:data proNum:proNum len:len];
    
    //获取到分包后的数组 packArray 放在消息队列中依次发送到服务器
    // 创建串行队列
    // 参数1 : 队列的标示符
    // 参数2 : 队列的属性,决定了队列是串行的还是并行的 SERIAL : 串行
    
    //     创建串行队列
    dispatch_main_sync_safe(^{
        for (int i = 0; i < packArray.count; i++) {
            NSMutableData *data = packArray[i];
            [self.socket writeData:data withTimeout:-1 tag:1];
            data = nil;
        }
        [packArray removeAllObjects];
        packArray = nil;
    })
}
@end
