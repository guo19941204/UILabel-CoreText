//
//  GroupHeadView.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/14.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@class sectionModel;
@interface GroupHeadView : UITableViewHeaderFooterView
@property (nonatomic, strong) UIButton *openAction;
@property (nonatomic, strong) UILabel *textLab;
@property (nonatomic, strong) sectionModel *model;
@property (nonatomic, strong) UIView *seperator;
/*** 点击回调 */
@property (nonatomic, copy)void (^callBackOpenStatus)(BOOL isOpen);

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier andFrame:(CGRect)frame;
@end
