
//  ViewOnViewController.m
//  XXPageController
//
//  Created by 林祥兴 on 2017/8/13.
//  Copyright © 2017年 pogo.inxx. All rights reserved.
//

#import "Parent1Controller.h"
#import "XXPageMenuController.h"
#import "PageCell1Controller.h"
@interface Parent1Controller ()

@end

@implementation Parent1Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
    NSArray *titles = @[@"0新闻",@"1体育",@"2汽车",@"3房产",@"4旅游局",@"5教育",@"6时尚",@"7科技"];

    NSMutableArray *controllers = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [controllers addObject:[PageCell1Controller new]];
    }];
    XXPageMenuController *pageMenuController = [[XXPageMenuController alloc] initWithTitles:titles controllers:controllers onNavigationBar:YES];
    pageMenuController.lineColor = [UIColor orangeColor];
    pageMenuController.titleFont = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    pageMenuController.titleColor = [UIColor colorWithWhite:0.2 alpha:1];
    pageMenuController.titleSelectedColor = [UIColor blackColor];
    pageMenuController.pageBarBgColor = [UIColor clearColor];
    
    //因为这里是将pageMenuController添加到ParentController(self类)上的,所以要为pageMenuController设置父视图控制器
    [pageMenuController setSuperViewController:self];

    pageMenuController.defaultIndex = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
