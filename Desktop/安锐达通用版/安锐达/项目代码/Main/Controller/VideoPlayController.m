//
//  VideoPlayController.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/23.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "VideoPlayController.h"
#import "AAPLEAGLLayer.h"
#include <stdio.h>
#import "H264HwDecoderImpl.h"
#import "H264HwEncoderImpl.h"
#import "Contains.h"
#import "VideoFileParser.h"
#import "FunctionClass.h"
#define clamp(a) (a>255?255:(a<0?0:a))

@interface VideoPlayController ()<H264HwDecoderImplDelegate> {
    AVCaptureSession *captureSession;
    AVCaptureConnection* connectionVideo;
    AVCaptureDevice *cameraDeviceB;
    AVCaptureDevice *cameraDeviceF;
    
    BOOL cameraDeviceIsF;
    
    H264HwEncoderImpl *h264Encoder;
    AVCaptureVideoPreviewLayer *recordLayer;
    
    H264HwDecoderImpl *h264Decoder;
    AAPLEAGLLayer *playLayer;
}

@end

@implementation VideoPlayController

- (void)initSubviews {
    [super initSubviews];
    
    h264Decoder = [[H264HwDecoderImpl alloc] init];
    h264Decoder.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLayer) name:@"addLayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLayer) name:@"removeLayer" object:nil];

    playLayer = [[AAPLEAGLLayer alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view.layer addSublayer:playLayer];
    [self addLayer];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self decodeFile:@"ck1080P" fileExt:@"264"];
//    });
}

- (void)addLayer {
    if (playLayer.sublayers.count == 0) {
        UIImage *image = [UIImage imageNamed:@"5"];
        CALayer *imageLayer = [CALayer layer];
        imageLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        imageLayer.contents = (id)image.CGImage;
        [playLayer addSublayer:imageLayer];
    }
}

- (void)removeLayer {
    if (playLayer.sublayers[0]) {
        [playLayer.sublayers[0] removeFromSuperlayer];
    }
}

- (void)decodeH264:(NSData *)data withBufOut:(uint8_t *)bufOut {

    [h264Decoder decodeNalu:(uint8_t *)[data bytes] withSize:(uint32_t)data.length withBufOut:bufOut];
    data = nil;
}

-(void)decodeFile:(NSString*)fileName fileExt:(NSString*)fileExt {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt];
    VideoFileParser *parser = [VideoFileParser alloc];
    [parser open:path];
    
    VideoPacket *vp = nil;
    while(true) {
        vp = [parser nextPacket];
        if(vp == nil) {
            break;
        }
        [h264Decoder decodeNalu:vp.buffer withSize:vp.size withBufOut:[FunctionClass sharedInstance].bufOut];
    }
}

- (void)displayDecodedFrame:(CVImageBufferRef)imageBuffer {
    if(imageBuffer)
    {
        dispatch_main_async_safe(^{
            playLayer.pixelBuffer = imageBuffer;
            
            CVPixelBufferRelease(imageBuffer);

        })
        
        }
}

- (UIImage *)imageWithImageBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer =  playLayer.pixelBuffer;
    
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    uint8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    uint8_t *cbCrBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = malloc(width * height * bytesPerPixel);
    
    for(int y = 0; y < height; y++) {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
        
        for(int x = 0; x < width; x++) {
            int16_t y = yBufferLine[x];
            int16_t cb = cbCrBufferLine[x & ~1] - 128;
            int16_t cr = cbCrBufferLine[x | 1] - 128;
            
            uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];
            
            int16_t r = (int16_t)roundf( y + cr *  1.4 );
            int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
            int16_t b = (int16_t)roundf( y + cb *  1.765);
            
            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}
@end
