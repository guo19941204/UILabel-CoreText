//
//  GroupHeadView.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/14.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "GroupHeadView.h"
#import "Contains.h"
#import "sectionModel.h"

@interface GroupHeadView () {
    
}

@end
@implementation GroupHeadView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier andFrame:(CGRect)frame {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.openAction = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.openAction setBackgroundImage:[UIImage qmui_imageWithColor:RGBA(91, 161, 217, 1)] forState:UIControlStateSelected];
        [self.openAction setBackgroundImage:[UIImage qmui_imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
        self.openAction.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.openAction addTarget:self action:@selector(handleSectionOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.openAction];
        self.textLab = [[UILabel alloc] init];
        self.textLab.frame = CGRectMake(15, 0, frame.size.width-15, frame.size.height);
        self.textLab.textColor = [UIColor whiteColor];
        self.textLab.textAlignment = NSTextAlignmentLeft;
        self.textLabel.font = [UIFont systemFontOfSize:19];
        [self.contentView addSubview:self.textLab];
        self.seperator = [[UIView alloc] initWithFrame:CGRectMake(20, frame.size.height-2, frame.size.width-40, 2)];
        [self.contentView addSubview:self.seperator];
    }
    return self;
}

- (void)handleSectionOpen:(UIButton *)button {
    self.model.isExpanded = !self.model.isExpanded;
    if (self.callBackOpenStatus) {
        self.callBackOpenStatus(self.model.isExpanded);
    }
}

- (void)setModel:(sectionModel *)model {
    if (_model != model) {
        _model = model;
    }
}




@end
