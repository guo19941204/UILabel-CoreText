//
//  NSString+HexString.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/15.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HexString)
/*** 十六进制的字符串转换成NSString ***/
+ (NSString *)convertHexStrToString:(NSString *)str;
/*** 将NSString转换成十六进制的字符串 ***/
+ (NSString *)convertStringToHexStr:(NSString *)str;
@end
