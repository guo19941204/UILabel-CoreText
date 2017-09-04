//
//  WebLoginEntity.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/9.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "BaseEntity.h"

@class DataEntity,LoadModuleEntity;
@interface WebLoginEntity : BaseEntity

/*** data */
@property (nonatomic, strong) DataEntity *data;
/*** loadmodule */
@property (nonatomic, strong) LoadModuleEntity *loadmodule;
/*** monitors */
@property (nonatomic, copy) NSString *monitors;
/*** result */
@property (nonatomic, copy) NSString *result;


@end

@interface DataEntity : BaseEntity
/*** description */
@property (nonatomic, copy) NSString *description;
/*** showInHomepage */
@property (nonatomic, copy) NSString *showInHomepage;
/*** title */
@property (nonatomic, copy) NSString *title;
/*** uId */
@property (nonatomic, strong) NSString *uId;

@end

@interface LoadModuleEntity : BaseEntity

/*** kindId */
@property (nonatomic, copy) NSString *kindId;
/*** kindName */
@property (nonatomic, copy) NSString *kindName;

@end
