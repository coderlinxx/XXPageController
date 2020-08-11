//
//  Parent4Controller.m
//  XXPageController
//
//  Created by GoGo: 林祥星 on 2018/6/29.
//  Copyright © 2018年 pogo.inxx. All rights reserved.
//

#import "Parent4Controller.h"
#import "XXPageMenuController.h"
#import "PageCell1Controller.h"

@interface Parent4Controller ()

@end
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width

@implementation Parent4Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);

    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    [header setImage:[UIImage imageNamed:@"bg"]];
    header.contentMode = UIViewContentModeScaleAspectFill;
    header.clipsToBounds = YES;
    [self.view addSubview:header];
    
    NSArray *titles = @[@"新闻",@"体育",@"汽车",@"房产"];
    
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
    pageMenuController.lineWidthType = LineWidthTypeStaticShort;
    //pageMenuController.lineScrollType = arc4random() % 2 + 1; //1,2随机 LineScrollTypeFinishedAnimation 或者 LineScrollTypeFinishedLinear;
    pageMenuController.defaultIndex = 1;
    pageMenuController.originY = 100;
    //因为这里是将pageMenuController添加到ParentController(self类)上的,所以要为pageMenuController设置父视图控制器
    [pageMenuController setSuperViewController:self];
        
    pageMenuController.didLayoutSubviewsBlock = ^(UIView *pageMenuControllerView, UIScrollView *scrollViewPage, UICollectionView *collectionMain) {
        //do something
    };

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
