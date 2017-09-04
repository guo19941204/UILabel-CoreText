//
//  ServerView.m
//  安锐达
//
//  Created by 郭炜 on 2017/7/10.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "ServerView.h"
#import "Contains.h"
#import "FunctionClass.h"

@interface ServerView ()<UITextFieldDelegate>

@end
@implementation ServerView
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor blackColor];
    self.sureAction.tintColor = [UIColor whiteColor];
    self.cancelAction.tintColor = [UIColor whiteColor];
    [self.sureAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sureAction.layer.masksToBounds = YES;
    self.cancelAction.layer.masksToBounds = YES;
    self.layer.masksToBounds = YES;
    self.sureAction.layer.cornerRadius = 5.0f;
    self.cancelAction.layer.cornerRadius = 5.0f;
    self.layer.cornerRadius = 15.0f;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_login_IP"]];
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_login_XX"]];
    self.hostTextField.leftView = imageView;
    self.portTextField.leftView = imageView1;
    self.hostTextField.leftViewMode = UITextFieldViewModeAlways;
    self.portTextField.leftViewMode = UITextFieldViewModeAlways;
    self.hostTextField.delegate = self;
    self.portTextField.delegate = self;
    
    self.hostTextField.text = [FunctionClass sharedInstance].host;
    self.portTextField.text = [FunctionClass sharedInstance].port;
}
- (IBAction)handleSureAction:(id)sender {
    if ([self.hostTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"不正确的服务器"];
        return;
    }
    if ([self.portTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"不正确的端口"];
        return;
    }
    [FunctionClass sharedInstance].host = self.hostTextField.text;
    [FunctionClass sharedInstance].port = self.portTextField.text;
    self.block();
}

- (IBAction)handleCancelAction:(id)sender {
    self.block();
}

#pragma mark -- delegate --
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.hostTextField]) {
        [self.portTextField becomeFirstResponder];
    }
    return YES;
}
@end
