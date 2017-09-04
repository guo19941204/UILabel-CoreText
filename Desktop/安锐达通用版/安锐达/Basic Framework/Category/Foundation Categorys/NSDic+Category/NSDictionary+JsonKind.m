//
//  NSDictionary+JsonKind.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/8.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#define AESKEY @"cnambition123456"
#import "NSDictionary+JsonKind.h"
#import "NSString+AES.h"


@implementation NSDictionary (JsonKind)

- (NSString *)jsonStringWithSelf {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *string2 = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *postString = [NSString encryptAES:string2 key:AESKEY];
    return postString;
}
@end
