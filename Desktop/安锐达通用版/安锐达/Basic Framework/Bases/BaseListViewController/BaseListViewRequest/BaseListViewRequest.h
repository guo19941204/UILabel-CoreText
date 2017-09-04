//
//  BaseListViewRequest.h
//  GWFramework
//
//  Created by 郭炜 on 2017/6/1.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "BaseRequest.h"

@interface BaseListViewRequest : BaseRequest

/*** 请求地址 */
@property (nonatomic, copy) NSString *url;
/*** 请求参数 */
@property (nonatomic, strong) NSDictionary *param;


@end
