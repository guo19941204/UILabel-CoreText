//
//  VideoPlayerViewController.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/30.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "VideoFileParser.h"
#import "AAPLEAGLLayer.h"
#import <VideoToolbox/VideoToolbox.h>


@interface VideoPlayerViewController ()
{
    uint8_t *_sps;
    NSInteger _spsSize;
    uint8_t *_pps;
    NSInteger _ppsSize;
    VTDecompressionSessionRef _deocderSession;
    CMVideoFormatDescriptionRef _decoderFormatDescription;
    
    AAPLEAGLLayer *_glLayer;
}
@end

static void didDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

@implementation VideoPlayerViewController

-(BOOL)initH264Decoder {
    if(_deocderSession) {
        return YES;
    }
    
    const uint8_t* const parameterSetPointers[2] = { _sps, _pps };
    const size_t parameterSetSizes[2] = { _spsSize, _ppsSize };
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, //param count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4, //nal start code size
                                                                          &_decoderFormatDescription);
    
    if(status == noErr) {
        CFDictionaryRef attrs = NULL;
        const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
        //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
        //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
        uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
        attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = NULL;
        
        status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                              _decoderFormatDescription,
                                              NULL, attrs,
                                              &callBackRecord,
                                              &_deocderSession);
        CFRelease(attrs);
    } else {
        NSLog(@"IOS8VT: reset decoder session failed status=%d", status);
    }
    
    return YES;
}

-(void)clearH264Deocder {
    if(_deocderSession) {
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = NULL;
    }
    
    if(_decoderFormatDescription) {
        CFRelease(_decoderFormatDescription);
        _decoderFormatDescription = NULL;
    }
    
    free(_sps);
    free(_pps);
    _spsSize = _ppsSize = 0;
}

-(CVPixelBufferRef)decode:(VideoPacket*)vp {
    CVPixelBufferRef outputPixelBuffer = NULL;
    
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                          (void*)vp.buffer, vp.size,
                                                          kCFAllocatorNull,
                                                          NULL, 0, vp.size,
                                                          0, &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {vp.size};
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           _decoderFormatDescription ,
                                           1, 0, NULL, 1, sampleSizeArray,
                                           &sampleBuffer);
        if (status == kCMBlockBufferNoErr && sampleBuffer) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                                      sampleBuffer,
                                                                      flags,
                                                                      &outputPixelBuffer,
                                                                      &flagOut);
            
            if(decodeStatus == kVTInvalidSessionErr) {
                NSLog(@"IOS8VT: Invalid session, reset decoder session");
            } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                NSLog(@"IOS8VT: decode failed status=%d(Bad data)", decodeStatus);
            } else if(decodeStatus != noErr) {
                NSLog(@"IOS8VT: decode failed status=%d", decodeStatus);
            }
            
            CFRelease(sampleBuffer);
        }
        CFRelease(blockBuffer);
    }
    
    return outputPixelBuffer;
}
static int findNalUnit(uint8_t* buf, int size, int* nal_start, int* nal_end)
{
    int i;
    // find start
    *nal_start = 0;
    *nal_end = 0;
    i = 0;
    while (   //( next_bits( 24 ) != 0x000001 && next_bits( 32 ) != 0x00000001 )
           (buf[i] != 0 || buf[i+1] != 0 || buf[i+2] != 0x01) &&
           (buf[i] != 0 || buf[i+1] != 0 || buf[i+2] != 0 || buf[i+3] != 0x01)
           )
    {
        i++; // skip leading zero
        if (i+4 >= size)
        {
            return 0;
        } // did not find nal start
    }
    if  (buf[i] != 0 || buf[i+1] != 0 || buf[i+2] != 0x01) // ( next_bits( 24 ) != 0x000001 )
    {
        i++;
    }
    if  (buf[i] != 0 || buf[i+1] != 0 || buf[i+2] != 0x01)
    {
        /* error, should never happen */
        return 0;
    }
    i+= 3;
    *nal_start = i;
    while (   //( next_bits( 24 ) != 0x000000 && next_bits( 24 ) != 0x000001 )
           (buf[i] != 0 || buf[i+1] != 0 || buf[i+2] != 0) &&
           (buf[i] != 0 || buf[i+1] != 0 || buf[i+2] != 0x01)
           )
    {
        i++;
        // FIXME the next line fails when reading a nal that ends exactly at the end of the data
        if (i+3 >= size)
        {
            *nal_end = size;
            return (*nal_end - *nal_start);//return -1;
        } // did not find nal end, stream ended first
    }
    *nal_end = i;
    return (*nal_end - *nal_start);
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
        
        uint8_t* p = vp.buffer, *pf = NULL;
        size_t sz = vp.size;
        int nal_start = 0, nal_end = 0;
        
        while (![[NSThread currentThread] isCancelled] && findNalUnit(p, sz, &nal_start, &nal_end) > 0) {
            CVPixelBufferRef pixelBuffer = NULL;
            int nalu_type = p[nal_start] & 0x1f;
            int nal_len = nal_end - nal_start;
            uint8_t *pnal_size = (uint8_t*)(&nal_len);
            //{(uint8_t)(nal_len >> 24), (uint8_t)(nal_len >> 16), (uint8_t)(nal_len >> 8), (uint8_t)nal_len};
            if (nal_start == 3) { //big-endian
                p[-1] = *(pnal_size + 3);
                p[0]  = *(pnal_size + 2);
                p[1]  = *(pnal_size + 1);
                p[2]  = *(pnal_size);
                pf = p - 1;
            }
            else if (nal_start == 4) {
                p[0] = *(pnal_size + 3);
                p[1] = *(pnal_size + 2);
                p[2] = *(pnal_size + 1);
                p[3] = *(pnal_size);
                pf = p;
            }
            //    NSLog(@">>>>>>>>>>开始解码");
            //    int nalu_type = (frame[4] & 0x1F);
            //    CVPixelBufferRef pixelBuffer = NULL;
            //    uint32_t nalSize = (uint32_t)(frameSize - 4);
            //    uint8_t *pNalSize = (uint8_t*)(&nalSize);
            //    frame[0] = *(pNalSize + 3);
            //    frame[1] = *(pNalSize + 2);
            //    frame[2] = *(pNalSize + 1);
            //    frame[3] = *(pNalSize);
            //传输的时候。关键帧不能丢数据 否则绿屏   B/P可以丢  这样会卡顿
            switch (nalu_type)
            {
                case 0x05:
                    NSLog(@"nalu_type:%d Nal type is IDR frame", nalu_type);
                    if ([self initH264Decoder]) {
                        vp.buffer = pf;
                        vp.size = nal_len+4;
                        pixelBuffer = [self decode:vp];
                    }
                    break;
                case 0x07:
                    NSLog(@"nalu_type:%d Nal type is SPS", nalu_type);
                    free(_sps);
                    _spsSize = 0;
                    _spsSize = nal_len;
                    _sps = (uint8_t*)malloc(_spsSize);
                    memcpy(_sps, &pf[4], _spsSize);
                    break;
                case 0x08:
                    NSLog(@"nalu_type:%d Nal type is PPS", nalu_type);
                    free(_pps);
                    _ppsSize = 0;
                    _ppsSize = nal_len;
                    _pps = (uint8_t*)malloc(_ppsSize);
                    memcpy(_pps, &pf[4], _ppsSize);
                    break;
                default:{
                    NSLog(@"nalu_type:%d Nal type is B/P frame", nalu_type);
                    vp.buffer = pf;
                    vp.size = nal_len+4;
                    pixelBuffer = [self decode:vp];
                }
                    break;
            }
            if(pixelBuffer) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    _glLayer.pixelBuffer = pixelBuffer;
                });
                
                CVPixelBufferRelease(pixelBuffer);
            }
            
            p += nal_start;
            p += nal_len;
            sz -= nal_end;
        }
    }
}

-(IBAction)on_playButton_clicked:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self decodeFile:@"test1080p" fileExt:@"h264"];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _glLayer = [[AAPLEAGLLayer alloc] initWithFrame:self.view.bounds];
    [self.view.layer addSublayer:_glLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
