//
//  AppDelegate.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;

@end

