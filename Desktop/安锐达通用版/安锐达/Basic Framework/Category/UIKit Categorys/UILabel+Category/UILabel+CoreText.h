//
//  UILabel+CoreText.h
//  Lable+Categary
//
//  Created by 郭炜 on 2017/5/24.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CoreText)

/*** 字间距 ***/
@property (nonatomic, assign) CGFloat characterSpace;

/*** 行间距 ***/
@property (nonatomic, assign) CGFloat lineSpace;

/**
 *  关键字
 *
 *   keywordStr   需设置富文本的字
 *   keywordFont   富文本字体大小
 *   keywordColor   富文本字颜色
 */
@property (nonatomic, copy) NSString *keywordStr;
@property (nonatomic, strong) UIFont *keywordFont;
@property (nonatomic, strong) UIColor *keywordColor;

/**
 *  下划线
 *
 *   underLineStr   需设置下划线的字
 *   underLineColor   下划线颜色
 */
@property (nonatomic, copy) NSString *underLineStr;
@property (nonatomic, strong) UIColor *underLineColor;

/**
 *  斜体字
 *
 *   ItalicStr   需设置斜体的字
 *   ItalicFont   斜体字的字体大小
 *   ItalicColor   斜体字颜色
 *   ItalicDegree   斜体度数
 */
@property (nonatomic, copy) NSString *ItalicStr;
@property (nonatomic, strong) UIFont *ItalicFont;
@property (nonatomic, strong) UIColor *ItalicColor;
@property (nonatomic, assign) CGFloat ItalicDegree;

/**
 *  计算label宽高，必须调用
 *
 *  @param maxWidth 最大宽度
 *
 *  @return label的rect
 */
- (CGRect)getLableHeightWithMaxWidth:(CGFloat)maxWidth;
@end
