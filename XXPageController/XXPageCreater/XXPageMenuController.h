//
//  XXPageController.h
//  XXPageController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 下划线长度取值类型
 
 - LineWidthTypeStaticShort: 静态短长度,取个固定短值
 - LineWidthTypeStaticLong: 静态长度,根据总长度/数量
 - LineWidthTypeDynamic: 动态长度,根据文字长度
 */
typedef NS_ENUM(NSInteger, LineWidthType) {
    LineWidthTypeStaticShort = 0,
    LineWidthTypeStaticLong,
    LineWidthTypeDynamic,
};

/**
 下划线在条目切换时的动态表现类型

 - LineScrollTypeDynamicAnimation: 即时的下划线动态动画
 - LineScrollTypeFinishedAnimation: 完成后的下划线动态动画
 - LineScrollTypeFinishedLinear: 完成后的下划线线性动画
 - LineScrollTypeDynamicLinear: 即时的下划线线性动画(先不做了,实用性完全被LineScrollTypeDynamicAnimation替代了...)
 */
typedef NS_ENUM(NSInteger, LineScrollType) {
    LineScrollTypeDynamicAnimation = 0,
    LineScrollTypeFinishedAnimation,
    LineScrollTypeFinishedLinear,
};

/** 分页控制器加载工具,利用UICollectionView来实现 */
@interface XXPageMenuController : UIViewController

/** 分页条高度 */
@property(nonatomic, assign) CGFloat pageBarHeight;
/** 分页条背景色 */
@property (nonatomic,strong) UIColor *pageBarBgColor;
/** 下滑线颜色 */
@property (nonatomic,strong) UIColor *lineColor;
/** 下滑线高度 */
@property (nonatomic,assign) CGFloat lineHeight;
/** 下划线长度取值类型 */
@property (nonatomic,assign) LineWidthType lineWidthType;
/** 下划线在条目切换时的动态表现类型 */
@property (nonatomic,assign) LineScrollType lineScrollType;
/** 标题颜色 */
@property (nonatomic,strong) UIColor *titleColor;
/** 标题选中颜色(可不设置) */
@property (nonatomic,strong) UIColor *titleSelectedColor;
/** 标题字体 */
@property (nonatomic,strong) UIFont *titleFont;

/** 默认选择的 index 位置 ,默认值为0*/
- (void)moveToDefaultIndex:(NSInteger)index;

/**
 创建分页控制器 : 自动创建全部控制器(方式一)
 
 @param titlesArray 标题数组
 @param controllers 控制器数组
 @param onNavigationBar 分页栏是否放在控制器导航栏上
 @return 栈顶控制管理器
 */
- (instancetype)initWithTitles:(NSArray *)titlesArray controllers:(NSArray *)controllers onNavigationBar:(BOOL)onNavigationBar;

/**
 *  创建分页控制器 : 滑动到相应 index 位置时才去创建相应控制器,此方式不太好传参(方式二)
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

 @param superVc 目标父视图控制器
 */
- (void)setSuperViewController:(UIViewController *)superVc;

@end

/** 此子类的主要目的: iOS横向滚动的scrollView和系统pop手势返回冲突的解决办法,如果您使用了自定义的UINavigationController或者自定义了UINavigationBar 的返回按钮,那么此类必须使用 */
@interface PopEnabeldCollectionView : UICollectionView<UIGestureRecognizerDelegate>
@end

@interface ItemCell : UICollectionViewCell
@property(nonatomic, strong) UILabel *titleLabel;
@end
