//
//  TestCustomerLogViewController.m
//  Logs_CocoaLumberjack_Demo
//
//  Created by JXH on 2020/12/22.
//  Copyright © 2020 MrYeL. All rights reserved.
//

#import "TestCustomerLogViewController.h"

@interface TestCustomerLogViewController ()

/** shuju*/
@property (nonatomic, copy) NSArray *dataA;



@end

@implementation TestCustomerLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataA = @[@"崩溃信息记录",@"警告记录",@"基本info记录"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TestCustomerLogViewController"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataA.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static  NSString *const cellId = @"TestCustomerLogViewController";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
 
    
    cell.textLabel.text = self.dataA[indexPath.row];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    DDLogError(@"[Error]:%@", @"输出错误信息");    //输出错误信息
//    DDLogWarn(@"[Warn]:%@", @"输出警告信息");    //输出警告信息
//    DDLogInfo(@"[Info]:%@", @"输出描述信息");
    switch (indexPath.row) {
        case 0:
            DDLogError(@"通常用于崩溃信息统计。");
            break;
        case 1:
            DDLogWarn(@"通常用于警告信息统计。");
            break;
        case 2:
            DDLogInfo(@"%@",self.dataA);
            break;
        default:
            break;
    }
    
    NSMutableArray *ma = @[];
    [ma addObject:@1];
    
}


@end
