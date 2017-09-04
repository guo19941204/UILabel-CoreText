//
//  UIButton+countDown.h
//  countdown
//
//  Created by WooY on 16/1/12.
//  Copyright © 2016年 WooY. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 验证码点击之后的按钮效果
 */
@interface UIButton (countDown)
- (void)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color;
@end
