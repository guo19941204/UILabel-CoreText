//
//  ServerView.h
//  安锐达
//
//  Created by 郭炜 on 2017/7/10.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMUITextField,QMUIButton;
typedef void(^SelectBlock)(void);
@interface ServerView : UIView
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet QMUIButton *sureAction;
@property (weak, nonatomic) IBOutlet QMUIButton *cancelAction;

/*** <#statements#> */
@property (nonatomic, copy) SelectBlock block;

@end
