//
//  GWDecoder.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/29.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "GWDecoder.h"
#import "FunctionClass.h"

@interface GWDecoder (){
    NSThread *thread;
    uint8_t* _vdata;
    size_t _vsize;
    
    uint8_t *_buf_out; // 原始接收的重组数据包
    
    uint8_t *_sps;
    size_t _spsSize;
    uint8_t *_pps;
    size_t _ppsSize;
    VTDecompressionSessionRef _deocderSession;
    CMVideoFormatDescriptionRef _decoderFormatDescription;
}

@end
@implementation GWDecoder
//解码回调函数
static void didDecompress(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef imageBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ) {
    
    if (status != noErr || imageBuffer == nil) {
        NSLog(@"Error decompresssing frame at time: %.3lld error: %d infoFlags: %u",
             presentationTimeStamp.value/presentationTimeStamp.timescale, status, infoFlags);
        return;
    }
    
    if (kVTDecodeInfo_FrameDropped & infoFlags) {
        NSLog(@"video frame droped");
        return;
    }
    
    //    int i,j;
    //    if (CVPixelBufferIsPlanar(imageBuffer)) {
    //        i  = (int)CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    //        j = (int)CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    //    } else {
    //        i  = (int)CVPixelBufferGetWidth(imageBuffer);
    //        j = (int)CVPixelBufferGetHeight(imageBuffer);
    //    }
    
    __weak GWDecoder *decoder = (__bridge GWDecoder *)decompressionOutputRefCon;
    if (decoder.delegate != nil) {
        CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
        *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
//        [decoder.delegate displayDecodedFrame:decoder.uid imageBuffer:imageBuffer];
    }
}


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
        NSDictionary* destinationPixelBufferAttributes = @{
                                                           (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
                                                           //硬解必须是 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
                                                           //                                                           或者是kCVPixelFormatType_420YpCbCr8Planar
                                                           //因为iOS是  nv12  其他是nv21
                                                           (id)kCVPixelBufferWidthKey : [NSNumber numberWithInt:[FunctionClass sharedInstance].nWidth],
                                                           (id)kCVPixelBufferHeightKey : [NSNumber numberWithInt:[FunctionClass sharedInstance].nHeight],
                                                           //这里款高和编码反的
                                                           (id)kCVPixelBufferOpenGLCompatibilityKey : [NSNumber numberWithBool:YES]
                                                           };
        
        
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
        status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                              _decoderFormatDescription,
                                              NULL,
                                              (__bridge CFDictionaryRef)destinationPixelBufferAttributes,
                                              &callBackRecord,
                                              &_deocderSession);
        VTSessionSetProperty(_deocderSession, kVTDecompressionPropertyKey_ThreadCount, (__bridge CFTypeRef)[NSNumber numberWithInt:1]);
        VTSessionSetProperty(_deocderSession, kVTDecompressionPropertyKey_RealTime, kCFBooleanTrue);
    } else {
        NSLog(@"IOS8VT: reset decoder session failed status=%d", status);
    }
    
    return YES;
}

-(CVPixelBufferRef)decode:(uint8_t *)frame withSize:(uint32_t)frameSize
{
    CVPixelBufferRef outputPixelBuffer = NULL;
    
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus status  = CMBlockBufferCreateWithMemoryBlock(NULL,
                                                          (void *)frame,
                                                          frameSize,
                                                          kCFAllocatorNull,
                                                          NULL,
                                                          0,
                                                          frameSize,
                                                          FALSE,
                                                          &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {frameSize};
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

-(void) decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize
{
    
    uint8_t* p = frame, *pf = NULL;
    size_t sz = frameSize;
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
                    pixelBuffer = [self decode:pf withSize:(nal_len + 4)];
                }
                break;
            case 0x07:
                NSLog(@"nalu_type:%d Nal type is SPS", nalu_type);
                if (_sps == NULL) {
                    _spsSize = nal_len;
                    _sps = (uint8_t*)malloc(_spsSize);
                    memcpy(_sps, &pf[4], _spsSize);
                }
                break;
            case 0x08:
                NSLog(@"nalu_type:%d Nal type is PPS", nalu_type);
                if (_pps == NULL) {
                    _ppsSize = nal_len;
                    _pps = (uint8_t*)malloc(_ppsSize);
                    memcpy(_pps, &pf[4], _ppsSize);
                }
                break;
            default:
                NSLog(@"nalu_type:%d Nal type is B/P frame", nalu_type);
                if ([self initH264Decoder]) {
                    pixelBuffer = [self decode:pf withSize:(nal_len + 4)];
                }
                break;
                
        }
        p += nal_start;
        p += nal_len;
        sz -= nal_end;
    }
}
@end
