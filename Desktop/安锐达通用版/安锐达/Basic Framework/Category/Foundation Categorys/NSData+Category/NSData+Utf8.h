//
//  NSData+Utf8.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Utf8)
+ (NSData *)replaceNoUtf8:(NSData *)data;
@end
