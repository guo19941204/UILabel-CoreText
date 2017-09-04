//
//  RecivedEntity.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/9.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "RecivedEntity.h"
#import "Contains.h"
static int dataLen = 1543;
@implementation RecivedEntity

- (instancetype)init {
    if (self = [super init]) {
        _count = 0;
        _packHead = [[PackHead alloc] init];
        _list = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSMutableData *)getData {
    self.data = [[NSMutableData alloc] initWithLength:0];
    for (int i = 0; i < _count; i ++) {
        ///<??>暂时确定接收到的数据小包的ID顺序是从0开始到包的总数量
        @try {
            self.key = [NSString stringWithFormat:@"%d",i];
            if ([_list objectForKey:self.key]) {
                [self.data appendData:[_list objectForKey:self.key]];
            }
        } @catch (NSException *exception) {
            
        }
    }
    return self.data;
}

@end
