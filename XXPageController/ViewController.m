//
//  ViewController.m
//  XXPageController
//
//  Created by 林祥兴 on 16/2/1.
//  Copyright © 2016年 pogo.inxx. All rights reserved.
//

#import "ViewController.h"
#import "XXPageController.h"
#import "PageCell1Controller.h"
#import "PageCell2Controller.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong)UITableView *tableView;
@property(nonatomic,strong)UIColor *color ;
@end

#define SCREEN_Width ([[UIScreen mainScreen] bounds].size.width)

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [self addHeaderView];
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
}

-(UIView *)addHeaderView{
    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_Width, 200)];
    [header setImage:[UIImage imageNamed:@"bg"]];
    header.contentMode = UIViewContentModeScaleAspectFill;
    header.clipsToBounds = YES;
    
    return header;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"ViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"分页加载管理器 多页&&onNavigationBar : YES";
            break;
        case 1:
            cell.textLabel.text = @"分页加载管理器 多页&&onNavigationBar : NO";
            break;
        case 2:
            cell.textLabel.text = @"分页加载管理器 少页&&onNavigationBar :  YES";
            break;
        case 3:
            cell.textLabel.text = @"分页加载管理器 少页&&onNavigationBar : NO";
            break;
        default:
            cell.textLabel.text = @"分页加载管理器 少页&&onNavigationBar : NO";
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *pageVc;
    switch (indexPath.row) {
        case 0:
        {
            pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
        }
            break;
        case 1:
        {
            pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class]] onNavigationBar:NO];
        }
            break;
        case 2:
        {
            pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
        }
            break;
        default:
            pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信"] controllersClass:@[[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class]] onNavigationBar:NO];
            break;
    }
    [self.navigationController pushViewController:pageVc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
