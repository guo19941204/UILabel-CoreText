//
//  ExchangeSocketServe.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

enum : NSUInteger {
    ExchangeSocketOffLineBySever,               //服务器断开
    ExchangeSocketOffLineByUser,                //用户断开
    ExchangeSocketOffLineByWifiCut,            //WIFI断开
};
@class HandleDataProcess;
@interface ExchangeSocketServe : NSObject<AsyncSocketDelegate>
/*** socket */
@property (nonatomic, strong) AsyncSocket *socket;
/*** 心跳计时器 */
@property (nonatomic, retain) NSTimer *heartTimer;
/*** host */
@property (nonatomic, copy) NSString *host;
/*** port ***/
@property (nonatomic, copy) NSString *port;
/*** 收到服务器传回的消息的block */
@property (nonatomic, copy) void (^callBackMessage)(NSDictionary *responseData,NSData *data);
/*** 连接服务器成功 */
@property (nonatomic, copy) void (^callBackConnectStatus)(BOOL isConnected);
/*** 是否加解密 */
@property (nonatomic, assign) BOOL isEncry;
@property (nonatomic, strong) NSMutableData *cacheData;
/*** handledata */
@property (nonatomic, strong) HandleDataProcess *handleData;


/*** 创建单例类 ***/
+ (ExchangeSocketServe *)sharedInstance;

/*** 开始连接服务器 ***/
- (void)startConnectSocket;
/*** 断开连接 ***/
- (void)cutOffSocket;
/*** 发送指令 ***/
- (void)sendMessage:(id)message;


/*** 发送消息 （socket 包头+包体 分包等处理） */
- (void)sendMessageWithMessage:(NSMutableData *)data proNum:(int)proNum len:(int)len;
@end
