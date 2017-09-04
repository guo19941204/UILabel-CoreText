//
//  MyAudioCC.h
//  LastWebRTC
//
//  Created by 郭炜 on 2017/7/19.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#ifndef __c_cantian_oc__COCFile_State_1__
#define __c_cantian_oc__COCFile_State_1__
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string>
#include <list>
#include <pthread.h>

#import "MyAudioCC.h"
#include "voe_audio_processing.h"
#include "voe_base.h"
#include "voe_dtmf.h"
#include "voe_errors.h"
#include "voe_file.h"
#include "voe_rtp_rtcp.h"
#include "voe_call_report.h"
#include "voe_codec.h"
#include "voe_encryption.h"
#include "voe_external_media.h"
#include "voe_hardware.h"
#include "voe_network.h"
#include "voe_video_sync.h"
#include "voe_volume_control.h"
#include "common_types.h"
#include "tick_util.h"
#import <Foundation/Foundation.h>


/*****************************************************************************************************************/
//音频头，目前没用
/*****************************************************************************************************************/
struct WebrtcAudioHeader
{
    char Codecname[32] = {0};                  //音频编码方式
    unsigned short FS = 0;                      // 音频采样频率
    unsigned short pt = 0;                     //音频采样位数
    unsigned short rate = 0;                  //音频带宽
    unsigned short ch = 0;                     //音频通道数
    unsigned short size = 0;                  //音频数据包大小
    unsigned int IsHaveAudio = false;      //是否有音频包
};

/*****************************************************************************************************************/
//webrtc的音频传输回调,用于获取要发送的音频数据，送到java层发送
/*****************************************************************************************************************/
class VoeExTP : public webrtc::Transport
{
public:
    NSMutableData *allData = [[NSMutableData alloc] init];
    VoeExTP(int sender_channel, unsigned int localSSRC);
    ~VoeExTP();
    virtual int SendPacket(int channel, const void *data, int len);      //rtp包
    virtual int SendRTCPPacket(int channel, const void *data, int len);   //rtcp包
    void EnableN2NTrans(bool bN2N);   //开关多对多传输
    void Init(const std::string& strName);   //初始化
    void Release();  //卸载
    void file();
private:
    int m_nOuterAudioChannel = 0;     //从这个通道往外发包
    int m_nRtpPacket = 0;    //rtp包
    int m_nRtcpPacket = 0;   //rtcp包
    WebRtc_UWord32 m_nLocalSSRC = 0;        //内部SSRC
    bool m_bN2N = false;
    std::string m_strLogonName = "";    //登录名
    bool m_bCanUse = false;   //是否能用
};

/*****************************************************************************************************************/
//用于多对多时接收音频数据
/*****************************************************************************************************************/
class VoeN2NExTP : public webrtc::Transport
{
public:
    VoeN2NExTP();
    ~VoeN2NExTP();
    virtual int SendPacket(int channel, const void *data, int len);            //多对多时只接收别人发过来的数据
    virtual int SendRTCPPacket(int channel, const void *data, int len);
    
public:
    int nChannel;    //接收音频数据的通道
    bool bPlaying;      //是该通道在播放
    bool bReceiving;    //是否该通道在接收
    int nRtpPackNum;     //接收的rtp包的数量
    int nRtcpPackNum;    //接收的rtcp包的数量
};

/*****************************************************************************************************************/
//音频处理类
/*****************************************************************************************************************/
class CWebRtcAudioStream
{
public:
    CWebRtcAudioStream();
    ~CWebRtcAudioStream();
    
    bool Init(bool enableWebrtcAuLog);              //初始化
    void InitFalse();
    void Release();       //销毁
    bool CreateChannel();  //创建音频通道
    bool SetupCodecSetting(const int idx);      //按给定的序号设置音频编解码
    bool SetupExSender(const std::string& strName);              //设置传输回调
    void ReleaseExSender();					//卸载传输回调
    bool StartSend();       //开始传输，对于音频引擎，开始传输的同时也开始录音,必须先设置扩展传输类
    bool StopSend();      //停止传输，停止了传输之后别人也听不到你的声音了
    bool StartAudioPlayout();     //开始播放
    bool StopAudioPlayout();     //停止播放
    bool StartReceive();     //开始接收
    bool StopReceive();     //停止接收
    bool ReceivedN2NRtpData(char* pDataBuffer, int nLen);      //主动接收rtp包
    void EnableAllN2NReceiving(bool bAllN2N);       //允许多对多接收
    bool AddN2NUser(const char* userID);         //添加一个用户，发过来的为该用户对应的服务器id
    bool ReleaseN2NUser(const char* username);      //删除一个用户
    void ReleaseN2NUsers();         //删除所有用户
    
    
public:
    //webrtc引擎接口
    webrtc::VoiceEngine*			m_pVoeEngine;             //webrtc音频引擎
    webrtc::VoEBase*				m_pVoeBase;				//音频引擎的一些基本接口
    webrtc::VoECodec*				m_pVoeCodec;				//编解码
    webrtc::VoEEncryption*		    m_pVoeEncrypt;			//加解密
    webrtc::VoEHardware*            m_pVoeHardware;			//音频硬件
    webrtc::VoENetwork*             m_pVoeNetwork;				//网络
    webrtc::VoERTP_RTCP*            m_pVoeRtpRtcp;				//RtpRtcp协议
    webrtc::VoEVolumeControl*       m_pVoeVolumeControl;      //音量控制
    webrtc::VoEAudioProcessing*     m_pVoe_apm;           //音频处理
    int                             m_nAudioChannel;     //视频通道，用来输出采集的数据，也可以同时接收网络过来的数据
    WebrtcAudioHeader  audioHeader;
    
private:
    webrtc::CodecInst m_CodecInst;     //voe的编码
    bool m_bInit;      //是否初始化成功
    VoeExTP* m_pSender;     //传输时的回调
    bool m_bSending;    //是否在发送数据
    bool m_bReceiving;  //是否在接收数据，接收p2p
    bool m_bRecording;    //是否录音本地数据
    bool m_bReceivingN2N;   //n2n
    unsigned int m_nRtpPackNum;     //接收到的rtp包的数量
    unsigned int m_nRtcpPackNum;    //接收到的rtcp包的数量
    unsigned int m_nFirstRTPRecvSSRC;     //接收过来的第一个rtp包的ssrc
    std::map<std::string,VoeN2NExTP*> m_Userlist;       //正在与该用户进行多对多的用户
};


bool myAudioInit(bool enableWebrtcAuLog, const std::string& logonName);  //初始化
void myAudioRelease();  //卸载
void myAudioAddOrReleaseUser(const std::string& uid, bool bAdd);  //通话组变动，有人加入或退出
void myAudioClientingListNonEmpty();  //通话组发生变动，通话组不为空
void myAudioClientingListEmpty();  //通话组发生变动，通话组为空了
void myAudioReceiveAuBuffer(char* auBufContainer, int nlen);  //接收音频数据
void myAudioStopReveiveAuBuffer();
void myAudioReveive();
void myAudioStopSend();
void myAudioSend();

#endif
