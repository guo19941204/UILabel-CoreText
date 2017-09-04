//
//  UserInfo.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/16.
//  Copyright © 2017年 郭炜. All rights reserved.
//

//    `u_id` int(10) NOT NULL COMMENT '用户ID',
//    `title` varchar(255) NOT NULL COMMENT '用户中文名',
//    `description` varchar(255) NOT NULL COMMENT '用户描述',
//    `email` varchar(255) DEFAULT NULL COMMENT '邮箱',
//     show_in_homepage 字段，默认值为0，当值为1时，表示该会员信息用于首页展示，展示信息取自新增表 user_homepage_info（具体字段待定）
//    `gmt_create` datetime DEFAULT NULL COMMENT '创建时间',
//    `gmt_modified` datetime DEFAULT NULL COMMENT '修改时间',
#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
@property (nonatomic, copy) NSString *kindName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, assign) uint32_t uId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) uint32_t showInHomepage;
@property (nonatomic, strong) NSDate *gmtCreate;
@property (nonatomic, strong) NSDate *gmtModified;
@property (nonatomic, assign) uint32_t groupId;

@end
