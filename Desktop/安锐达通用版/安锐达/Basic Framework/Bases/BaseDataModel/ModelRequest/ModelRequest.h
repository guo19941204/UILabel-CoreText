//
//  ModelRequest.h
//  GWFramework
//
//  Created by 郭炜 on 2017/5/31.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "BaseRequest.h"

@interface ModelRequest : BaseRequest
/**接口需要传的参数*/
@property (nonatomic, strong) NSDictionary *param;
/*** 请求路径 */
@property (nonatomic, copy) NSString *url;

@end
