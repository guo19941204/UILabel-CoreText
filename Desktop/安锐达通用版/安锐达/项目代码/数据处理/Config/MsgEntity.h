//
//  MsgEntity.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/8.
//  Copyright © 2017年 郭炜. All rights reserved.
//

/*** 分包 ***/
#import <Foundation/Foundation.h>

@interface MsgEntity : NSObject

+ (NSMutableArray<NSMutableData *> *)getPackArrayWithMessage:(NSMutableData *)data proNum:(int)proNum len:(int)len;

@end
