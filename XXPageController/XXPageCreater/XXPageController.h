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
 创建分页控制器 : 自动创建全部控制器(方式一)

 @param titlesArray 标题数组
 @param controllers 控制器数组
 @param onNavigationBar 分页栏是否放在控制器导航栏上
 @return 栈顶控制管理器
 */
- (instancetype)initWithTitles:(NSArray *)titlesArray controllers:(NSArray *)controllers onNavigationBar:(BOOL)onNavigationBar;

/**
 *  创建分页控制器 : 滑动到相应 index 位置时才去创建相应控制器(方式二)
 *
 *  @param titlesArray      标题数组
 *  @param controllersClass 要创建的控制器类名数组
 *  @param onNavigationBar 分页栏是否放在控制器导航栏上
 *  @return 栈顶控制管理器
 */
- (instancetype)initWithTitles:(NSArray *)titlesArray controllersClass:(NSArray *)controllersClass onNavigationBar:(BOOL)onNavigationBar;

/**
 如果将分页控制器添加到父视图控制器上,则直接调用此方式来最后添加到其上!
 PS: 如果是直接push分页控制器PageViewController,则不需要调用此方法!

 @param viewController 目标父视图控制器
 */
- (void)addPageViewControllerToSuperViewController:(UIViewController *)viewController;

@end

/** 此子类的主要目的: iOS横向滚动的scrollView和系统pop手势返回冲突的解决办法,如果您使用了自定义的UINavigationController或者自定义了UINavigationBar 的返回按钮,那么此类必须使用 */
@interface PopEnabeldCollectionView : UICollectionView<UIGestureRecognizerDelegate>
@end

@interface ItemCell : UICollectionViewCell
@property(nonatomic, strong) UILabel *titleLabel;
@end
