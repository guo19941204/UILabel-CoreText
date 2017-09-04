//
//  GCDExchangeSocketServe.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/22.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "GCDExchangeSocketServe.h"
#import <UIKit/UIKit.h>
#import "Contains.h"
#import "MsgEntity.h"
#import "PackHead.h"
#import "HandleDataProcess.h"
#import "FunctionClass.h"
@implementation GCDExchangeSocketServe
+ (GCDExchangeSocketServe *)sharedInstance
{
    static GCDExchangeSocketServe *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstace = [[self alloc] init];
        sharedInstace.handleData = [[HandleDataProcess alloc] init];
    });
    return sharedInstace;
}

- (void)startConnectSocket
{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = (self.port?self.port:PORT).intValue;
    NSString *host = self.host?self.host:API_HOST;
    [self.socket connectToHost:host onPort:port withTimeout:20 error:&error];
}

-(void)cutOffSocket
{
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
    [self.socket writeData:postData withTimeout:-1 tag:0];
}

#pragma mark -- delegate --
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //这里需要对Socket的工作原理进行一点解释，当Socket accept一个连接服务请求时，将生成一个新的Socket，即此处的newSocket。在此可查看newSocket.connectedHost和newSocket.connectedPort等参数，并通过新的socket向客户端发送一包数据后会关闭你一开始创建的socket(self.serverSocket),接下来你都将使用newSocket(我将此保存为self.clientSocket)
    self.socket = newSocket;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //创建的socket单例
    NSLog(@"GCD连接成功 主机：%@  端口:%d",host,port);
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
{
    NSLog(@"连接失败,要怎么做,你自己看着办吧");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"可通过参数中的tag值管理发送的数据，想怎么管理，您看着办");
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到消息%@,要怎么处理，您看着办",data);
    [self.handleData didReadData:data];
}

- (void)sendMessageWithMessage:(NSMutableData *)data proNum:(int)proNum len:(int)len {
    //    //拿到了消息体  现在我们要封包
    //    PackHead *packHead = [[PackHead alloc] init];
    //    NSMutableData *allPackData = [packHead packet:data];
    
    //封包完成之后 我们拿到所有的数据（包头+包体）的包，现在要分包
    NSMutableArray *packArray = [MsgEntity getPackArrayWithMessage:data proNum:proNum len:len];
    
    //获取到分包后的数组 packArray 放在消息队列中依次发送到服务器
    // 创建串行队列
    // 参数1 : 队列的标示符
    // 参数2 : 队列的属性,决定了队列是串行的还是并行的 SERIAL : 串行
    
    // 创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("ck", DISPATCH_QUEUE_SERIAL);
    
    for (int i = 0; i < packArray.count; i++) {
        // 创建任务
        void (^task)() = ^{
            NSMutableData *data = packArray[i];
            [self.socket writeData:data withTimeout:-1 tag:0];
        };
        // 将同步任务添加到串行队列
        dispatch_sync(queue, task);
    }
}

@end
