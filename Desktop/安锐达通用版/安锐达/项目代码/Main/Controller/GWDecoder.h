//
//  GWDecoder.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/29.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVSampleBufferDisplayLayer.h>


@protocol GH264HwDecoderImplDelegate <NSObject>

- (void)displayDecodedFrame:(CVImageBufferRef )imageBuffer;

@end

@interface GWDecoder : NSObject
@property (weak, nonatomic) id<GH264HwDecoderImplDelegate> delegate;

-(BOOL)initH264Decoder;
-(void)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize;

@end
