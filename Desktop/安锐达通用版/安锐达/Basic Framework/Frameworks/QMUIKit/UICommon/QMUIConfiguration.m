//
//  QMUIConfiguration.m
//  qmui
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIConfiguration.h"
#import "QMUICommonDefines.h"
#import "QMUIConfigurationMacros.h"
#import "UIImage+QMUI.h"
#import "QMUIButton.h"
#import "QMUITabBarViewController.h"

@implementation QMUIConfiguration

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static QMUIConfiguration *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[QMUIConfiguration alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDefaultConfiguration];
    }
    return self;
}

#pragma mark - 初始化默认值

- (void)initDefaultConfiguration {
    
    #pragma mark - Global Color
    
    self.clearColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    self.whiteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.blackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.grayColor = UIColorMake(179, 179, 179);
    self.grayDarkenColor = UIColorMake(163, 163, 163);
    self.grayLightenColor = UIColorMake(198, 198, 198);
    self.redColor = UIColorMake(227, 40, 40);
    self.greenColor = UIColorMake(79, 214, 79);
    self.blueColor = UIColorMake(43, 133, 208);
    self.yellowColor = UIColorMake(255, 252, 233);

    self.linkColor = UIColorMake(56, 116, 171);
    self.disabledColor = self.grayColor;
    self.backgroundColor = UIColorMake(246, 246, 246);
    self.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);
    self.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);
    self.separatorColor = UIColorMake(200, 199, 204);
    self.separatorDashedColor = UIColorMake(17, 17, 17);
    self.placeholderColor = UIColorMake(187, 187, 187);
    
    self.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
    self.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
    self.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);
    
    #pragma mark - UIControl
    
    self.controlHighlightedAlpha = 0.5f;
    self.controlDisabledAlpha = 0.5f;
    
    #pragma mark - UIButton
    
    self.buttonHighlightedAlpha = self.controlHighlightedAlpha;
    self.buttonDisabledAlpha = self.controlDisabledAlpha;
    self.buttonTintColor = self.blueColor;
    
    self.ghostButtonColorBlue = self.blueColor;
    self.ghostButtonColorRed = self.redColor;
    self.ghostButtonColorGreen = self.greenColor;
    self.ghostButtonColorGray = self.grayColor;
    self.ghostButtonColorWhite = self.whiteColor;
    
    self.fillButtonColorBlue = self.blueColor;
    self.fillButtonColorRed = self.redColor;
    self.fillButtonColorGreen = self.greenColor;
    self.fillButtonColorGray = self.grayColor;
    self.fillButtonColorWhite = self.whiteColor;
    
    #pragma mark - UITextField & UITextView
    
    self.textFieldTintColor = self.blueColor;
    self.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    
    #pragma mark - NavigationBar
    
    self.navBarHighlightedAlpha = 0.2f;
    self.navBarDisabledAlpha = 0.2f;
    self.navBarButtonFont = UIFontMake(17);
    self.navBarButtonFontBold = UIFontBoldMake(17);
    self.navBarBackgroundImage = nil;
    self.navBarShadowImage = nil;
    self.navBarBarTintColor = nil;
    self.navBarTintColor = self.blackColor;
    self.navBarTitleColor = self.navBarTintColor;
    self.navBarTitleFont = UIFontBoldMake(17);
    self.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;
    self.navBarBackIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavBack size:CGSizeMake(12, 20) tintColor:self.navBarTintColor];
    self.navBarCloseButtonImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:self.navBarTintColor];
    
    self.navBarLoadingMarginRight = 3;
    self.navBarAccessoryViewMarginLeft = 5;
    self.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.navBarAccessoryViewTypeDisclosureIndicatorImage = [[UIImage qmui_imageWithShape:QMUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:self.whiteColor] qmui_imageWithOrientation:UIImageOrientationDown];
    
    #pragma mark - TabBar
    
    self.tabBarBackgroundImage = nil;
    self.tabBarBarTintColor = nil;
    self.tabBarShadowImageColor = nil;
    self.tabBarTintColor = UIColorMake(22, 147, 229);
    self.tabBarItemTitleColor = UIColorMake(119, 119, 119);
    self.tabBarItemTitleColorSelected = self.tabBarTintColor;
    
    #pragma mark - Toolbar
    
    self.toolBarHighlightedAlpha = 0.4f;
    self.toolBarDisabledAlpha = 0.4f;
    self.toolBarTintColor = self.blueColor;
    self.toolBarTintColorHighlighted = [self.toolBarTintColor colorWithAlphaComponent:self.toolBarHighlightedAlpha];
    self.toolBarTintColorDisabled = [self.toolBarTintColor colorWithAlphaComponent:self.toolBarDisabledAlpha];
    self.toolBarBackgroundImage = nil;
    self.toolBarBarTintColor = nil;
    self.toolBarShadowImageColor = UIColorMake(178, 178, 178);
    self.toolBarButtonFont = UIFontMake(17);
    
    #pragma mark - SearchBar
    
    self.searchBarTextFieldBackground = self.whiteColor;
    self.searchBarTextFieldBorderColor = UIColorMake(205, 208, 210);
    self.searchBarBottomBorderColor = UIColorMake(205, 208, 210);
    self.searchBarBarTintColor = UIColorMake(247, 247, 247);
    self.searchBarTintColor = self.blueColor;
    self.searchBarTextColor = self.blackColor;
    self.searchBarPlaceholderColor = self.placeholderColor;
    self.searchBarSearchIconImage = nil;
    self.searchBarClearIconImage = nil;
    self.searchBarTextFieldCornerRadius = 2.0;
    
    #pragma mark - TableView / TableViewCell
    
    self.tableViewBackgroundColor = self.whiteColor;
    self.tableViewGroupedBackgroundColor = self.backgroundColor;
    self.tableSectionIndexColor = self.grayDarkenColor;
    self.tableSectionIndexBackgroundColor = self.clearColor;
    self.tableSectionIndexTrackingBackgroundColor = self.clearColor;
    self.tableViewSeparatorColor = self.separatorColor;
    
    self.tableViewCellNormalHeight = 44;
    self.tableViewCellTitleLabelColor = self.blackColor;
    self.tableViewCellDetailLabelColor = self.grayColor;
    self.tableViewCellContentDefaultPaddingLeft = 15;
    self.tableViewCellContentDefaultPaddingRight = 10;
    self.tableViewCellBackgroundColor = self.whiteColor;
    self.tableViewCellSelectedBackgroundColor = UIColorMake(232, 232, 232);
    self.tableViewCellWarningBackgroundColor = self.yellowColor;
    self.tableViewCellDisclosureIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeDisclosureIndicator size:CGSizeMake(8, 13) tintColor:UIColorMakeWithRGBA(0, 0, 0, .2)];
    self.tableViewCellCheckmarkImage = [UIImage qmui_imageWithShape:QMUIImageShapeCheckmark size:CGSizeMake(15, 12) tintColor:self.blueColor];
    
    self.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionHeaderFont = UIFontBoldMake(12);
    self.tableViewSectionFooterFont = UIFontBoldMake(12);
    self.tableViewSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewSectionFooterTextColor = self.grayColor;
    self.tableViewSectionHeaderHeight = 20;
    self.tableViewSectionFooterHeight = 0;
    self.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    self.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    
    self.tableViewGroupedSectionHeaderFont = UIFontMake(12);
    self.tableViewGroupedSectionFooterFont = UIFontMake(12);
    self.tableViewGroupedSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewGroupedSectionFooterTextColor = self.grayColor;
    self.tableViewGroupedSectionHeaderHeight = 15;
    self.tableViewGroupedSectionFooterHeight = 1;
    self.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);
    self.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);
    
    #pragma mark - UIWindowLevel
    self.windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0;
    self.windowLevelQMUIImagePreviewView = UIWindowLevelStatusBar + 1;
    
    #pragma mark - Others
    
    self.supportedOrientationMask = UIInterfaceOrientationMaskPortrait;
    self.statusbarStyleLightInitially = NO;
    self.needsBackBarButtonItemTitle = NO;
    self.hidesBottomBarWhenPushedInitially = YES;
}

- (void)setNavBarBarTintColor:(UIColor *)navBarBarTintColor {
    _navBarBarTintColor = navBarBarTintColor;
    [UINavigationBar appearance].barTintColor = _navBarBarTintColor;
}

- (void)setNavBarShadowImage:(UIImage *)navBarShadowImage {
    _navBarShadowImage = navBarShadowImage;
    [UINavigationBar appearance].shadowImage = _navBarShadowImage;
}

- (void)setNavBarBackgroundImage:(UIImage *)navBarBackgroundImage {
    _navBarBackgroundImage = navBarBackgroundImage;
    [[UINavigationBar appearance] setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)setNavBarTitleFont:(UIFont *)navBarTitleFont {
    _navBarTitleFont = navBarTitleFont;
    if (self.navBarTitleFont || self.navBarTitleColor) {
        NSMutableDictionary<NSString *, id> *titleTextAttributes = [[NSMutableDictionary alloc] init];
        if (self.navBarTitleFont) {
            [titleTextAttributes setValue:self.navBarTitleFont forKey:NSFontAttributeName];
        }
        if (self.navBarTitleColor) {
            [titleTextAttributes setValue:self.navBarTitleColor forKey:NSForegroundColorAttributeName];
        }
        [UINavigationBar appearance].titleTextAttributes = titleTextAttributes;
    }
}

- (void)setNavBarTitleColor:(UIColor *)navBarTitleColor {
    _navBarTitleColor = navBarTitleColor;
    if (self.navBarTitleFont || self.navBarTitleColor) {
        NSMutableDictionary<NSString *, id> *titleTextAttributes = [[NSMutableDictionary alloc] init];
        if (self.navBarTitleFont) {
            [titleTextAttributes setValue:self.navBarTitleFont forKey:NSFontAttributeName];
        }
        if (self.navBarTitleColor) {
            [titleTextAttributes setValue:self.navBarTitleColor forKey:NSForegroundColorAttributeName];
        }
        [UINavigationBar appearance].titleTextAttributes = titleTextAttributes;
    }
}

- (void)setNavBarBackIndicatorImage:(UIImage *)navBarBackIndicatorImage {
    _navBarBackIndicatorImage = navBarBackIndicatorImage;
    
    if (_navBarBackIndicatorImage) {
        UINavigationBar *navBarAppearance = [UINavigationBar appearance];
        
        // 返回按钮的图片frame是和系统默认的返回图片的大小一致的（13, 21），所以用自定义返回箭头时要保证图片大小与系统的箭头大小一样，否则无法对齐
        CGSize systemBackIndicatorImageSize = CGSizeMake(13, 21); // 在iOS9上实际测量得到
        CGSize customBackIndicatorImageSize = _navBarBackIndicatorImage.size;
        if (!CGSizeEqualToSize(customBackIndicatorImageSize, systemBackIndicatorImageSize)) {
            CGFloat imageExtensionVerticalFloat = CGFloatGetCenter(systemBackIndicatorImageSize.height, customBackIndicatorImageSize.height);
            _navBarBackIndicatorImage = [_navBarBackIndicatorImage qmui_imageWithSpacingExtensionInsets:UIEdgeInsetsMake(imageExtensionVerticalFloat,
                                                                                                                         0,
                                                                                                                         imageExtensionVerticalFloat,
                                                                                                                         systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width)];
        }
        
        navBarAppearance.backIndicatorImage = _navBarBackIndicatorImage;
        navBarAppearance.backIndicatorTransitionMaskImage = navBarAppearance.backIndicatorImage;
    }
}

- (void)setNavBarBackButtonTitlePositionAdjustment:(UIOffset)navBarBackButtonTitlePositionAdjustment {
    _navBarBackButtonTitlePositionAdjustment = navBarBackButtonTitlePositionAdjustment;
    
    if (!UIOffsetEqualToOffset(UIOffsetZero, _navBarBackButtonTitlePositionAdjustment)) {
        UIBarButtonItem *backBarButtonItem = [UIBarButtonItem appearance];
        [backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)setToolBarBarTintColor:(UIColor *)toolBarBarTintColor {
    _toolBarBarTintColor = toolBarBarTintColor;
    [UIToolbar appearance].barTintColor = _toolBarBarTintColor;
}

- (void)setToolBarBackgroundImage:(UIImage *)toolBarBackgroundImage {
    _toolBarBackgroundImage = toolBarBackgroundImage;
    [[UIToolbar appearance] setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)setToolBarShadowImageColor:(UIColor *)toolBarShadowImageColor {
    _toolBarShadowImageColor = toolBarShadowImageColor;
    if (_toolBarShadowImageColor) {
        [[UIToolbar appearance] setShadowImage:[UIImage qmui_imageWithColor:_toolBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0] forToolbarPosition:UIBarPositionAny];
    }
}

- (void)setToolBarButtonFont:(UIFont *)toolBarButtonFont {
    _toolBarButtonFont = toolBarButtonFont;
    if (_toolBarButtonFont) {
        UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
        [barButtonItemAppearance setTitleTextAttributes:@{NSFontAttributeName: _toolBarButtonFont} forState:UIControlStateNormal];
    }
}

- (void)setTabBarBarTintColor:(UIColor *)tabBarBarTintColor {
    _tabBarBarTintColor = tabBarBarTintColor;
    [UITabBar appearance].barTintColor = _tabBarBarTintColor;
}

- (void)setTabBarBackgroundImage:(UIImage *)tabBarBackgroundImage {
    _tabBarBackgroundImage = tabBarBackgroundImage;
    [UITabBar appearance].backgroundImage = _tabBarBackgroundImage;
}

- (void)setTabBarShadowImageColor:(UIColor *)tabBarShadowImageColor {
    _tabBarShadowImageColor = tabBarShadowImageColor;
    if (_tabBarShadowImageColor) {
        [[UITabBar appearance] setShadowImage:[UIImage qmui_imageWithColor:_tabBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0]];
    }
}

- (void)setTabBarItemTitleColor:(UIColor *)tabBarItemTitleColor {
    _tabBarItemTitleColor = tabBarItemTitleColor;
    if (_tabBarItemTitleColor) {
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: _tabBarItemTitleColor} forState:UIControlStateNormal];
    }
}

- (void)setTabBarItemTitleColorSelected:(UIColor *)tabBarItemTitleColorSelected {
    _tabBarItemTitleColorSelected = tabBarItemTitleColorSelected;
    if (_tabBarItemTitleColorSelected) {
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: _tabBarItemTitleColorSelected} forState:UIControlStateSelected];
    }
}

@end
