


#import "UITableView+Placeholder.h"
#import <objc/runtime.h>

static char didSetupKey;
static char placeholderViewKey;
static char originalSeparatorStyleKey;

@implementation UITableView (Placeholder)

- (void)placeholderBaseOnNumber:(NSInteger)numberOfRows iconConfig:(void (^)(UIImageView *))iconConfig textConfig:(void (^)(UILabel *))textConfig {
    
    UITableViewPlaceholderView *placeholderView = [self viewWithTag:3333333];
    if (!placeholderView) {
        placeholderView = [[UITableViewPlaceholderView alloc] init];
        placeholderView.tag = 3333333;
    }
    
    if (iconConfig) {
        iconConfig(placeholderView.placeholderImageView);
    }
    
    if (textConfig) {
        textConfig(placeholderView.placeholderLabel);
    }
    
    if (!self.didSetup) {
        self.originalSeparatorStyle = self.separatorStyle;
        self.didSetup = YES;
        
        if (self.backgroundView) {
            [self.backgroundView addSubview:self.placeholderView];
        }else {
            self.backgroundView = placeholderView;
        }
    }
    
    if (numberOfRows) {
        self.separatorStyle = self.originalSeparatorStyle;
        placeholderView.hidden = YES;
    }else {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        placeholderView.hidden = NO;
    }
    
    placeholderView.frame = self.bounds;
}

- (void)clean {
    
}

- (void)placeholderBaseOnNumber:(NSInteger)numberOfRows withConf:(UITableViewPlaceholderConfig *)conf {
    [self placeholderBaseOnNumber:numberOfRows iconConfig:^(UIImageView *imageView) {
        imageView.animationImages = conf.animationImages;
        imageView.animationDuration = conf.animationDuration;
        imageView.image = conf.placeholderImage;
        if (conf.loadingData) {
            [imageView startAnimating];
        }else {
            [imageView stopAnimating];
        }
    } textConfig:^(UILabel *label) {
        label.text = conf.placeholderText;
        label.font = conf.placeholderFont;
        label.textColor = conf.placeholderColor;
        label.hidden = conf.loadingData;
    }];
}

#pragma mark -- setter&getter --
- (void)setDidSetup:(BOOL)didSetup {
    objc_setAssociatedObject(self, &didSetupKey, @(didSetup), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)didSetup {
    return [objc_getAssociatedObject(self, &didSetupKey) boolValue];
}

- (void)setPlaceholderView:(UITableViewPlaceholderView *)placeholderView {
    objc_setAssociatedObject(self, &placeholderViewKey, placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableViewPlaceholderView *)placeholderView {
    return objc_getAssociatedObject(self, &placeholderViewKey);
}

- (void)setOriginalSeparatorStyle:(UITableViewCellSeparatorStyle)originalSeparatorStyle {
    objc_setAssociatedObject(self, &originalSeparatorStyleKey, @(originalSeparatorStyle), OBJC_ASSOCIATION_ASSIGN);
}

- (UITableViewCellSeparatorStyle)originalSeparatorStyle {
    return [objc_getAssociatedObject(self, &originalSeparatorStyleKey) integerValue];
}


@end
@implementation UITableViewPlaceholderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.placeholderImageView = [UIImageView new];
        self.placeholderLabel     = [UILabel new];
        self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_placeholderImageView];
        [self addSubview:_placeholderLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat maxHeight = 0;
    if (_placeholderImageView.image) {
        maxHeight += _placeholderImageView.image.size.height;
    }
    
    CGSize textSize = CGSizeZero;
    if (_placeholderLabel.text.length) {
        NSString *text = _placeholderLabel.text;
        textSize = [text sizeWithAttributes:@{NSFontAttributeName:_placeholderLabel.font}];
        maxHeight += textSize.height;
    }
    
    CGFloat offset = 0;
    if (_placeholderImageView.image && _placeholderLabel.text.length) {
        offset = 8;
    }
    maxHeight += offset;
    
    _placeholderImageView.frame = CGRectMake((CGRectGetMaxX(self.frame)-_placeholderImageView.image.size.width)/2,
                                             (CGRectGetMaxY(self.frame)-maxHeight)/2,
                                             _placeholderImageView.image.size.width,
                                             _placeholderImageView.image.size.height);
    _placeholderLabel.frame = CGRectMake(0,
                                         CGRectGetMaxY(_placeholderImageView.frame) + offset,
                                         [UIScreen mainScreen].bounds.size.width,
                                         textSize.height);
    CGPoint center = _placeholderLabel.center;
    center.x = self.center.x;
    _placeholderLabel.center = center;
}
@end


@implementation UITableViewPlaceholderConfig
+ (instancetype)defaultConfig;
{
    static dispatch_once_t onceToken;
    static UITableViewPlaceholderConfig *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [UITableViewPlaceholderConfig new];
            [sharedObject _setupDefaultValue];
        }
    });
    return sharedObject;
}

- (void)_setupDefaultValue
{
    self.placeholderText = @"没有发现数据";
    self.placeholderImage= nil;
    self.animationImages      = nil;
    self.loadingData     = NO;
    
    self.placeholderFont = [UIFont systemFontOfSize:15];
    self.placeholderColor= [UIColor lightGrayColor];
    
    self.animationDuration    = 2;
}

@end
