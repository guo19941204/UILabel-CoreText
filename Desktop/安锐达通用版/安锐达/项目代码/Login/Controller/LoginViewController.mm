//
//  LoginViewController.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/5.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "LoginViewController.h"
#import "Contains.h"
#import "MainViewController.h"
#import "FunctionClass.h"
#import "ServerView.h"
#import "MyAudioCC.h"

@interface LoginViewController ()<QMUITextFieldDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate> {
    AVPlayer *player;
}
@property (weak, nonatomic) IBOutlet QMUITextField *userName;
@property (weak, nonatomic) IBOutlet QMUITextField *password;
@property (weak, nonatomic) IBOutlet QMUIButton *loginAction;
@property (weak, nonatomic) IBOutlet QMUIButton *serverAction;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (nonatomic, strong) ServerView *serverView;
@property (nonatomic, strong) UIView *backGroundView;
/*** audioPlayer */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation LoginViewController

- (void)initSubviews {
    [super initSubviews];
    
    self.userName.delegate = self;
    self.password.delegate = self;
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    self.userName.text = ([userInfo objectForKey:@"userName"] == nil ? @"" : [userInfo objectForKey:@"userName"]);
    self.password.text = ([userInfo objectForKey:@"password"] == nil ? @"" : [userInfo objectForKey:@"password"]);
    
    __weak __typeof(self)weakSelf = self;
    self.userName.qmui_keyboardWillChangeFrameNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        [QMUIKeyboardManager handleKeyboardNotificationWithUserInfo:keyboardUserInfo showBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            [weakSelf showToolbarViewWithKeyboardUserInfo:keyboardUserInfo];
        } hideBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            self.userName.layer.transform = CATransform3DIdentity;
            self.logoImageView.layer.transform = CATransform3DIdentity;
        }];
    };
    
    self.password.qmui_keyboardWillChangeFrameNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        [QMUIKeyboardManager handleKeyboardNotificationWithUserInfo:keyboardUserInfo showBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
                CGFloat distanceFromBottom = [QMUIKeyboardManager visiableKeyboardHeight];
                //                CGFloat distanceY = SCREEN_HEIGHT - distanceFromBottom;
                //                CGFloat userNameY = CGRectGetMaxY(self.password.frame);
                //                if (userNameY > distanceY) {
                self.userName.layer.transform = CATransform3DMakeTranslation(0, -80, 0);
                self.logoImageView.layer.transform = CATransform3DMakeTranslation(0, -80, 0);
                self.password.layer.transform = CATransform3DMakeTranslation(0, -80, 0);
                //                }
            } completion:NULL];
            
        } hideBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            self.userName.layer.transform = CATransform3DIdentity;
            self.logoImageView.layer.transform = CATransform3DIdentity;
            self.password.layer.transform = CATransform3DIdentity;
        }];
    };
    
    [self playOutByRegisterAllLongBackground];
}

- (void)playOutByRegisterAllLongBackground {
    WEAK(self);
    dispatch_queue_t dispatchQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        
        
        
        [weakSelf.audioPlayer setNumberOfLoops:-1];
        if ([weakSelf.audioPlayer prepareToPlay] && [self.audioPlayer play]){
            NSLog(@"Successfully started playing...");
        } else {
            NSLog(@"Failed to play.");
        }
    }
                   );
}

- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath = [mainBundle pathForResource:@"mySong"ofType:@"mp3"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.loginAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.userName.layer.cornerRadius = 3.0f;
    self.userName.layer.masksToBounds = YES;
    self.password.layer.cornerRadius = 3.0f;
    self.password.layer.masksToBounds = YES;
    self.loginAction.layer.cornerRadius = 3.0f;
    self.loginAction.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark -- 事件 --
- (IBAction)loginAction:(id)sender {
    //登录事件
    
    if ([self.userName.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入用户名"];
        return;
    }
    if ([self.password.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    [userInfo setValue:self.userName.text forKey:@"userName"];
    [userInfo setValue:self.password.text forKey:@"password"];
    //连接前，先手动断开
    [[SocketServe sharedInstance] cutOffSocket];
    [SocketServe sharedInstance].socket.userData = SocketOffLineBySever;
    
    [[SocketServe sharedInstance] startConnectSocket];
    
    /*
     1. 向服务器发送信息，例如：登录指令的data数据
     2.登录成功后，这里可以通过通知，block，代理接收到 SingletonSoket.m 中接收到的数据进行解析
     */
    
    //发送数据
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:LD,@"cmd",self.userName.text,@"username",self.password.text,@"password", nil];
    [[SocketServe sharedInstance] sendMessage:[dic jsonStringWithSelf]];
    [SocketServe sharedInstance].callBackMessage = ^(NSDictionary *responseData,NSData *data) {
        NSLog(@"%@",responseData);
        if ([responseData count] >0) {
            int result = [[responseData objectForKey:@"result"] intValue];
            switch (result) {
                case 0:
                {
                    //数据返回成功
                    /*** 拿到uid 获取公共配置***/
                    @try {
                        NSString *uId = [Util getString:[responseData objectForKey:@"data"][@"uId"]];
                        [FunctionClass sharedInstance].uId = uId;
                        NSString *kindName = [Util getString:[responseData objectForKey:@"loadmodule"][0][@"kindName"]];
                        [self setKindTypeWithKindName:kindName];
                        [self getGDCWithUid:uId];
                    } @catch (NSException *exception) {
                        
                    }
                }
                    break;
                case 1:
                {
                    [SVProgressHUD showErrorWithStatus:@"密码错误"];
                }
                    break;
                case 2:
                {
                    [SVProgressHUD showErrorWithStatus:@"账号不存在"];
                }
                default:
                    break;
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"登录失败"];
        }
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (IBAction)serverAction:(id)sender {
    //显示服务器
    [self clickPopView];
}

#pragma mark -- 设置clientType --
- (void)setKindTypeWithKindName:(NSString *)kindName {
    if ([kindName isEqualToString:@"NoClient"]) {
        [FunctionClass sharedInstance].clientType = 0;
    }else if ([kindName isEqualToString:@"RemoteClient"]) {
        [FunctionClass sharedInstance].clientType = 1;
    }else if ([kindName isEqualToString:@"InnerDclient"]) {
        [FunctionClass sharedInstance].clientType = 2;
    }else if ([kindName isEqualToString:@"InnerClient"]) {
        [FunctionClass sharedInstance].clientType = 3;
    }else if ([kindName isEqualToString:@"MonitorDclient"]) {
        [FunctionClass sharedInstance].clientType = 4;
    }else if ([kindName isEqualToString:@"MeetingClient"]) {
        [FunctionClass sharedInstance].clientType = 5;
    }
}
#pragma mark -- 拿到登录后数据去获取公共配置 --
- (void)getGDCWithUid:(NSString *)uId {
    if ([uId isEqualToString:@""]) return;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:GDC,@"cmd",@"uId",uId, nil];
    //发送指令
    [[SocketServe sharedInstance] sendMessage:[dic jsonStringWithSelf]];
    [SocketServe sharedInstance].callBackMessage = ^(NSDictionary *responseData,NSData *data) {
        NSLog(@"%@",responseData);
        @try {
            NSArray *baseConfig = [responseData objectForKey:@"baseConfig"];
            NSDictionary *config = baseConfig.count>0?baseConfig[0]:[NSDictionary new];
            if (config.count>0) {
                //获取到公共配置服务器
                [ExchangeSocketServe sharedInstance].host = [Util getString:[config objectForKey:@"exIp"]];
                [ExchangeSocketServe sharedInstance].port = [Util getString:[config objectForKey:@"exPort"]];
                [FunctionClass sharedInstance].host = [Util getString:[config objectForKey:@"exIp"]];
                [FunctionClass sharedInstance].port = [Util getString:[config objectForKey:@"exPort"]];
                //连接到公共配置服务器
                //连接前，先手动断开
                [[ExchangeSocketServe sharedInstance] cutOffSocket];
                [ExchangeSocketServe sharedInstance].socket.userData = SocketOffLineBySever;
                
                [[ExchangeSocketServe sharedInstance] startConnectSocket];
                [self loginGDCServer:uId];
                
            }
        } @catch (NSException *exception) {
            
        }
    };
    
}

#pragma mark -- 登录GDC服务器 --
- (void)loginGDCServer:(NSString *)uId {
    //登录到GDC服务器
    std::string *bar = new std::string([uId UTF8String]);
    myAudioInit(YES, *bar);
    [SVProgressHUD showWithStatus:@"正在登录"];
    [[FunctionClass sharedInstance] login];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToMain) name:@"popToMain" object:nil];
}

#pragma mark -- 其他 --
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)popToMain {
    [self.navigationController pushViewController:[MainViewController new] animated:YES];
}

#pragma mark - ToolbarView Show And Hide
- (void)showToolbarViewWithKeyboardUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (keyboardUserInfo) {
        // 相对于键盘
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            CGFloat distanceFromBottom = [QMUIKeyboardManager visiableKeyboardHeight];
            //            CGFloat distanceY = SCREEN_HEIGHT - distanceFromBottom;
            //            CGFloat userNameY = CGRectGetMaxY(self.userName.frame);
            //            if (userNameY > distanceY) {
            self.userName.layer.transform = CATransform3DMakeTranslation(0, -80, 0);
            self.logoImageView.layer.transform = CATransform3DMakeTranslation(0, -80, 0);
            //            }
        } completion:NULL];
    } else {
        // 相对于表情面板
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            //            self.toolbarView.layer.transform = CATransform3DMakeTranslation(0, - CGRectGetHeight(self.qqEmotionManager.emotionView.bounds) - kToolbarHeight, 0);
        } completion:NULL];
    }
}

#pragma mark -- textfielddelegate --
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    if ([textField isEqual:self.userName]) {
        [self.password becomeFirstResponder];
    }
    return YES;
}

- (void)clickPopView {
    //显示 加载另一个view弹出另一个视图
    [self.view addSubview:self.backGroundView];
    [self.backGroundView addSubview:self.serverView];
    [UIView animateWithDuration:0.6f animations:^{
        self.serverView.frame = CGRectMake(0, 0, 323.0/1024.0*SCREEN_WIDTH, 226.0);
        self.serverView.center = CGPointMake(SCREEN_WIDTH/2.0, 226.0/2+20);
    }];
}

- (void)hide {
    //隐藏
    if (self.serverView) {
        [UIView animateWithDuration:0.6f animations:^{
            self.serverView.center = CGPointMake(SCREEN_WIDTH/2.0, -226.0-20);
        }completion:^(BOOL finished) {
            [self.backGroundView removeFromSuperview];
            [self.serverView removeFromSuperview];
        }];
    }
}

//别删 别改
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.serverView]) {
        return NO;
    }
    
    return YES;
}
#pragma mark -- init --
- (ServerView *)serverView {
    if (!_serverView) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ServerView" owner:self options:nil];
        _serverView = array[0];
        _serverView.frame = CGRectMake(0, 0, 323.0/1024.0*SCREEN_HEIGHT, 226.0);
        _serverView.center = CGPointMake(SCREEN_WIDTH/2, -226);
        MJWeakSelf;
        _serverView.block = ^{
            [weakSelf hide];
        };
    }
    return _serverView;
}

- (UIView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backGroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        UITapGestureRecognizer *gesTure = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        gesTure.delegate = self;
        [_backGroundView addGestureRecognizer:gesTure];
    }
    return _backGroundView;
}
@end
