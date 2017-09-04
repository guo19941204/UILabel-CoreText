//
//  ModelRequest.m
//  GWFramework
//
//  Created by 郭炜 on 2017/5/31.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "ModelRequest.h"

@implementation ModelRequest

- (GWRequestMethod)requestMethod {
    return GWRequestMethodPOST;
}

- (NSString *)requestURLPath {
    return self.url;
}

- (NSDictionary *)requestArguments {
    return self.param;
}

///< 配置请求头，根据需求决定是否重写
- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return nil;
}

- (void)handleData:(id)data errCode:(NSInteger)errCode {
    NSDictionary *dict = (NSDictionary *)data;
    
    if (errCode == 0) {
        
        ///< 方式1：block 回调
        if (self.successBlock) {
            self.successBlock(errCode, dict, nil);
        }
        
        ///< 方式2：代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFinishLoadingWithData:errCode:)]) {
            [self.delegate requestDidFinishLoadingWithData:dict errCode:errCode];
        }
    }
    else {
        ///< block 回调
        if (self.successBlock) {
            self.successBlock(errCode, dict, nil);
        }
        
        ///< 代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFinishLoadingWithData:errCode:)]) {
            [self.delegate requestDidFinishLoadingWithData:data errCode:errCode];
        }
    }
}


@end
