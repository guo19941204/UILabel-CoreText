//
//  WebLoginEntity.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/9.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "WebLoginEntity.h"

@implementation WebLoginEntity

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:[NSString stringWithFormat:@"%@",value] forKey:key];
}

@end

@implementation DataEntity

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:[NSString stringWithFormat:@"%@",value] forKey:key];
}

@end

