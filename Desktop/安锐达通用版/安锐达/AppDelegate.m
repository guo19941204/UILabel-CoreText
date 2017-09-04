//
//  AppDelegate.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "AppDelegate.h"
#import "QMUIConfigurationTemplate.h"
#import "Contains.h"
#import "LoginViewController.h"
#import "UIImage+GIF.h"
#import "DataProcessThread.h"
#import "FunctionClass.h"
#import "RLUncaughtExceptionHandler.h"
#import <sys/time.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 启动QMUI的配置模板
    [QMUIConfigurationTemplate setupConfigurationTemplate];
    
    // 将状态栏设置为希望的样式
    [QMUIHelper renderStatusBarStyleLight];
    InstallUncaughtExceptionHandler();
    [FunctionClass sharedInstance].port = PORT;
    [FunctionClass sharedInstance].host = API_HOST;
    // 界面
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[LoginViewController new]];
    [self.window makeKeyAndVisible];
    
    // 启动动画
    [self startLaunchingAnimation];
    
    return YES;
}

- (void)startLaunchingAnimation {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIView *launchScreenView = [[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil].firstObject;
    launchScreenView.frame = window.bounds;
    [window addSubview:launchScreenView];
    UIImageView *backGroundView = launchScreenView.subviews[0];
    backGroundView.image = [UIImage sd_animatedGIFNamed:@"loading"];
    
    [self animationWithView:backGroundView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0 animations:^{
            backGroundView.alpha = 0;
        }completion:^(BOOL finished) {
            [launchScreenView removeFromSuperview];
        }];
    });
}

- (void)animationWithView:(UIImageView *)view {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithInteger:1];
    animation.toValue = [NSNumber numberWithInteger:5];
    animation.duration = 1.1;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    animation.beginTime = CACurrentMediaTime()+3.0f;
    [view.layer addAnimation:animation forKey:@"scaleAnimation"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // app从后台进入前台都会调用这个方法
    [FunctionClass sharedInstance].isEnterForeFrmoBackground = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 使用这个方法来释放公共的资源、存储用户数据、停止我们定义的定时器（timers）、并且存储在程序终止前的相关信息。
    // 如果，我们的应用程序提供了后台执行的方法，那么，在程序退出时，这个方法将代替applicationWillTerminate方法的执行。
    
    
    // 标记一个长时间运行的后台任务将开始
    // 通过调试，发现，iOS给了我们额外的10分钟（600s）来执行这个任务。
    self.backgroundTaskIdentifier =[application beginBackgroundTaskWithExpirationHandler:^(void) {
        
        // 当应用程序留给后台的时间快要到结束时（应用程序留给后台执行的时间是有限的）， 这个Block块将被执行
        // 我们需要在次Block块中执行一些清理工作。
        // 如果清理工作失败了，那么将导致程序挂掉
        
        // 清理工作需要在主线程中用同步的方式来进行
        [self endBackgroundTask];
    }];
    
    // 模拟一个Long-Running Task
    self.myTimer =[NSTimer scheduledTimerWithTimeInterval:1.0f
                                                   target:self
                                                 selector:@selector(timerMethod:)     userInfo:nil
                                                  repeats:YES];
}

- (void) endBackgroundTask{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            [strongSelf.myTimer invalidate];// 停止定时器
            
            // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
            // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
            // 也就是要告诉应用程序：“好借好还”嘛。
            // 标记指定的后台任务完成
            [[UIApplication sharedApplication]endBackgroundTask:self.backgroundTaskIdentifier];
            // 销毁后台任务标识符
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}

// 模拟的一个 Long-Running Task 方法
- (void) timerMethod:(NSTimer *)paramSender{
    // backgroundTimeRemaining 属性包含了程序留给的我们的时间
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication]backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
    }
}

@end
