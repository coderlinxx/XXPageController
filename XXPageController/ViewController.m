//
//  ViewController.m
//  XXPageController
//
//  Created by 林祥兴 on 16/2/1.
//  Copyright © 2016年 pogo.inxx. All rights reserved.
//

#import "ViewController.h"
#import "XXPageMenuController.h"
#import "PageCell1Controller.h"
#import "PageCell2Controller.h"
#import "Parent1Controller.h"
#import "Parent2Controller.h"
#import "Parent3Controller.h"
#import "Parent4Controller.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong)UITableView *tableView;
@property(nonatomic,strong)UIColor *color ;
@end

#define SCREEN_Width ([[UIScreen mainScreen] bounds].size.width)

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PageMenu:菜单控制器展示方式";
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
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 30)];
    label.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    if (section == 0) {
        label.text = @"    直接push-->XXPageMenuController 方式";
    }else{
        label.text = @"    将PageMenu添加到 parentViewController/view 方式";
    }
    return label;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"ViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @" 多菜单页 & onNavigationBar: YES";
                break;
            case 1:
                cell.textLabel.text = @" 多菜单页 & onNavigationBar: NO";
                break;
            case 2:
                cell.textLabel.text = @" 少菜单页 & onNavigationBar: YES";
                break;
            default:
                cell.textLabel.text = @" 少菜单页 & onNavigationBar: NO";
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @" 多菜单页 & onNavigationBar: YES";
                break;
            case 1:
                cell.textLabel.text = @" 多菜单页 & onNavigationBar: NO";
                break;
            case 2:
                cell.textLabel.text = @" 少菜单页 & onNavigationBar: YES";
                break;
            default:
                cell.textLabel.text = @" 少菜单页 & onNavigationBar: NO";
                break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSArray *titles = @[@"0新闻",@"1体育",@"2汽车",@"3房产",@"4旅游局",@"5教育基地",@"6时尚",@"7科技"];
    NSArray *titles2 = @[@"0新闻",@"1体育",@"2汽车",@"3房产"];

    if (indexPath.section == 0) {
        
        
        XXPageMenuController *pageMenuController = nil;
        
        switch (indexPath.row) {
            case 0:
            {
                NSMutableArray *controllersClass = [NSMutableArray array];
                [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [controllersClass addObject:[PageCell2Controller class]];
                }];
                pageMenuController = [[XXPageMenuController alloc] initWithTitles:titles controllersClass:controllersClass onNavigationBar:YES];
            }
                break;
            case 1:
            {
                NSMutableArray *controllers = [NSMutableArray array];
                [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [controllers addObject:[PageCell1Controller new]];
                }];
                pageMenuController = [[XXPageMenuController alloc] initWithTitles:titles controllers:controllers onNavigationBar:NO];
                pageMenuController.titleColor = [UIColor whiteColor];
                pageMenuController.pageBarBgColor = [UIColor grayColor];
                pageMenuController.pageBarHeight = 44;
                pageMenuController.lineColor = [UIColor orangeColor];
            }
                break;
            case 2:
            {
                pageMenuController = [[XXPageMenuController alloc] initWithTitles:titles2 controllersClass:@[[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
            }
                break;
            default:
            {
                pageMenuController = [[XXPageMenuController alloc] initWithTitles:titles2 controllersClass:@[[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell2Controller class]] onNavigationBar:NO];
            }
                break;
        }
        
        [self.navigationController pushViewController:pageMenuController animated:YES];
        
    }else{
        switch (indexPath.row) {
            case 0:
                [self.navigationController pushViewController:[Parent1Controller new] animated:YES];
                break;
            case 1:
                [self.navigationController pushViewController:[Parent2Controller new] animated:YES];
                break;
            case 2:
                [self.navigationController pushViewController:[Parent3Controller new] animated:YES];
                break;
            default:
                [self.navigationController pushViewController:[Parent4Controller new] animated:YES];
                break;
        }
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
