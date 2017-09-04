//
//  Util.m
//  chongqingzhiye
//
//  Created by crly on 15/10/14.
//  Copyright © 2015年 sevnce. All rights reserved.
//

#import "Util.h"


@interface Util ()

@end
@implementation Util

+ (NSString *)getString:(id)Data
{
    NSString *str;
    if (Data == nil || [Data isEqual:NULL]) {
        str = @"";
    }else{
        if ([Data isKindOfClass:[NSNumber class]]) {
            str = [self decimalNumberWithDouble:[Data doubleValue]];
        }else{
            str = [NSString stringWithFormat:@"%@", Data];
        }
        
        
    }
    return str;
}

+(NSString *)decimalNumberWithDouble:(double )conversionValue{
    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}
@end
