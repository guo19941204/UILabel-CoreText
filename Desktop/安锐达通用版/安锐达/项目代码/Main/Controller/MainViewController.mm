//
//  MainViewController.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/13.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "MainViewController.h"
#import "Contains.h"
#import "GroupModel.h"
#import "DesModel.h"
#import "GroupHeadView.h"
#import "FunctionClass.h"
#import "sectionModel.h"
#import "VideoPlayController.h"
#import "GroupListView.h"
#import "YKMultiLevelTableView.h"
#import "MyAudioCC.h"
#import "OnLine.h"

static NSString *kind = @"InnerClient";
@interface MainViewController ()<UIGestureRecognizerDelegate> {
    NSMutableArray *dataSource;
    NSMutableArray *groupArray;
    NSMutableArray *callListUsers;//通话组列表人
    NSMutableDictionary *onLineUsers;
    BOOL actionViewShow;
    BOOL listViewShow;
    BOOL isInited;
    QMUIAlertController *alert1;
}
@property (weak, nonatomic) IBOutlet UIView *actionsView;
/*** 通话 ***/
@property (weak, nonatomic) IBOutlet QMUIButton *phoneButton;
/*** 播放 ***/
@property (weak, nonatomic) IBOutlet QMUIButton *voiceButton;
/*** 录音 ***/
@property (weak, nonatomic) IBOutlet QMUIButton *soundButton;
/*** 截图 ***/
@property (weak, nonatomic) IBOutlet QMUIButton *cutLight;
/*** 列表 ***/
@property (weak, nonatomic) IBOutlet QMUIButton *listButton;

/*** 截图的imageView ***/
@property (nonatomic, strong) UIImageView *cutViewImage;
/*** 列表 ***/
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (nonatomic, strong) GroupListView *groupListView;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UITapGestureRecognizer *gest;
@end

@implementation MainViewController
- (void)initSubviews {
    [super initSubviews];
    [self.playView addGestureRecognizer:self.gest];
    [self startGCDTimer];
    //配置属性
    [self configTemple];
    //配置tableview的头视图
    [self initWithDataSource];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callList:) name:@"callList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOnLineUser:) name:@"getOnlineUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAlert) name:@"hideAlert" object:nil];
    
    VideoPlayController *playController = [FunctionClass sharedInstance].playerController;
    playController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.playView addSubview:playController.view];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.actionsView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    NSArray *btnArray = @[self.phoneButton,self.voiceButton,self.soundButton,self.cutLight,self.listButton];
    for (int i = 0; i < btnArray.count; i ++) {
        QMUIButton *button = btnArray[i];
        [button setImagePosition:QMUIButtonImagePositionTop];
        [button setSpacingBetweenImageAndTitle:8];
        if ([button isEqual:self.voiceButton] || [button isEqual:self.soundButton]) {
            [button setTitleColor:RGBA(100, 184, 252, 1) forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [button setTitleColor:RGBA(100, 184, 252, 1) forState:UIControlStateHighlighted];
        [button setTitleColor:RGBA(100, 184, 252, 1) forState:UIControlStateSelected];
    }
    self.listButton.selected = YES;
    [self.view layoutIfNeeded];
}

-(void) startGCDTimer{
    
    // GCD定时器
    static dispatch_source_t _timer;
    NSTimeInterval period = 3.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    // 事件回调
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getUserStatus];
        });
    });
    
    // 开启定时器
    dispatch_resume(_timer);
    
    // 关闭定时器
    // dispatch_source_cancel(_timer);
}

- (void)configTemple {
    dataSource = [[NSMutableArray alloc] init];
    groupArray = [[NSMutableArray alloc] init];
    callListUsers = [[NSMutableArray alloc] init];
    onLineUsers = [[NSMutableDictionary alloc] init];
    
    self.phoneButton.userInteractionEnabled = NO;
}

#pragma mark -- 数据源 --
- (void)initWithDataSource {
    //连接前，先手动断开
    [[SocketServe sharedInstance] cutOffSocket];
    [SocketServe sharedInstance].socket.userData = SocketOffLineBySever;
    
    [SocketServe sharedInstance].host = API_HOST;
    [SocketServe sharedInstance].port = PORT;
    [[SocketServe sharedInstance] startConnectSocket];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:GGL,@"cmd", nil];
    [[SocketServe sharedInstance] sendMessage:[dic jsonStringWithSelf]];
    [SocketServe sharedInstance].callBackMessage = ^(NSDictionary *responseData,NSData *data) {
        NSLog(@"11111%@",responseData);
        @try {
            if ([responseData[@"data"] count] > 0 && [[responseData objectForKey:@"result"] integerValue] == 0) {
                for (int i = 0; i < [responseData[@"data"] count]; i ++) {
                    NSError *error = nil;
                    GroupModel *model = [[GroupModel alloc] initWithDictionary:responseData[@"data"][i] error:&error];
                    [groupArray addObject:model];
                }
                //进行QU请求
                [self quRequestWithKindName:kind];
            }
        } @catch (NSException *exception) {
            
        }
    };
}

- (void)quRequestWithKindName:(NSString *)kindName {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:QU,@"cmd",kindName,@"kindName", nil];
    //连接前，先手动断开
    [[SocketServe sharedInstance] cutOffSocket];
    [SocketServe sharedInstance].socket.userData = SocketOffLineBySever;
    
    [SocketServe sharedInstance].host = API_HOST;
    [SocketServe sharedInstance].port = PORT;
    [[SocketServe sharedInstance] startConnectSocket];
    
    [[SocketServe sharedInstance] sendMessage:[dic jsonStringWithSelf]];
    [SocketServe sharedInstance].callBackMessage = ^(NSDictionary *responseData,NSData *data) {
        NSLog(@"%@",responseData);
        if ([[responseData objectForKey:@"result"] integerValue] == 0) {
            NSArray *data = responseData[@"data"];
            
            for (int i = 0; i < data.count; i ++) {
                NSError *error = nil;
                DesModel *model = [[DesModel alloc] initWithDictionary:data[i] error:&error];
                [dataSource addObject:model];
            }
            [FunctionClass sharedInstance].allUser = dataSource;
        }
    };
}

#pragma mark -- 获取用户状态 --
- (void)getUserStatus {
    SendMessage *getUsStatus = [[SendMessage alloc] init];
    getUsStatus.Type = 10;
    getUsStatus.ClientType = [FunctionClass sharedInstance].clientType;
    getUsStatus.userName = [FunctionClass sharedInstance].uId;
    NSMutableData *data = [getUsStatus getByteArray];
    [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:data proNum:0 len:318];
}

#pragma mark -- 左侧栏按钮点击事件 --
- (IBAction)handlePhoneAction:(id)sender {
    /*** 通话按钮点击 ***/
    NSMutableString *mess = [[NSMutableString alloc] init];
    for (int i = 0; i < callListUsers.count; i ++) {
        [mess appendString:[NSString stringWithFormat:@"%d. %@\n",i+1,callListUsers[i]]];
    }
    QMUIAlertController *alert = [QMUIAlertController alertControllerWithTitle:@"当前通话组列表" message:mess preferredStyle:QMUIAlertControllerStyleAlert];
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"退出通话组" style:QMUIAlertActionStyleDestructive handler:^(QMUIAlertAction *action) {
        [[FunctionClass sharedInstance] exitTalk];
        self.phoneButton.userInteractionEnabled = NO;
        self.phoneButton.selected = NO;
    }];
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
        [alert hideWithAnimated:YES];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert showWithAnimated:YES];
}

- (IBAction)handleVoiceAction:(id)sender {
    /*** 播放按钮点击 ***/
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (!button.selected) {
        [FunctionClass sharedInstance].isPlayout = YES;
//        myAudioReveive();
    }else {
        [FunctionClass sharedInstance].isPlayout = NO;
//        myAudioStopReveiveAuBuffer();
    }
    
}

- (IBAction)handleSoundAction:(id)sender {
    /*** 录音按钮点击 ***/
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (!button.selected) {
        myAudioSend();
    }else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            myAudioStopSend();
        });
    }
}

- (IBAction)handleCutLightAction:(id)sender {
    /*** 截图按钮点击 ***/
    //防止多次点击
    self.cutLight.userInteractionEnabled = NO;
    UIImage *image;
    if ([[FunctionClass sharedInstance].playerController imageWithImageBuffer]) {
        image = [[FunctionClass sharedInstance].playerController imageWithImageBuffer];
    } else {
        image = [self.view qmui_snapshotLayerImage];
    }
    self.cutViewImage.image = image;
    self.cutViewImage.frame = CGRectMake(CGFloatGetCenter(SCREEN_WIDTH, SCREEN_WIDTH/9.0), CGFloatGetCenter(SCREEN_HEIGHT, SCREEN_HEIGHT/9.0), SCREEN_WIDTH/9.0, SCREEN_HEIGHT/9.0);
    [self.view addSubview:self.cutViewImage];
    [UIView animateWithDuration:0.8 animations:^{
        self.cutViewImage.frame = CGRectMake(CGFloatGetCenter(SCREEN_WIDTH, SCREEN_WIDTH*0.8), CGFloatGetCenter(SCREEN_HEIGHT, SCREEN_HEIGHT*0.8), SCREEN_WIDTH*0.8, SCREEN_HEIGHT*0.8);
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.cutViewImage.frame = CGRectMake(CGFloatGetCenter(SCREEN_WIDTH, SCREEN_WIDTH*0.7), CGFloatGetCenter(SCREEN_HEIGHT, SCREEN_HEIGHT*0.7), SCREEN_WIDTH*0.7, SCREEN_HEIGHT*0.7);
        }completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //保存  remove
                [self loadImageFinished:self.cutViewImage.image];
            });
        }];
    }];
    [self performSelector:@selector(openButtonInterface) withObject:nil afterDelay:2.0f];
}

- (IBAction)handleListAction:(id)sender {
    /*** 列表按钮点击 ***/
    [self handleTapGesture];
}

#pragma mark -- 截图 --
- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    [self.cutViewImage removeFromSuperview];
    [SVProgressHUD showSuccessWithStatus:@"保存在系统相册"];
}

#pragma mark -- init --
- (UIImageView *)cutViewImage {
    if (!_cutViewImage) {
        _cutViewImage = [[UIImageView alloc] init];
        _cutViewImage.layer.borderWidth = 1.0;
        _cutViewImage.layer.borderColor = RGBA(100, 184, 252, 1).CGColor;
    }
    return _cutViewImage;
}

- (GroupListView *)groupListView {
    if (!_groupListView) {
        isInited = YES;
        _groupListView = [[GroupListView alloc] initWithFrame:CGRectMake(110, -SCREEN_HEIGHT, SCREEN_WIDTH-110-150, SCREEN_HEIGHT) GroupList:groupArray dataSource:dataSource online:onLineUsers];
        _groupListView.block = ^(YKNodeModel *node) {
            [FunctionClass sharedInstance].targetUserName = [NSString stringWithFormat:@"%ld",node.desModel.uId];
            NSString *mess = [NSString stringWithFormat:@"确定连入/邀请%@",node.desModel.title];
            QMUIAlertController *alert = [QMUIAlertController alertControllerWithTitle:@"提示" message:mess preferredStyle:QMUIAlertControllerStyleAlert];
            QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"连入" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
                [[FunctionClass sharedInstance] connected:0];
                
                alert1 = [QMUIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"正在连入%@",node.desModel.title] preferredStyle:QMUIAlertControllerStyleAlert];
                QMUIAlertAction *actionC = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
                    [[FunctionClass sharedInstance] cancel:0];
                }];
                [alert1 addAction:actionC];
                [alert1 showWithAnimated:YES];
            }];
            QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"邀请" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
                [[FunctionClass sharedInstance] invitation:0];
                alert1 = [QMUIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"正在邀请%@",node.desModel.title] preferredStyle:QMUIAlertControllerStyleAlert];
                QMUIAlertAction *actionC = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
                    [[FunctionClass sharedInstance] cancel:0];
                }];
                [alert1 addAction:actionC];
                [alert1 showWithAnimated:YES];
            }];
            QMUIAlertAction *action3 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
                [alert hideWithAnimated:YES];
            }];
            [alert addAction:action1];
            [alert addAction:action2];
            [alert addAction:action3];
            [alert showWithAnimated:YES];
        };
    }
    return _groupListView;
}

- (UIView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backGroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        UITapGestureRecognizer *gesTure = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
        gesTure.delegate = self;
        gesTure.numberOfTapsRequired = 1;
        [_backGroundView addGestureRecognizer:gesTure];
    }
    return _backGroundView;
}

- (UITapGestureRecognizer *)gest {
    if (!_gest) {
        _gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActions)];
        _gest.numberOfTapsRequired = 1;
    }
    return _gest;
}
#pragma mark -- 其他 --
- (void)openButtonInterface {
    self.cutLight.userInteractionEnabled = YES;
}

//通知获取在线用户列表
- (void)getOnLineUser:(NSNotification *)notification {
    NSDictionary *nameDictionary = [notification userInfo];
    onLineUsers = nameDictionary[@"getOnlineUser"];
    if (isInited) {
        self.groupListView.tableView.onlines = onLineUsers;
    }
}

//通知处理通话组
- (void)callList:(NSNotification *)notification {
    if (callListUsers.count > 0) {
        [callListUsers removeAllObjects];
    }
    NSDictionary *nameDictionary = [notification userInfo];
    NSMutableArray *onlineCalls = nameDictionary[@"callList"];
    if (onlineCalls.count == 0) {
        //通话组没人
        self.phoneButton.userInteractionEnabled = NO;
        self.phoneButton.selected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addLayer" object:nil];
    }else {
        //通话组有人
        self.phoneButton.userInteractionEnabled = YES;
        self.phoneButton.selected = YES;
        for (int i = 0; i < onlineCalls.count; i ++) {
            NSInteger onLineUid = [onlineCalls[i] integerValue];
            for (int i = 0; i < dataSource.count; i ++) {
                DesModel *model = dataSource[i];
                if (model.uId == onLineUid) {
                    [callListUsers addObject:model.title];
                }
            }
        }
    }
}

- (void)showOrHideActionsView {
    actionViewShow = !actionViewShow;
    if (actionViewShow) {
        [UIView animateWithDuration:0.5 animations:^{
            self.actionsView.frame = CGRectMake(0, 0, 110, SCREEN_HEIGHT);
        }];
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            self.actionsView.frame = CGRectMake(-110, 0, 110, SCREEN_HEIGHT);
        }];
    }
}

- (void)showOrHideListView {
    listViewShow = !listViewShow;
    if (listViewShow) {
        //显示
        [self.view insertSubview:self.backGroundView belowSubview:self.groupListView];
        [self.view addSubview:self.groupListView];
        // 弹簧动画，参数分别为：时长，延时，弹性（越小弹性越大），初始速度
        [UIView animateWithDuration: 0.6f delay:0.2 usingSpringWithDamping:0.8 initialSpringVelocity:0.9 options:0 animations:^{
            self.groupListView.frame = CGRectMake(110, 0, SCREEN_WIDTH-110-150, SCREEN_HEIGHT);
        } completion:nil];
    }else {
        self.backGroundView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.6f delay:0.3 options:0 animations:^{
            self.groupListView.frame = CGRectMake(110, 2*SCREEN_HEIGHT, 0, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
            self.groupListView.frame = CGRectMake(110, -SCREEN_HEIGHT, 0, SCREEN_HEIGHT);
            [self.groupListView removeFromSuperview];
            self.backGroundView.userInteractionEnabled = YES;
            [self.backGroundView removeFromSuperview];
        }];
    }
}

- (void)handleTapGesture {
    //显示隐藏侧边栏
    [self showOrHideListView];
}

- (void)handleActions {
    [self showOrHideActionsView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.actionsView] || [touch.view isDescendantOfView:self.groupListView]) {
        return NO;
    }
    
    return YES;
}

- (void)hideAlert {
    [alert1 hideWithAnimated:YES];
}
@end
