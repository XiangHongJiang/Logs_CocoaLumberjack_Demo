//
//  XHLogsManager.m
//  Test_Logs
//
//  Created by MrYeL on 2018/7/10.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "XHLogsManager.h"

static const NSString * crash_fileName = @"";

static XHLogsManager *logsManager = nil;

@interface XHLogsManager ()
/** 自定义Log记录*/
@property (nonatomic, strong) MyLog * myLog;
/** 框架DDFileLogger文件记录 */
@property (nonatomic, strong) MyFileLogger * fileLog;
/** 自定义输出格式*/
@property (nonatomic, strong) MyLogFromatter * format;

/** LOG类型*/
@property (nonatomic, assign) LogType logType;
/** 当前上传的类型*/
@property (nonatomic, assign) UploadLogsType currentUploadType;
/** 当前上传的文件路径*/
@property (nonatomic, copy) NSString * currentUploadFilePath;


/** 上传回调*/
@property (nonatomic, copy) void(^completedBlock)(BOOL succeed,NSString *filePath);


@end

@implementation XHLogsManager

#pragma mark - Lazy Load
- (MyLog *)myLog {
    
    if (_myLog == nil) {
        _myLog = [MyLog new];
    }
    return _myLog;
}
- (MyFileLogger *)fileLog {
    
    if (_fileLog == nil) {
        
        _fileLog = [[MyFileLogger alloc] initWithLogFileManager:[MyFileLoggerManagerDefault new]];
    }
    return _fileLog;
}
- (MyLogFromatter *)format {
    if (_format == nil) {
        _format = [MyLogFromatter new];
    }
    return _format;
}

#pragma mark - -------------- 初始化 -----------------
+ (instancetype)defaultManager {

    static dispatch_once_t oc;
    dispatch_once(&oc, ^{
        logsManager = [XHLogsManager new];
    });
    return logsManager;
}
/** 初始化*/
- (instancetype)init
{
    self = [super init];
    if (self) {
        /** 启动配置:获取初始化信息*/
        [self startConfig];
//        [self startLogsConfigWithLogType:LogType_MyLog];//与用户绑定
    }
    return self;
}
/** 启动配置*/
- (void)startConfig {
    //自定义数据
    self.currentLogsInfoModel = [LogsInfoModel new];
    //上次上传的信息
    NSDictionary *preUploadInfo =  [[NSUserDefaults standardUserDefaults] objectForKey:preUploadInfoKey];
    self.preUploadInfo = [PreUploadLogsInfoModel modelWithDictionary:preUploadInfo];
}
#pragma mark - -------------- 启用Log -----------------

/** 通过类型，启用不同Log*/
- (void)startLogsConfigWithLogType:(LogType)type {
    
    self.logType = type;
    
    /** 先移除所有 再添加，防止重复*/
    [DDLog removeAllLoggers];

    
    /** Log类型*/
    switch (type) {
        case LogType_MyLog:
        {
            self.myLog.logFormatter = self.format;
            [DDLog addLogger:self.myLog];
        }
            
            break;
        case LogType_MyFileLogger:{
            
            self.fileLog.logFormatter = self.format;//日志格式
            [DDLog addLogger:self.fileLog];
        }
            break;
        default:
            break;
    }

    /** 控制台Log*/
#ifdef DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    //    [[DDTTYLogger sharedInstance] setLogFormatter:self.format];

#endif
    
}

#pragma mark - -------------- 崩溃处理 -----------------
/** 奔溃调用*/
void uncaughtExceptionHandler(NSException *exception)  {
    
    //获取系统当前时间，（注：用[NSDate date]直接获取的是格林尼治时间，有时差）
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *crashTime = [formatter stringFromDate:[NSDate date]];
    
    //异常处堆栈
    NSArray *stackArr = [exception callStackSymbols];

   //异常原因
    NSString *reason = [exception reason];
    
    //异常名称
    NSString *name = [exception name];
    
    //拼接错误信息
//    NSString *exceptionInfo = [NSString stringWithFormat:@"\ncrashTime: %@ \nException reason: %@\nException name: %@\nException stack:%@", crashTime, name, reason, stackArr];
   
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:crashTime.length?crashTime:@"" forKey:@"crashTime"];
    [dict setObject:reason.length?reason:@"" forKey:@"Exception_reason"];
    [dict setObject:name.length?name:@"" forKey:@"Exception_name"];
    [dict setObject:stackArr forKey:@"Exception_stack"];

    NSString *jsonStr = [MyLogFromatter dictToJsonString:dict];

    //保存到系统日志，上传时，只需要上传系统日志即可。最后一条即为崩溃信息，可以存储多个文件，不会出现覆盖
    MyLogError(@"%@",jsonStr);
    
//    //可保存到本地，也可以上传，如果是下次上传，需要区分多个保存防止覆盖。
//    NSString *errorLogPath = [NSString stringWithFormat:@"%@/Documents/error.log", NSHomeDirectory()];
//    NSError *error = nil;
//    BOOL isSuccess = [exceptionInfo writeToFile:errorLogPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    if (!isSuccess) {
//        NSLog(@"将crash信息保存到本地失败: %@", error.userInfo);
//    }else {
//        NSLog(@"将crash信息保存到本地成功：%@",errorLogPath);
//    }
    
//    [[XHLogsManager defaultManager] upLoadLogsWithType:UploadLogsType_SysLogs andCompleteBlock:^(BOOL succeed,NSString *filePath) {
//
//        if (succeed) {
//            NSLog(@"上传成功：%@",filePath);
//        }else {
//            NSLog(@"上传失败：%@",filePath);
//        }
//
//    }];

}
#pragma mark - -------------- 预处理 -----------------
//启动预处理: 是否上传或删除 或写入日志 或判断是否已上传
- (void)prepare {
    
    //0.删除过期日志
    [self deleteOutOfDateLog];
    
    //1.若上次上传并失败，根据上次上传的类型，重新上传一次。 否则不操作
    for (LogsFileInfoModel *model in self.preUploadInfo.logsFileInfoArray) {
        
        BOOL preUploadSucceed = model.uploadSucceed;//成功就不传了
        BOOL needUpload = model.faildUploadNextTime;//不需要再传

        if (!preUploadSucceed && needUpload) {//是否失败需要重传
            
//                NSString *filePath = model.filePath;
//                model.faildUploadNextTime = NO;//
//                __weak typeof(self) weakSelf = self;
//                __weak LogsFileInfoModel *weakModel = model;
//                  // 1.重传
//                [self uploadFileWithFilePath:filePath andCompleteBlock:^(BOOL succeed,NSString *path) {
//
//                    weakModel.uploadSucceed = succeed;
//                    [weakSelf savePreUploadInfo:YES];
//
//                }];
            
            }
        }
}
#pragma mark - -------------- 上传 Start -----------------
//上传日志: 不同类型
- (void)upLoadLogsWithType:(UploadLogsType)type andCompleteBlock:(void(^)(BOOL succeed,NSString *filePath))completedBlock{
    
    [self upLoadLogsWithType:type andApplyCd:@"" andLogType:@"" andCompleteBlock:completedBlock];
   
}
- (void)upLoadLogsWithType:(UploadLogsType)type andApplyCd:(NSString *)applyCd andLogType:(NSString *)logType andCompleteBlock:(void(^)(BOOL succeed,NSString *filePath))completedBlock {
    
    self.currentUploadType = type;
    
    //0.根据类型获取需要上传的文件
    if (type != UploadLogsType_SysLogs) {
        
        NSDictionary *dicInfo = [self.currentLogsInfoModel modelToJSONObject];
        if (dicInfo.count) {
            NSString *jsonResult = [MyLogFromatter dictToJsonString:dicInfo];
            NSData *jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
            //1.上传自定义收集的 信息
            [self uploadData:jsonData WithfileName:@"jsonDic" andFileTypeName:@"json" andApplyCd:applyCd andLogType:logType  andCompleteBlock:completedBlock];
        }
    }
    
    //2.上传系统 LOG日志
    if (self.logType == LogType_MyLog) {
        
        NSString *logPath = self.myLog.filePath;
        NSString *fileName = self.myLog.fileName;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",logPath,fileName];
        
        dispatch_async(self.myLog->_loggerQueue, ^{
            
            [self.myLog db_save];
            /** 上传文件*/
            [self uploadFileWithFilePath:filePath andApplyCd:applyCd andLogType:logType andCompleteBlock:completedBlock];
        });
        
        
        
    }else if (self.logType == LogType_MyFileLogger){
        
        DDFileLogger *fileLogger =  self.fileLog ? self.fileLog : [[MyFileLogger alloc] initWithLogFileManager:[MyFileLoggerManagerDefault new]];
        NSArray *logFilePaths = [fileLogger.logFileManager sortedLogFilePaths];
        NSUInteger logCounts = logFilePaths.count;
        NSUInteger needUploadCount = self.fileLog.logFileManager.maximumNumberOfLogFiles > logCounts? logCounts:self.fileLog.logFileManager.maximumNumberOfLogFiles;
        
        for (int i = 0; i < needUploadCount; i ++) {
            
            NSString *filePath = logFilePaths[i];
            /** 上传文件*/
            [self uploadFileWithFilePath:filePath andApplyCd:applyCd andLogType:logType andCompleteBlock:completedBlock];
            
        }
    }
    
}
/** 通过文件路径上传文件，并确定是否下次上传*/
- (void)uploadFileWithFilePath:(NSString *)filePath andApplyCd:(NSString *)applyCd andLogType:(NSString *)logType andCompleteBlock:(void(^)(BOOL succeed,NSString *filePath))completedBlock{
   
    //记录回调
    self.completedBlock = completedBlock;

    //0.判断文件是否存在，如果过期会被删除，无法上传
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) return;//不存在，直接return；
    
    if (filePath.length) {
        self.currentUploadFilePath = filePath;
    }
    
    NSString *fileType = @"";
    
    if ([filePath containsString:@".plist"]) {
#ifdef DEBUG
        NSLog(@"上传 plist 文件 : \n%@",filePath);
#endif
        fileType = @"plist";

    }else if ([filePath containsString:@".json"]) {
#ifdef DEBUG
        NSLog(@"上传 json 文件: \n%@",filePath);
#endif
        fileType = @"json";


    }else if ([filePath containsString:@".txt"]) {
#ifdef DEBUG
        NSLog(@"上传 txt 文件: \n%@",filePath);
#endif
        fileType = @"txt";
        
    }else if ([filePath containsString:@".log"]) {
#ifdef DEBUG
        NSLog(@"上传 log 文件: \n%@",filePath);
#endif
        fileType = @"log";
        
    }else {//非固定的这几种格式
        
        return;
    }
    
    NSString *fileName = @"";
    NSArray *directoryNameArray = [filePath componentsSeparatedByString:@"/"];
    if ([directoryNameArray.lastObject containsString:fileType]) {
        fileName = directoryNameArray.lastObject;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if ([filePath containsString:@".json"]) {
        
        NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:nil];
        NSString *dataStr =  [MyLogFromatter dictToJsonString:dict];
        data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        fileType = @"txt";
//        fileName = [fileName replace:@".json" withString:@".txt"];
        [fileName stringByReplacingOccurrencesOfString:@".json" withString:@".txt"];
    }

//    WS(weakSelf);
//
//    [self uploadData:data WithfileName:fileName andFileTypeName:fileType andApplyCd:applyCd andLogType:logType  andCompleteBlock:^(BOOL succeed, NSString *path) {
//        SS(strongSelf);
//        if (strongSelf.completedBlock) {
//           strongSelf.completedBlock(succeed,weakSelf.currentUploadFilePath);
//        }
//
//        if (succeed) {//删除文件
//            [strongSelf deleteFileWithFilePath:weakSelf.currentUploadFilePath];
//        }
//    }];

}

/** 数据上传 ：调用 自己的网络框架进行数据传输*/
- (void)uploadData:(NSData *)data WithfileName:(NSString *)fileName andFileTypeName:(NSString *)typeName andApplyCd:(NSString *)applyCd andLogType:(NSString *)logType andCompleteBlock:(void(^)(BOOL succeed,NSString *filePath))completedBlock {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
//
//    [params setObject:isNotEmptyValue_Custom(logType, logType, @"0") forKey:@"logType"];
//    [params setObject:isNotEmptyValue_Custom(applyCd, applyCd, @"") forKey:@"applyCd"];
//
//    [params setObject:[TBLoginConfig shareLogin].userInfo.phone.length ? [TBLoginConfig shareLogin].userInfo.phone: @"" forKey:@"phoneNo"];
//    [params setObject:ST(kDfimName) forKey:@"dfimUserName"];
//    [params setObject:ST(kDfimId) forKey:@"dfimId"];
//
//    UploadParamModel *model = [[UploadParamModel alloc] init];
//    model.data = data;
//    model.mimeType = typeName.length?typeName:@"txt";
//    model.fileName = fileName.length?fileName:[XHTools currentSystemTimeString];
//    model.name = @"file";

//    NSString *urlStr = [NSString stringWithFormat:@"%@/%@",@"http://10.43.26.88:8080",@"log/uploadAppLog"];
//    
//    [[XHNetAPIClient sharedClient] Upload:urlStr parameters:params uploadParam:model requestResult:^(NSDictionary *requestParams, NSInteger code, NSDictionary *responseObject) {
//    
////        1.上传
//        if (code == 0 && requestParams) {//
//
//            if (completedBlock) {
//                completedBlock(YES,nil);
//            }
//        }else {
//            if (completedBlock) {
//                completedBlock(NO, nil);
//            }
//        }
//    }];

    
}
/** 上传结束后删除文件*/
- (void)deleteFileWithFilePath:(NSString *)filePath {
    //0.存在路径
    if (filePath.length) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:filePath]) return;//不存在，直接return；
        //删除日志文件
        [fm removeItemAtPath:filePath error:nil];
      
        //新生成一个日志 （重新记录设备信息）
        [self collectDeviceInfo];
    }
    
}

#pragma mark - -------------- 上传 End -----------------

/** 保存或删除 上传的状态信息*/
- (void)savePreUploadInfo:(BOOL)save {
    
    NSDictionary *dict = [self.preUploadInfo modelToJSONObject];
    
    if (dict.count && save) {
        
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:preUploadInfoKey];
        
    }else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:preUploadInfoKey];
        
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - ------------- 删除 ------------------
/** MyLog 下才有效：每天只保留一份文件*/
- (void)deleteOutOfDateLog {
    
    
    NSString *logPath =  @"";//文件夹路径
    NSTimeInterval interval = 0;//过期时间
    NSString *fileTypeName = @"";//文件类型
    NSString *filePreName = @"";//文件除时间外的前缀
    
    if (self.logType == LogType_MyLog && self.myLog && [self.myLog isKindOfClass:[MyLog class]]) {
        logPath = self.myLog.filePath;
        interval = self.myLog.maxAge;
        fileTypeName = self.myLog.fileTypeName;
        filePreName = self.myLog.filePreName;

    }else if(self.logType == LogType_MyFileLogger && self.fileLog && [self.fileLog isKindOfClass:[MyFileLogger class]]) {
    
        MyFileLoggerManagerDefault *fmD = (MyFileLoggerManagerDefault *)self.fileLog.logFileManager;
        logPath = fmD.filePath;
        interval = self.fileLog.rollingFrequency;
        fileTypeName = fmD.fileTypeName;
        filePreName = fmD.filePreName;

    }
    
#ifdef DEBUG
    NSLog(@"\n日志地址:\n%@",logPath);
#endif

    //删除过期interval s的日志
    NSDate *prevDate = [[NSDate date] dateByAddingTimeInterval:-(interval)];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:prevDate];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    //要删除1天以前的日志（0点开始）
    NSDate *delDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSArray *logFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logPath error:nil];
    
    //如果沙盒里面日志小于2份，就不要删除了，最少保留1天
    if (logFiles.count < 2) {
        
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];// 日期到天
    delDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:prevDate] ];
    
    for (NSString *file in logFiles)
    {
        if ([file containsString:@".DS_Store"]) continue;
        NSString *fileName = [file stringByReplacingOccurrencesOfString:fileTypeName withString:@""];
        fileName = [fileName stringByReplacingOccurrencesOfString:filePreName withString:@""];
        NSDate *fileDate = [dateFormatter dateFromString:fileName];//文件的创建时间
        if (nil == fileDate)
        {
            continue;
        }
        if (NSOrderedAscending == [fileDate compare:delDate])
        {
            [[NSFileManager defaultManager] removeItemAtPath:[logPath stringByAppendingString:file] error:nil];//删除日志文件
            DDLogInfo(@"删除过期日志文件成功:%@",file);
        }
    }
    
}
//收集设备信息 添加时自定义重写get方法
- (void)collectDeviceInfo {
    
        NSDictionary *deviveInfoDic = [self.currentLogsInfoModel modelToJSONObject];
        NSString *deviceInfoStr = [MyLogFromatter dictToJsonString:deviveInfoDic];
       
        MyLogDeviceInfo(@"%@",deviceInfoStr);
}

@end



