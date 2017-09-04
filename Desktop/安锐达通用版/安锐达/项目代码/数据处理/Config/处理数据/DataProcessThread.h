//
//  DataProcessThread.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RecivedEntity,QMUIAlertController;
@interface DataProcessThread : NSObject
+ (instancetype)sharedObject;
- (void)dealWithInstruction:(RecivedEntity *)entity;
@end
