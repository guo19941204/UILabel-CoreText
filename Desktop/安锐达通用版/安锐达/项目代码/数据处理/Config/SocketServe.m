//
//  SocketServe.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/5.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "SocketServe.h"
#import <UIKit/UIKit.h>
#import "Contains.h"
#import "MsgEntity.h"
#import "PackHead.h"
#import "HandleDataProcess.h"
#import "YMSocketUtils.h"
#import "FunctionClass.h"

@interface SocketServe () {
    NSInteger kLength;
}
@property (nonatomic, strong) NSMutableData *cacheData;

@end
@implementation SocketServe
+ (SocketServe *)sharedInstance
{
    static SocketServe *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstace = [[self alloc] init];
    });
    return sharedInstace;
}

- (void)startConnectSocket
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
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
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    
    NSLog(@"7878 sorry the connect is failure %ld",sock.userData);
    
    if (sock.userData == SocketOffLineBySever) {
        // 服务器掉线，重连
        [self startConnectSocket];
    }
    else if (sock.userData == SocketOffLineByUser) {
        
        // 如果由用户断开，不进行重连
        return;
    }else if (sock.userData == SocketOffLineByWifiCut) {
        
        // wifi断开,重连
        [self startConnectSocket];
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


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    // 连接成功，
    NSLog(@"didConnectToHost");
    if (self.callBackConnectStatus) {
        self.callBackConnectStatus(YES);
    }
    //通过定时器不断发送消息，来检测长连接
    //    self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkLongConnect) userInfo:nil repeats:YES];
    //    [self.heartTimer fire];
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

#warning 未作长度验证
    NSLog(@"data is %@",data);
    /*
     1.data为接收到的数据
     2.通过通知，block，代理等方法传出去
     */
    if (self.callBackMessage) {
        if (self.isEncry) {
            //不做解密处理
            /*** 获取到包数据后  我们要做拆包处理  因为会出现粘包 ***/
//            [[HandleDataProcess new] didReadData:data];
        }else {
            //做解密处理
            NSData *sd =[data subdataWithRange:NSMakeRange(4, data.length-4)];//截取一部分数据
            NSInteger lenth = [YMSocketUtils valueFromBytes:[data subdataWithRange:NSMakeRange(0, 4)]];
            if (lenth == sd.length) {
                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                NSString *resultString = [[NSString alloc] initWithData:sd encoding:enc];
                NSString *s = [NSString decryptAES:resultString key:@"cnambition123456"];
                NSDictionary *dic = [s dictionaryWithJsonString];

                self.callBackMessage(dic==nil?[NSDictionary dictionary]:dic,data);
            }else if (lenth > 0 && lenth > sd.length && self.cacheData.length == 0) {
                //说明还有数据没拿到
                //先存起来
                [self.cacheData appendData:sd];
                kLength = lenth;
            }else if (self.cacheData.length > 0) {
                [self.cacheData appendData:data];
            }
            
            if (self.cacheData.length == kLength && kLength != 0) {
                //数据拿全了
                NSString *resultString = [[NSString alloc] initWithData:[NSData replaceNoUtf8:self.cacheData] encoding:NSUTF8StringEncoding];
                NSString *s = [NSString decryptAES:resultString key:@"cnambition123456"];
                NSLog(@"接收到数据：%@",s);
                NSDictionary *dic = [s dictionaryWithJsonString];
                self.callBackMessage(dic==nil?[NSDictionary dictionary]:dic,data);
            }
            [self.socket readDataWithTimeout:-1 tag:0];
        }
    }
}


//发送消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //读取消息
    [self.socket readDataWithTimeout:-1 tag:0];
}

#pragma mark -- 发送消息 --
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
            [self.socket writeData:packArray[i] withTimeout:-1 tag:i+1];
        };
        // 将同步任务添加到串行队列
        dispatch_sync(queue, task);
    }
}

- (NSMutableData *)cacheData {
    if (!_cacheData) {
        _cacheData = [[NSMutableData alloc] init];
    }
    return _cacheData;
}
@end
