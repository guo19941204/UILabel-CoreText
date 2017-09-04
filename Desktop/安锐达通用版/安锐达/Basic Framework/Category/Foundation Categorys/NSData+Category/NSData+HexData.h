//
//  NSData+HexData.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/15.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexData)
/*** 将十六进制字符串转换成NSData ***/
- (NSData *)convertHexStrToData:(NSString *)str;
/*** 将NSData转换成十六进制的字符串 ***/
- (NSString *)convertDataToHexStr:(NSData *)data;
@end
