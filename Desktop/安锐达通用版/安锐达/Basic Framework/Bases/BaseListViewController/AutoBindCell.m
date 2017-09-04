//
//  AutoBindCell.m
//  GWFramework
//
//  Created by 郭炜 on 2017/6/1.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "AutoBindCell.h"
#import "BaseDataModel.h"
#import "Contains.h"
#import <objc/message.h>

@implementation AutoBindCell
/*** 获取子类cell中的所有属性列表 ***/
static NSMutableDictionary *allProperties;

- (NSMutableArray *)properties {
    if (!allProperties) {
        allProperties = [NSMutableDictionary new];
    }
    NSString *className = [NSString stringWithFormat:@"%@",self.class];
    NSMutableArray *_properties = allProperties[className];
    if (!_properties) {
        u_int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        _properties = [[NSMutableArray alloc] initWithCapacity:count];
        for (int i = 0; i < count; i ++) {
            objc_property_t property = properties[i];
            NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            id value = [self valueForKey:key];
            if (value) {
                [_properties addObject:key];
            }
        }
        free(properties);
        allProperties[className] = _properties;
    }
    return _properties;
}

/*** 可重写  如果需要添加新的控件  则在else下继续添加 ***/
- (void)handleDataWithModel:(BaseDataModel *)data {
    id value;
    NSMutableArray *_properties = [self properties];
    for (NSString *key in _properties) {
        UIView *control = [self valueForKey:key];
        @try {
            value = [data valueForKey:key];
        } @catch (NSException *exception) {
            value = [data getValueWithKey:key];
        }
        if (!value) continue;
        value = [NSString stringWithFormat:@"%@",value];
        if ([control isKindOfClass:[UIButton class]]) {
            [((UIButton *)control) setTitle:value forState:UIControlStateNormal];
        }else if ([control isKindOfClass:[UILabel class]]) {
            ((UILabel *)control).text = value;
        }else if ([control isKindOfClass:[UITextField class]]) {
            ((UITextField *)control).text = value;
        }else if ([control isKindOfClass:[UITextView class]]) {
            ((UITextView *)control).text = value;
        }else if ([control isKindOfClass:[UIImageView class]]) {
            NSURL *url;
            NSString *urlString;
            if ([(NSString *)value rangeOfString:@"http"].location != NSNotFound) {
                urlString = (NSString *)value;
                url = [NSURL URLWithString:urlString];
            }else {
                urlString = (NSString *)value;
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",API_HOST,urlString]];
            }
            [((UIImageView *)control) sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"默认图"] options:SDWebImageProgressiveDownload];
        }
    }
    [self layoutSubviews];
}

/*** 设置cell关联的data数据模型  必须要设置data才能实现自动绑定 ***/
- (void)setData:(BaseDataModel *)Data {
    if (_Data == Data) return;
    if (_Data) {
        [_Data removeDataChangedListener:self];
    }
    _Data = Data;
    if (_Data) {
        [_Data addDataChangedListener:self];
    }
}

/*** 从重用池中取出cell时，保证cell上的数据是空的，防止错乱 ***/
- (void)prepareForReuse {
    [super prepareForReuse];
    self.Data = nil;
}

- (void)dealloc {
    if (_Data) {
        [_Data removeDataChangedListener:self];
    }
}



@end
