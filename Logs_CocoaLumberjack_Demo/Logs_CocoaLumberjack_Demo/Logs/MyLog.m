//
//  MyLog.m
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//


#import "MyLog.h"


/** 自定义Log 信息*/
@interface MyLog ()

/**日志数组 */
@property (nonatomic, strong) NSMutableArray *logMessagesArray;


@end

@implementation MyLog
@synthesize fileName = _fileName;
@synthesize fileTypeName = _fileTypeName;
@synthesize filePath = _filePath;
@synthesize filePreName = _filePreName;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.deleteInterval = 0;
        self.maxAge =maxAgeTime;//每天
        self.deleteOnEverySave = NO;
        self.saveInterval = 1;//每1s保存一次
        self.saveThreshold = 1;//当未保存的log达到1条时，会调用db_save方法保存，每1条保存一次
        
        //注册app切换到后台通知，保存日志到沙盒
//                [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(saveLog)
        //                                                     name:@"UIApplicationWillResignActiveNotification"
        //                                                   object:nil];
    }
    return self;
}

- (void)saveLog {
    dispatch_async(_loggerQueue, ^{
        [self db_save];
    });
}

/**
 *  每次打 log 时，db_log会被调用
 *
 */
- (BOOL)db_log:(DDLogMessage *)logMessage
{
    if (!_logFormatter) {
        //没有指定 formatter
        return NO;
    }
    
    if (!_logMessagesArray)
        _logMessagesArray = [NSMutableArray array]; // saveThreshold
    
    //利用 formatter 得到消息字符串，添加到缓存，当调用db_save时，写入沙盒
    [_logMessagesArray addObject:[_logFormatter formatLogMessage:logMessage]];
    return YES;
}


/**
 *  写入文件的log数达到 X 时，db_save 调用
 *
 */
- (void)db_save{
    //判断是否在 logger 自己的GCD队列中
    if (![self isOnInternalLoggerQueue])
        NSAssert(NO, @"db_saveAndDelete should only be executed on the internalLoggerQueue thread, if you're seeing this, your doing it wrong.");
    
    //如果缓存内没数据，啥也不做
    if ([_logMessagesArray count] == 0) {
        return;
    }
    //获取缓存中所有数据，之后将缓存清空
    NSArray *oldLogMessagesArray = [_logMessagesArray copy];
    _logMessagesArray = [NSMutableArray arrayWithCapacity:0];
    
    //用换行符，把所有的数据拼成一个大字符串
    NSString *logMessagesString = [oldLogMessagesArray componentsJoinedByString:@"\n"];
    
    
    //判断有没有文件夹，如果没有，就创建
    NSString *createPath = self.filePath;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",createPath,self.fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSMutableArray *logsArray = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {//文件存在
        
        if ([self.fileTypeName containsString:@"plist"]) {//plist
            logsArray = [NSMutableArray arrayWithContentsOfFile:filePath];
        }else if ([self.fileTypeName containsString:@"json"]) {//json
            logsArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:nil];
        }
        
    }else {
        
        if ([self.fileTypeName containsString:@"txt"]||[self.fileTypeName containsString:@"log"]) {//txt
            
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }

    }
    
    logsArray = logsArray? logsArray : [NSMutableArray new];
    
    NSDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:[logMessagesString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    [logsArray addObject:infoDic];
    
    if ([self.fileTypeName containsString:@"plist"]) {//写成plist文件
      
        [logsArray writeToFile:filePath atomically:YES];

    }else if ([self.fileTypeName containsString:@"json"]){//写成json文件
        
        NSData *json_data = [NSJSONSerialization dataWithJSONObject:logsArray options:NSJSONWritingPrettyPrinted error:nil];

        [json_data writeToFile:filePath atomically:YES];
        
    }else if ([self.fileTypeName containsString:@"txt"]||[self.fileTypeName containsString:@"log"]) {//写成字符串文件
            //1.通过字符串追加方式添加
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
            [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
            NSData* stringData  = [[NSString stringWithFormat:@",\n%@",logMessagesString] dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:stringData]; //追加写入数据
            [fileHandle closeFile];
    }
    
    //跳过iCloud上传
//    [self addSkipBackupAttributeToItemAtPath:filePath];
    
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSString *err = [NSString stringWithFormat:@"Error excluding %@ from backup %@", [URL lastPathComponent], error];
    }
    return success;
}
/** 获取日期*/
- (NSString *)dateStrWithDate:(NSDate *)date andFormatStr:(NSString *)formatStr {
    
    date = date? date:[NSDate date];
    formatStr = formatStr.length? formatStr: @"yyyy-MM-dd";
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = formatStr;
    NSString *resultStr = [df stringFromDate:date];
    return resultStr;
}

- (NSString *)fileName {//自定义文件名：deviceid + phonenum + 日期
    if (!_fileName) {
        _fileName = [NSString stringWithFormat:@"%@%@%@",self.filePreName,[self dateStrWithDate:[NSDate date] andFormatStr:@"yyyyMMdd"],self.fileTypeName];
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
        _filePath = [NSString stringWithFormat:@"%@/Logs/%@",DOCUMENTS_PATH,oyToStr(USERID_Logs)];
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
