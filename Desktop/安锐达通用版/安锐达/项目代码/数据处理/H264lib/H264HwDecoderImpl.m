//
//  WBH264Decoder.mm
//
//  Created by zhouweiwei on 16/11/20.
//  Copyright © 2016年 zhouweiwei. All rights reserved.
//

#import "H264HwDecoderImpl.h"
#import "FunctionClass.h"

/**
 Find the beginning and end of a NAL (Network Abstraction Layer) unit in a byte buffer containing H264 bitstream data.
 @param[in]   buf        the buffer
 @param[in]   size       the size of the buffer
 @param[out]  nal_start  the beginning offset of the nal
 @param[out]  nal_end    the end offset of the nal
 @return                 the length of the nal, or 0 if did not find start of nal, or -1 if did not find end of nal
 */

static int find_nal_unit(uint8_t* buf, int size, int* nal_start, int* nal_end)
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

static const uint8_t *avc_find_startcode_internal(const uint8_t *p, const uint8_t *end)
{
    const uint8_t *a = p + 4 - ((intptr_t)p & 3);
    
    for (end -= 3; p < a && p < end; p++) {
        if (p[0] == 0 && p[1] == 0 && p[2] == 1)
            return p;
    }
    
    for (end -= 3; p < end; p += 4) {
        uint32_t x = *(const uint32_t*)p;
        //      if ((x - 0x01000100) & (~x) & 0x80008000) // little endian
        //      if ((x - 0x00010001) & (~x) & 0x00800080) // big endian
        if ((x - 0x01010101) & (~x) & 0x80808080) { // generic
            if (p[1] == 0) {
                if (p[0] == 0 && p[2] == 1)
                    return p;
                if (p[2] == 0 && p[3] == 1)
                    return p+1;
            }
            if (p[3] == 0) {
                if (p[2] == 0 && p[4] == 1)
                    return p+2;
                if (p[4] == 0 && p[5] == 1)
                    return p+3;
            }
        }
    }
    
    for (end += 3; p < end; p++) {
        if (p[0] == 0 && p[1] == 0 && p[2] == 1)
            return p;
    }
    
    return end + 3;
}

static const uint8_t *avc_find_startcode(const uint8_t *p, const uint8_t *end)
{
    const uint8_t *out = avc_find_startcode_internal(p, end);
    if (p < out && out < end && !out[-1]) out--;
    return out;
}

@interface H264HwDecoderImpl()
{
    uint16_t _out_width;
    uint16_t _out_height;
    
    uint8_t* _vdata;
    size_t _vsize;
    
    uint8_t *_buf_out; // 原始接收的重组数据包
    
    uint8_t *_sps;
    size_t _spsSize;
    uint8_t *_pps;
    size_t _ppsSize;
    VTDecompressionSessionRef _deocderSession;
    CMVideoFormatDescriptionRef _decoderFormatDesc;
}
@property (strong, nonatomic) NSThread *thread;

@end

@implementation H264HwDecoderImpl

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
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
    H264HwDecoderImpl *decoder = (__bridge H264HwDecoderImpl *)decompressionOutputRefCon;
    if (decoder != nil && decoder.delegate != nil) {
        [decoder.delegate displayDecodedFrame:imageBuffer];
    }
}

- (BOOL)initH264Decoder {
    if (_deocderSession != nil) {
        return YES;
    }
    
    if (!_sps || !_pps || _spsSize == 0 || _ppsSize == 0) {
        return NO;
    }
    
    const uint8_t* const parameterSetPointers[2] = { _sps, _pps };
    const size_t parameterSetSizes[2] = { _spsSize, _ppsSize };
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, //param count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4, //nal start code size
                                                                          &_decoderFormatDesc);
    if (status == noErr) {
        NSDictionary* destinationPixelBufferAttributes = @{
                                                           (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
                                                           //硬解必须是 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange 或者是kCVPixelFormatType_420YpCbCr8Planar
                                                           //因为iOS是nv12  其他是nv21
                                                           , (id)kCVPixelBufferWidthKey  : [NSNumber numberWithInt:[FunctionClass sharedInstance].nWidth]
                                                           , (id)kCVPixelBufferHeightKey : [NSNumber numberWithInt:[FunctionClass sharedInstance].nHeight]
                                                           //, (id)kCVPixelBufferBytesPerRowAlignmentKey : [NSNumber numberWithInt:_out_width*2]
                                                           , (id)kCVPixelBufferOpenGLCompatibilityKey : [NSNumber numberWithBool:NO]
                                                           , (id)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]
                                                           };
        
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
        
        status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                              _decoderFormatDesc,
                                              NULL,
                                              (__bridge CFDictionaryRef)destinationPixelBufferAttributes,
                                              &callBackRecord,
                                              &_deocderSession);
        VTSessionSetProperty(_deocderSession, kVTDecompressionPropertyKey_ThreadCount, (__bridge CFTypeRef)[NSNumber numberWithInt:1]);
        VTSessionSetProperty(_deocderSession, kVTDecompressionPropertyKey_RealTime, kCFBooleanTrue);
    } else {
        NSLog(@"reset decoder session failed status=%d", status);
        return NO;
    }
    
    return YES;
}

- (BOOL)resetH264Decoder {
    if(_deocderSession) {
        VTDecompressionSessionWaitForAsynchronousFrames(_deocderSession);
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = NULL;
    }
    return [self initH264Decoder];
}

- (CVPixelBufferRef)decode:(uint8_t *)frame withSize:(uint32_t)frameSize {
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
        //        const size_t sampleSizeArray[] = {frameSize};
        //        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
        //                                           blockBuffer,
        //                                           _decoderFormatDescription,
        //                                           1, 0, NULL, 1, sampleSizeArray,
        //                                           &sampleBuffer);
        status = CMSampleBufferCreate(NULL, blockBuffer, TRUE, 0, 0, _decoderFormatDesc, 1, 0, NULL, 0, NULL, &sampleBuffer);
        
        if (status == kCMBlockBufferNoErr && sampleBuffer) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            status = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                       sampleBuffer,
                                                       flags,
                                                       &outputPixelBuffer,
                                                       &flagOut);
            
            if (status == kVTInvalidSessionErr) {
                NSLog(@"Invalid session, reset decoder session");
                [self resetH264Decoder];
            } else if(status == kVTVideoDecoderBadDataErr) {
                NSLog(@"decode failed status=%d(Bad data)", status);
            } else if(status != noErr) {
                NSLog(@"decode failed status=%d", status);
            } else {
                status = VTDecompressionSessionWaitForAsynchronousFrames(_deocderSession);
            }
            CFRelease(sampleBuffer);
        }
    }
    CFRelease(blockBuffer);
    
    return outputPixelBuffer;
}

- (BOOL)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize withBufOut:(uint8_t *)bufOut {
    // LOGD(@">>>>>>>>>>开始解码");

    if (frame == NULL || frameSize == 0)
        return NO;
    
    uint32_t size = frameSize;
    const uint8_t *p = frame;
    const uint8_t *end = p + size;
    const uint8_t *nal_start, *nal_end;
    int nal_len, nalu_type;
    
    size = 0;
    nal_start = avc_find_startcode(p, end);
    while (![[NSThread currentThread] isCancelled]) {
        while (![[NSThread currentThread] isCancelled] && nal_start < end && !*(nal_start++));
        if (nal_start == end)
            break;
        
        nal_end = avc_find_startcode(nal_start, end);
        nal_len = (int)(nal_end - nal_start);
        
        nalu_type = nal_start[0] & 0x1f;
        if (nalu_type == 0x07) {
            if (_sps == NULL) {
                _spsSize = nal_len;
                _sps = (uint8_t*)malloc(_spsSize);
                memcpy(_sps, nal_start, _spsSize);
            }
        }
        else if (nalu_type == 0x08) {
            if (_pps == NULL) {
                _ppsSize = nal_len;
                _pps = (uint8_t*)malloc(_ppsSize);
                memcpy(_pps, nal_start, _ppsSize);
            }
        }
        else {
            bufOut[size]     = (uint8_t)(nal_len >> 24);
            bufOut[size + 1] = (uint8_t)(nal_len >> 16);
            bufOut[size + 2] = (uint8_t)(nal_len >> 8 );
            bufOut[size + 3] = (uint8_t)(nal_len);
            
            memcpy(bufOut + 4 + size, nal_start, nal_len);
            size += 4 + nal_len;
        }
        
        nal_start = nal_end;
    }
    
    if ([self initH264Decoder]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [self decode:bufOut withSize:size];
    }
    
    frame = nil;
    return size > 0 ? YES : NO;
}

@end
