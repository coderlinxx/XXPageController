
//  XXPageMenuController.m
//  XXPageMenuController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "XXPageMenuController.h"
#import "XXPageMenuHeader.h"

@interface XXPageMenuController ()<UICollectionViewDataSource,UICollectionViewDelegate>

/** 分页条滑动的下滑线 */
@property(nonatomic, strong)UIView *line;
/** 下滑线宽度 */
@property(nonatomic, assign)CGFloat lineWidth;
/** 是否将分页工具条创建在NavigationBar上 */
@property(nonatomic,assign) BOOL onNavigationBar;
/** 分页工具条 */
@property(nonatomic, weak)UICollectionView *collectionPage;
/** 主collection视图 */
@property(nonatomic, weak)PopEnabeldCollectionView *collectionMain;
/** 分页工具条的总宽度 */
@property (nonatomic,assign) CGFloat pageMenuW;
/** 分页工具条上每个 cell 的宽度 */
@property (nonatomic,assign) CGFloat pageCellW;

@property(nonatomic ,strong)NSArray *itemsArray;
@property(nonatomic, strong)NSArray *controllersClass;
@property(nonatomic, strong)NSArray *controllers;

/** 当前选中的 index 位置 */
@property (nonatomic,assign) NSInteger selectedIndex;
@end

#define kPageSlideCount 4  //分页工具条可滑动的条目数量临界值

static NSString *pageBarCell = @"inxx_pageBarCell";
static NSString *mainCell = @"inxx_mainCell";

@implementation XXPageMenuController

- (NSArray *)controllers{
    if (!_controllers) {
        NSMutableArray *controllers = [NSMutableArray array];
        [_controllersClass enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Class className = _controllersClass[idx];
            UIViewController *vc = [className new];
            vc.title = _itemsArray[idx];      //可以给各个分页赋标题,但是 UI 上没有 vc.title 的表现
            [self addChildViewController:vc];
            [controllers addObject:vc];
        }];
        _controllers = [NSArray arrayWithArray:controllers];
    }else{
        [_controllers enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
            vc.title = _itemsArray[idx];      //可以给各个分页赋标题,但是 UI 上没有 vc.title 的表现
            [self addChildViewController:vc];
        }];
    }
    return _controllers;
}

- (instancetype)initWithTitles:(NSArray *)titlesArray controllersClass:(NSArray *)controllersClass onNavigationBar:(BOOL)onNavigationBar{
    if (self == [super init]) {
        self.onNavigationBar = onNavigationBar;
        self.itemsArray = titlesArray;
        self.controllersClass = controllersClass;
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray *)titlesArray controllers:(NSArray *)controllers onNavigationBar:(BOOL)onNavigationBar{
    if (self == [super init]) {
        self.onNavigationBar = onNavigationBar;
        self.itemsArray = titlesArray;
        self.controllers = controllers;
    }
    return self;
}

- (void)setSuperViewController:(UIViewController *)superVc{
    [superVc addChildViewController:self];
    [superVc.view addSubview:self.view];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //将XXPageMenuController对象的view被添加到另一个控制器的view上时就会发生if内的情况
    if (self.nextResponder && self.view.superview && self.view.superview == self.nextResponder) {
        if ([self.view.superview.nextResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *controller = (UIViewController *)self.view.superview.nextResponder;
            //解决一个view上面放两个不同的collectionview的显示冲突
            controller.automaticallyAdjustsScrollViewInsets = NO;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    /** 在_onNavigationBar上面时,子视图出现的顺序是不一样的!
        需要在UINavigationController的视图显示以后,子视图才会显示!
        猜测,并做了一些验证:
        iOS 11之后可能修复了这个...
     */
    if (_onNavigationBar && [UIDevice currentDevice].systemVersion.doubleValue<=11.0 && self.selectedIndex >= kPageSlideCount) {
         [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self configProperties];
    [self addCollectionPage];
    [self addCollectionMain];
    [self addPageBottomLine];
    
    [self addObserver:self forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ( object == self && [keyPath isEqualToString:@"selectedIndex"]) {
        NSInteger oldIndex = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        NSInteger newIndex = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (newIndex != oldIndex) {
            NSLog(@"已经响应到KVO, 并且selectedIndex已经改变! oldIndex = %zd, newIndex = %zd",oldIndex,newIndex);
            [self.collectionPage reloadData];
        }
    }
}

- (void)moveToDefaultIndex:(NSInteger)index{
    
    self.selectedIndex = index; //0. selectedIndex会引起 KVO 监听调用reloadData
    
    [self updateLineFrameWithIndex:index]; //1. 更新下划线的frame
    
    if (index >= 1) {   //2. 更新collection page的显示index 位置
        [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    //3. 更新collection main的显示index 位置
    [self.collectionMain scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}


- (void)configProperties{
    
    //init default value
    _pageBarHeight = _onNavigationBar ? 44 : (_pageBarHeight ?: 44);
    _pageBarBgColor = _pageBarBgColor ? : [UIColor whiteColor];
    _lineColor = _lineColor ? : [UIColor blueColor];
    _lineHeight = _lineHeight ? : 3;
    _titleFont = _titleFont ? : [UIFont systemFontOfSize:15];
    _titleColor = _titleColor ? : [UIColor colorWithWhite:0.2 alpha:1];
    _titleSelectedColor = _titleSelectedColor ?: [UIColor blackColor];
    _pageMenuW =  _onNavigationBar ? (ScreenW - 120) : ScreenW; //120为预估的左右navigationItem的总宽度
    _pageCellW = (_itemsArray.count <= kPageSlideCount) ? _pageMenuW / _itemsArray.count : _pageMenuW / kPageSlideCount;
        
    self.selectedIndex = _selectedIndex ? : 0;
}

-(void)addCollectionPage{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat width = (_itemsArray.count <= kPageSlideCount) ? _pageMenuW / _itemsArray.count : _pageMenuW / kPageSlideCount ;
    layout.itemSize = CGSizeMake(width, _pageBarHeight);
    CGFloat pageMenuY = _onNavigationBar ? 0 : kNavAndStatus_Height;
    CGRect frame = CGRectMake(0, pageMenuY, _pageMenuW, _pageBarHeight);
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collection.dataSource = self;
    collection.delegate = self;
    collection.pagingEnabled = YES;
    collection.scrollEnabled = YES;
    collection.bounces = NO;   //禁止左右弹簧拉伸
    collection.showsHorizontalScrollIndicator = NO;
    [collection registerClass:[ItemCell class] forCellWithReuseIdentifier:pageBarCell];
    self.collectionPage = collection;
    
    if (_onNavigationBar) {
        collection.backgroundColor = [UIColor clearColor];  //位于导航条时背景色处理为透明色,不公开属性
        if (self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
            self.parentViewController.navigationItem.titleView = self.collectionPage;
        }else{
            self.navigationItem.titleView = self.collectionPage;
        }
    }else{
        collection.backgroundColor = _pageBarBgColor;
        [self.view addSubview:self.collectionPage];
    }
    
}

- (void)addPageBottomLine{
    
    _line = [UIView new];
    _line.backgroundColor = _lineColor;
    _line.clipsToBounds = YES;
    _line.layer.cornerRadius = _lineHeight/2;
    [self.collectionPage addSubview:_line];
    [self.collectionPage bringSubviewToFront:_line];
    
    [self updateLineFrameWithIndex:self.selectedIndex];
}

-(void)addCollectionMain{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGRect frame;
    if (_onNavigationBar) { //分页条 onNavigationBar && isIPhoneX && parentViewController &&  如下
        if (isIPhoneX && self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
            layout.itemSize = CGSizeMake(ScreenW, ScreenH - kNavAndStatus_Height - kBottom_Safe_Height);
        }else{
            layout.itemSize = CGSizeMake(ScreenW, ScreenH - kNavAndStatus_Height);
        }
        frame = CGRectMake(0, kNavAndStatus_Height, layout.itemSize.width, layout.itemSize.height);
    }else{
        layout.itemSize = CGSizeMake(ScreenW, ScreenH - kNavAndStatus_Height- _pageBarHeight);//kBottom_Safe_Height
        frame = CGRectMake(0, CGRectGetMaxY(_collectionPage.frame),  layout.itemSize.width, layout.itemSize.height);
    }
    
    PopEnabeldCollectionView *collection = [[PopEnabeldCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collection.backgroundColor = [UIColor greenColor];
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
}


#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.collectionPage) {
        ItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:pageBarCell forIndexPath:indexPath];
        [cell.titleLabel setText:self.itemsArray[indexPath.row]];
        
        if (indexPath.row == self.selectedIndex) {
            [cell.titleLabel setFont:[UIFont boldSystemFontOfSize:(_titleFont.pointSize + 1)]];
            [cell.titleLabel setTextColor:_titleSelectedColor];
        }else{
            [cell.titleLabel setFont:_titleFont];
            [cell.titleLabel setTextColor:_titleColor];
        }
        
        return cell;
    }else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mainCell forIndexPath:indexPath];
        [cell.contentView addSubview:((UIViewController *)self.controllers[indexPath.row]).view];
        return cell;
    }
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.collectionPage) {  //self.collectionMain的点击不用判断,会被具体视图所遮挡
        
        if (self.lineScrollType != LineScrollTypeDynamicAnimation) { //LineScrollTypeDynamicAnimation时在scrollViewDidScroll:内已经滑动
            [UIView animateWithDuration:0.25 animations:^{
                [self updateLineFrameWithIndex:indexPath.row];
            }];
        }
        
        if (indexPath.row >= 1) {
            [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        }
        
        [self.collectionMain scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    
}

static float oldOffsetX;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.lineScrollType == LineScrollTypeDynamicAnimation) {
        
        if (scrollView == self.collectionMain) {
            
            CGFloat x = scrollView.contentOffset.x ;
            int index = (x + ScreenW*0.5) / ScreenW;         //滑动切换index基准选择: ScreenW*0.5(半屏) 过半屏 index 值会+1
            
            if (index >= 1) {
                [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            }
            _lineWidth = [self lineWidthWithsSelectedIndex:index]; //根据 index 值判断的静态宽度
            
            if (scrollView == self.collectionMain) {
                BOOL toLeft;
                if (x > oldOffsetX) {
                    //NSLog(@"向左拉(手指左滑), newOffsetX = %.1f",x);
                    toLeft = YES;
                } else {
                    //NSLog(@"向右拉(手指右滑), newOffsetX = %.1f",x);
                    toLeft = NO;
                }
                oldOffsetX = x;
                
                /**line改变的长度changedW的逻辑推算:
                 
                 changedW  -----------------------_pageCellW
                 
                 (x-ScreenW*index)绝对值------------ ScreenW/2 (除以2的原因是index过半屏就会+1)
                 
                 ==>changedW/(x-ScreenW*index)绝对值 == _pageCellW / (ScreenW/2)
                 
                 ==> changedW = _pageCellW*2*fabs(x-ScreenW*index) / ScreenW;
                 */
                
                //line 改变的长度
                CGFloat changedW = _pageCellW*2*fabs(x-ScreenW*index) / ScreenW;
                //NSLog(@"滑动距离 = %.1f,  index = %d, changedW = %.1f",(x-ScreenW*index),index,changedW);
                
                _line.frame = CGRectMake(0, _pageBarHeight-_lineHeight,  _lineWidth+changedW, _lineHeight);
                
                CGFloat centerX;
                if (toLeft) {
                    if ((x-ScreenW*index) > 0) { //未过半屏: 过半屏之后因为index = (x + ScreenW*0.5) / ScreenW;  所以 index 值会+1
                        centerX = index * _pageCellW + _pageCellW/2 + changedW/2;
                    }else{ //划过半屏
                        centerX = index * _pageCellW + _pageCellW/2 - changedW/2;
                    }
                }else{
                    if ((x-ScreenW*index) < 0) { //未过半屏
                        centerX = index * _pageCellW + _pageCellW/2 - changedW/2;
                    }else{  //划过半屏
                        centerX = index * _pageCellW + _pageCellW/2 + changedW/2;
                    }
                }
                _line.center = CGPointMake(centerX, _pageBarHeight-_lineHeight/2);
            }

        }
        
    }
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == self.collectionMain) {
        
        if (self.lineScrollType == LineScrollTypeFinishedLinear || self.lineScrollType == LineScrollTypeFinishedAnimation) {
            CGFloat x = scrollView.contentOffset.x ;
            int index = (x + ScreenW*0.5) / ScreenW;         //滑动切换基准选择: ScreenW*0.5(半屏)
            
            if (index >= 1) {
                [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            }
            
            //完成后的下划线动态动画
            if (self.lineScrollType == LineScrollTypeFinishedAnimation) {
                
                /**优雅判断scrollView的滑动方向,这只针对一次手势（手指不离开屏幕:scrollView.panGestureRecognizer）中的一个方向有效!与UIPanGestureRecognizer有关的判断方式适用于 scrollViewDidEndDecelerating: 但是绝对不适用于 scrollViewDidScroll:
                 */
                CGPoint point =  [scrollView.panGestureRecognizer translationInView:self.view];
                
                //                if (point.x > 0 ) {
                //                    NSLog(@"------往→滚动");
                //                }else{
                //                    NSLog(@"------往←滚动");
                //                }
                
                [UIView animateWithDuration:0.25 animations:^{
                    [self updateHalfLineFrameWithIndex:index direction:(point.x > 0)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.25 animations:^{
                        [self updateLineFrameWithIndex:index];
                    }];
                }];
            }
            
            //或者线性平滑移动 2选1
            if (self.lineScrollType == LineScrollTypeFinishedLinear) {
                [UIView animateWithDuration:0.25 animations:^{
                    [self updateLineFrameWithIndex:index];
                }];
            }
            
        }
    }
    
}


/** 更新/设置 下划线的 frame */
- (void)updateLineFrameWithIndex:(NSInteger)index{
    _lineWidth = [self lineWidthWithsSelectedIndex:index];
    _line.frame = CGRectMake(0, _pageBarHeight - _lineHeight, _lineWidth, _lineHeight);
    _line.center = CGPointMake((index * _pageCellW) + _pageCellW/2, _pageBarHeight - _lineHeight/2);
}

/** 加动画位移时的前一半动作 */
- (void)updateHalfLineFrameWithIndex:(NSInteger)index direction:(BOOL)isLeft{
    _lineWidth = [self lineWidthWithsSelectedIndex:index];
    _line.frame = CGRectMake(0, _pageBarHeight - _lineHeight, _lineWidth + _pageCellW, _lineHeight);
    _line.center = CGPointMake( isLeft ? ((index+1)*_pageCellW) : (index*_pageCellW), _pageBarHeight - _lineHeight/2);
}

- (CGFloat)lineWidthWithsSelectedIndex:(NSInteger)index{
    
    //0.动态修改选中的 index
    //    _selectedIndex = index; //这样写, KVO 是不会响应的...
    self.selectedIndex = index;
    NSLog(@"self.selectedIndex = %zd",index);
    
    switch (self.lineWidthType) {
        case LineWidthTypeStaticLong:
            _lineWidth = (_itemsArray.count <= kPageSlideCount) ? _pageMenuW / _itemsArray.count : _pageMenuW / kPageSlideCount;
            break;
        case LineWidthTypeDynamic:
            _lineWidth = ((NSString *)_itemsArray[index]).length * (_titleFont.pointSize);
            break;
        default: //包含(LineWidthTypeStaticShort)
            _lineWidth = 30;
            break;
    }
    return _lineWidth;
    
    
   

}

-(void)dealloc{
    NSLog(@"dealloc : %@ ",self.class);
    [self removeObserver:self forKeyPath:@"selectedIndex"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end


@implementation PopEnabeldCollectionView
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) {
            return YES;
        }
    }
    return NO;
}
@end


@implementation ItemCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}
@end
