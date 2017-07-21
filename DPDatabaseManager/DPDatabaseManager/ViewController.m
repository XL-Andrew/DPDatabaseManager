//
//  ViewController.m
//  DPDatabaseManager
//
//  Created by Andrew on 2017/7/20.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "ViewController.h"
#import "DemoModel.h"
#import "DPDatabaseManager.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSMutableArray *dataSource;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    dataSource = [NSMutableArray array];
    [self reloadAllData];
    
    UIButton *addData = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addData.frame = CGRectMake(0, 0, 40, 40);
    [addData addTarget:self action:@selector(addDataClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:addData];
    self.navigationItem.rightBarButtonItems = @[backItem];
    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
}

- (void)addDataClick
{
    NSString *name = [[NSArray arrayWithObjects:@"张三", @"李四", @"王五", @"赵六", @"鬼脚七", @"张小凡", @"碧瑶", @"周一仙", @"炼器师", nil] objectAtIndex:arc4random() % 8];
    NSUInteger age = arc4random() % 101 + 1;
    NSUInteger adult = arc4random() % 2;
    
    DemoModel *model = [[DemoModel alloc]init];
    model.userName = name;
    model.userAge = age;
    model.isAdult = adult == 1?YES:NO;
    
    //数据插入
    [[DPDatabaseManager sharedDBManager]insertDataWithModel:model withFileName:@"textDemo"];
    [self reloadLastData];
}

- (void)reloadAllData
{
    //获取全部数据
    NSArray *dbArray = [[DPDatabaseManager sharedDBManager]getAllDataWithModelClass:[DemoModel class] withFileName:@"textDemo"];
    [dataSource addObjectsFromArray:dbArray];
    [myTableView reloadData];
}

- (void)reloadLastData
{
    //获取最后一条数据
    DemoModel *model = [[DPDatabaseManager sharedDBManager]getLastDataWithModelClass:[DemoModel class] withFileName:@"textDemo"];
    [dataSource addObject:model];
    [myTableView reloadData];
}

- (void)reloadDataWithCount:(NSUInteger)count
{
    NSArray *dbArray = [[DPDatabaseManager sharedDBManager]getDataWithCount:count withModelClass:[DemoModel class] withFileName:@"textDemo"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DemoModel *model = [dataSource objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"姓名:%@ 年龄:%ld 是否成仙:%@",model.userName,model.userAge,model.isAdult?@"是":@"否"];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
