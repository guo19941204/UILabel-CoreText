//
//  BaseEntity.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/9.
//  Copyright © 2017年 郭炜. All rights reserved.
//

/*** 非自动绑定 数据模型基类 ***/
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface BaseEntity : NSObject

//接收数据使用
- (id)initWithDictionary:(NSDictionary*)jsonDic;

//归档专用
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
