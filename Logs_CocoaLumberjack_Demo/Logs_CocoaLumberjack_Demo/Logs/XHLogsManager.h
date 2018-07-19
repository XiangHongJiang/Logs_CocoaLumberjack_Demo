//
//  XHLogsManager.h
//  Test_Logs
//
//  Created by MrYeL on 2018/7/10.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogsInfoModel.h"// 自己存储的信息
#import "MyLogFromatter.h"// 控制台输出格式
#import "MyLog.h" //自定义的 logs日志
#import "MyFileLogger.h" //继承DDfileLogger
#import "MyFileLoggerManagerDefault.h"//继承 DD

static  NSString *const preUploadInfoKey = @"preUploadInfo";

typedef NS_ENUM(NSInteger,UploadLogsType){
    UploadLogsType_CustomCollect,//自定义收集的信息
    UploadLogsType_SysLogs,//系统打印的日志
    UploadLogsType_All,//自定义 + 系统打印

} ;
typedef NS_ENUM(NSInteger,LogType){
    
    LogType_MyLog,//自定义的 logs日志 ： 手动保存和删除 ，初始化设置
    LogType_MyFileLogger,//继承DDfile ：自动保存和删除 ，手动配置一下

} ;

@interface XHLogsManager : NSObject

/** 之前上传的信息： 暂时不用，预留*/
@property (nonatomic, strong) PreUploadLogsInfoModel * preUploadInfo;

/** 当前自定义log信息：用来手动收集信息：不变的值建议重写 get方法*/
@property (nonatomic, strong) LogsInfoModel * currentLogsInfoModel;

//奔溃调用
void uncaughtExceptionHandler(NSException *exception);

//创建并初始化设置
+ (instancetype)defaultManager;

/** 默认启动Log ，类型 0.MyLog 1：DDfile ,可手动重启*/
- (void)startLogsConfigWithLogType:(LogType)type;

//启动预处理: 是否上传或删除 或写入日志 或判断是否已上传
- (void)prepare;

//上传日志: 不同类型
- (void)upLoadLogsWithType:(UploadLogsType)type andCompleteBlock:(void(^)(BOOL succeed,NSString *filePath))completedBlock;

//删除过期日志，默认在 - (void)prepare;里调用 LogType_MyLog (可以设置双有效)下有效：每天只保留一份文件，可修改位置到 启动 Log 时就调用,
- (void)deleteOutOfDateLog;

@end





