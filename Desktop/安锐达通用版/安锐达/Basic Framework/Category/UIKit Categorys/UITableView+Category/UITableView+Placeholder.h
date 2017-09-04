

#import <UIKit/UIKit.h>
@class UITableViewPlaceholderConfig;
@interface UITableView (Placeholder)
/*** 原始分割线样式 ***/
@property (nonatomic, assign) UITableViewCellSeparatorStyle originalSeparatorStyle;

@property (nonatomic, assign) BOOL didSetup;

- (void)placeholderBaseOnNumber:(NSInteger)numberOfRows iconConfig:(void (^) (UIImageView *imageView))iconConfig textConfig:(void (^) (UILabel *label))textConfig;

- (void)clean;

- (void)placeholderBaseOnNumber:(NSInteger)numberOfRows withConf:(UITableViewPlaceholderConfig *)conf;

@end

@interface UITableViewPlaceholderView : UIView

/*** placeholderImageView ***/
@property (nonatomic, strong) UIImageView *placeholderImageView;

/*** placeholderLabel ***/
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@interface UITableViewPlaceholderConfig : NSObject

/*** placeholder文字 ***/
@property (nonatomic, copy) NSString *placeholderText;

/*** placeholder文字字体 ***/
@property (nonatomic, strong) UIFont *placeholderFont;

/*** placeholder文字颜色 ***/
@property (nonatomic, strong) UIColor *placeholderColor;

/*** placeholder图片 ***/
@property (nonatomic, strong) UIImage *placeholderImage;

/*** placeholder动画组图 ***/
@property (nonatomic, strong) NSArray *animationImages;

/*** 动画的时间间隔 ***/
@property (nonatomic, assign) NSTimeInterval animationDuration;

/*** 是否正在加载数据 ***/
@property (nonatomic, assign) BOOL loadingData;

+ (instancetype)defaultConfig;
@end
