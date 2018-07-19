//
//  MyFileLoggerManagerDefault.m
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "MyFileLoggerManagerDefault.h"

@interface MyFileLoggerManagerDefault ()

@end


@implementation MyFileLoggerManagerDefault

@synthesize fileName = _fileName;
@synthesize fileTypeName = _fileTypeName;
@synthesize filePath = _filePath;
@synthesize filePreName = _filePreName;
@synthesize logsDirectory = _logsDirectory;

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory
                             fileName:(NSString *)name {
    //logsDirectory日志自定义路径
    self = [super initWithLogsDirectory:logsDirectory];
    if (self) {
        _fileName = name;
        _logsDirectory = self.filePath;
    }
    return self;
}
- (instancetype)init {
    if (self = [super init]) {
        
    
        _logsDirectory = self.filePath;
    }
    return self;
}

#pragma mark - Override methods

- (NSString *)newLogFileName {
    //重写文件名称
    NSDateFormatter *dateFormatter = [self logFileDateFormatter];
    NSString *formattedDate = [dateFormatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@%@%@", self.filePreName,formattedDate,self.fileTypeName];
}

- (BOOL)isLogFile:(NSString *)fileName {
    //返回YES为每次重新创建文件，如果每次需要重新创建就直接返回NO，如果有别的创建需要直接重写此方法
    
    if ([fileName isEqualToString:self.fileName]) {
        return YES;
    }
    return NO;
}

- (NSDateFormatter *)logFileDateFormatter {
    NSMutableDictionary *dictionary = [[NSThread currentThread]
                                       threadDictionary];
    NSString *dateFormat = @"yyyy-MM-dd";
    NSString *key = [NSString stringWithFormat:@"logFileDateFormatter.%@", dateFormat];
    NSDateFormatter *dateFormatter = dictionary[key];
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:dateFormat];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        dictionary[key] = dateFormatter;
    }
    
    return dateFormatter;
}

#pragma mark - Getter
- (NSString *)fileName {//自定义文件名：deviceid + phonenum + 日期
    if (!_fileName) {
        _fileName = [self newLogFileName];
    }
    return _fileName;
}
- (NSString *)fileTypeName {
    if (!_fileTypeName) {
        _fileTypeName = @".json";
    }
    return _fileTypeName;
    
}
- (NSString *)filePath {
    if (!_filePath) {
        _filePath = [NSString stringWithFormat:@"%@/FileLogs/%@/",DOCUMENTS_PATH,oyToStr(USERID_Logs)];//最后的 “/” 注意不能省略
    }
    return _filePath;
}
- (NSString *)filePreName {
    if (!_filePreName) {
        NSString *name  =[NSString stringWithFormat:@"%@_%@_",DeviceID_Logs,Phone_Logs];
        _filePreName =  name.length?name:@"DeviceId_PhoneNum_";
    }
    return _filePreName;
}

@end
