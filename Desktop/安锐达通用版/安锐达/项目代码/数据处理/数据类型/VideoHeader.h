//
//  VideoHeader.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/23.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoHeader : NSObject
/*** 原始数据的画面宽 */
@property (nonatomic, assign) int nWidth;
/*** 原始数据的画面高 */
@property (nonatomic, assign) int nHeight;
/*** 原始数据帧率 */
@property (nonatomic, assign) double nFrameRate;
/*** 颜色空间 */
@property (nonatomic, assign) int nColorSpace;
/*** 编码模式 */
@property (nonatomic, assign) int nRecordMode;
/*** quality */
@property (nonatomic, assign) int nQuality;
/*** qop */
@property (nonatomic, assign) int nQop;
/*** bitrate */
@property (nonatomic, assign) int nBitrate;

/*** 采集卡名字 */
@property (nonatomic, strong) NSData *cardName;


+ (VideoHeader *)getObject:(NSData *)buff len:(int)len;







@end
