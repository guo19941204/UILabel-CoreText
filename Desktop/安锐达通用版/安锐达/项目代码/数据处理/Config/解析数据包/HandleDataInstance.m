//
//  HandleDataInstance.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/20.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "HandleDataInstance.h"

@implementation HandleDataInstance

+ (instancetype)sharedObject {
    static HandleDataInstance *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[HandleDataInstance alloc] init];
        _sharedInstance.handleDataDic = [[NSMutableDictionary alloc] init];
    });
    return _sharedInstance;
}

@end
