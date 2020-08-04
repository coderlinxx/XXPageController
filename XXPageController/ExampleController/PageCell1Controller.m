//
//  PageCell1Controller.m
//  XXPageController
//
//  Created by 林祥兴 on 15/2/1.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "PageCell1Controller.h"
#import "ImageViewController.h"
#import "XXPageMenuController.h"

@interface PageCell1Controller ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

//#define kNavAndStatus_Height ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)

@implementation PageCell1Controller

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
//    [self addTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //当调用_childController.view.frame时，触发ChildViewController的-(void)viewDidLoad方法执行，但是这个时候_childController.view还没被添加在父视图上呢，所以坐标是被设置了，但是还没完成设置，也就是没有最终落地到实处。所以tableView去self.view.bounds还是取得默认的试图控制器的宽和高，默认的宽和高是屏幕的宽和高，所以导致了上述问题。
    //在 viewWillAppear/viewWillLayoutSubviews/viewDidLayoutSubviews 中 subview 的 frame 是准确的
    if (!_tableView) {
        [self addTableView];
    }

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    _tableView.frame = self.view.bounds;
//    _indicatorView.center = _tableView.center;

}

-(UIView *)addHeaderView{
    UIImageView *header = [[UIImageView alloc] initWithFrame:(CGRect){{0, 0}, {self.view.bounds.size.width, 200}}];
    [header setImage:[UIImage imageNamed:@"bg"]];
    header.contentMode = UIViewContentModeScaleAspectFill;
    header.clipsToBounds = YES;
    
    return header;
}

-(void)addTableView{
    CGRect frame = self.view.bounds;
    //frame.size.height = frame.size.height - kNavAndStatus_Height;
    _tableView = [[UITableView alloc] initWithFrame:frame];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [self addHeaderView];
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    _tableView.hidden = YES;

    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.hidesWhenStopped = YES;
    _indicatorView.center = _tableView.center;
    [self.view addSubview:_indicatorView];
    
    [_indicatorView startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_indicatorView stopAnimating];
        _tableView.hidden = NO;
    });
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"PageCell2ControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@" 第 %zd 行 - %@ - %@",indexPath.row,self.title,[self class]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[ImageViewController new]  animated:YES];
}


@end
