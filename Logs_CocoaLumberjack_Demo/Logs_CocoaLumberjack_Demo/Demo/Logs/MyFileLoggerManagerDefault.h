//
//  MyFileLoggerManagerDefault.h
//  Test_Logs
//
//  Created by MrYeL on 2018/7/13.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyFileLoggerManagerDefault : DDLogFileManagerDefault

/**重写 Get方法 */
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSString *filePreName;
@property (nonatomic, strong, readonly) NSString *fileTypeName;
@property (nonatomic, strong, readonly) NSString *filePath;

@end
