//
//  OnLine.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/19.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnLine : NSObject

/*** 通话组列表 */
@property (nonatomic, strong) NSMutableArray *inStructList;
/*** roomId */
@property (nonatomic, assign) int roomId;
+ (OnLine *)sharedObject;
/*** 退出通话组 ***/
- (int)exitInList;
/*** 更新通话组 ***/
- (void)setInList:(NSMutableArray *)list;
/*** 找用户 ***/
- (BOOL)findUser:(int)Id;
@end

/**
 * 用户状态：0初始状态，1在线，2在通话组，3增加，4减少
 */
@class UserInfo;
@interface UserStruct : NSObject

/*** sign */
@property (nonatomic, assign) int sign;
@property (nonatomic, strong) UserInfo *info;
@end
