//
//  VideoHeader.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/23.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "VideoHeader.h"
#import "Contains.h"
#import "YMSocketUtils.h"

@implementation VideoHeader

- (instancetype)init {
    if (self = [super init]) {
        self.nWidth = 0;
        self.nHeight = 0;
        self.nFrameRate = 0.0;
        self.nColorSpace = 0;
        self.nRecordMode = 0;
        self.nQuality = 0;
        self.nBitrate = 0;
        self.nQop = 0;
        self.cardName = [[NSData alloc] init];
    }
    return self;
}

/*** 转化数据 ***/
+ (VideoHeader *)getObject:(NSData *)buff len:(int)len {
    VideoHeader *header = [[VideoHeader alloc] init];
    header.nWidth = (int)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(0, 4)]];
    header.nHeight = (int)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(4, 4)]];
    header.nFrameRate = [[NSString convertHexStrToString:[YMSocketUtils hexStringFromData:[buff subdataWithRange:NSMakeRange(8, 8)]]] doubleValue];
    header.nColorSpace = (int)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(16, 4)]];
    header.nRecordMode = (int)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(20, 4)]];
    header.nQuality = (int)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(24, 4)]];
    header.nBitrate = (int)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(28, 4)]];
    header.nQop = (int)[YMSocketUtils valueFromBytes:[buff subdataWithRange:NSMakeRange(32, 4)]];
    header.cardName = [buff subdataWithRange:NSMakeRange(0, 36)];
    return header;
}






@end
