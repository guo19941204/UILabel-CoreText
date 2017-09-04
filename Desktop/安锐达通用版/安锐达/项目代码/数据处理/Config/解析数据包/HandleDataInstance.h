//
//  HandleDataInstance.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/20.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandleDataInstance : NSObject

/*** 全局的dic  tag作为key，包长作为value */
@property (nonatomic, strong) NSMutableDictionary *handleDataDic;
/*** tag */
@property (nonatomic, assign) long tag;

+ (instancetype)sharedObject;
@end
