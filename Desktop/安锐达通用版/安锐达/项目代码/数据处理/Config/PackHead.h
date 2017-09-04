//
//  PackHead.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/8.
//  Copyright © 2017年 郭炜. All rights reserved.
//


/*** 封包 ***/
#import <Foundation/Foundation.h>

@interface PackHead : NSObject

/*** 当前数据包的长度  4*/
@property (nonatomic, assign) uint32_t uiPackageLen;
/*** 大包ID 收到后用来区分存放  4*/
@property (nonatomic, assign) uint32_t uiPackageID;
/*** 有效数据包的长度，只是消息体长度  4*/
@property (nonatomic, assign) uint32_t uiAllLen;
/*** 被拆分包的数量  2*/
@property (nonatomic, assign) uint16_t uiIDCount;
/*** 小包的id  2*/
@property (nonatomic, assign) uint16_t uiDataID;
/***  1*/
@property (nonatomic, assign) uint8_t ucDataType;


/*** 包头长度 */
@property (nonatomic, assign) int packHeadLen;
/*** 封包的数据 */
@property (nonatomic, strong) NSMutableData *dataBuff;
/*** 临时缓冲区 */
@property (nonatomic, strong) NSMutableData *data;

/*** 封包 ***/
- (NSMutableData *)packet:(NSMutableData *)sendBuf;
- (NSMutableData *)pack;

/*** 解析包 ***/
+ (PackHead *)getObject:(NSData *)buff lenth:(int)len;

@end
