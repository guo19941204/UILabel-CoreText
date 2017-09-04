//
//  H264HwDecoderImpl.h
//  ShiPinHuiYi
//
//  Created by 徐杨 on 16/3/31.
//  Copyright (c) 2016年 feiyuxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVSampleBufferDisplayLayer.h>


@protocol H264HwDecoderImplDelegate <NSObject>

- (void)displayDecodedFrame:(CVImageBufferRef )imageBuffer;


@end

@interface H264HwDecoderImpl : NSObject
@property (weak, nonatomic) id<H264HwDecoderImplDelegate> delegate;
@property (nonatomic, assign) uint32_t uid;

-(BOOL)initH264Decoder;
- (BOOL)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize withBufOut:(uint8_t *)bufOut;
@end
