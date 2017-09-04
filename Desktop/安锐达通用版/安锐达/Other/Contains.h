//
//  Contains.h
//  GWFramework
//
//  Created by 郭炜 on 2017/5/31.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#ifndef Contains_h
#define Contains_h
#if __has_include(<UIKit/UIKit.h>)

#else
#import <UIKit/UIKit.h>
#endif

#if __has_include(<Foundation/Foundation.h>)

#else
#import <Foundation/Foundation.h>
#endif

/**
 *  ************** 所有接口 **************
 */
#import "LibraryAPI.h"

/**
 *  *****************工具类相关*****************
 */
#import "CommonMacro.h"
#import "UIView+Extensions.h"
#import "NSString+AES.h"
#import "NSString+JsonKind.h"
#import "SocketServe.h"
#import "NSDictionary+JsonKind.h"
#import "Util.h"
#import "NSData+Utf8.h"
#import "ExchangeSocketServe.h"
#import "NSData+HexData.h"
#import "NSString+HexString.h"
#import "GCDExchangeSocketServe.h"
/**
 *  *****************UI框架*****************
 */
#import "QMUIKit.h"

/**
 *  *****************SDWEB*****************
 */
#import "UIImageView+WebCache.h"

/**
 *  *****************MJRefresh*****************
 */
#import "MJRefresh.h"

/**
 *  *****************toast*****************
 */
#import "SVProgressHUD.h"


/**
 *  *****************AsySocket*****************
 */
#import "AsyncSocket.h"
#import "SendMessage.h"
// core
#import "JSONModel.h"
#import "JSONModelError.h"

#define AESKEY @"cnambition123456"

#define gwdispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define gwdispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WEAK(var)   __weak typeof(var) weakSelf = var
#define STRONG(var) __strong typeof(var) strongSelf = var

#endif /* Contains_h */
