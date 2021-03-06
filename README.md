# Logs_CocoaLumberjack_Demo

#### 项目介绍
基于CocoaLumberjack 记录控制台输出的Log日志
1. 支持Xcode输出 Log收集 并 分级。
2. 支持自定义文件路径和格式。（.json/.plist/.txt/.log）
3. 支持缓存与清除。（默认保存时长，文件大小，文件数量）
4. 支持上传到服务器。（灵活调用上传）
5. 使用简单，扩展方便，可继承可重新。（各种自定义。）

#### 软件架构
主要文件：Logs 文件夹
Demo文件：Demo 文件夹


#### 安装教程

1. cocoapods 安装
2. pod 库（ pod 'CocoaLumberjack'    pod 'YYKit' ）


#### 使用说明

1. 添加 pch，添加不同模式下收集的内容

/** 日志上传*/
#import <DDLog.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;//收集所有
#else
static const DDLogLevel ddLogLevel = DDLogLevelInfo;//收集 Error、Waring、Info
#endif

#import "XHLogsManager.h"
#import <YYKit.h>

2.启用日志，自定义打印收集的信息
/** 启用日志:与用户绑定，登录成功后启用，登录之前的信息，可通过自定义收集信息先记录*/
- (void)starLog {
//崩溃调用
NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//启用
[[XHLogsManager defaultManager] startLogsConfigWithLogType:LogType_MyLog];
//预处理：删除 \上传之前失败的，默认不上传，调用上传
[[XHLogsManager defaultManager] prepare];

}
//记录收集
- (void)logsCollect {

//打印系统Log并记录
DDLogError(@"[Error]:%@", @"输出错误信息");    //输出错误信息
DDLogWarn(@"[Warn]:%@", @"输出警告信息");    //输出警告信息
DDLogInfo(@"[Info]:%@", @"输出描述信息");    //输出描述信息
//    DDLogDebug(@"[Debug]:%@", @"输出调试信息");    //输出调试信息
//    DDLogVerbose(@"[Verbose]:%@", @"输出详细信息"); //输出详细信息
[XHLogsManager defaultManager].currentLogsInfoModel.platform = @"iOS";//运行中自定义收集的信息

}

3.上传到自己的服务器
//上传
- (void)logsUpload {
[[XHLogsManager defaultManager] upLoadLogsWithType:UploadLogsType_SysLogs andCompleteBlock:^(BOOL succeed, NSString *filePath) {

if (succeed) {
NSLog(@"上传成功:%@",filePath);
}else {
NSLog(@"上传失败:%@",filePath);
}
}];
}
#### 效果图
1. Demo功能图
<div align=center><img width="500" height="1083" src="https://github.com/XiangHongJiang/Logs_CocoaLumberjack_Demo/blob/master/Pic/Simulator%20Screen%20Shot%20-%20iPhone%20X%20-%202018-07-27%20at%2011.19.04.png"/></div>


2. 文件
![image](https://github.com/XiangHongJiang/Logs_CocoaLumberjack_Demo/blob/master/Pic/1532670329816.jpg)

3. 控制台
![image](https://github.com/XiangHongJiang/Logs_CocoaLumberjack_Demo/blob/master/Pic/1532670944903.jpg)

4.文件位置及内容
![image](https://github.com/XiangHongJiang/Logs_CocoaLumberjack_Demo/blob/master/Pic/1532671063991.jpg)
![image](https://github.com/XiangHongJiang/Logs_CocoaLumberjack_Demo/blob/master/Pic/1532670440137.jpg)

