//
//  ViewOnViewController.m
//  XXPageController
//
//  Created by 林祥兴 on 2017/8/13.
//  Copyright © 2017年 pogo.inxx. All rights reserved.
//

#import "ViewOnViewController.h"
#import "XXPageController.h"
#import "PageCell1Controller.h"
@interface ViewOnViewController ()
@property (nonatomic, strong) XXPageController *pageVc;
@end

@implementation ViewOnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
    
    NSArray *titles = @[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] ;
    NSMutableArray *controllers = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [controllers addObject:[PageCell1Controller new]];
    }];
    _pageVc = [[XXPageController alloc] initWithTitles:titles controllers:controllers onNavigationBar:NO];
    _pageVc.lineColor = [UIColor orangeColor];
    _pageVc.titleColor = [UIColor whiteColor];
    _pageVc.pageBarBgColor = [UIColor blackColor];
    _pageVc.pageBarHeight = 32;
    
    //    [self.view addSubview:_pageVc.view];
    //    [self addChildViewController:_pageVc];
    [_pageVc addPageViewControllerToSuperViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
