//
//  MyLog.h
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "DDAbstractDatabaseLogger.h"

#define maxAgeTime 60*60*24

#pragma mark - ----------------------沙盒路径----------------------------
#define CACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject
#define DOCUMENTS_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
#define oyToStr(desStr)             [NSString stringWithFormat:@"%@",desStr]

#define USERID_Logs @"UserId" //修改UserId 为当前登录的文件名
#define DeviceID_Logs @"DeviceId" //修改DeviceId 为当前设备UUID
#define Phone_Logs @"PhoneNum" //修改phoneNumber 为当前登录的手机号


/** 自定义Log 信息*/ //每天只会生成一个文件，并且可设置文件的
@interface MyLog : DDAbstractDatabaseLogger

/**重写 Get方法 */
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSString *filePreName;
@property (nonatomic, strong, readonly) NSString *fileTypeName;
@property (nonatomic, strong, readonly) NSString *filePath;

- (void)db_save;

@end
