//
//  NSString+CheckContent.h
//  WestCar
//
//  Created by 郭炜 on 2017/1/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CheckContent)

//是否全为数字
- (BOOL)isAllNum;
//是否包含汉字
- (BOOL)isHaveChineseInString;
//在superstring中是否包含次字符串
- (BOOL)IsHaveStringInSuperString:(NSString *)superString;
//是否含有空格
- (BOOL)isHaveSpaceInString;
//是否为车牌号
- (BOOL)validateCarNo;
//是否为车辆VIN
- (BOOL)isCarVinNo;
//判断电话
- (BOOL) validateMobile;
//判断身份证
- (BOOL) validateIdentityCard;
//身份证号
- (BOOL)CheckIsIdentityCard;
//汉字转换拼音 返回首字母大写
- (NSString *)firstCharactor;
@end
