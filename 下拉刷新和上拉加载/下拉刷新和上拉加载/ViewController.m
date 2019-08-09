//
//  ViewController.m
//  下拉刷新和上拉加载
//
//  Created by 谢鑫 on 2019/8/8.
//  Copyright © 2019 Shae. All rights reserved.
//

#import "ViewController.h"
#import <MJRefresh.h>
# define randomData [NSString stringWithFormat:@"随机数————%d",arc4random_uniform(1000000)]
@interface ViewController ()<UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property int moreDataFlag;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _moreDataFlag=1;
    [self.view addSubview:self.tableView];
}
- (UITableView *)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 30, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)-30) style:UITableViewStylePlain];
        _tableView.dataSource=self;
        self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self loadNewData];
        }];
        self.tableView.mj_footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    }
    return _tableView;
}
- (NSMutableArray *)dataArray{
    if (_dataArray==nil) {
         _dataArray=[NSMutableArray array];
    for (int i=0; i<5; i++) {
        [_dataArray addObject:randomData];
        }
    }
    return _dataArray;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5*_moreDataFlag;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text=self.dataArray[indexPath.row];
    return cell;
}
-(void)loadNewData{
    NSLog(@"1");
    //刷新前先移除表中数据
    [self.dataArray removeAllObjects];
    //1.添加与移除前等量的新数据
    for(int i=0;i<5*self.moreDataFlag;i++){
        [self.dataArray insertObject:randomData  atIndex:0];
    }
    //2.模拟2s后刷新表格UI（真实开发中，可以移除这段GCD代码）
    __weak UITableView *tableView=self.tableView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //刷新表格
        [tableView reloadData];
        //拿到当前的下拉刷新控件，结束刷新状态
        [tableView.mj_header endRefreshing];
    });
    
}
-(void)loadMoreData{
    NSLog(@"2");
   
    //添加数据
    for (int i=0; i<5; i++) {
        [self.dataArray addObject:randomData];
    }
    //模拟2s后刷新表格UI,（真实开发中，可以移除这段GCD代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW , (int64_t)(2.0)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    });
    self.moreDataFlag ++;
}
@end
