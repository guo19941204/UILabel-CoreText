//
//  DesModel.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/14.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "JSONModel.h"

@interface DesModel : JSONModel

/*** description */
@property (nonatomic, copy) NSString *description;
/*** groupId */
@property (nonatomic, assign) NSInteger groupId;
/*** kindName */
@property (nonatomic, copy) NSString *kindName;
/*** showInHomepage */
@property (nonatomic, assign) NSInteger showInHomepage;
/*** title */
@property (nonatomic, copy) NSString *title;
/*** uId */
@property (nonatomic, assign) NSInteger uId;


@end
