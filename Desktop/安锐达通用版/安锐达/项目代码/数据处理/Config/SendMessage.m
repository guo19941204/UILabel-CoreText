//
//  SendMessage.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/8.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "SendMessage.h"
#import <string.h>
#import "Contains.h"
#import "YMSocketUtils.h"

@interface SendMessage ()

@end
@implementation SendMessage

- (instancetype)init {
    if (self = [super init]) {
        self.Type = 0;
        self.strOrderID = @"";
        self.data = @"";
        self.userName = @"";
        self.targetUserName = @"";
        self.ClientType = 0;
        self.ClientStatus = 0;
        self.HostName = @"";
        self.IP = @"";
        self.SocketService = @"";
    }
    return self;
}
#pragma mark -- 拼接byte --
- (NSMutableData *)getByteArray {
    NSMutableData *data = [NSMutableData new];
    @try {
        //4
        [data appendData:[YMSocketUtils bytesFromUInt32:self.Type]];
        //30
        [data appendData:[self dataWithShortData:[[Util getString:self.strOrderID] dataUsingEncoding:NSUTF8StringEncoding] tagetLength:30]];
        //128
        [data appendData:[self dataWithShortData:[[Util getString:self.data] dataUsingEncoding:NSUTF8StringEncoding] tagetLength:128]];
        //8
        [data appendData:[self dataWithShortData:[[Util getString:self.userName] dataUsingEncoding:NSUTF8StringEncoding] tagetLength:8]];
        //8
        [data appendData:[self dataWithShortData:[[Util getString:self.targetUserName] dataUsingEncoding:NSUTF8StringEncoding] tagetLength:8]];
        //4
        [data appendData:[YMSocketUtils bytesFromUInt32:self.ClientType]];
        //4
        [data appendData:[YMSocketUtils bytesFromUInt32:self.ClientStatus]];
        //64
        [data appendData:[self dataWithShortData:[[Util getString:self.HostName] dataUsingEncoding:NSUTF8StringEncoding] tagetLength:64]];
        //64
        [data appendData:[self dataWithShortData:[[Util getString:self.IP] dataUsingEncoding:NSUTF8StringEncoding] tagetLength:64]];
        //4
        [data appendData:[self dataWithShortData:[[Util getString:self.SocketService] dataUsingEncoding:NSUTF8StringEncoding] tagetLength:4]];
    } @catch (NSException *exception) {
        
    }

    return data;
}

- (NSMutableData *)dataWithShortData:(NSData *)shortData tagetLength:(int)lenth {
    int shortDataLenth = (int)shortData.length;
    if (lenth < shortDataLenth) {
        return [NSMutableData dataWithBytes:nil length:lenth];
    }
    NSMutableData *returnData = [[NSMutableData alloc] init];
    [returnData appendData:shortData];
    [returnData appendData:[NSMutableData dataWithLength:lenth-shortDataLenth]];
    return returnData;
}

+ (SendMessage *)getObjectWithData:(NSData *)data withLocation:(int)location {
    
    SendMessage *sendMessage = [[SendMessage alloc] init];
    sendMessage.Type = (uint32_t)[YMSocketUtils valueFromBytes:[data subdataWithRange:NSMakeRange(location, 4)]];
    sendMessage.strOrderID = [NSString stringWithCString:[[data subdataWithRange:NSMakeRange(location+4, 30)] bytes] encoding:NSUTF8StringEncoding];
    sendMessage.data = [NSString stringWithCString:[[data subdataWithRange:NSMakeRange(location+34, 128)] bytes] encoding:NSUTF8StringEncoding];
    sendMessage.userName = [NSString stringWithCString:[[data subdataWithRange:NSMakeRange(location+34+96+32, 2)] bytes] encoding:NSUTF8StringEncoding];
    sendMessage.targetUserName = [NSString stringWithCString:[[data subdataWithRange:NSMakeRange(location+66 + 8 + 96, 2)] bytes] encoding:NSUTF8StringEncoding];
    sendMessage.ClientType = [YMSocketUtils uint32FromBytes:[data subdataWithRange:NSMakeRange(location+66 + 8 + 8 + 96, 4)]];
    sendMessage.ClientStatus = [YMSocketUtils uint32FromBytes:[data subdataWithRange:NSMakeRange(location+86 + 96, 4)]];
    return sendMessage;
}


@end
