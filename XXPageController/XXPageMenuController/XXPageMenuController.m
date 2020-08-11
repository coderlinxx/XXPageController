
//  XXPageMenuController.m
//  XXPageMenuController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥兴. All rights reserved.
//

#import "XXPageMenuController.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kNavAndStatus_Height ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)

@interface PopEnabeldCollectionView : UICollectionView
@end
@implementation PopEnabeldCollectionView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //解决横向滚动的scrollView和系统pop手势返回冲突
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")] && otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) return YES;
    return NO;
}
@end

@class XXPageItemCell;
@protocol XXPageItemCellDelegate <NSObject>
- (void)pageItemCell:(XXPageItemCell *)pageItemCell didSelectItemAtIndex:(NSInteger)index;
@end
@interface XXPageItemCell : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, assign) NSInteger titleIndex;
@property (nonatomic, weak) id<XXPageItemCellDelegate> delegate;
@end
@implementation XXPageItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
//        _titleLabel.backgroundColor = [UIColor greenColor];
        _titleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick)];
        [_titleLabel addGestureRecognizer:tap];
        [self addSubview:_titleLabel];
        
        
        
        
        
        _titleBtn = [[UIButton alloc] initWithFrame:self.bounds];
        _titleBtn.contentMode = UIViewContentModeCenter;
        _titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        _titleBtn.imageEdgeInsets = UIEdgeInsetsMake(1, -3, 0, 0);
        CGSize size = CGSizeMake(15, 15);
        _titleBtn.imageView.frame = (CGRect){{0,0},size};
        _titleBtn.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleBtn.userInteractionEnabled = YES;
        [_titleBtn addTarget:self action:@selector(titleClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleBtn];
    }
    return self;
}

- (void)titleClick {
    if ([self.delegate respondsToSelector:@selector(pageItemCell:didSelectItemAtIndex:)]) {
        [self.delegate pageItemCell:self didSelectItemAtIndex:self.titleIndex];
    }
}

@end

@interface XXPageMenuController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,XXPageItemCellDelegate>
/** 分页条滑动的下滑线 */
@property (readonly, nonatomic, strong) UIView *line;
/** 下滑线宽度 */
@property (nonatomic, assign) CGFloat lineWidth;
/** 是否将分页工具条创建在NavigationBar上 */
@property (nonatomic, assign) BOOL onNavigationBar;
/** 分页工具条 */
@property (nonatomic, strong) UIScrollView *scrollViewPage;
/** 主collection视图 */
@property (nonatomic, weak) PopEnabeldCollectionView *collectionMain;
/** 分页工具条的总宽度 */
@property (nonatomic, assign) CGFloat pageMenuW;
/** 分页工具条上每个 cell 的宽度 */
@property (nonatomic, assign) CGFloat pageCellW;
/** 分页工具条上每个 cell 的宽度集合 */
@property (nonatomic, strong) NSMutableArray *pageCellWs;
/** 分页工具条 cell 集合 */
@property (nonatomic, strong) NSMutableArray *pageCells;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *controllersClass;
@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, strong) NSArray *icons;
/** 当前选中的 index 位置 */
@property (nonatomic, assign) NSInteger selectedIndex;
/** 点击didSelectItemAtIndexPath:方法的标记 */
@property (nonatomic,assign) BOOL didSelectCollectionPageItem;
@end

#define kAnimateDuration 0.3
static NSString *mainCell = @"inxx_mainCell";

@implementation XXPageMenuController

- (NSArray *)controllers {
    if (!_controllers) {
        NSMutableArray *controllers = [NSMutableArray array];
        [_controllersClass enumerateObjectsUsingBlock:^(Class  _Nonnull controllerClass, NSUInteger idx, BOOL * _Nonnull stop) {
            UIViewController *vc = [controllerClass new];
            vc.title = self->_titles[idx];
            [self addChildViewController:vc];
            [controllers addObject:vc];
        }];
        _controllers = [NSArray arrayWithArray:controllers];
    } else {
        [_controllers enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
            vc.title = self->_titles[idx];
            [self addChildViewController:vc];
        }];
    }
    return _controllers;
}

- (instancetype)initWithTitles:(NSArray *)titles controllersClass:(NSArray *)controllersClass onNavigationBar:(BOOL)onNavigationBar {
    self = [super init];
    if (self) {
        self.onNavigationBar = onNavigationBar;
        self.titles = titles;
        self.controllersClass = controllersClass;
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray *)titles controllers:(NSArray *)controllers onNavigationBar:(BOOL)onNavigationBar {
    self = [super init];
    if (self) {
        self.onNavigationBar = onNavigationBar;
        self.titles = titles;
        self.controllers = controllers;
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray *)titles iconNames:(NSArray *)iconNames controllers:(NSArray *)controllers onNavigationBar:(BOOL)onNavigationBar {
    self.icons = iconNames;
    return [self initWithTitles:titles controllers:controllers onNavigationBar:onNavigationBar];
}

- (void)setSuperViewController:(UIViewController *)superVc {
    [superVc addChildViewController:self];
    [superVc.view addSubview:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //1. 更新下划线的frame
    [self updateLineFrameWithIndex:self.selectedIndex];
    //2. 更新collection page的显示index 位置
    [self updateCurrentScrollViewPageContentOffsetByIndex:self.selectedIndex];
    //3. 更新collection main的显示index 位置
    [self.collectionMain scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //FIXME: iOS 11前后在_onNavigationBar上面时,子视图出现的顺序是不一样的! iOS11前需要在UINavigationController的视图显示以后,子视图才会显示!  iOS 11之后可能修复了这个bug
    if (_onNavigationBar && [UIDevice currentDevice].systemVersion.doubleValue<=11.0 && self.selectedIndex >= _maxPagesCountInPageShowArea) {
        [self updateCurrentScrollViewPageContentOffsetByIndex:self.selectedIndex];
    }
}

- (void)loadView {
    [super loadView];
    [self configProperties];
    [self addScrollViewPage];
    [self addCollectionMain];
    [self addPageBottomLine];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addObserver:self forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectedIndex"]) {
        NSInteger oldIndex = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        NSInteger newIndex = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        XXPageItemCell *oldCell = _pageCells[oldIndex];
        XXPageItemCell *newCell = _pageCells[newIndex];
        
        if (newIndex != oldIndex) {
            [self reloadCollectionPageCell:oldCell index:oldIndex selected:NO];
            [self reloadCollectionPageCell:newCell index:newIndex selected:YES];
        }
    }
}

/// 刷新 CollectionPage的Cell 数据
/// @param selected 待刷新cell是否被选中
- (void)reloadCollectionPageCell:(XXPageItemCell *)cell index:(NSInteger)index selected:(BOOL)selected {
    
    UILabel *titleLabel = nil;
    if (self.icons) {
        cell.titleLabel.hidden = YES; cell.titleBtn.hidden = NO;
        titleLabel = cell.titleBtn.titleLabel;
        [cell.titleBtn setImage:[UIImage imageNamed:self.icons[index]] forState:UIControlStateNormal];
        [cell.titleBtn.titleLabel setFont:(selected ? _titleSelectedFont : _titleFont)];
    } else {
        cell.titleLabel.hidden = NO; cell.titleBtn.hidden = YES;
        titleLabel = cell.titleLabel;
        //title font 的改变方式: 滑动结束动画改变 || 点击didSelectItemAtIndexPath:方法
        if (_pageTitleFontChangeType == PageTitleFontChangeTypeScrollEndAnimation || _didSelectCollectionPageItem) {
            CGFloat scale = selected ? _titleSelectedFont.pointSize/_titleFont.pointSize : _titleFont.pointSize/_titleSelectedFont.pointSize;
            [UIView animateWithDuration:kAnimateDuration animations:^{
                titleLabel.transform = CGAffineTransformMakeScale(scale, scale);
            } completion:^(BOOL finished) {
                //缩放结束后重置transform, 并设置当前对应的字体大小. 这样就能避免transform从小到大时字体模糊
                titleLabel.transform = CGAffineTransformIdentity;
                [titleLabel setFont:(selected ? self->_titleSelectedFont : self->_titleFont)];
            }];
        } else {
            [titleLabel setFont:(selected ? _titleSelectedFont : _titleFont)];
        }
    }
    
    [titleLabel setText:self.titles[index]];
    [titleLabel setTextColor:(selected ? _titleSelectedColor : _titleColor)];
}

- (void)configProperties {
    
    //edgesForExtendedLayout 边缘延伸属性，默认为UIRectEdgeAll.
    //UIRectEdgeAll 当前视图控制器里各种UI控件会忽略导航栏和标签的存在，布局时若设置其原点设置为(0,0)，视图会延伸显示到导航栏的下面被覆盖；
    //UIRectEdgeNone: 意味着子控件本身会自动躲避导航栏和标签栏，以免被遮挡。
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (self.parentViewController ) {
        self.parentViewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if (_originY) {
           CGRect frame = self.view.frame;
           frame.origin.y += _originY;
           frame.size.height -= _originY;
           self.view.frame = frame;
    }

    //init default value
    _pageBarHeight = _onNavigationBar ? 44 : (_pageBarHeight ?: 44);
    _pageBarBgColor = _pageBarBgColor ? : [UIColor whiteColor];
    _lineColor = _lineColor ? : [UIColor blueColor];
    _lineColors = _lineColors ?: _lineColors;
    _lineHeight = _lineHeight ? : 3;
    _lineStaticWidth = _lineStaticWidth ?: 8;
    _maxPagesCountInPageShowArea = _maxPagesCountInPageShowArea ?: (_onNavigationBar ? 4 : 5);
    _titleFont = _titleFont ? : [UIFont systemFontOfSize:15];
    _titleSelectedFont = _titleSelectedFont ?: [UIFont systemFontOfSize:20];
    _titleColor = _titleColor ? : [UIColor colorWithWhite:0.1 alpha:1];
    _titleSelectedColor = _titleSelectedColor ?: [UIColor blackColor];
    _pageMenuW =  _onNavigationBar ? (kScreenWidth - 120) : kScreenWidth; //120为预估的左右navigationItem的总宽度
    if (_pageCellWidthType == PageCellWidthTypeSplitScreen) {
        //根据titles.count平分宽度
        _pageCellW = (_titles.count <= _maxPagesCountInPageShowArea) ? _pageMenuW / _titles.count : _pageMenuW / _maxPagesCountInPageShowArea;
    } else if (_pageCellWidthType == PageCellWidthTypeWidthByStaticCount) {
        //根据_maxPagesCountInPageShowArea平分宽度
        _pageCellW = _pageMenuW / _maxPagesCountInPageShowArea;
    } else if (_pageCellWidthType == PageCellWidthTypeByTitleLength) {
        //根据title长度取cell动态宽度, 初始化宽度值数组
        _pageCellWs = [NSMutableArray array];
        NSInteger showCount = 0;
        CGFloat sumWidth = 0;
        for (NSString *title in _titles) {
            CGFloat width1 = title.length * _titleFont.pointSize + 25;
            CGFloat width2 = title.length * _titleSelectedFont.pointSize; //防止有少数过长标题时滑动异常
            CGFloat width = MAX(width1, width2);
            if (self.icons) {
                width += 24;
            }
            sumWidth += width;
            if (sumWidth < _pageMenuW) {
                showCount++;
            }
            [_pageCellWs addObject:@(width)]; //保存每个动态宽度
        }
        _maxPagesCountInPageShowArea = showCount;
    }
        
    self.selectedIndex = _defaultIndex;
}

- (void)addScrollViewPage {
    
    CGRect frame = CGRectMake(0, 0, _pageMenuW, _pageBarHeight);
    UIScrollView *scrollViewPage = [[UIScrollView alloc] initWithFrame:frame];
    scrollViewPage.showsVerticalScrollIndicator = NO;
    scrollViewPage.showsHorizontalScrollIndicator = NO;
    scrollViewPage.delegate = self;
    
    if (_onNavigationBar) {
        scrollViewPage.backgroundColor = [UIColor clearColor];  //位于导航条时背景色处理为透明色,不公开属性
        if (self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
            self.parentViewController.navigationItem.titleView = scrollViewPage;
        } else {
            self.navigationItem.titleView = scrollViewPage;
        }
    } else {
        scrollViewPage.backgroundColor = _pageBarBgColor;
        [self.view addSubview:scrollViewPage];
    }
    
    CGFloat contentWidth = 0;
    if (_pageCellWidthType != PageCellWidthTypeByTitleLength) {
        contentWidth = _pageCellW * _titles.count;
    } else {
        contentWidth = [[_pageCellWs valueForKeyPath:@"@sum.floatValue"] floatValue];
    }
    scrollViewPage.contentSize = CGSizeMake(contentWidth, _pageBarHeight);
    
    _pageCells = [NSMutableArray array];

    __block CGFloat currentX = 0;
    [_pageCellWs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat pageCellW = [obj floatValue];
        CGRect frame = CGRectMake(currentX, 0, pageCellW, _pageBarHeight);
        currentX += pageCellW;
        XXPageItemCell *pageItemCell = [[XXPageItemCell alloc] initWithFrame:frame];
        pageItemCell.titleIndex = idx;
        pageItemCell.delegate = self;
        BOOL selected = (idx == self.selectedIndex);  //是否被选中
        if (self.icons) {
            pageItemCell.titleLabel.hidden = YES;
            pageItemCell.titleBtn.hidden = NO;
            [pageItemCell.titleBtn setTitle:self.titles[idx] forState:UIControlStateNormal];
            [pageItemCell.titleBtn setImage:[UIImage imageNamed:self.icons[idx]] forState:UIControlStateNormal];
            [pageItemCell.titleBtn setTitleColor:(selected ? _titleSelectedColor : _titleColor) forState:UIControlStateNormal];
            [pageItemCell.titleBtn.titleLabel setFont:(selected ? _titleSelectedFont : _titleFont)];
        } else {
            pageItemCell.titleLabel.hidden = NO;
            pageItemCell.titleBtn.hidden = YES;
            [pageItemCell.titleLabel setText:self.titles[idx]];
            [pageItemCell.titleLabel setTextColor:(selected ? _titleSelectedColor : _titleColor)];
            [pageItemCell.titleLabel setFont:(selected ? _titleSelectedFont : _titleFont)];
        }
        
        [scrollViewPage addSubview:pageItemCell];
        [_pageCells addObject:pageItemCell];
    }];

    self.scrollViewPage = scrollViewPage;
}

- (void)addPageBottomLine {
    _line = [UIView new];
    _line.backgroundColor = _lineColor;
    _line.clipsToBounds = YES;
    _line.layer.cornerRadius = _lineHeight/2;
    [self.scrollViewPage addSubview:_line];
    [self.scrollViewPage bringSubviewToFront:_line];
}

CGRect childFrame;
- (void)addCollectionMain {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat y = _onNavigationBar ? 0 : _pageBarHeight;
    layout.itemSize = CGSizeMake(self.view.bounds.size.width, kScreenHeight - kNavAndStatus_Height - y - _originY);
    CGRect frame = CGRectMake(0, y, layout.itemSize.width, layout.itemSize.height);
    PopEnabeldCollectionView *collection = [[PopEnabeldCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collection.backgroundColor = [UIColor whiteColor];
    collection.dataSource = self;
    collection.delegate = self;
    collection.pagingEnabled = YES;
    collection.scrollEnabled = YES;
    collection.bounces = NO;   //禁止左右弹簧拉伸
    collection.showsHorizontalScrollIndicator = NO;
    [collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:mainCell];
    self.collectionMain = collection;
    [self.view addSubview:collection];
    [self.view bringSubviewToFront:self.collectionMain];
    
    childFrame = frame;
    for (UIViewController *childVc in self.controllers) {
        //子控制器的frame.origin.y肯定要从其自己的0开始
        childFrame.origin.y = 0;
        childVc.view.frame = childFrame;
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.didLayoutSubviewsBlock) {
        self.didLayoutSubviewsBlock(self.view, self.scrollViewPage, self.collectionMain);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mainCell forIndexPath:indexPath];
    [cell.contentView addSubview:((UIViewController *)self.controllers[indexPath.row]).view];
    return cell;
}

#pragma mark - XXPageItemCellDelegate
- (void)pageItemCell:(XXPageItemCell *)pageItemCell didSelectItemAtIndex:(NSInteger)index {
    
    _didSelectCollectionPageItem = YES;
    
    BOOL needReset = NO;
    LineScrollType lineScrollType = _lineScrollType;
    PageTitleFontChangeType titleFontChangeType = _pageTitleFontChangeType;
    PageTitleColorChangeType titleColorChangeType = _pageTitleColorChangeType;
    if ((_lineScrollType != LineScrollTypeScrollEndLinear)) {
        _lineScrollType = LineScrollTypeScrollEndLinear;
        needReset = YES;
    }
    if (_pageTitleFontChangeType != PageTitleFontChangeTypeScrollEnd) {
        _pageTitleFontChangeType = PageTitleFontChangeTypeScrollEnd;
        needReset = YES;
    }
    if (_pageTitleColorChangeType != PageTitleColorChangeTypeScrollEnd) {
        _pageTitleColorChangeType = PageTitleColorChangeTypeScrollEnd;
        needReset = YES;
    }

    [UIView animateWithDuration:kAnimateDuration animations:^{
        //ABS(self.selectedIndex - indexPath.item)>1 表示跨越至少 2 个 index 移动
        [self updateLineFrameWithIndex:index] ;
    } completion:^(BOOL finished) {
        if (needReset) { //复位
            self->_lineScrollType = lineScrollType;
            self->_pageTitleFontChangeType = titleFontChangeType;
            self->_pageTitleColorChangeType = titleColorChangeType;
        }
        self->_didSelectCollectionPageItem = NO;
    }];
    

    [self updateCurrentScrollViewPageContentOffsetByIndex:index];
    
    [self.collectionMain scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

static float oldOffsetX;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_didSelectCollectionPageItem) return;

    if (scrollView == self.collectionMain) {
                
        // 处理working中的2个分页标题底部线性指示器的实时属性
        [self changePageLinePropertyiesWithSrollX:scrollView.contentOffset.x];
        
        //处理working中的2个分页标题的实时属性
        [self changePageTitlePropertyiesWithSrollX:scrollView.contentOffset.x];
    }

}

/// 处理working中的2个分页标题底部线性指示器的实时属性
/// @param x SrollX
- (void)changePageLinePropertyiesWithSrollX:(CGFloat)x {
    
    //需要随滑动而改变UI样式:LineScrollTypeDynamicAnimation/LineScrollTypeDynamicLinear
    if (_lineScrollType == LineScrollTypeDynamicAnimation || _lineScrollType == LineScrollTypeDynamicLinear) {
        
        int lineIndex = (x + kScreenWidth*0.5) / kScreenWidth;  ///< 线指示器滑动切换index基准选择: kScreenWidth*0.5(半屏) 过半屏 index 值会+1
                
        CGFloat scrollRatio = fabs(x-kScreenWidth*lineIndex) / kScreenWidth;  ///< 滑动比率 [0 ~ 0.5 ~ 0]

        CGFloat changedW;  ///< line动态改变的宽度

        CGFloat centerX; ///< 线的实时滑动中心
        //NSLog(@"scrollRatio - %.1f",scrollRatio);
        BOOL toLeft = (x > oldOffsetX);
        oldOffsetX = x;
        if (toLeft) {
            
            if ((x-kScreenWidth*lineIndex) > 0) { //未过半屏: 过半屏之后因为lineIndex = (x + kScreenWidth*0.5) / kScreenWidth  所以 lineIndex 值会+1
                
                if (_pageCellWidthType == PageCellWidthTypeByTitleLength) {
                    CGFloat chazhi =  [_pageCellWs[lineIndex+1] floatValue] - [_pageCellWs[lineIndex] floatValue];
                    chazhi = 0;
                    changedW = [_pageCellWs[lineIndex] floatValue] * scrollRatio + [_pageCellWs[lineIndex+1] floatValue] * scrollRatio + chazhi * scrollRatio;
                    centerX = [self lineCenterXWithIndex:lineIndex] + changedW/2;
                } else {
                    //保留减少消耗方案:每一个 cell 的宽度都是_pageCellW,是相等的, 不用去_pageCellWs数组里去取每个 _pageCellW 的值
                    changedW = _pageCellW * scrollRatio * 2;
                    //保留减少消耗方案: 每一个 cell 的宽度都是_pageCellW,是相等的, 省去了 for 循环计算宽度
                    centerX = lineIndex * _pageCellW + _pageCellW/2 + changedW/2;
                }
            }else{ //划过半屏, lineIndex 值会+1
                if (_pageCellWidthType == PageCellWidthTypeByTitleLength) {
                    CGFloat chazhi = [_pageCellWs[lineIndex] floatValue] - [_pageCellWs[lineIndex-1] floatValue];
                    chazhi = 0;
                    changedW = [_pageCellWs[lineIndex-1] floatValue] * scrollRatio + [_pageCellWs[lineIndex] floatValue] * scrollRatio - chazhi * scrollRatio;
                    centerX = [self lineCenterXWithIndex:lineIndex] - changedW/2;
                } else {
                    changedW = _pageCellW * scrollRatio * 2;
                    centerX = lineIndex * _pageCellW + _pageCellW/2 - changedW/2;
                }
            }
            
        }else{
            
            if ((x-kScreenWidth*lineIndex) < 0) { //未过半屏
                if (_pageCellWidthType == PageCellWidthTypeByTitleLength) {
                    CGFloat chazhi = [_pageCellWs[lineIndex] floatValue] - [_pageCellWs[lineIndex-1] floatValue];
                    chazhi = 0;
                    changedW = [_pageCellWs[lineIndex-1] floatValue] * scrollRatio + [_pageCellWs[lineIndex] floatValue] * scrollRatio - chazhi * scrollRatio;
                    centerX = [self lineCenterXWithIndex:lineIndex] - changedW/2;
                } else {
                    changedW = _pageCellW * scrollRatio * 2;
                    centerX = lineIndex * _pageCellW + _pageCellW/2 - changedW/2;
                }
            }else{  //划过半屏
                if (_pageCellWidthType == PageCellWidthTypeByTitleLength) {
                    CGFloat chazhi =  [_pageCellWs[lineIndex+1] floatValue] - [_pageCellWs[lineIndex] floatValue];
                    chazhi = 0;
                    changedW = [_pageCellWs[lineIndex] floatValue] * scrollRatio + [_pageCellWs[lineIndex+1] floatValue] * scrollRatio + chazhi * scrollRatio;
                    centerX = [self lineCenterXWithIndex:lineIndex] + changedW/2;
                } else {
                    changedW = _pageCellW * scrollRatio * 2;
                    centerX = lineIndex * _pageCellW + _pageCellW/2 + changedW/2;
                }
            }
            
        }
        
        _lineWidth = [self lineWidthWithsSelectedIndex:lineIndex]; //根据 lineIndex 值判断的静态宽度

        if (_lineScrollType == LineScrollTypeDynamicAnimation) {
            _line.frame = CGRectMake(0, _pageBarHeight-_lineHeight,  _lineWidth+changedW, _lineHeight);
        } else if (_lineScrollType == LineScrollTypeDynamicLinear) {
            _line.frame = CGRectMake(0, _pageBarHeight-_lineHeight,  _lineWidth, _lineHeight);
        }
        _line.center = CGPointMake(centerX, _pageBarHeight-_lineHeight/2);
    }
    
    if (_lineColors) {
           //_line.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:_line.bounds andColors:_lineColors];
       }
}

/// 处理working中的2个分页标题的实时属性
/// @param x SrollX
- (void)changePageTitlePropertyiesWithSrollX:(CGFloat)x {
    
    //创建通用变量
    int pageIndex = ABS(x) / kScreenWidth;
    CGFloat xInScreen = x-kScreenWidth*pageIndex;  //一屏内的位移距离
    
    XXPageItemCell *oldCell = _pageCells[pageIndex];
    XXPageItemCell *newCell = nil;
    if (pageIndex+1 < _pageCells.count) {
         newCell = _pageCells[pageIndex+1];
    }
    
    //滑动过程中字体实时改变的大小
    if (_pageTitleFontChangeType == PageTitleFontChangeTypeScrolling && _titleSelectedFont.pointSize != _titleFont.pointSize) {
        
        CGFloat fontRuntimeDifferenceSize = xInScreen/kScreenWidth*(_titleSelectedFont.pointSize-_titleFont.pointSize);
        
        //此方案会有抖动,效果不太完美
        //oldCell.titleLabel.font = [UIFont fontWithDescriptor:oldCell.titleLabel.font.fontDescriptor size:_titleSelectedFont.pointSize-fontRuntimeDifferenceSize];
        //newCell.titleLabel.font = [UIFont fontWithDescriptor:newCell.titleLabel.font.fontDescriptor size:_titleFont.pointSize+fontRuntimeDifferenceSize];
        
        //transform形变稳定防抖动处理
        //避免transform从小到大时字体模糊: 先把font设置为缩放的最大值，再缩小到最小值，最后根据当前的titleLabelZoomScale值，进行缩放更新
        newCell.titleLabel.font = _titleSelectedFont;
        oldCell.titleLabel.font = _titleSelectedFont;
        CGFloat baseScale = _titleFont.lineHeight/_titleSelectedFont.lineHeight;
        CGFloat upRatio = (_titleFont.pointSize+fontRuntimeDifferenceSize)/_titleFont.pointSize;
        CGFloat downRatio = (_titleSelectedFont.pointSize-fontRuntimeDifferenceSize)/_titleFont.pointSize;
        newCell.titleLabel.transform = CGAffineTransformMakeScale(baseScale*upRatio, baseScale*upRatio);
        oldCell.titleLabel.transform = CGAffineTransformMakeScale(baseScale*downRatio, baseScale*downRatio);
        
        [_pageCells enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([view isKindOfClass:[XXPageItemCell class]]) {
                XXPageItemCell *cell = view;
                if (idx != pageIndex && idx != pageIndex+1) {
                    cell.titleLabel.transform = CGAffineTransformIdentity;
                    cell.titleLabel.font = _titleFont;
                }
            }
        }];
        
    }
    
    if (_pageTitleColorChangeType == PageTitleColorChangeTypeScrolling) {
        NSArray *rgba0 = [self getRGBValueFromColor:_titleColor];
        NSArray *rgba1 = [self getRGBValueFromColor:_titleSelectedColor];
        CGFloat diffR = xInScreen / kScreenWidth * ([rgba1[0] floatValue] - [rgba0[0] floatValue]);
        CGFloat diffG = xInScreen / kScreenWidth * ([rgba1[1] floatValue] - [rgba0[1] floatValue]);
        CGFloat diffB = xInScreen / kScreenWidth * ([rgba1[2] floatValue] - [rgba0[2] floatValue]);
        CGFloat runingRed0 = [rgba0[0] floatValue] + diffR;
        CGFloat runingGreen0 = [rgba0[1] floatValue] + diffG;
        CGFloat runingBlue0 = [rgba0[2] floatValue] + diffB;
        CGFloat runingred1 = [rgba1[0] floatValue] - diffR;
        CGFloat runinGreen1 = [rgba1[1] floatValue] - diffG;
        CGFloat runingBlue1 = [rgba1[2] floatValue] - diffB;
        UIColor *runtimeColor0 = [UIColor colorWithRed:runingRed0 green:runingGreen0 blue:runingBlue0 alpha:1.0];
        UIColor *runtimeColor1 = [UIColor colorWithRed:runingred1 green:runinGreen1 blue:runingBlue1 alpha:1.0];
        oldCell.titleLabel.textColor = runtimeColor1;
        newCell.titleLabel.textColor = runtimeColor0;
    }
}

/** 系统API获取UIColor的RGBA值 */
- (NSArray *)getRGBValueFromColor:(UIColor *)color {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return @[@(red), @(green), @(blue), @(alpha)];
}


/** 需要在滑动结束后处理的各UI type */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (_didSelectCollectionPageItem) return;
    
    if (scrollView == _collectionMain) {
        
        CGFloat x = scrollView.contentOffset.x ;
        int index = (x + kScreenWidth*0.5) / kScreenWidth;         //滑动切换基准选择: kScreenWidth*0.5(半屏)
        
        // ScrollViewPage 处理偏移:setContentOffset
        [self updateCurrentScrollViewPageContentOffsetByIndex:index];
        
        // 下划线线性动画
        if ( _lineScrollType == LineScrollTypeScrollEndLinear) {
            [UIView animateWithDuration:kAnimateDuration animations:^{
                [self updateLineFrameWithIndex:index];
            }];
        }
        
        if (_pageTitleFontChangeType == PageTitleFontChangeTypeScrolling) {
            //FIXME: 防止 cell 在复用时取到未复位的 cell
            int pageIndex = ABS(x) / kScreenWidth;
            [_pageCells enumerateObjectsUsingBlock:^(__kindof XXPageItemCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx != pageIndex) {
                    cell.titleLabel.transform = CGAffineTransformIdentity;
                    cell.titleLabel.font = _titleFont;
                }
            }];
        }
        
    }
    
}


/// 更新当前使用的分页ScrollView偏移量,复现UICollectionView滑动到view边缘处理的大致流程
/// @param index 当前位置
- (void)updateCurrentScrollViewPageContentOffsetByIndex:(NSInteger)index {
    NSArray *currentArray = [_pageCellWs subarrayWithRange:NSMakeRange(0, index)];
    CGFloat currentOffX = [[currentArray valueForKeyPath:@"@sum.floatValue"] floatValue]; //↑
    CGFloat contentWidth = [[_pageCellWs valueForKeyPath:@"@sum.floatValue"] floatValue]; // -
    if (contentWidth <= _pageMenuW) return; //contentSize宽度小于_pageMenuW时,不偏移
    if (currentOffX < _pageMenuW*0.5) {
        [self.scrollViewPage setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (currentOffX >= contentWidth-_pageMenuW*0.6) {
        [self.scrollViewPage setContentOffset:CGPointMake(contentWidth-_pageMenuW, 0) animated:YES];
    } else {
        [self.scrollViewPage setContentOffset:CGPointMake(currentOffX-_pageMenuW*0.4, 0) animated:YES];
    }
}

/** 更新/设置 下划线的 frame */
- (void)updateLineFrameWithIndex:(NSInteger)index {
    _lineWidth = [self lineWidthWithsSelectedIndex:index];
    _line.frame = CGRectMake(0, _pageBarHeight - _lineHeight, _lineWidth, _lineHeight);
    if (_pageCellWidthType == PageCellWidthTypeByTitleLength) {
        CGFloat width = [self lineCenterXWithIndex:index];
        _line.center = CGPointMake(width, _pageBarHeight - _lineHeight/2);
    } else {
        _line.center = CGPointMake((index * _pageCellW) + _pageCellW/2, _pageBarHeight - _lineHeight/2);
    }
    if (_lineColors) {
        //_line.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:_line.bounds andColors:_lineColors];
    }
}


- (CGFloat)lineCenterXWithIndex:(NSInteger)index {
    __block CGFloat centerX = 0;
    [_titles enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < index) {
            centerX = centerX + [_pageCellWs[idx] floatValue];
        } else {
            centerX = centerX + [_pageCellWs[idx] floatValue]/2;
            *stop = YES;
        }
    }];
    return centerX;
}

- (CGFloat)lineWidthWithsSelectedIndex:(NSInteger)index {
    
    self.selectedIndex = index;     //动态修改选中的 index -> KVO
    
    CGFloat adaptIconW = self.icons ? (15 + 6) : 0;  //15icon + 6margin
    switch (_lineWidthType) {
        case LineWidthTypeStaticLong:
            _lineWidth = (_titles.count <= _maxPagesCountInPageShowArea) ? _pageMenuW / _titles.count : _pageMenuW / _maxPagesCountInPageShowArea;
            break;
        case LineWidthTypeDynamic:
            //_lineWidth = [_pageCellWs[index] floatValue] + adaptIconW;
            _lineWidth = [(NSString *)_titles[index] length] * _titleSelectedFont.pointSize+ adaptIconW; //更标准, _pageCellWs内宽度的取值是 2 者取最大,不准确
            break;
        case LineWidthTypeStaticShort:
        default:
            _lineWidth = _lineStaticWidth + adaptIconW;
            break;
    }
    return _lineWidth;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"selectedIndex"];
}

@end
