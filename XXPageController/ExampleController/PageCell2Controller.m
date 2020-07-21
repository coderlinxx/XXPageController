//
//  PageCell2Controller.m
//  XXPageController
//
//  Created by 林祥兴 on 16/1/22.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "PageCell2Controller.h"
#import "ImageViewController.h"
#import "XXPageMenuController.h"
@interface PageCell2Controller ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

#define kNavAndStatus_Height ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)

@implementation PageCell2Controller

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self addTableView];
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
    frame.size.height = frame.size.height - kNavAndStatus_Height;
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.tableHeaderView = [self addHeaderView];
    _tableView.tableFooterView = [[UIView alloc] init];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.hidesWhenStopped = YES;
    _indicatorView.center = _tableView.center;
    _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_indicatorView];
    
    [_indicatorView startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_indicatorView stopAnimating];
        [self.view addSubview:_tableView];
    });

}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
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
    [self.navigationController pushViewController:[ImageViewController new] animated:YES];
}

@end
