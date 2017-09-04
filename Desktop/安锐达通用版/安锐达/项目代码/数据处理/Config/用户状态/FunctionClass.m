//
//  FunctionClass.m
//  安锐达
//
//  Created by 郭炜 on 2017/6/12.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "FunctionClass.h"
#import "SendMessage.h"
#import "Contains.h"
#import "UserInfo.h"
#import "OnLine.h"
#import "VideoPlayController.h"


@implementation FunctionClass
+ (FunctionClass *)sharedInstance
{
    static FunctionClass *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstace = [[self alloc] init];
        sharedInstace.esm = [[SendMessage alloc] init];
        sharedInstace.talkList = [[NSMutableArray alloc] init];
        sharedInstace.completeMsgList = [[NSMutableArray alloc] init];
        sharedInstace.tag = 0;
        sharedInstace.cacheData = [[NSMutableData alloc] init];
        sharedInstace.cacheDataList = [[NSMutableArray alloc] init];
        sharedInstace.allUser = [[NSMutableArray alloc] init];
        sharedInstace.playerController = [[VideoPlayController alloc] init];
        sharedInstace.getVideoHeader = YES;
        sharedInstace.isPlayout = YES;
        sharedInstace.isEnterForeFrmoBackground = NO;
    });
    return sharedInstace;
}

- (void)login {
    SendMessage *login = [[SendMessage alloc] init];
    login.Type = 0;
    login.ClientType = [FunctionClass sharedInstance].clientType;
    login.userName = [FunctionClass sharedInstance].uId;
    NSMutableData *data = [login getByteArray];
    [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:data proNum:0 len:318];
}

- (void)logOut {
    SendMessage *loginOut = [[SendMessage alloc] init];
    loginOut.Type = -1;
    loginOut.ClientType = [FunctionClass sharedInstance].clientType;
    loginOut.userName = [FunctionClass sharedInstance].uId;
    NSMutableData *data = [loginOut getByteArray];
    [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:data proNum:0 len:318];
}

- (NSMutableDictionary *)convertToUserList:(NSMutableData *)data {
    NSLog(@"%@",data);
    NSMutableDictionary *returnArray = [[NSMutableDictionary alloc] init];
    NSString *hexString = [data convertDataToHexStr:data];
    NSLog(@"%@",hexString);
    NSString *string = [NSString convertHexStrToString:hexString];
    NSArray *sArray = [string componentsSeparatedByString:@" "];
    for (int i = 0; i < sArray.count; i ++) {
        NSString *subString = sArray[i];
        if ([subString containsString:@"_"]) {
            NSRange range = [subString rangeOfString:@"_"];
            NSInteger location = range.location;
            //截取uId
            NSString *uId = [subString substringWithRange:NSMakeRange(0, location)];
            //截取type
            NSString *type = [subString substringWithRange:NSMakeRange(location+1, 1)];
            [returnArray setValue:type forKey:uId];
        }
    }
    NSLog(@"用户在线列表：%@",returnArray);
    return returnArray;
}

//转化为通话组列表
- (NSMutableArray *)groupList:(NSData *)data len:(int)len {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < (data.length - len)/64; i ++) {
        NSMutableData *buff = [[NSMutableData alloc] init];
        [buff appendData:[data subdataWithRange:NSMakeRange(i * 64 + len, 64)]];
//        NSString *buffString1 = [[NSString alloc] initWithData:buff encoding:NSUTF8StringEncoding];
//        NSString *hexString = [NSString convertStringToHexStr:buffString1];
//        NSString *buffString = [NSString convertHexStrToString:[hexString stringByReplacingOccurrencesOfString:@"0" withString:@""]];
        char *buffString1 = (char *)[buff bytes];
        NSString *buffString = [NSString stringWithCString:buffString1 encoding:NSUTF8StringEncoding];
        if (![buffString isEqualToString:@""] && buffString != nil) {
            if ([self isListObj:self.talkList string:buffString] != -1 || self.talkList.count == 0) {
                [array addObject:buffString];
            }else {
                [self.talkList addObject:buffString];
            }
        }
    }
    return array;
}

- (int)isListObj:(NSMutableArray *)array string:(NSString *)string {
    if (array.count>0) {
        for (int i = 0; i < array.count; i ++) {
            if ([array[i] isEqualToString:string]) {
                return i;
            }
        }
        return -1;
    }
    return -1;
}

//退出通话组
- (void)exitTalk {
    SendMessage *exitTalk = [[SendMessage alloc] init];
    exitTalk.Type = -2;
    exitTalk.ClientType = [FunctionClass sharedInstance].clientType;
    exitTalk.userName = [FunctionClass sharedInstance].uId;
    [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:[exitTalk getByteArray] proNum:0 len:318];
}
//连入 连入0，被连入1，不允许连入2
- (void)connected:(int)sign {
    SendMessage *connect = [[SendMessage alloc] init];
    connect.Type = 12;
    connect.ClientType = [FunctionClass sharedInstance].clientType;
    if (sign == 0) {
        connect.userName = [FunctionClass sharedInstance].uId;
        connect.targetUserName = [FunctionClass sharedInstance].targetUserName;
        connect.data = @"";
        if ([OnLine sharedObject].inStructList != nil) {
            if ([OnLine sharedObject].inStructList.count > 0) {
                [self exitTalk];
            }
        }
        [[OnLine sharedObject] exitInList];
    } else if (sign == 1) {
        connect.userName = self.esm.targetUserName;
        connect.targetUserName = self.esm.userName;
        connect.strOrderID = self.esm.strOrderID;
        connect.data = @"yes";
        if ([OnLine sharedObject].inStructList == nil) {
            [OnLine sharedObject].roomId = [[FunctionClass sharedInstance].uId intValue];
        }
    }else if (sign == 2) {
        connect.userName = self.esm.targetUserName;
        connect.targetUserName = self.esm.userName;
        connect.strOrderID = self.esm.strOrderID;
        connect.data = @"no";
    }
    [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:[connect getByteArray] proNum:0 len:318];
}

//邀请
- (void)invitation:(int)sign {
    SendMessage *sendMessage = [[SendMessage alloc] init];
    sendMessage.Type = 13;
    if (sign == 0) {
        sendMessage.userName = [FunctionClass sharedInstance].uId;
        sendMessage.targetUserName = [FunctionClass sharedInstance].targetUserName;
        sendMessage.data = @"";
        if ([OnLine sharedObject].inStructList == nil) {
            [OnLine sharedObject].roomId = [[FunctionClass sharedInstance].uId intValue];
        }
    }else if (sign == 1) {
        sendMessage.userName = self.esm.targetUserName;
        sendMessage.targetUserName = self.esm.userName;
        sendMessage.strOrderID = self.esm.strOrderID;
        sendMessage.data = @"yes";
        if ([OnLine sharedObject].inStructList != nil) {
            [OnLine sharedObject].roomId = -1;
            [[OnLine sharedObject] exitInList];
            [self exitTalk];
        }
    }else if (sign == 2) {
        sendMessage.userName = self.esm.targetUserName;
        sendMessage.targetUserName = self.esm.userName;
        sendMessage.strOrderID = self.esm.strOrderID;
        sendMessage.data = @"no";
    }
    [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:[sendMessage getByteArray] proNum:0 len:318];
}

//取消
- (void)cancel:(int)sign {
    SendMessage *sendMessage = [[SendMessage alloc] init];
    sendMessage.Type = 13;
    if (sign == 0) {
        sendMessage.userName = [FunctionClass sharedInstance].uId;
        sendMessage.targetUserName = [FunctionClass sharedInstance].targetUserName;
        sendMessage.data = @"drop";
        if ([OnLine sharedObject].inStructList == nil) {
            [OnLine sharedObject].roomId = [[FunctionClass sharedInstance].uId intValue];
        }
    }
    [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:[sendMessage getByteArray] proNum:0 len:318];
}
//确认函数
- (void)validation:(int)type cnt:(int)cnt userName:(NSString *)userName targetUserName:(NSString *)targetUserName {
    SendMessage *sendMessage = [[SendMessage alloc] init];
    if (type == 1) {
        sendMessage.Type = cnt;
        sendMessage.userName = [userName stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        sendMessage.targetUserName = [targetUserName stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    }
    [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:[sendMessage getByteArray] proNum:0 len:318];
    
}

-(BOOL)runningInBackground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateBackground);
    
    return result;
}

-(BOOL)runningInForeground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateActive);
    
    return result;
}

@end
