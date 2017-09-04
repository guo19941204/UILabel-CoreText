//
//  VideoPlayController.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/23.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "QMUICommonViewController.h"

@interface VideoPlayController : QMUICommonViewController

- (void)decodeH264:(NSData *)data withBufOut:(uint8_t *)bufOut;

- (UIImage *)imageWithImageBuffer;
@end
