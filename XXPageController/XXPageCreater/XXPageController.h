//
//  XXPageController.h
//  XXPageController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 分页控制器加载工具,利用UICollectionView来实现 */
@interface XXPageController : UIViewController

/** 下滑线颜色 */
@property (nonatomic,strong) UIColor *lineColor;
/** 分页条高度 */
@property(nonatomic, assign) CGFloat pageBarHeight;
/** 分页条背景色 */
@property (nonatomic,strong) UIColor *pageBarBgColor;
/** 标题颜色 */
@property (nonatomic,strong) UIColor *titleColor;
/** 标题字体 */
@property (nonatomic,strong) UIFont *titleFont;

/**
 自动创建全部控制器的分页创建方式

 @param titlesArray 标题数组
 @param controllers 控制器数组
 @param onNavigationBar 是否放在控制器上
 @return 栈顶控制管理器
 */
- (instancetype)initWithTitles:(NSArray *)titlesArray controllers:(NSArray *)controllers onNavigationBar:(BOOL)onNavigationBar;

/**
 *  滑动到相应 index 位置时才去创建相应控制器的分页创建方式
 *
 *  @param titlesArray      标题数组
 *  @param controllersClass 要创建的控制器类名数组
 *
 *  @return 栈顶控制管理器
 */
- (instancetype)initWithTitles:(NSArray *)titlesArray controllersClass:(NSArray *)controllersClass onNavigationBar:(BOOL)onNavigationBar;



@end
