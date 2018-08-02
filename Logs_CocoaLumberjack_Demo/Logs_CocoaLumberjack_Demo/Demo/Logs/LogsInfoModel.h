//
//  LogsInfoModel.h
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LogsFileInfoModel;

/** 需要手动生成保存的日志信息：用于上传*/
@interface LogsInfoModel : NSObject


#pragma mark - 通用设备信息
/** 平台类型*/
@property (nonatomic, copy) NSString * platform;
/** 操作系统版本: 10.1*/
@property (nonatomic, copy) NSString * osVersion;
/** 手机型号： iPhone 7*/
@property (nonatomic, copy) NSString * phoneInfo;
/** App版本号*/
@property (nonatomic, copy) NSString * appVersion;
/** App名称*/
@property (nonatomic, copy) NSString * appName;
/** 语言*/
@property (nonatomic, copy) NSString * languageEnv;
/** cpuType*/
@property (nonatomic, copy) NSString * cpuType;
/** carrierName：运营商*/
@property (nonatomic, copy) NSString * carrierName;
/** netWorkStates：网络状态*/
@property (nonatomic, copy) NSString * netWorkStates;
/** memory：总内存 M*/
@property (nonatomic, copy) NSString *  totalMemory;
/** memory：空闲内存 M*/
@property (nonatomic, copy) NSString *  freeMemory;
/** memory：已用内存 M*/
@property (nonatomic, copy) NSString *  usedMemory;


#pragma mark - 控制台Log日志信息 & 其他信息
/** appInfo*/
@property (nonatomic, strong) NSMutableDictionary * launchInfo;

@end

/** 上次上传的文件信息*/
@interface PreUploadLogsInfoModel : NSObject

/** 创建的时间*/
@property (nonatomic, copy) NSString * createTime;
/** 上传类型*/
@property (nonatomic, copy) NSString * uploadType;
/** 上传数量*/
@property (nonatomic, copy) NSString * count;
/** 上传的Log文件信息*/
@property (nonatomic, strong) NSArray <LogsFileInfoModel *> * logsFileInfoArray;

@end

@interface LogsFileInfoModel : NSObject

/** 上传成功与否*/
@property (nonatomic, assign) BOOL uploadSucceed;
/** 失败是否下次上传*/
@property (nonatomic, assign) BOOL faildUploadNextTime;
/** 文件大小*/
@property (nonatomic, copy) NSString * filePath;


@end

