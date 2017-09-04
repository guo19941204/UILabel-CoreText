//
//  UILabel+CoreText.m
//  Lable+Categary
//
//  Created by 郭炜 on 2017/5/24.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "UILabel+CoreText.h"
#import <objc/runtime.h>
#import <CoreText/CoreText.h>

static char characterSpaceKey;
static char lineSpaceKey;
static char keywordStrKey;
static char keywordFontKey;
static char keywordColorKey;
static char underLineKey;
static char underLineColorKey;
static char ItalicStrKey;
static char ItalicFontKey;
static char ItalicColorKey;
static char ItalicDegreeKey;

@implementation UILabel (CoreText)

- (CGRect)getLableHeightWithMaxWidth:(CGFloat)maxWidth {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, self.text.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    /*** 字间距 ***/
    if (self.characterSpace) {
        long space = self.characterSpace;
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &space);
        [attributedString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, [attributedString length])];
    }
    
    /*** 行间距 ***/
    if (self.lineSpace) {
        [paragraphStyle setLineSpacing:self.lineSpace];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    }
    
    /*** 关键字 ***/
    if (self.keywordStr) {
        NSRange keywordRange = [self.text rangeOfString:self.keywordStr];
        if (keywordRange.length > 0) {
            if (self.keywordFont) {
                [attributedString addAttribute:NSFontAttributeName value:self.keywordFont range:keywordRange];
            }
            
            if (self.keywordColor) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:self.keywordColor range:keywordRange];
            }
        }
    }
    
    /*** 下划线 ***/
    if (self.underLineStr) {
        NSRange underLineRange = [self.text rangeOfString:self.underLineStr];
        if (underLineRange.length > 0) {
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:underLineRange];
            if (self.underLineColor) {
                [attributedString addAttribute:NSUnderlineColorAttributeName value:self.underLineColor range:underLineRange];
            }
        }
    }
    
    /*** 斜体 ***/
    if (self.ItalicStr) {
        NSRange italicStrRange = [self.text rangeOfString:self.ItalicStr];
        if (italicStrRange.length > 0) {
            CGFloat degree = self.ItalicDegree?self.ItalicDegree:14;
            if (self.ItalicFont) {
                CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(degree * (CGFloat)M_PI / 180), 1, 0, 0);
                CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.ItalicFont.fontName, 14, &matrix);
                [attributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id)(fontRef) range:italicStrRange];
            }else {
                CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(degree * (CGFloat)M_PI / 180), 1, 0, 0);
                CTFontRef fontRef = CTFontCreateWithName((CFStringRef)[UIFont italicSystemFontOfSize:20].fontName, 14, &matrix);
                [attributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id _Nonnull)(fontRef) range:italicStrRange];
            }
            if (self.ItalicColor) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:self.ItalicColor range:italicStrRange];
            }
        }
    }
    
    self.attributedText = attributedString;
    
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    return rect;
}


#pragma mark -- setter&getter --
- (void)setCharacterSpace:(CGFloat)characterSpace {
    objc_setAssociatedObject(self, &characterSpaceKey, @(characterSpace), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)characterSpace {
    return [objc_getAssociatedObject(self, &characterSpaceKey) floatValue];
}

- (void)setLineSpace:(CGFloat)lineSpace {
    objc_setAssociatedObject(self, &lineSpaceKey, @(lineSpace), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)lineSpace {
    return [objc_getAssociatedObject(self, &lineSpaceKey) floatValue];
}

- (void)setKeywordStr:(NSString *)keywordStr {
    objc_setAssociatedObject(self, &keywordStrKey, keywordStr, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)keywordStr {
    return objc_getAssociatedObject(self, &keywordStrKey);
}

- (void)setKeywordFont:(UIFont *)keywordFont {
    objc_setAssociatedObject(self, &keywordFontKey, keywordFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)keywordFont {
    return objc_getAssociatedObject(self, &keywordFontKey);
}

- (void)setKeywordColor:(UIColor *)keywordColor {
    objc_setAssociatedObject(self, &keywordColorKey, keywordColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)keywordColor {
    return objc_getAssociatedObject(self, &keywordColorKey);
}
- (void)setUnderLineStr:(NSString *)underLineStr {
    objc_setAssociatedObject(self, &underLineKey, underLineStr, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)underLineStr {
    return  objc_getAssociatedObject(self, &underLineKey);
}

- (void)setUnderLineColor:(UIColor *)underLineColor {
    objc_setAssociatedObject(self, &underLineColorKey, underLineColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)underLineColor {
    return objc_getAssociatedObject(self, &underLineColorKey);
}

- (void)setItalicStr:(NSString *)ItalicStr {
    objc_setAssociatedObject(self, &ItalicStrKey, ItalicStr, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)ItalicStr {
    return objc_getAssociatedObject(self, &ItalicStrKey);
}

- (void)setItalicFont:(UIFont *)ItalicFont {
    objc_setAssociatedObject(self, &ItalicFontKey, ItalicFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)ItalicFont {
    return objc_getAssociatedObject(self, &ItalicFontKey);
}

- (void)setItalicColor:(UIColor *)ItalicColor {
    objc_setAssociatedObject(self, &ItalicColorKey, ItalicColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)ItalicColor {
    return objc_getAssociatedObject(self, &ItalicColorKey);
}

- (void)setItalicDegree:(CGFloat)ItalicDegree {
    objc_setAssociatedObject(self, &ItalicDegreeKey, @(ItalicDegree), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)ItalicDegree {
    return [objc_getAssociatedObject(self, &ItalicDegreeKey) floatValue];
}
@end
