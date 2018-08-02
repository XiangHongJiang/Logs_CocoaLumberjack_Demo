//
//  MyLogFromatter.h
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MyLogLifeCycle(...) DDLogWarn(__VA_ARGS__)
#define MyLogLogs(...) DDLogInfo(__VA_ARGS__)
#define MyLogDeviceInfo(...) DDLogDebug(__VA_ARGS__)
#define MyLogError(...) DDLogError(__VA_ARGS__)

typedef NS_ENUM(NSInteger,MyLogLevelCode){
    
    MyLogLevelCode_Logs = 100100,//系统Log  DDLogInfo
    MyLogLevelCode_LifeCycle = 100101,//生命周期 DDLogWarning
    MyLogLevelCode_DeviceInfo = 100102,//设备信息 DDLogDebug
    MyLogLevelCode_Error = 100103,//错误奔溃信息 DDLogError
 
};

/** 自定义Log 日志格式*/
@interface MyLogFromatter : NSObject<DDLogFormatter>

+ (NSString *)dictToJsonString:(NSDictionary *)dictionary;

@end


