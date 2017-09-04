//
//  SendMessage.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/8.
//  Copyright © 2017年 郭炜. All rights reserved.
//

/*** 封装消息体 ***/
#import <Foundation/Foundation.h>

@interface SendMessage : NSObject
/**
 * 指令类型：
 *
 * 0：客户端登录请求；
 * -1：客户端退出请求；
 * -2: 客户端停止通话
 * 1：客户端请求连接另一客户端请求；
 * 2：客户端请求获取在线专家列表；
 * 3: 主任客户端请求连接hclient
 * 4: 添加与客户端通信中的客户端信息到MAP 中
 * 5：客户端返回通信状态
 * 6: 独立获取通话组所有音频头
 * 7：独立获取通话组所有摄像头
 * 8：独立获取通话组视频头
 * 9：混合获取hclient音频、摄像头、视频头
 * 10: 得到客户端当前通话用户组
 * 11: 主任邀请主任
 * 12: hclient连入别的hclient参观
 * 13: hclient邀请别的hclient过来会诊
 * 14: exchanger脉冲,查看客户端socket是否掉线
 */
/*** 指令类型 4*/
@property (nonatomic, assign) uint32_t Type;
/*** jh 单号  30*/
@property (nonatomic, copy) NSString *strOrderID;
/*** 需要发送的数据  128字节 */
@property (nonatomic, copy) NSString *data;
/*** 自身用户名   8个字节 */
@property (nonatomic, copy) NSString *userName;
/*** 目标用户名   8个字节 */
@property (nonatomic, copy) NSString *targetUserName;
/*** 客户端类型  4*/
@property (nonatomic, assign) uint32_t ClientType;
/*** 客户端状态  4*/
@property (nonatomic, assign) uint32_t ClientStatus;
/*** 当前端机器相关信息 */
/*** hostname 64 ***/
@property (nonatomic, copy) NSString *HostName;
/*** ip  64 */
@property (nonatomic, copy) NSString *IP;
/*** socketservice 64 */
@property (nonatomic, copy) NSString *SocketService;

/*** 赋值后获取data ***/
- (NSMutableData *)getByteArray;

/*** 通过data获取sendmessage实例对象 ***/
+ (SendMessage *)getObjectWithData:(NSData *)data withLocation:(int)location;
@end
