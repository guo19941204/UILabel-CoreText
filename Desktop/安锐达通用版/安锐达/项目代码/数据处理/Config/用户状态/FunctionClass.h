//
//  FunctionClass.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SendMessage,VideoPlayController;
@interface FunctionClass : NSObject
/*** 是否登录 */
@property (nonatomic, assign) BOOL isLogin;
/*** uId */
@property (nonatomic, copy) NSString *uId;
/*** clientYype */
@property (nonatomic, assign) int clientType;
/*** exchangeHost */
@property (nonatomic, copy) NSString *host;
/*** exchangePort */
@property (nonatomic, copy) NSString *port;
/*** targetUserName */
@property (nonatomic, copy) NSString *targetUserName;
/*** sendMessage */
@property (nonatomic, strong) SendMessage *esm;
/*** 通话组列表 */
@property (nonatomic, strong) NSMutableArray *talkList;

/*** 完成队列 ***/
@property (nonatomic, strong) NSMutableArray *completeMsgList;
@property (nonatomic, strong) NSMutableData *cacheData;
@property (nonatomic, strong) NSMutableArray *cacheDataList;
/*** 是否点击播放 */
@property (nonatomic, assign) BOOL  isPlayout;

/*** tag */
@property (nonatomic, assign) long tag;

/*** 全局的视频播放 */
@property (nonatomic, strong) VideoPlayController *playerController;
/*** 判断是否获取视频头 */
@property (nonatomic, assign) BOOL getVideoHeader;


/*** nWidth */
@property (nonatomic, assign) int nWidth;
/*** nHeight */
@property (nonatomic, assign) int nHeight;
/*** nFrameRate */
@property (nonatomic, assign) int nFrameRate;
@property (nonatomic, strong) NSMutableArray *allUser;
@property (nonatomic, assign) uint8_t *bufOut;
@property (nonatomic, assign) BOOL isEnterForeFrmoBackground;

+ (FunctionClass *)sharedInstance;

- (void)login;

- (BOOL)runningInForeground;
- (BOOL)runningInBackground;
//转化在线用户列表
- (NSMutableDictionary *)convertToUserList:(NSMutableData *)data;
//退出通话组
- (void)exitTalk;
//转化为通话组列表
- (NSMutableArray *)groupList:(NSData *)data len:(int)len;
//连入
- (void)connected:(int)sign;
- (void)invitation:(int)sign;
- (void)cancel:(int)sign;
//连接后确认
- (void)validation:(int)type cnt:(int)cnt userName:(NSString *)userName targetUserName:(NSString *)targetUserName;
@end
