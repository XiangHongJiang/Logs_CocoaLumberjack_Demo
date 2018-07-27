//
//  MyFileLogger.m
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "MyFileLogger.h"
#import "MyFileLoggerManagerDefault.h"



@implementation MyFileLogger

- (instancetype)init {
    if (self = [super init]) {
        
        self.maximumFileSize = 1024*1024;// 1M
        self.rollingFrequency = 60*60*24;//1天
        self.logFileManager.maximumNumberOfLogFiles = 1;//最大1个文件
    }
    return self;
}


static int exception_count = 0;
- (void)logMessage:(DDLogMessage *)logMessage {
    
//    [super logMessage:logMessage];
//    return;
    NSString *message = logMessage->_message;
    BOOL isFormatted = NO;
    
    if (_logFormatter) {
        message = [_logFormatter formatLogMessage:logMessage];
        isFormatted = message != logMessage->_message;
    }
    
    if (message) {
        
        NSString *filePath =self.currentLogFileInfo.filePath;
        [self saveLogMessage:message withFilePath:filePath];
    }
    
}
/** 保存数据*/
- (void)saveLogMessage:(NSString *)message withFilePath:(NSString *)path {
    
    //获取原数据
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];

    NSMutableArray *logsArray = nil;
    
    MyFileLoggerManagerDefault *fmD = (MyFileLoggerManagerDefault *)self.logFileManager;
    NSString *createPath = fmD.filePath;
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {//文件夹不存在
        [[NSFileManager defaultManager] createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] ) {//文件存在
        {
            
            if ([path containsString:@"plist"]) {//plist
                logsArray = [NSMutableArray arrayWithContentsOfFile:path];
            }else if ([path containsString:@"json"]) {//json
                logsArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
            }
        }
    }else{
        
        if ([path containsString:@"txt"]||[path containsString:@"log"]) {//txt

            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        }
        
    }

    //保存数据
    logsArray = logsArray? logsArray : [NSMutableArray new];
    NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    [logsArray addObject:infoDic];
    
    @try {
        [self willLogMessage];
        
        if ([path containsString:@"plist"]) {//写成plist文件
            
            [logsArray writeToFile:path atomically:YES];
            
        }else if ([path containsString:@"json"]){//写成json文件
            
            NSData *json_data = [NSJSONSerialization dataWithJSONObject:logsArray options:NSJSONWritingPrettyPrinted error:nil];
            
            [json_data writeToFile:path atomically:YES];
            
        }else if ([path containsString:@"txt"]||[path containsString:@"log"]) {//写成字符串文件
            //1.通过字符串追加方式添加
            if (![message hasSuffix:@"\n"]) {
                message = [message stringByAppendingString:@",\n"];
            }
            NSData *logData = [message dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
            [fileHandle writeData:logData]; //追加写入数据
            [fileHandle closeFile];
            
        }
        [self didLogMessage];
        
    } @catch (NSException *exception) {
        exception_count++;
        
        if (exception_count <= 10) {
            //                NSLogError(@"DDFileLogger.logMessage: %@", exception);
            
            if (exception_count == 10) {
                //                    NSLogError(@"DDFileLogger.logMessage: Too many exceptions -- will not log any more of them.");
            }
        }
    }
    

}


@end
