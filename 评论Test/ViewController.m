//
//  ViewController.m
//  评论Test
//
//  Created by 伯驹网络 on 2017/11/1.
//  Copyright © 2017年 Nicholas. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "hDetailViewController.h"
#import "hMyDetailViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *dataAry;
}

@property(strong,nonatomic)UITableView *hTableV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"列表";
    dataAry = @[@"headerImg1.jpg",@"headerImg2.jpg",@"headerImg3.jpg",@"headerImg1.jpg",@"headerImg2.jpg",@"headerImg3.jpg"];
    [self creatUI];
}

-(void)creatUI
{
    _hTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight) style:UITableViewStylePlain];
    _hTableV.delegate = self;
    _hTableV.dataSource = self;
    _hTableV.tableFooterView = [[UIView alloc]init];
    _hTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_hTableV registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
    [self.view addSubview:_hTableV];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataAry.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    if (!cell) {
        cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewCell"];
    }
    cell.headerLab.text = [NSString stringWithFormat:@"第  %ld  行",(long)indexPath.row];
    cell.bgImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",dataAry[indexPath.row]]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        hDetailViewController *hdetailVC = [[hDetailViewController alloc]init];
        hdetailVC.idenStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [self.navigationController pushViewController:hdetailVC animated:true];
    }else if (indexPath.row == 1)
    {
        hMyDetailViewController *hmyVC = [[hMyDetailViewController alloc]init];
        [self.navigationController pushViewController:hmyVC animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
