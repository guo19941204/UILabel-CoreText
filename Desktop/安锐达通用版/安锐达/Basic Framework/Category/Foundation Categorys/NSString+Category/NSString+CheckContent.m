//
//  NSString+CheckContent.m
//  WestCar
//
//  Created by 郭炜 on 2017/1/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "NSString+CheckContent.h"

@implementation NSString (CheckContent)

- (BOOL)validateCarNo
{
    NSString *carRegex =@"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    if ([carTest evaluateWithObject:self]) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isHaveSpaceInString{
    NSRange _range = [self rangeOfString:@" "];
    if (_range.location != NSNotFound) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)IsHaveStringInSuperString:(NSString *)superString {
    NSRange _range = [superString rangeOfString:self];
    if (_range.location != NSNotFound) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)isHaveChineseInString {
    for(NSInteger i = 0; i < [self length]; i++){
        int a = [self characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isAllNum {
    unichar c;
    for (int i=0; i<self.length; i++) {
        c=[self characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isCarVinNo {
    NSInteger length = self.length;
    if (length == 17) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL) validateMobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^1[3|4|5|7|8][0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

- (BOOL) validateIdentityCard {
    if (self.length <= 0) {
        return NO;
    }
    NSString *identityRegex = @"^(\\d{14}|\\d{17}|\\d{9})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",identityRegex];
    return [identityCardPredicate evaluateWithObject:self];
}

- (NSString *)firstCharactor
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:self];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

//身份证号
- (BOOL)CheckIsIdentityCard
{
    NSString *identityCard = self;
    //判断是否为空
    if (identityCard==nil||identityCard.length <= 0) {
        return NO;
    }
    //判断是否是18位，末尾是否是x
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    if(![identityCardPredicate evaluateWithObject:identityCard]){
        return NO;
    }
    //判断生日是否合法
    NSRange range = NSMakeRange(6,8);
    NSString *datestr = [identityCard substringWithRange:range];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat : @"yyyyMMdd"];
    if([formatter dateFromString:datestr]==nil){
        return NO;
    }
    
    //判断校验位
    if(identityCard.length==18)
    {
        NSArray *idCardWi= @[ @"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2" ]; //将前17位加权因子保存在数组里
        NSArray * idCardY=@[ @"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2" ]; //这是除以11后，可能产生的11位余数、验证码，也保存成数组
        int idCardWiSum=0; //用来保存前17位各自乖以加权因子后的总和
        for(int i=0;i<17;i++){
            idCardWiSum+=[[identityCard substringWithRange:NSMakeRange(i,1)] intValue]*[idCardWi[i] intValue];
        }
        
        int idCardMod=idCardWiSum%11;//计算出校验码所在数组的位置
        NSString *idCardLast=[identityCard substringWithRange:NSMakeRange(17,1)];//得到最后一位身份证号码
        
        //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
        if(idCardMod==2){
            if([idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"]){
                return YES;
            }else{
                return NO;
            }
        }else{
            //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
            if([idCardLast intValue]==[idCardY[idCardMod] intValue]){
                return YES;
            }else{
                return NO;
            }
        }
    }
    return NO;
}

@end
