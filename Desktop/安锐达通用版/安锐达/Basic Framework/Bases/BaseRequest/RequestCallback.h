//
//  RequestCallback.h
//  GWFramework
//
//  Created by 郭炜 on 2017/5/31.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseRequest;

@protocol AFMultipartFormData;

typedef void(^AFConstructingBodyBlock)(id<AFMultipartFormData> data);
typedef void(^AFURLSessionTaskProgressBlock)(NSProgress *progress);


/*!
 *   AFN 请求封装的Block回调
 */
typedef void(^GWRequestSuccessBlock)(NSInteger errCode, NSDictionary *responseDict, id model);
typedef void(^GWRequestFailureBlock)(NSError *error);


/*!
 *   AFN 请求封装的代理回调
 */
@protocol GWBaseRequestDelegate <NSObject>

@optional
/**
 *   请求结束
 *   @param returnData 返回的数据
 */
- (void)requestDidFinishLoadingWithData:(id)returnData errCode:(NSInteger)errCode;

/**
 *   请求失败
 *   @param error 失败的 error
 */
- (void)requestDidFailWithError:(NSError *)error;

/**
 *   网络请求项即将被移除掉
 *   @param item 网络请求项
 */
- (void)requestWillDealloc:(BaseRequest *)item;
@end

