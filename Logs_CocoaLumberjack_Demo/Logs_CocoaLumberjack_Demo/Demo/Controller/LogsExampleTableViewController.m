//
//  LogsExampleTableViewController.m
//  Logs_CocoaLumberjack_Demo
//
//  Created by MrYeL on 2018/7/19.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "LogsExampleTableViewController.h"
#import "TestCustomerLogViewController.h"

@interface LogsExampleTableViewController ()

/** 数据Array*/
@property (nonatomic, copy) NSArray * dataArray;



@end

@implementation LogsExampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"日志";
    
    self.dataArray = @[@"启用Log",@"打印Log",@"上传Log",@"越界崩溃(使用前，先启用Log才会记录)",@"跳转自定义log输出",@"开启\关闭崩溃监听"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [self starLog];
            break;
        case 1:
            [self logsCollect];
            break;
        case 2:
            [self logsUpload];
            break;
        case 3:
            [self crashChoose];
            break;
        case 4:
            [self skipVC];
        case 5:
            [XHLogsManager defaultManager].isHandleCrash = ![XHLogsManager defaultManager].isHandleCrash;
            break;
        default:
            break;
    }
    
}
- (void)skipVC{
    [self.navigationController pushViewController:[TestCustomerLogViewController new] animated:NO];
}
- (void)crashChoose {
    
    [NSArray new][1];
   
}
#pragma mark - Action
/** 启用日志:与用户绑定，登录成功后启用，登录之前的信息，可通过自定义收集信息先记录*/
- (void)starLog {
    
    //启用
    [[XHLogsManager defaultManager] startLogsConfigWithLogType:LogType_MyLog];
    //预处理：删除 \上传之前失败的，默认不上传，调用上传
    [[XHLogsManager defaultManager] prepare];
   
}

//记录收集
- (void)logsCollect {
    
    //打印系统Log并记录
    DDLogError(@"[Error]:%@", @"输出错误信息");    //输出错误信息
    DDLogWarn(@"[Warn]:%@", @"输出警告信息");    //输出警告信息
    DDLogInfo(@"[Info]:%@", @"输出描述信息");    //输出描述信息
    //    DDLogDebug(@"[Debug]:%@", @"输出调试信息");    //输出调试信息
    //    DDLogVerbose(@"[Verbose]:%@", @"输出详细信息"); //输出详细信息
    [XHLogsManager defaultManager].currentLogsInfoModel.platform = @"iOS";//运行中自定义收集的信息
    
}
//上传
- (void)logsUpload {
    [[XHLogsManager defaultManager] upLoadLogsWithType:UploadLogsType_SysLogs andCompleteBlock:^(BOOL succeed, NSString *filePath) {
        
        if (succeed) {
            NSLog(@"上传成功:%@",filePath);
        }else {
            NSLog(@"上传失败:%@",filePath);
        }
    }];
}

@end
