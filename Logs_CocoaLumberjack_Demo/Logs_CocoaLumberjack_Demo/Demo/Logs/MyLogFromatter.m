//
//  MyLogFromatter.m
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "MyLogFromatter.h"
#import <libkern/OSAtomic.h>


/** 自定义Log 日志格式*/
@implementation MyLogFromatter
{
    int atomicLoggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}
static NSString *const KdateFormatString = @"yyyy-MM-dd HH:mm:ss";

- (NSString *)stringFromDate:(NSDate *)date {
    int32_t loggerCount = OSAtomicAdd32(0, &atomicLoggerCount);
    if (loggerCount <= 1) {
        // Single-threaded mode. if (threadUnsafeDateFormatter == nil)
        {
            threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
            [threadUnsafeDateFormatter setDateFormat:KdateFormatString];
            
        } return [threadUnsafeDateFormatter stringFromDate:date];
        
    } else {
        // Multi-threaded mode. // NSDateFormatter is NOT thread-safe.
        NSString *key = @"MyCustomFormatter_NSDateFormatter";
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
        NSDateFormatter *dateFormatter = [threadDictionary objectForKey:key];
        if (dateFormatter == nil) { dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:KdateFormatString];
            [threadDictionary setObject:dateFormatter forKey:key];
            
        }
        return [dateFormatter stringFromDate:date];
    }
    
}
/** 自定义输出格式*/
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    
    NSString *logLevel;
    NSMutableDictionary *logDict = [NSMutableDictionary dictionary];

    switch (logMessage->_flag) {//可修改等级的 描述用 code表示
        case DDLogFlagError    : logLevel = [NSString stringWithFormat:@"%ld",MyLogLevelCode_Error]; break;
        case DDLogFlagWarning  : logLevel = [NSString stringWithFormat:@"%ld",MyLogLevelCode_LifeCycle]; break;
        case DDLogFlagInfo     : logLevel = [NSString stringWithFormat:@"%ld",MyLogLevelCode_Logs]; break;
        case DDLogFlagDebug    : logLevel = [NSString stringWithFormat:@"%ld",MyLogLevelCode_DeviceInfo]; break;
        default                : logLevel = @"V"; break;
    }
    NSString *dateAndTime = [self stringFromDate:(logMessage.timestamp)];
    // 日期和时间
    NSString *logFileName = logMessage -> _fileName; // 文件名
    NSString *logFunction = logMessage -> _function; // 方法名
    NSUInteger logLine = logMessage -> _line; // 行号
    NSString *logMsg = logMessage->_message; // 日志消息
    // 日志格式：日期和时间 文件名 方法名 : 行数 <日志等级> 日志消息
    
    NSString *formateStr = [NSString stringWithFormat:@"\ndateAndTime: %@ \nlogFileName: %@ \nlogFunction: %@ \nlogLine: %lu \nlogLevel: <%@> \nlogMsg: %@\n", dateAndTime, logFileName, logFunction, logLine, logLevel, logMsg];
    
    [logDict setObject:dateAndTime.length?dateAndTime:@"" forKey:@"dateAndTime"];
    [logDict setObject:logFileName.length?logFileName:@"" forKey:@"logFileName"];
    [logDict setObject:logFunction.length?logFunction:@"" forKey:@"logFunction"];
    [logDict setObject:[NSString stringWithFormat:@"%lu",logLine] forKey:@"logLine"];
    [logDict setObject:logLevel.length?logLevel:@"" forKey:@"logLevel"];
    [logDict setObject:logMsg.length?logMsg:@"" forKey:@"logMsg"];
    
    NSString *jsonStr = [MyLogFromatter dictToJsonString:logDict];

    if (jsonStr) {
        return jsonStr;
    }//
    
    return formateStr;
    
}
- (void)didAddToLogger:(id <DDLogger>)logger {
    OSAtomicIncrement32(&atomicLoggerCount);
}
- (void)willRemoveFromLogger:(id <DDLogger>)logger {
    OSAtomicDecrement32(&atomicLoggerCount);
}

+ (NSString *)dictToJsonString:(NSDictionary *)dictionary
{
    NSString *backVal = nil;
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    backVal = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (error) {
        NSLog(@"dic->%@",error);
    }
    
    return backVal;
}


@end
