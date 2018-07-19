//
//  MyLogFromatter.h
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 自定义Log 日志格式*/
@interface MyLogFromatter : NSObject<DDLogFormatter>

+ (NSString *)dictToJsonString:(NSDictionary *)dictionary;

@end


