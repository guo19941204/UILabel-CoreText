//
//  DataProcessThread.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "DataProcessThread.h"
#import "SendMessage.h"
#import "RecivedEntity.h"
#import "FunctionClass.h"
#import "Contains.h"
#import "OnLine.h"
#import "UserInfo.h"
#import <AudioToolbox/AudioToolbox.h>
#import "VideoHeader.h"
#import "VideoPlayController.h"
#import "DesModel.h"
#import "MyAudioCC.h"
static SystemSoundID shake_sound_male_id = 0;
static dispatch_queue_t queue =dispatch_queue_create("serial",DISPATCH_QUEUE_SERIAL);
static dispatch_queue_t Voicequeue =dispatch_queue_create("voiceserial",DISPATCH_QUEUE_SERIAL);

@interface DataProcessThread () {
    QMUIAlertController *alertController;
    uint8_t *bufOut;
    VideoPlayController *player;
    NSMutableArray *completeList;
    NSThread *thread;
    BOOL start;
    NSTimer *timer;
}
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableData *allData;
@end
@implementation DataProcessThread

+ (instancetype)sharedObject {
    static DataProcessThread * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DataProcessThread alloc] init];
        _sharedInstance.allData = [[NSMutableData alloc] init];
        
    });
    return _sharedInstance;
}

- (void)dealWithInstruction:(RecivedEntity *)entity {
    
    if (entity == nil) {
        return;
    }
    int ucDataType = entity.packHead.ucDataType;
    switch (ucDataType) {
        case 0:
        {
            //指令消息
            [self dealInstruct:entity];
        }
            break;
        case 3:
        {
            NSLog(@"音频数据.........................");
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //                if ([FunctionClass sharedInstance].isPlayout && ![FunctionClass sharedInstance].runningInBackground) {
            //                    NSData *data = [entity getData];
            //                    char * p =(char *)[data bytes];
            //                    myAudioReceiveAuBuffer(p, (int)[data length]);
            //                }
            //            });
            dispatch_async(Voicequeue, ^{
                if ([FunctionClass sharedInstance].isPlayout && ![FunctionClass sharedInstance].runningInBackground) {
                    NSData *data = [entity getData];
                    char * p =(char *)[data bytes];
                    myAudioReceiveAuBuffer(p, (int)[data length]);
                }
            });
        }
            break;
        case 7:
        {
            //通话组列表信息
            //            NSLog(@"%@",entity);
            [self dealCallListInfo:entity];
        }
            break;
        case 9:
        {
            NSLog(@"视频头数据.........................");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeLayer" object:nil];
            [self dealWithVideoHeader:entity];
            [self startDecode];
        }
            break;
        case 10:
        {
            NSLog(@"视频数据.........................");
            if ([FunctionClass sharedInstance].runningInBackground) {
                break;
            }
            
            if ([FunctionClass sharedInstance].completeMsgList.count <= 100) {
                [[FunctionClass sharedInstance].completeMsgList addObject:entity];
            }
            //            dispatch_async(queue, ^{
            //                [player decodeH264:[[entity getData] subdataWithRange:NSMakeRange(0, [entity getData].length-1)] withBufOut:bufOut];
            //            });
            
            BOOL getVideoHeader = [FunctionClass sharedInstance].getVideoHeader;
            if (getVideoHeader) {
                SendMessage *getUsStatus = [[SendMessage alloc] init];
                getUsStatus.Type = 8;
                getUsStatus.ClientType = [FunctionClass sharedInstance].clientType;
                getUsStatus.userName = [FunctionClass sharedInstance].uId;
                NSMutableData *data = [getUsStatus getByteArray];
                [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:data proNum:0 len:318];
                [FunctionClass sharedInstance].getVideoHeader = NO;
            }
        }
            break;
        case 11:
        {
            NSLog(@"收到在线用户列表数据");
            NSMutableDictionary *array = [[FunctionClass sharedInstance] convertToUserList:[entity getData]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getOnlineUser" object:nil userInfo:@{@"getOnlineUser":array}];
        }
            break;
        default:
            NSLog(@"ucDataType-------------------------%d",ucDataType);
            break;
    }
    entity = nil;
}

/*** 处理视频头数据 ***/
- (void)dealWithVideoHeader:(RecivedEntity *)entity {
    NSData *data = [entity getData];
    VideoHeader *header = [VideoHeader getObject:data len:0];
    int nWidth = header.nWidth;
    int nHeight = header.nHeight;
    int nFrameRate = header.nFrameRate;
    [FunctionClass sharedInstance].nWidth = nWidth;
    [FunctionClass sharedInstance].nHeight = nHeight;
    [FunctionClass sharedInstance].nFrameRate = nFrameRate;
    [FunctionClass sharedInstance].bufOut = (uint8_t*)malloc([FunctionClass sharedInstance].nWidth * [FunctionClass sharedInstance].nHeight * sizeof(uint8_t));
    bufOut = nil;
    bufOut = (uint8_t*)malloc([FunctionClass sharedInstance].nWidth * [FunctionClass sharedInstance].nHeight * sizeof(uint8_t));
    player = nil;
    player = [FunctionClass sharedInstance].playerController;
}

/*** 处理指令消息 ***/
- (void)dealInstruct:(RecivedEntity *)entity {
    SendMessage *sendMessage = [SendMessage getObjectWithData:[entity getData] withLocation:0];
    int type = sendMessage.Type;
    switch (type) {
        case 0:
        {
            if (![FunctionClass sharedInstance].isLogin && [sendMessage.data containsString:@"1"]) {
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                [FunctionClass sharedInstance].isLogin = YES;
                //通知跳转
                [[NSNotificationCenter defaultCenter] postNotificationName:@"popToMain" object:nil];
                
            }
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            
        }
            break;
        case 10:
        {
            
        }
            break;
        case 11:
        {
            
        }
            break;
        case 12:
        {
            [SVProgressHUD dismiss];
            //连入确定判断
            
            if ([QMUIAlertController isAnyAlertControllerVisible]) {
                [alertController hideWithAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAlert" object:nil];
            }
            if ([sendMessage.data containsString:@"yes"]) {
                [[FunctionClass sharedInstance] validation:1 cnt:4 userName:sendMessage.userName targetUserName:sendMessage.targetUserName];
                [SVProgressHUD showSuccessWithStatus:@"连接成功"];
            }else if ([sendMessage.data containsString:@"unattended"]) {
                
            }else if ([sendMessage.data containsString:@"no"]) {
                [SVProgressHUD showErrorWithStatus:@"对方正在通话中，请稍后再连线"];
            }else if ([sendMessage.data containsString:@"s_no"]) {
                [SVProgressHUD showErrorWithStatus:@"不能连入该用户，请更换源用户"];
            }else {
                [self playSound];
                [FunctionClass sharedInstance].esm = sendMessage;
                NSString *mess;
                for (int i = 0; i < [FunctionClass sharedInstance].allUser.count; i ++) {
                    DesModel *model = [FunctionClass sharedInstance].allUser[i];
                    if ([[sendMessage.userName stringByReplacingOccurrencesOfString:@"\0" withString:@""] isEqualToString:[NSString stringWithFormat:@"%ld",model.uId]]) {
                        mess = [NSString stringWithFormat:@"%@ 请求连入",model.title];
                        break;
                    }
                }
                alertController = [QMUIAlertController alertControllerWithTitle:@"提示" message:mess preferredStyle:QMUIAlertControllerStyleAlert];
                QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"接受" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
                    //接受邀请
                    [[FunctionClass sharedInstance] connected:1];
                    [self.audioPlayer stop];
                }];
                QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"拒绝" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
                    //拒绝邀请
                    [[FunctionClass sharedInstance] connected:2];
                    [self.audioPlayer stop];
                }];
                
                [alertController addAction:action1];
                [alertController addAction:action2];
                [alertController showWithAnimated:YES];
            }
            
        }
            break;
        case 13:
        {
            [SVProgressHUD dismiss];
            //邀请判断
            if ([QMUIAlertController isAnyAlertControllerVisible]) {
                [alertController hideWithAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAlert" object:nil];
            }
            if ([sendMessage.data containsString:@"yes"]) {
                [[FunctionClass sharedInstance] validation:1 cnt:4 userName:sendMessage.targetUserName targetUserName:sendMessage.userName];
                [SVProgressHUD showWithStatus:@"正在等待对方确认"];
                [SVProgressHUD showSuccessWithStatus:@"连接成功"];
            }else if ([sendMessage.data containsString:@"unattended"]) {
                
            }else if ([sendMessage.data containsString:@"no"] || [sendMessage.data containsString:@"s_no"]) {
                [SVProgressHUD showErrorWithStatus:@"对方挂断"];
            }else {
                [self playSound];
                [FunctionClass sharedInstance].esm = sendMessage;
                NSString *mess;
                for (int i = 0; i < [FunctionClass sharedInstance].allUser.count; i ++) {
                    DesModel *model = [FunctionClass sharedInstance].allUser[i];
                    if ([[sendMessage.userName stringByReplacingOccurrencesOfString:@"\0" withString:@""] isEqualToString:[NSString stringWithFormat:@"%ld",model.uId]]) {
                        mess = [NSString stringWithFormat:@"%@ 邀请连入",model.title];
                    }
                }
                alertController = [QMUIAlertController alertControllerWithTitle:@"提示" message:mess preferredStyle:QMUIAlertControllerStyleAlert];
                QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"接受" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
                    //接受邀请
                    [[FunctionClass sharedInstance] invitation:1];
                    [self.audioPlayer stop];
                }];
                QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"拒绝" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
                    //拒绝邀请
                    [[FunctionClass sharedInstance] invitation:2];
                    [self.audioPlayer stop];
                }];
                
                [alertController addAction:action1];
                [alertController addAction:action2];
                [alertController showWithAnimated:YES];
            }
        }
            break;
        case 14:
        {
            
        }
            break;
        default:
            break;
    }
}

//处理通话组列表
- (void)dealCallListInfo:(RecivedEntity *)entity {
    NSLog(@"处理通话组列表");
    NSMutableArray *onlineCalls = [[FunctionClass sharedInstance] groupList:[entity getData] len:0];
    if (onlineCalls.count == 0) {
        //通话组没有人
        [ [ UIApplication sharedApplication] setIdleTimerDisabled:NO] ;
        if ([OnLine sharedObject].inStructList.count != 0) {
            [[FunctionClass sharedInstance] exitTalk];
            [[OnLine sharedObject].inStructList removeAllObjects];
            [FunctionClass sharedInstance].getVideoHeader = YES;
            thread = nil;
            [timer setFireDate:[NSDate distantFuture]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                myAudioClientingListEmpty();
            });
        }
    }else {
        //通话组有人
        //通话组有人时 设置屏幕常亮
        [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [[OnLine sharedObject] setInList:onlineCalls];
        if ([OnLine sharedObject].inStructList != nil && [OnLine sharedObject].inStructList.count > 0) {
            for (int i = 0; i < [OnLine sharedObject].inStructList.count; i ++) {
                UserStruct *user = [OnLine sharedObject].inStructList[i];
                if (user.sign == 3) {
                    //增加用户
                    int uid = user.info.uId;
                    const char* destDir = [[NSString stringWithFormat:@"%d",uid] UTF8String];
                    myAudioAddOrReleaseUser(destDir, YES);
                    myAudioClientingListNonEmpty();
                }else if (user.sign == 4) {
                    //减少用户
                    int uid = user.info.uId;
                    const char* destDir = [[NSString stringWithFormat:@"%d",uid] UTF8String];
                    myAudioAddOrReleaseUser(destDir, YES);
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callList" object:nil userInfo:@{@"callList":onlineCalls}];
}

- (void)startDecode {
    if (thread == nil) {
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(startTime) object:nil];
        [thread start];
    }
    completeList = [FunctionClass sharedInstance].completeMsgList;
}


- (void)startTime {
    @autoreleasepool {
        if (!timer) {
            timer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(handle) userInfo:nil repeats:YES];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            //如果注释了下面这一行，子线程中的任务并不能正常执行
            [runLoop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
            [runLoop run];
        }else {
            [timer setFireDate:[NSDate date]];
        }
    }
}

- (void)handle {
    if ([FunctionClass sharedInstance].completeMsgList.count > 1) {
        if ([[completeList objectAtIndex:0] isKindOfClass:[RecivedEntity class]]) {
            RecivedEntity *entity = (RecivedEntity *)[completeList objectAtIndex:0];
            [self handleVideoData:[entity getData]];
            entity = nil;
        }else {
            [completeList removeObjectAtIndex:0];
        }
    }
}
- (void)handleVideoData:(NSData *)data {
    if ([FunctionClass sharedInstance].runningInBackground) {
        return;
    }
    [player decodeH264:[data subdataWithRange:NSMakeRange(0, data.length-1)] withBufOut:bufOut];
    data = nil;
    [completeList removeObjectAtIndex:0];
}

- (void)writefile:(NSMutableData *)data
{
    NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *homePath = [paths objectAtIndex:0];
    
    NSString *filePath = [homePath stringByAppendingPathComponent:@"h264000"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath]) //如果不存在
    {
        
        [data writeToFile:filePath atomically:YES];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
    
    [fileHandle closeFile];
}

-(void) playSound
{
    NSURL *fileURL = [[NSBundle mainBundle]URLForResource:@"audio_invite" withExtension:@".mp3"];
    // 2.创建 AVAudioPlayer 对象
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    // 3.打印歌曲信息
    NSString *msg = [NSString stringWithFormat:@"音频文件声道数:%ld\n 音频文件持续时间:%g",self.audioPlayer.numberOfChannels,self.audioPlayer.duration];
    NSLog(@"%@",msg);
    // 4.设置循环播放
    self.audioPlayer.numberOfLoops = -1;
    // 5.开始播放
    [self.audioPlayer play];
    
}
@end
