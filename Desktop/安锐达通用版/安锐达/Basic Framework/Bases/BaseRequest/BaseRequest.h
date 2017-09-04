//
//  BaseRequest.h
//  GWFramework
//
//  Created by 郭炜 on 2017/5/31.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestCallback.h"

extern NSString * const GWNetworkDomain; ///< 请求网络域名,即你后台服务器的域名

///< HTTP Request method.
typedef NS_ENUM(NSInteger, GWRequestMethod) {
    GWRequestMethodGET = 0,
    GWRequestMethodPOST
};

///< Request serializer type.
typedef NS_ENUM(NSInteger, GWRequestSerializerType) {
    GWRequestSerializerTypeHTTP = 0,
    GWRequestSerializerTypeJSON
};

///< Response serializer type, which determines response serialization process and
///  the type of `responseObject`.
typedef NS_ENUM(NSInteger, GWResponseSerializerType) {
    GWResponseSerializerTypeHTTP = 0, ///< NSData
    GWResponseSerializerTypeJSON, ///< JSON
    GWResponseSerializerTypeXMLParser ///< NSXMLParser
};

@interface BaseRequest : NSObject

@property (nonatomic, assign) BOOL showHUD;

@property (nonatomic, weak) id<GWBaseRequestDelegate> delegate;

@property (nonatomic, copy) AFConstructingBodyBlock constructingBodyBlock;
@property (nonatomic, copy) AFURLSessionTaskProgressBlock resumableDownloadProgressBlock;
@property (nonatomic, copy) AFURLSessionTaskProgressBlock uploadProgress;

@property (nonatomic, copy) GWRequestSuccessBlock successBlock;
@property (nonatomic, copy) GWRequestFailureBlock failureBlock;

- (instancetype)initWithSuccessBlock:(GWRequestSuccessBlock)successBlock
                        failureBlock:(GWRequestFailureBlock)failureBlock;
+ (instancetype)requestWithSuccessBlock:(GWRequestSuccessBlock)successBlock
                           failureBlock:(GWRequestFailureBlock)failureBlock;

- (void)startCompletionBlockWithSuccess:(GWRequestSuccessBlock)success
                                failure:(GWRequestFailureBlock)failure;

/**
 带进度的图片上传
 
 @param success 成功回调
 @param failure 失败回调
 @param uploadProgress 进度回调
 */
- (void)startUploadTaskWithSuccess:(GWRequestSuccessBlock)success
                           failure:(GWRequestFailureBlock)failure
                    uploadProgress:(AFURLSessionTaskProgressBlock)uploadProgress;

/**
 * @brief 公共方法，开始请求，不管是使用 block 回调还是 delegate 回调，都要调用此方法
 */
- (void)startRequest;

/**
 * @brief 请求参数，即URL入参
 *
 * @warning 必须重写
 */
- (NSDictionary *)requestArguments;

/**
 * @brief 请求URL路径
 *
 * @warning 必须重写
 */
- (NSString *)requestURLPath;

/**
 * @brief 请求方式 GET or POST
 *
 * @warning 按需重写
 */
- (GWRequestMethod)requestMethod; ///< 默认 GET 请求

/**
 * @brief 请求序列类型
 *
 * @warning 按需重写
 */
- (GWRequestSerializerType)requestSerializerType;

/**
 * @brief 响应序列类型
 *
 * @warning 按需重写
 */
- (GWResponseSerializerType)responseSerializerType;

/**
 * @brief 设置请求头
 *
 * @warning 按需重写
 */
- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary; ///< Additional HTTP request header field. HTTP 请求头配置，按需重写

/**
 * 处理请求返回的数据
 *
 * @param data 需要的数据
 * @param resCode 后台返回的错误码（代表各种情况）
 */
- (void)handleData:(id)data errCode:(NSInteger)resCode;
@end
