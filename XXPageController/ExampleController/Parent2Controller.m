//
//  Parent2Controller.m
//  XXPageController
//
//  Created by GoGo: 林祥星 on 2018/6/29.
//  Copyright © 2018年 pogo.inxx. All rights reserved.
//

#import "Parent2Controller.h"
#import "XXPageMenuController.h"
#import "PageCell1Controller.h"

@interface Parent2Controller ()

@end

@implementation Parent2Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
    NSArray *titles = @[
        @"即时的",
        @"下划线",
        @"动态",
        @"动画",
        @"根据",
        @"文字长度",
        @"动态",
        @"决定",
        @"下划线长度",
        @"体育",
        @"汽车",
        @"房产",
        @"旅游局",
        @"教育",
    ];
    
    NSMutableArray *controllers = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [controllers addObject:[PageCell1Controller new]];
    }];
    XXPageMenuController *pageMenuController = [[XXPageMenuController alloc] initWithTitles:titles controllers:controllers onNavigationBar:NO];
    pageMenuController.lineColor = [UIColor orangeColor];
    pageMenuController.titleFont = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    pageMenuController.titleColor = [UIColor colorWithWhite:0.2 alpha:1];
    pageMenuController.titleSelectedColor = [UIColor blackColor];
    pageMenuController.pageBarBgColor = [UIColor whiteColor];
    pageMenuController.pageBarHeight = 44;
    pageMenuController.lineWidthType = LineWidthTypeDynamic;
//    pageMenuController.lineWidthType = LineWidthTypeStaticLong; ///<下划线长度取值类型
    pageMenuController.lineScrollType = LineScrollTypeDynamicAnimation; ///<下划线在条目切换时的动态表现类型
    pageMenuController.pageCellWidthType = PageCellWidthTypeByTitleLength; ///<分页条目 cell 宽度取值类型
    pageMenuController.pageTitleFontChangeType = PageTitleFontChangeTypeScrolling; ///<分页滑动时标题字体大小改变方式
    //因为这里是将pageMenuController添加到ParentController(self类)上的,所以要为pageMenuController设置父视图控制器
    [pageMenuController setSuperViewController:self];
    
    pageMenuController.defaultIndex = 5;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
