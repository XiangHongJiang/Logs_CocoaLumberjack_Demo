//
//  LogsInfoModel.m
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "LogsInfoModel.h"

@implementation LogsInfoModel

- (NSString *)platform {
    if (_platform == nil) {
        _platform = @"iOS";
    }
    return _platform;
}

@end

@implementation PreUploadLogsInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"logsFileInfoArray" : [LogsFileInfoModel class]};
}


@end

@implementation LogsFileInfoModel

@end

