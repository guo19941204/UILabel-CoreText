//
//  OnLine.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/19.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "OnLine.h"
#import "UserInfo.h"
#import "Contains.h"


@implementation OnLine

+ (OnLine *)sharedObject {
    static OnLine *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (NSMutableArray *)newInList {
    if (_inStructList != nil) {
        return nil;
    }else {
        _inStructList = [[NSMutableArray alloc] init];
    }
    return _inStructList;
}


/**
 * 退出通话组
 * 失败返回0
 * 成功返回1
 * 没有通话组返回-1
 */
- (int)exitInList {
    if (self.inStructList == nil) {
        return  -1;
    }
    if (self.inStructList) {
        self.inStructList = nil;
    }
    return 1;
}

- (void)setInList:(NSMutableArray *)list {
    //没有通话组
    if (self.inStructList == nil) {
        [self newInList];
    }
    
    [self removeUser];
    if (self.inStructList.count == 0) {
        for (int i = 0; i < list.count; i ++) {
            UserStruct *user = [[UserStruct alloc] init];//新增用户
#warning list类型
            NSString *Id = [NSString stringWithFormat:@"%@",list[i]];
            user.info.uId = (uint32_t)[Id intValue];
            user.sign = 3;
            [self.inStructList addObject:user];
        }
    }else if (self.inStructList.count > 0) {
        for (int i = 0; i < list.count; i ++) {
            for (int j = 0; j < self.inStructList.count; j ++) {
                UserStruct *user1 = self.inStructList[j];
                
                if (user1.info.uId == (uint32_t)[list[i] intValue]) {
                    user1.sign = 2;
                    [self.inStructList replaceObjectAtIndex:j withObject:user1];
                    break;
                }else if (j == self.inStructList.count -1) {
                    //新增用户
                    UserStruct *user = [[UserStruct alloc] init];
                    user.info.uId = (uint32_t)[list[i] intValue];
                    user.sign = 3;
                    [self.inStructList addObject:user];
                }
            }
        }
        for (int m = 0; m < self.inStructList.count; m ++) {
            for (int n = 0; n < self.inStructList.count; n ++) {
                UserStruct *mUser = self.inStructList[m];
                if (mUser.info.uId != (uint32_t)[list[n] intValue] && mUser.sign != 4) {
                    mUser.sign = 4;
                    [self.inStructList replaceObjectAtIndex:m withObject:mUser]; //标记退出
                }
            }
        }
    }
}

//初始化通话组
- (int)removeUser {
    if (self.inStructList == nil) {
        return -1;
    }
    for (int i = 0; i < self.inStructList.count; i ++) {
        UserStruct *mUser = self.inStructList[i];
        if (mUser.sign == 4) {
            [self.inStructList removeObjectAtIndex:i];
        }else {
            mUser.sign = 2;
            [self.inStructList replaceObjectAtIndex:i withObject:mUser];
        }
    }
    return 0;
}

- (BOOL)findUser:(int)Id {
    if (self.inStructList == nil || self.inStructList.count == 0) {
        return NO;
    }
    for (int i = 0; i < self.inStructList.count; i ++) {
        UserStruct *mUser = self.inStructList[i];
        if (Id == mUser.info.uId) {
            return YES;
        }
    }
    return NO;
}


@end

@implementation UserStruct
- (instancetype)init {
    if (self = [super init]) {
        self.info = [[UserInfo alloc] init];
    }
    return self;
}


@end
