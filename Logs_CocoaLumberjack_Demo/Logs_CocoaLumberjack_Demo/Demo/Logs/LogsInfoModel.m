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
- (NSString *)osVersion {
    
    return @"";
}
- (NSString *)phoneInfo {
    
    return @"";
}
- (NSString *)appVersion {
    
    return @"";
}
- (NSString *)appName {
    
    return @"";
}
- (NSString *)languageEnv {
    
    return @"";
}
- (NSString *)cpuType {
    
    return  @"";
}
- (NSString *)carrierName {
    
    return @"";
}
- (NSString *)netWorkStates {
    
    return @"";
}

//- (NSString *)totalMemory {
//
//    return [NSString stringWithFormat:@"%lld M", getTotalMemory]/(1024*1024)];
//}
//- (NSString *)freeMemory {
//
//    return [NSString stringWithFormat:@"%lld M",[ getFreeMemory]/(1024*1024)];
//}
//- (NSString *)usedMemory {
//
//    return [NSString stringWithFormat:@"%lld M",[ getUsedMemory]/(1024*1024)];
//}
@end

@implementation PreUploadLogsInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"logsFileInfoArray" : [LogsFileInfoModel class]};
}


@end

@implementation LogsFileInfoModel

@end

