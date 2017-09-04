//
//  GroupModel.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/13.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "JSONModel.h"

@interface GroupModel : JSONModel

/*** fGroupId */
@property (nonatomic, assign) NSInteger fGroupId;
/*** groupId */
@property (nonatomic, assign) NSInteger groupId;
/*** groupName */
@property (nonatomic, copy) NSString *groupName;

@end
