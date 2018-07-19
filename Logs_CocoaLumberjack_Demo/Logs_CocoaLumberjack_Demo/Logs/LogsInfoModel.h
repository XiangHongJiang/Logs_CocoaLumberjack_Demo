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

#pragma mark - 通用信息
/** dfimid*/
@property (nonatomic, copy) NSString * dfimid;
/** 平台类型*/
@property (nonatomic, copy) NSString * platform;
/** 申请编号*/
@property (nonatomic, copy) NSString * applyCd;
/** 手机型号*/
@property (nonatomic, copy) NSString * phoneVersion;
/** 系统版本号*/
@property (nonatomic, copy) NSString * sysVersion;
/** 盒子版本号*/
@property (nonatomic, copy) NSString * boxVersion;


#pragma mark - 控制台Log日志信息 & 其他信息
/** 当前控制器*/
@property (nonatomic, copy) NSString * currentController;
/** 时间*/
@property (nonatomic, copy) NSString * timesTamp;
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

