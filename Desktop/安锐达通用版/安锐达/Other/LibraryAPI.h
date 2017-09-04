//
//  LibraryAPI.h
//  GWFramework
//
//  Created by 郭炜 on 2017/5/31.
//  Copyright © 2017年 郭炜. All rights reserved.
//
///**
// * 登录
// */
//public static  final String LD="LD";
///**
// * SQR 获取单个用户信息
// */
//
//public static  final String SQR="SQR";
///**
// * QLV 获取服务器上存在的最新版本号
// */
//
//public static  final String QLV="QLV";
///**
// * GDC 获取公共配置
// */
//
//public static  final String GDC="GDC";
///**
// * GHC 获取诊室端配置
// */
//
//public static  final String GHC="GHC";
///**
// * BM  开始会话
// */
//
//public static  final String BM="BM";
///**
// * IV 邀请专家
// */
//
//public static  final String IV="IV";
///**
// *   MER 异常中断
// */
//public static  final String MER="MER";
///**
// *    LV 离开会话
// */
//public static  final String LV="LV";
///**
// *     EM 结束会话
// */
//public static  final String EM="EM";
//
///**
// * INF 处理强制更新 用json串发送：用update_type 和sys_info来去重
// *
// */
//public static  final String INF="INF";
///**
// * MAC 保存mac地址 有的话覆盖没有就新增
// *
// */
//public static  final String MAC="MAC";
///**
// * CC 修改诊室端颜色空间配置
// *
// */
//public static  final String CC="CC";
///**
// * GGL 获取所有节点列表
// *
// */
//public static  final String GGL="GGL";
///**
// * GPC 根据编号获取公共配置信息
// *
// */
//public static  final String GPC="GPC";
///**
// *  MCR 修改监控诊室端用户信息
// *
// */
//public static  final String MCR="MCR";
///**
// *  QU 获取对应类型的用户列表
// *
// */
//public static  final String QU="QU";
//
///**
// * 获取病人列表
// */
//public static final String HXPAS = "HXPAS";
//
///**
// * 会诊结束回传信息
// */
//public static final String HXEND = "HXEND";
#ifndef LibraryAPI_h
#define LibraryAPI_h

#define API_HOST @"192.168.3.131"

#define PORT @"8888"

/*** 登录 ***/
#define LD @"LD"

/*** 获取公共配置 ***/
#define GDC @"GDC"

/*** GGL 获取所有节点列表 ***/
#define GGL @"GGL"

/*** QU 获取对应类型的数据列表 ***/
#define QU @"QU"
#endif /* LibraryAPI_h */
