//
//  MyAudioCC.m
//  LastWebRTC
//
//  Created by 郭炜 on 2017/7/19.
//  Copyright © 2017年 郭炜. All rights reserved.
//
#include "MyAudioCC.h"
#import "ExchangeSocketServe.h"

#define WEBRTC_LOG_TAG @"WEBRTC_LOG_TAG"
/*****************************************************************************************************************/
//VoeExTP类的实现
/*****************************************************************************************************************/
VoeExTP::VoeExTP(int sender_channel, unsigned int localSSRC)
{
    m_nOuterAudioChannel = sender_channel;        //webrtc的通道号
    m_nLocalSSRC = localSSRC;
}

VoeExTP::~VoeExTP()
{
}

void VoeExTP::EnableN2NTrans(bool bN2N)
{
    m_bN2N = bN2N;
}

int VoeExTP::SendPacket(int channel, const void *data, int len)
{
    ++m_nRtpPacket;
    if (channel == m_nOuterAudioChannel && true == m_bN2N && true == m_bCanUse)
    {
        Byte* pPacket = new Byte[len+8];
        memcpy(pPacket,data,len);//填充pData
        memcpy(pPacket+len,m_strLogonName.c_str(),m_strLogonName.length());//填充数据来源用户名
        pPacket[len + m_strLogonName.length()]='\0';
        //////
        /*** 将pPacket发送到服务端 ***/
        @autoreleasepool {
            NSData *data = [NSData dataWithBytes:pPacket length:len+8];
            [[ExchangeSocketServe sharedInstance] sendMessageWithMessage:[NSMutableData dataWithData:data] proNum:3 len:len+8];
            data = nil;
        }
        
        delete[] pPacket;
    }
    return len;
}

int VoeExTP::SendRTCPPacket(int channel, const void *data, int len)
{
    return len;
}

void VoeExTP::Init(const std::string& strName)
{
    m_strLogonName = strName;
    //    int ret = pthread_mutex_init(&m_AudioSenderLock , NULL);    //初始化音频发送锁
    //    if(ret != 0)
    //    {
    //        __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "Unable to init mutex");
    //        m_bCanUse = false;
    //    }
    //    else
    //    {
    //        m_bCanUse = true;
    //    }
    m_bCanUse = true;
}

void VoeExTP::Release()
{
}


/*****************************************************************************************************************/
//VoeN2NExTP类的实现
/*****************************************************************************************************************/
VoeN2NExTP::VoeN2NExTP()
{
    nChannel = -1;
    bPlaying = false;
    bReceiving = false;
    nRtpPackNum = 0;
    nRtcpPackNum = 0;
}

VoeN2NExTP::~VoeN2NExTP()
{
}

int VoeN2NExTP::SendPacket(int channel, const void *data, int len)            //多对多时只接收别人发过来的数据
{
    return len;
}
int VoeN2NExTP::SendRTCPPacket(int channel, const void *data, int len)
{
    return len;
}



/*****************************************************************************************************************/
//CWebRtcAudioStream 类的实现
/*****************************************************************************************************************/

//默认构造
CWebRtcAudioStream::CWebRtcAudioStream()
{
    m_pVoeEngine = NULL;
    m_pVoeBase = NULL;
    m_pVoeCodec = NULL;
    m_pVoeEncrypt = NULL;
    m_pVoeHardware = NULL;
    m_pVoeNetwork = NULL;
    m_pVoeRtpRtcp = NULL;
    m_pVoeVolumeControl = NULL;
    m_pVoe_apm = NULL;
    m_bInit = false;
    m_nAudioChannel = -1;
    m_bSending = false;
    m_bReceiving = false;
    m_bRecording = false;
    m_bReceivingN2N = false;
    m_nRtpPackNum = 0;
    m_nRtcpPackNum = 0;
    m_nFirstRTPRecvSSRC = 999;
    m_pSender = NULL;
}


//析构
CWebRtcAudioStream::~CWebRtcAudioStream()
{
    if(m_bInit)          //如果之前没有卸载过，现在就卸载
    {
        Release();
    }
    if(m_pSender)
    {
        delete m_pSender;
    }
}


//初始化
bool CWebRtcAudioStream::Init(bool enableWebrtcAuLog)
{
    int nRet = -1;    //音频引擎各模块初始化结果
    m_pVoeEngine = webrtc::VoiceEngine::Create();        //webrtc的视频引擎全局接口
    if (!m_pVoeEngine)
    {
        NSLog(@"%@初始化VoeEngine失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    if (enableWebrtcAuLog)   //是否启用内部日志
    {
        if(m_pVoeEngine->SetTraceFile("/sdcard/trace.txt"))   //音频引擎内部日志文件名，调试用，函数成功返回0，不成功返回-1
        {
            NSLog(@"%@设置VoeEngine的TraceFile出错!",WEBRTC_LOG_TAG);
        }
        if(m_pVoeEngine->SetTraceFilter(
                                        webrtc::kTraceError |
                                        webrtc::kTraceWarning |
                                        webrtc::kTraceCritical))      // enum TraceLevel 定义了监视那些行为
        {
            NSLog(@"%@设置VoeEngine的TraceFilter出错!",WEBRTC_LOG_TAG);
        }
    }
    else
    {
        m_pVoeEngine->SetTraceFile(NULL);
        m_pVoeEngine->SetTraceFilter(webrtc::kTraceNone);
    }
    
    m_pVoeBase = webrtc::VoEBase::GetInterface(m_pVoeEngine);      //VoeBase用来创建通道，传输
    if (!m_pVoeBase)
    {
        NSLog(@"%@获取VoeBase失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    if(m_pVoeBase->Init())             //初始化VoeBase
    {
        NSLog(@"%@初始化VoeBase失败! 错误码 %d",WEBRTC_LOG_TAG,m_pVoeBase->LastError());
        m_bInit = false;
        return m_bInit;
    }
    //voefile
    m_pVoeCodec = webrtc::VoECodec::GetInterface(m_pVoeEngine);          //编解码
    if (!m_pVoeCodec)
    {
        NSLog(@"%@获取VoeCodec失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    
    m_pVoeEncrypt = webrtc::VoEEncryption::GetInterface(m_pVoeEngine);            //加解密
    if (!m_pVoeEncrypt)
    {
        NSLog(@"%@获取VoeEncrypt失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    
    m_pVoeHardware = webrtc::VoEHardware::GetInterface(m_pVoeEngine);            //音频硬件
    if (!m_pVoeHardware)
    {
        NSLog(@"%@获取VoeHardware失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    
    m_pVoeNetwork = webrtc::VoENetwork::GetInterface(m_pVoeEngine);            //网络
    if (!m_pVoeNetwork)
    {
        NSLog(@"%@获取VoeNetwork失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    
    m_pVoeRtpRtcp = webrtc::VoERTP_RTCP::GetInterface(m_pVoeEngine);            //rtcp协议
    if (!m_pVoeRtpRtcp)
    {
        NSLog(@"%@获取VoERTP_RTCP失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    
    m_pVoeVolumeControl = webrtc::VoEVolumeControl::GetInterface(m_pVoeEngine);            //音量控制
    if (!m_pVoeVolumeControl)
    {
        NSLog(@"%@获取VoeVolumeControl失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    
    m_pVoe_apm = webrtc::VoEAudioProcessing::GetInterface(m_pVoeEngine);            //音频处理
    if (!m_pVoe_apm)
    {
        NSLog(@"%@获取Voe_apm失败!",WEBRTC_LOG_TAG);
        m_bInit = false;
        return m_bInit;
    }
    nRet = m_pVoe_apm->SetEcStatus(true , webrtc::kEcConference);     //回声控制，设置成会议类型
    nRet = m_pVoe_apm->SetEcStatus(true , webrtc::kEcAecm);     //回声控制，aecm
    NSLog(@"%@EcStatus kEcConference... ret %d errcode %d",WEBRTC_LOG_TAG,nRet , m_pVoeBase->LastError());
    nRet = m_pVoe_apm->SetNsStatus(true , webrtc::kNsConference);     //噪音控制，设置成超高噪音抑制
    NSLog(@"%@NsStatus kNsConference... ret %d errcode %d",WEBRTC_LOG_TAG,nRet , m_pVoeBase->LastError());
    nRet = m_pVoe_apm->SetAgcStatus(true , webrtc::kAgcDefault);     //Automatic Gain Control 自动增益控制 ，设成默认
    NSLog(@"%@AgcStatus kAgcDefault... ret %d errcode %d",WEBRTC_LOG_TAG,nRet , m_pVoeBase->LastError());
    m_bInit = true;
    return m_bInit;
}


//强制初始化不成功
void CWebRtcAudioStream::InitFalse()
{
    m_bInit = false;
}


//卸载
void CWebRtcAudioStream::Release()
{
    //先卸载多对多
    ReleaseN2NUsers();
    ReleaseExSender();
    //最后才卸载引擎
    if (m_pVoe_apm)
    {
        m_pVoe_apm->Release();
        m_pVoe_apm = NULL;
    }
    if (m_pVoeVolumeControl)
    {
        m_pVoeVolumeControl->Release();
        m_pVoeVolumeControl = NULL;
    }
    if (m_pVoeRtpRtcp)
    {
        m_pVoeRtpRtcp->Release();
        m_pVoeRtpRtcp = NULL;
    }
    if (m_pVoeNetwork)
    {
        m_pVoeNetwork->Release();
        m_pVoeNetwork = NULL;
    }
    if (m_pVoeHardware)
    {
        m_pVoeHardware->Release();
        m_pVoeHardware = NULL;
    }
    if (m_pVoeEncrypt)
    {
        m_pVoeEncrypt->Release();
        m_pVoeEncrypt = NULL;
    }
    if (m_pVoeCodec)
    {
        m_pVoeCodec->Release();
        m_pVoeCodec = NULL;
    }
    if (m_pVoeBase)
    {
        m_pVoeBase->DeleteChannel(m_nAudioChannel);
        m_pVoeBase->Terminate();
        m_pVoeBase->Release();
        m_pVoeBase = NULL;
    }
    if (m_pVoeEngine)
    {
        webrtc::VoiceEngine::Delete(m_pVoeEngine);
        m_pVoeEngine = NULL;
    }
    m_bInit = false;
}


bool CWebRtcAudioStream::CreateChannel()
{
    if (!m_bInit)
    {
        return false;
    }
    m_nAudioChannel = m_pVoeBase->CreateChannel();         //创建通道
    if (m_nAudioChannel == -1)
    {
        //        __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "创建音频通用通道! 错误码 %d\n" , m_pVoeBase->LastError());
        NSLog(@"%@创建音频通用通道! 错误码 %d\n" ,WEBRTC_LOG_TAG, m_pVoeBase->LastError());
        return false;
    }
    return true;
}
//ISAC  fs= 16000, pt= 103, rate=  32000, ch= 1, size=  480
//ISAC  fs= 32000, pt= 104, rate=  56000, ch= 1, size=  960
//PCMU  fs=  8000, pt=   0, rate=  64000, ch= 1, size=  160
//PCMA  fs=  8000, pt=   8, rate=  64000, ch= 1, size=  160
//PCMU  fs=  8000, pt= 110, rate=  64000, ch= 2, size=  160
//PCMA  fs=  8000, pt= 118, rate=  64000, ch= 2, size=  160
//ILBC  fs=  8000, pt= 102, rate=  13300, ch= 1, size=  240
//CN  fs=  8000, pt=  13, rate=      0, ch= 1, size=  240
//CN  fs= 16000, pt=  98, rate=      0, ch= 1, size=  480
//CN  fs= 32000, pt=  99, rate=      0, ch= 1, size=  960
//CN  fs= 48000, pt= 100, rate=      0, ch= 1, size= 1440
//按给定的序号设置音频编解码
bool CWebRtcAudioStream::SetupCodecSetting(const int idx)
{
    if (!m_bInit)
    {
        return false;
    }
    int nCodecs = m_pVoeCodec->NumOfCodecs();     //当前有几种编码
    //编号从0开始
    //ISAC  fs= 16000, pt= 103, rate=  32000, ch= 1, size=  480
    //ISAC  fs= 32000, pt= 104, rate=  56000, ch= 1, size=  960
    //PCMU  fs=  8000, pt=   0, rate=  64000, ch= 1, size=  160
    //PCMA  fs=  8000, pt=   8, rate=  64000, ch= 1, size=  160
    //PCMU  fs=  8000, pt= 110, rate=  64000, ch= 2, size=  160
    //PCMA  fs=  8000, pt= 118, rate=  64000, ch= 2, size=  160
    //ILBC  fs=  8000, pt= 102, rate=  13300, ch= 1, size=  240
    //CN  fs=  8000, pt=  13, rate=      0, ch= 1, size=  240
    //CN  fs= 16000, pt=  98, rate=      0, ch= 1, size=  480
    //CN  fs= 32000, pt=  99, rate=      0, ch= 1, size=  960
    //CN  fs= 48000, pt= 100, rate=      0, ch= 1, size= 1440
    for (int index = 0; index < nCodecs; index++)
    {
        if (index == idx)
        {
            
            m_pVoeCodec->GetCodec(index, m_CodecInst);
            m_pVoeCodec->SetSendCodec(m_nAudioChannel , m_CodecInst);
            
            NSLog(@"已指定的编码为: %s  fs=%6d, pt=%4d, rate=%7d, ch=%2d, size=%5d",m_CodecInst.plname , m_CodecInst.plfreq , m_CodecInst.pltype , m_CodecInst.rate , m_CodecInst.channels , m_CodecInst.pacsize);
            
            memcpy(audioHeader.Codecname,m_CodecInst.plname,RTP_PAYLOAD_NAME_SIZE);
            audioHeader.FS=m_CodecInst.plfreq;
            audioHeader.pt=m_CodecInst.pltype;
            audioHeader.rate=m_CodecInst.rate;
            audioHeader.ch=m_CodecInst.channels;
            audioHeader.size=m_CodecInst.pacsize;
            audioHeader.IsHaveAudio=1;
            return true;
        }
    }
    //    __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "当前编码个数为%d，找不到第%d个指定编码!\n", nCodecs, idx);
    NSLog(@"%@当前编码个数为%d，找不到第%d个指定编码!",WEBRTC_LOG_TAG,nCodecs, idx);
    return true;
}


//设置传输回调
bool CWebRtcAudioStream::SetupExSender(const std::string& strName)
{
    ReleaseExSender();     //先卸载
    if(!m_bInit)
    {
        return false;
    }
    if (m_pSender == NULL)
    {
        srand((int) webrtc::TickTime::MicrosecondTimestamp());    //随机种子
        unsigned int localSSRC = (unsigned int)(rand() % 100);       //随机100中的一个数作为rtp包内部校验码
        int ret = m_pVoeRtpRtcp->SetLocalSSRC(m_nAudioChannel , localSSRC);
        
        NSLog(@"%@VoeRtpRtcp SetLocalSSRC ssrc %d ret %d errcode %d",WEBRTC_LOG_TAG,localSSRC , ret , m_pVoeBase->LastError());
        m_pSender = new VoeExTP(m_nAudioChannel , localSSRC);
        ret = m_pVoeNetwork->RegisterExternalTransport(m_nAudioChannel , *m_pSender);     //设置传输回调
        
        NSLog(@"%@已设置扩展传输类 channel %d ret %d errcode %d",WEBRTC_LOG_TAG,m_nAudioChannel , ret , m_pVoeBase->LastError());
        ret = m_pVoeRtpRtcp->SetRTCPStatus(m_nAudioChannel , true);      //开启rtp状态
        
        NSLog(@"%@VoeRtpRtcp SetRTCPStatus channel %d ret %d errcode %d\n",WEBRTC_LOG_TAG,m_nAudioChannel , ret , m_pVoeBase->LastError());
        ret = m_pVoeRtpRtcp->SetRTPAudioLevelIndicationStatus(m_nAudioChannel, true);
        
        NSLog(@"%@VoeRtpRtcp SetRTPAudioLevelIndicationStatus channel %d ret %d errcode %d",WEBRTC_LOG_TAG,m_nAudioChannel , ret , m_pVoeBase->LastError());
        m_pVoeCodec->SetSendCNPayloadType(m_nAudioChannel , m_CodecInst.pltype);   //设置噪音抑制
        ret = m_pVoeCodec->SetVADStatus(m_nAudioChannel, false);           //设置静音忽略和断续传输
        
        NSLog(@"%@VoeCodec SetVADStatus channel %d ret %d errcode %d\n",WEBRTC_LOG_TAG,m_nAudioChannel , ret , m_pVoeBase->LastError());
        m_pSender->Init(strName);
        m_pSender->EnableN2NTrans(false);
    }
    return true;
}


//卸载传输回调
void CWebRtcAudioStream::ReleaseExSender()
{
    if (!m_bInit)
    {
        return;
    }
    if (m_bSending)      //必须先停止发送或接收
    {
        StopSend();
    }
    if (m_bReceiving)
    {
        StopReceive();
    }
    if(m_pSender)
    {
        m_pVoeNetwork->DeRegisterExternalTransport(m_nAudioChannel);
        m_pSender->Release();
        delete m_pSender;
        m_pSender = NULL;
    }
    m_pVoeRtpRtcp->SetRTCPStatus(m_nAudioChannel , false);    //关rtp状态
    m_pVoeRtpRtcp->SetRTPAudioLevelIndicationStatus(m_nAudioChannel, false);
    m_pVoeCodec->SetVADStatus(m_nAudioChannel, false);
    m_nFirstRTPRecvSSRC = 999;
    m_nRtpPackNum = 0;     //接收到的rtp包的数量
    m_nRtcpPackNum = 0;    //接收到的rtcp包的数量
}


//开始播放
bool CWebRtcAudioStream::StartAudioPlayout()
{
    if (m_bInit)     //确保初始化了才开始采集
    {
        if(!m_bRecording)
        {
            int ret = -1;
            ret = m_pVoeBase->StartPlayout(m_nAudioChannel);
            m_bRecording = true;
            if(ret != 0)
            {
                //                __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "开始播放声音失败 channel %d ret %d errcode %d\n",
                //                                    m_nAudioChannel , ret , m_pVoeBase->LastError());
                NSLog(@"%@开始播放声音失败 channel %d ret %d errcode %d\n",WEBRTC_LOG_TAG,m_nAudioChannel , ret , m_pVoeBase->LastError());
            }
        }
        return true;    //若开始成功则ret为0
    }
    //    __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "VoeBase未初始化，无法开始播放声音...");
    NSLog(@"%@oeBase未初始化，无法开始播放声音...",WEBRTC_LOG_TAG);
    return false;
}


//停止播放
bool CWebRtcAudioStream::StopAudioPlayout(void)
{
    if (m_bInit)     //正在播
    {
        if (m_bRecording)
        {
            int ret = -1;
            m_pVoeBase->StopPlayout(m_nAudioChannel);
            m_bRecording = false;
            if(ret != 0)
            {
                //                __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "停止播放声音失败 channel %d ret %d errcode %d\n",
                //                                    m_nAudioChannel , ret , m_pVoeBase->LastError());
                NSLog(@"%@停止播放声音失败 channel %d ret %d errcode %d",WEBRTC_LOG_TAG,m_nAudioChannel , ret , m_pVoeBase->LastError());
            }
        }
        return true;
    }
    //    __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "VoeBase未初始化，无法停止播放声音...");
    return false;
}


//开始传输，对于音频引擎，开始传输的同时也开始录音,必须先设置扩展传输类
bool CWebRtcAudioStream::StartSend(void)
{
    if (!m_pSender)
    {
        return false;
    }
    if(m_bInit)
    {
        if (!m_bSending)        //如果没有发送才发送
        {
            int ret = -1;
            ret = m_pVoeBase->StartSend(m_nAudioChannel);
            m_bSending = true;
            if(ret != 0)
            {
                //                __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "开始发送音频失败! ret %d errcode %d\n",
                //                                    ret , m_pVoeBase->LastError());
                NSLog(@"%@开始发送音频失败! ret %d errcode %d\n",WEBRTC_LOG_TAG,ret , m_pVoeBase->LastError());
            }
            if(NULL != m_pSender)
            {
                m_pSender->EnableN2NTrans(true);    //允许往发送队列里面添加数据了
            }
        }
        return true;
    }
    //    __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "VoeBase未初始化，无法发送音频...");
    NSLog(@"%@VoeBase未初始化，无法发送音频...",WEBRTC_LOG_TAG);
    return false;
}


//停止传输，停止了传输之后别人也听不到你的声音了
bool CWebRtcAudioStream::StopSend(void)
{
    if (m_bInit)
    {
        if(m_bSending)       //如果已经在发送才停止
        {
            int ret = -1;
            if(NULL != m_pSender)
            {
                m_pSender->EnableN2NTrans(false);   //停止往发送队列避免添加数据
            }
            ret = m_pVoeBase->StopSend(m_nAudioChannel);     //先停止发送
            m_bSending = false;
            if(ret != 0)
            {
                //                __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "停止发送音频失败! ret %d errcode %d\n",
                //                                    ret , m_pVoeBase->LastError());
                NSLog(@"%@停止发送音频失败！ret %d errcode %d",WEBRTC_LOG_TAG,ret , m_pVoeBase->LastError());
            }
        }
        return true;
    }
    //    __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "VoeBase尚未初始化，无法停止发送!");
    NSLog(@"%@VoeBase尚未初始化，无法停止发送!",WEBRTC_LOG_TAG);
    return false;
}


//开始接收
bool CWebRtcAudioStream::StartReceive(void)
{
    if (!m_pSender)
    {
        return false;
    }
    if (m_pVoeBase)
    {
        if(!m_bReceiving)            //没有接收才开始接收
        {
            int ret = -1;
            ret = m_pVoeBase->StartReceive(m_nAudioChannel);
            m_bReceiving = true;
            if(ret != 0)
            {
                //                __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "开始接收音频数据失败! channel %d ret %d errcode %d\n",
                //                                    m_nAudioChannel , ret , m_pVoeBase->LastError());
                NSLog(@"%@开始接收音频数据失败! channel %d ret %d errcode %d",WEBRTC_LOG_TAG,m_nAudioChannel , ret , m_pVoeBase->LastError());
            }
        }
        return true;
    }
    //    __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "VoeBase尚未初始化，无法开始接收!");
    NSLog(@"%@VoeBase未初始化，无法发送音频...",WEBRTC_LOG_TAG);
    return false;
}


//停止接收
bool CWebRtcAudioStream::StopReceive(void)
{
    if (m_pVoeBase)
    {
        if (m_bReceiving)
        {
            int ret = -1;
            ret = m_pVoeBase->StopReceive(m_nAudioChannel);
            m_bReceiving = false;
            if(ret != 0)
            {
                //                __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "停止接收音频数据失败! channel %d ret %d errcode %d\n",
                //                                    m_nAudioChannel , ret , m_pVoeBase->LastError());
            }
        }
        return true;
    }
    //    __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "VoeBase尚未初始化，无法停止接收!");
    return false;
}


//主动接收rtp包
bool CWebRtcAudioStream::ReceivedN2NRtpData(char* pDataBuffer, int nLen)
{
    if (!m_bInit)
    {
        return false;
    }
    if (!m_bReceivingN2N)      //如果不要求接收n2n的数据，则退出
    {
        return false;
    }
    bool rettt = false;
    char FromUser[64];//有一位是\0
    memcpy(FromUser,pDataBuffer+(nLen - 8), 8);
    auto itr = m_Userlist.find(std::string(FromUser));
    if (itr != m_Userlist.end())
    {
        if (itr->second->bReceiving)
        {
            itr->second->nRtpPackNum++;      //对应该用户的rtp包增加
            int ret = m_pVoeNetwork->ReceivedRTPPacket(itr->second->nChannel , pDataBuffer , nLen-8);
            NSLog(@"----用户 %s对应的channel %d 接收到第 %d个rtp包，长度 %d ret %d errcode %d\n" ,FromUser, itr->second->nChannel , itr->second->nRtpPackNum ,nLen, ret , m_pVoeBase->LastError());
            
            rettt = true;
        }
    }
    return rettt;
}


//允许多对多接收
void CWebRtcAudioStream::EnableAllN2NReceiving(bool bAllN2N)
{
    if (m_bInit)
    {
        m_bReceivingN2N = bAllN2N;
    }
}


//添加一个用户
bool CWebRtcAudioStream::AddN2NUser(const char* userID)
{
    if (userID == NULL)
    {
        return false;
    }
    if (!m_bInit)
    {
        return false;
    }
    std::string strUserID = userID;
    if (m_Userlist.find(strUserID) != m_Userlist.end())
    {
        //        __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "已经在接收用户---服务器id【%s】，不要重复添加!\n", strUserID.c_str());
        return false;
    }
    VoeN2NExTP* newUser = new VoeN2NExTP();
    newUser->nChannel = m_pVoeBase->CreateChannel();         //创建通道
    if (newUser->nChannel == -1)
    {
        //        __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "为用户服务器id【%s】设置音频通道出错! 错误码 %d\n" ,
        //                            strUserID.c_str(), m_pVoeBase->LastError());
        NSLog(@"%@为用户服务器id【%s】设置音频通道出错! 错误码 %d",WEBRTC_LOG_TAG,strUserID.c_str(), m_pVoeBase->LastError());
    }
    int ret = m_pVoeNetwork->RegisterExternalTransport(newUser->nChannel , *newUser);     //设置传输回调
    //    __android_log_print(ANDROID_LOG_WARN, WEBRTC_LOG_TAG, "已为用户---服务器id【%s】设置音频扩展传输类 channel %d ret %d errcode %d..\n",
    
    //                        strUserID.c_str() , newUser->nChannel , ret , m_pVoeBase->LastError());
    NSLog(@"%@已为用户---服务器id【%s】设置音频扩展传输类 channel %d ret %d errcode %d..",WEBRTC_LOG_TAG,strUserID.c_str() , newUser->nChannel , ret , m_pVoeBase->LastError());
    ret = m_pVoeRtpRtcp->SetRTCPStatus(newUser->nChannel , true);      //开启rtp状态
    ret = m_pVoeRtpRtcp->SetRTPAudioLevelIndicationStatus(newUser->nChannel, true);
    ret = m_pVoeCodec->SetVADStatus(newUser->nChannel, true);           //设置静音忽略和断续传输
    ret = m_pVoeBase->StartPlayout(newUser->nChannel);    //创建了该用户就开始播放
    newUser->bPlaying = true;
    ret = m_pVoeBase->StartReceive(newUser->nChannel);     //创建了该用户就开始接收
    newUser->bReceiving = true;
    m_Userlist.insert(std::map<std::string,VoeN2NExTP*>::value_type(strUserID , newUser));   //把该用户添加到用户列表中
    return true;
}


//删除一个用户
bool CWebRtcAudioStream::ReleaseN2NUser(const char* username)
{
    if (!m_bInit)
    {
        return false;
    }
    auto itr = m_Userlist.find(std::string(username));
    if (itr == m_Userlist.end())
    {
        //        __android_log_print(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "没有此用户%s，不能删除!\n", username);
        return false;
    }
    if (itr->second->bPlaying)         //停止播放
    {
        m_pVoeBase->StopPlayout(itr->second->nChannel);
    }
    
    if (itr->second->bReceiving)         //停止接收
    {
        m_pVoeBase->StopReceive(itr->second->nChannel);
    }
    m_pVoeNetwork->DeRegisterExternalTransport(itr->second->nChannel);     //卸载传输回调
    m_pVoeRtpRtcp->SetRTCPStatus(itr->second->nChannel , false);    //关rtp状态
    m_pVoeRtpRtcp->SetRTPAudioLevelIndicationStatus(itr->second->nChannel, false);
    m_pVoeCodec->SetVADStatus(itr->second->nChannel, false);
    m_pVoeBase->DeleteChannel(itr->second->nChannel);
    delete itr->second;           //删传输回调
    itr->second = NULL;
    m_Userlist.erase(itr);      //删掉该用户
    return true;
}


//删除所有用户
void CWebRtcAudioStream::ReleaseN2NUsers(void)
{
    if (!m_bInit)
    {
        return;
    }
    for(auto itr = m_Userlist.begin(); itr != m_Userlist.end(); itr++)
    {
        if (itr->second->bPlaying)         //停止播放
            m_pVoeBase->StopPlayout(itr->second->nChannel);
        if (itr->second->bReceiving)         //停止接收
            m_pVoeBase->StopReceive(itr->second->nChannel);
        m_pVoeNetwork->DeRegisterExternalTransport(itr->second->nChannel);     //卸载传输回调
        m_pVoeRtpRtcp->SetRTCPStatus(itr->second->nChannel , false);    //关rtp状态
        m_pVoeRtpRtcp->SetRTPAudioLevelIndicationStatus(itr->second->nChannel, false);
        m_pVoeCodec->SetVADStatus(itr->second->nChannel, false);
        delete itr->second;           //删传输回调
        itr->second = NULL;
    }
    m_Userlist.clear();
}


/*****************************************************************************************************************/
//ios调用的音频业务函数的实现
/*****************************************************************************************************************/
//全局变量
static CWebRtcAudioStream g_WebRtcVoe;
static char g_szUserId[64];   //用来转换用户名
static Byte auBufContainer[2000];    //用来装音频数据的容器


//初始化
//enableWebrtcAuLog 是否启用webrtc内部日志
//logonName 登录名
bool myAudioInit(bool enableWebrtcAuLog, const std::string& logonName)
{
    
    if (false == g_WebRtcVoe.Init(enableWebrtcAuLog))
    {
        //        __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "webrtc音频初始化失败！");
        return false;
    }
    if(false == g_WebRtcVoe.CreateChannel())
    {
        g_WebRtcVoe.InitFalse();
        return false;
    }
    //[ 3]PCMA: fs=  8000, pt=   8, rate=  64000, ch= 1, size=  160
    if (false == g_WebRtcVoe.SetupCodecSetting(10))
    {
        //        __android_log_write(ANDROID_LOG_ERROR, WEBRTC_LOG_TAG, "webrtc音频设置编码方式失败!\n");
        g_WebRtcVoe.audioHeader.IsHaveAudio=0;
        g_WebRtcVoe.InitFalse();
        return false;
    }
    g_WebRtcVoe.SetupExSender(logonName);
    g_WebRtcVoe.StopAudioPlayout();
    g_WebRtcVoe.StopSend();    //不允许传输回调
    g_WebRtcVoe.EnableAllN2NReceiving(false);   //初始化音频为false
    return true;
}

//卸载
void myAudioRelease()
{
    g_WebRtcVoe.EnableAllN2NReceiving(false);
    g_WebRtcVoe.StopSend();
    g_WebRtcVoe.StopAudioPlayout();
    g_WebRtcVoe.Release();
}

//通话组变动，有人加入或退出
void myAudioAddOrReleaseUser(const std::string& uid, bool bAdd)
{
    if(true == bAdd)    //新加入的用户
    {
        g_WebRtcVoe.AddN2NUser(uid.c_str());
    }
    else   //这个用户退了
    {
        g_WebRtcVoe.ReleaseN2NUser(uid.c_str());
    }
}

//通话组发生变动，通话组不为空
void myAudioClientingListNonEmpty()
{
    g_WebRtcVoe.StartAudioPlayout();   //开始播音
    g_WebRtcVoe.EnableAllN2NReceiving(true);    //允许接收
    g_WebRtcVoe.StartSend();    //开始发送
}

//通话组发生变动，通话组为空了
void myAudioClientingListEmpty()
{
    g_WebRtcVoe.StopSend();   //关闭发送
    g_WebRtcVoe.EnableAllN2NReceiving(false);  //停止接收
    g_WebRtcVoe.ReleaseN2NUsers();
    g_WebRtcVoe.StopAudioPlayout();    //停止播音
}

//接收音频数据
void myAudioReceiveAuBuffer(char* auBufContainer, int nlen)
{
    g_WebRtcVoe.ReceivedN2NRtpData(auBufContainer , nlen);
}

//暂停接收音频数据
void myAudioStopReveiveAuBuffer() {
    g_WebRtcVoe.StopReceive();
}

//开始接收
void myAudioReveive() {
    g_WebRtcVoe.StartReceive();
}

//暂停发送音频
void myAudioStopSend(){
    g_WebRtcVoe.StopSend();   //关闭发送
}

//开始发送
void myAudioSend(){
    g_WebRtcVoe.StartSend();
}
