//
//  NSString+JsonKind.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/8.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "NSString+JsonKind.h"

@implementation NSString (JsonKind)

- (NSDictionary *)dictionaryWithJsonString {
    
    if (self == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}
@end
