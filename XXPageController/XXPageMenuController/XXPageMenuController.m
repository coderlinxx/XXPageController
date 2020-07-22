
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
#define isIPhoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size)) //是否是iphoneX
//底部安全高度
#define kBottom_Safe_Height (isIPhoneX ? 34 : 0)

@interface PopEnabeldCollectionView : UICollectionView
@end
@implementation PopEnabeldCollectionView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //解决横向滚动的scrollView和系统pop手势返回冲突
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")] && otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) return YES;
    return NO;
}
@end

@interface ItemCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *titleBtn;
@end

@implementation ItemCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByClipping;
        [self.contentView addSubview:_titleLabel];
        
        _titleBtn = [[UIButton alloc] initWithFrame:self.bounds];
        _titleBtn.contentMode = UIViewContentModeCenter;
        _titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        _titleBtn.imageEdgeInsets = UIEdgeInsetsMake(1, -3, 0, 0);
        CGSize size = CGSizeMake(15, 15);
        _titleBtn.imageView.frame = (CGRect){{0,0},size};
        _titleBtn.titleLabel.lineBreakMode = NSLineBreakByClipping;
        _titleBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_titleBtn];
    }
    return self;
}
@end

@interface XXPageMenuController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

/** 分页条滑动的下滑线 */
@property(readonly,nonatomic, strong)UIView *line;
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

@property(nonatomic ,strong)NSArray *titles;
@property(nonatomic, strong)NSArray *controllersClass;
@property(nonatomic, strong)NSArray *controllers;
@property(nonatomic ,strong)NSArray *icons;

/** 当前选中的 index 位置 */
@property (nonatomic,assign) NSInteger selectedIndex;

@end

#define kAnimateDuration 0.3
static NSString *pageBarCell = @"inxx_pageBarCell";
static NSString *mainCell = @"inxx_mainCell";

@implementation XXPageMenuController

- (NSArray *)controllers {
    if (!_controllers) {
        NSMutableArray *controllers = [NSMutableArray array];
        [_controllersClass enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Class className = self->_controllersClass[idx];
            UIViewController *vc = [className new];
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
    if (self == [super init]) {
        self.onNavigationBar = onNavigationBar;
        self.titles = titles;
        self.controllersClass = controllersClass;
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray *)titles controllers:(NSArray *)controllers onNavigationBar:(BOOL)onNavigationBar {
    if (self == [super init]) {
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
    //将XXPageMenuController对象的view被添加到另一个控制器的view上时就会发生if内的情况
    if (self.nextResponder && self.view.superview && self.view.superview == self.nextResponder) {
        if ([self.view.superview.nextResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *controller = (UIViewController *)self.view.superview.nextResponder;
            //解决一个view上面放两个不同的collectionview的显示冲突
            controller.automaticallyAdjustsScrollViewInsets = NO;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (self.selectedIndex > 0) {
        //1. 更新下划线的frame
        [self updateLineFrameWithIndex:self.selectedIndex];
        //2. 更新collection page的显示index 位置
        [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        //3. 更新collection main的显示index 位置
        [self.collectionMain scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /** △猜测并验证:  iOS 11前后在_onNavigationBar上面时,子视图出现的顺序是不一样的!
     iOS 11前需要在UINavigationController的视图显示以后,子视图才会显示!  iOS 11之后可能修复了这个bug
     */
    if (_onNavigationBar && [UIDevice currentDevice].systemVersion.doubleValue<=11.0 && self.selectedIndex >= _maxPagesCountInShowArea) {
        [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self configProperties];
    [self addCollectionPage];
    [self addCollectionMain];
    [self addPageBottomLine];
    
    [self addObserver:self forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( object == self && [keyPath isEqualToString:@"selectedIndex"]) {
        NSInteger oldIndex = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        NSInteger newIndex = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (newIndex != oldIndex) {
            //[self.collectionPage reloadData]; //reloadData时collectionPage会闪烁,效果并不好
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            ItemCell *oldCell = (ItemCell *)[self.collectionPage cellForItemAtIndexPath:oldIndexPath];
            ItemCell *newCell = (ItemCell *)[self.collectionPage cellForItemAtIndexPath:newIndexPath];
            [self reloadCollectionPageCell:oldCell indexPath:oldIndexPath selected:NO];
            [self reloadCollectionPageCell:newCell indexPath:newIndexPath selected:YES];
        }
    }
}

/// 刷新 CollectionPage的Cell 数据
/// @param selected 待刷新cell是否被选中
- (void)reloadCollectionPageCell:(ItemCell *)cell indexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    if (self.icons) {
        cell.titleLabel.hidden = YES; cell.titleBtn.hidden = NO;
        [cell.titleBtn setTitle:self.titles[indexPath.row] forState:UIControlStateNormal];
        [cell.titleBtn setImage:[UIImage imageNamed:self.icons[indexPath.row]] forState:UIControlStateNormal];
        [cell.titleBtn setTitleColor:(selected ? _titleSelectedColor : _titleColor) forState:UIControlStateNormal];
        [cell.titleBtn.titleLabel setFont:(selected ? _titleSelectedFont : _titleFont)];
    } else {
        cell.titleLabel.hidden = NO; cell.titleBtn.hidden = YES;
        [cell.titleLabel setText:self.titles[indexPath.row]];
        [cell.titleLabel setTextColor:(selected ? _titleSelectedColor : _titleColor)];
        //title font 的改变方式
        if (self.pageTitleFontChangeType == PageTitleFontChangeTypeScrollEndAnimation) {
            CGFloat scale = selected ? _titleSelectedFont.pointSize/_titleFont.pointSize : _titleFont.pointSize/_titleSelectedFont.pointSize;
            [UIView animateWithDuration:kAnimateDuration animations:^{
                cell.titleLabel.transform = CGAffineTransformScale(cell.titleLabel.transform, scale, scale);
            }];
        } else {
            [cell.titleLabel setFont:(selected ? _titleSelectedFont : _titleFont)];
        }
    }
}

- (void)moveToDefaultIndex:(NSInteger)index {
    self.selectedIndex = index; //0. selectedIndex会引起 KVO
}


- (void)configProperties {
    
    //init default value
    _pageBarHeight = _onNavigationBar ? 44 : (_pageBarHeight ?: 44);
    _pageBarBgColor = _pageBarBgColor ? : [UIColor whiteColor];
    _lineColor = _lineColor ? : [UIColor blueColor];
    _lineColors = _lineColors ?: _lineColors;
    _lineHeight = _lineHeight ? : 3;
    _lineStaticWidth = _lineStaticWidth ?: 8;
    _maxPagesCountInShowArea = _maxPagesCountInShowArea ?: (_onNavigationBar ? 4 : 5);
    _titleFont = _titleFont ? : [UIFont systemFontOfSize:15];
    _titleSelectedFont = _titleSelectedFont ?: [UIFont boldSystemFontOfSize:18];
    _titleColor = _titleColor ? : [UIColor colorWithWhite:0.1 alpha:1];
    _titleSelectedColor = _titleSelectedColor ?: [UIColor blackColor];
    _pageMenuW =  _onNavigationBar ? (kScreenWidth - 120) : kScreenWidth; //120为预估的左右navigationItem的总宽度
    
    if (self.pageCellWidthType == PageCellWidthTypeSplitScreen) {
        //根据titles.count平分宽度
        _pageCellW = (_titles.count <= _maxPagesCountInShowArea) ? _pageMenuW / _titles.count : _pageMenuW / _maxPagesCountInShowArea;
    } else if (self.pageCellWidthType == PageCellWidthTypeWidthByStaticCount) {
        //根据_maxPagesCountInShowArea平分宽度
        _pageCellW = _pageMenuW / _maxPagesCountInShowArea;
    }
        
    self.selectedIndex = _selectedIndex ? : 0;
}

- (void)addCollectionPage {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(_pageCellW, _pageBarHeight);
    CGFloat pageMenuY = _onNavigationBar ? 0 : kNavAndStatus_Height;
    CGRect frame = CGRectMake(0, pageMenuY, _pageMenuW, _pageBarHeight);
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collection.dataSource = self;
    collection.delegate = self;
    collection.pagingEnabled = YES;
    collection.scrollEnabled = YES;
    collection.bounces = YES;   //禁止左右弹簧拉伸
    collection.showsHorizontalScrollIndicator = NO;
    [collection registerClass:[ItemCell class] forCellWithReuseIdentifier:pageBarCell];
    self.collectionPage = collection;
    
    if (_onNavigationBar) {
        collection.backgroundColor = [UIColor clearColor];  //位于导航条时背景色处理为透明色,不公开属性
        if (self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
            self.parentViewController.navigationItem.titleView = self.collectionPage;
        } else {
            self.navigationItem.titleView = self.collectionPage;
        }
    } else {
        collection.backgroundColor = _pageBarBgColor;
        [self.view addSubview:self.collectionPage];

        UIView *borderline = [[UIView alloc] initWithFrame:CGRectMake(0, collection.bounds.size.height - 0.5, _pageCellW*_titles.count, 0.5)];
        borderline.backgroundColor = [UIColor colorWithWhite:0.75 alpha:0.5];
        //[collection addSubview:borderline];
    }
    
}

- (void)addPageBottomLine {
    
    _line = [UIView new];
    _line.backgroundColor = _lineColor;
    _line.clipsToBounds = YES;
    _line.layer.cornerRadius = _lineHeight/2;
    [self.collectionPage addSubview:_line];
    [self.collectionPage bringSubviewToFront:_line];
    
    [self updateLineFrameWithIndex:self.selectedIndex];
}

- (void)addCollectionMain {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGRect frame;
    if (_onNavigationBar) {
        //分页条 onNavigationBar && isIPhoneX && parentViewController &&  parentViewController不是NavigationController类型
        if (isIPhoneX && self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
            layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight - kNavAndStatus_Height - kBottom_Safe_Height);
        } else {
            layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight - kNavAndStatus_Height);
        }
        frame = CGRectMake(0, kNavAndStatus_Height, layout.itemSize.width, layout.itemSize.height);
    } else {
        layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight - kNavAndStatus_Height- _pageBarHeight);//kBottom_Safe_Height
        frame = CGRectMake(0, CGRectGetMaxY(_collectionPage.frame),  layout.itemSize.width, layout.itemSize.height);
    }
    
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
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionPage) {
        if (self.pageCellWidthType == PageCellWidthTypeByTitleLength) {
            CGFloat width = ((NSString *)_titles[indexPath.item]).length * (_titleFont.pointSize+2) + 10;
            _pageCellW = width;
        }
        return CGSizeMake(_pageCellW, _pageBarHeight);
    } else {
        CGSize itemSize;
        if (_onNavigationBar) {
            itemSize = CGSizeMake(kScreenWidth, kScreenHeight - kNavAndStatus_Height - kBottom_Safe_Height);
        } else {
            itemSize = CGSizeMake(kScreenWidth, kScreenHeight - kNavAndStatus_Height- _pageBarHeight);//kBottom_Safe_Height
        }
        return itemSize;
    }
}


#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionPage) {
        
        ItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:pageBarCell forIndexPath:indexPath];
        //cell.backgroundColor = [UIColor redColor];
        BOOL selected = (indexPath.row == self.selectedIndex);  //是否被选中
                
        if (self.icons) {
            cell.titleLabel.hidden = YES; cell.titleBtn.hidden = NO;
            [cell.titleBtn setTitle:self.titles[indexPath.row] forState:UIControlStateNormal];
            [cell.titleBtn setImage:[UIImage imageNamed:self.icons[indexPath.row]] forState:UIControlStateNormal];
            [cell.titleBtn setTitleColor:(selected ? _titleSelectedColor : _titleColor) forState:UIControlStateNormal];
            [cell.titleBtn.titleLabel setFont:(selected ? _titleSelectedFont : _titleFont)];
        } else {
            cell.titleLabel.hidden = NO; cell.titleBtn.hidden = YES;
            [cell.titleLabel setText:self.titles[indexPath.row]];
            [cell.titleLabel setTextColor:(selected ? _titleSelectedColor : _titleColor)];
            [cell.titleLabel setFont:(selected ? _titleSelectedFont : _titleFont)];
        }
        
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mainCell forIndexPath:indexPath];
        [cell.contentView addSubview:((UIViewController *)self.controllers[indexPath.row]).view];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionPage) {  //self.collectionMain的点击不用判断,会被具体视图所遮挡
        
        //FIXME: 为了屏蔽lineScrollType == LineScrollTypeDynamicAnimation时, 跨多个 index 点击联动异常的视觉效果,滑动效果结束后去复位
        BOOL needReset = NO;
        LineScrollType lineScrollType = self.lineScrollType; // && ABS(self.selectedIndex - indexPath.item)>1
        if ((self.lineScrollType == LineScrollTypeDynamicAnimation || self.lineScrollType == LineScrollTypeDynamicLinear)) {
            self.lineScrollType = LineScrollTypeFinishedLinear;
            needReset = YES;
        }
        
        if (self.lineScrollType != LineScrollTypeDynamicAnimation || self.lineScrollType != LineScrollTypeDynamicLinear) { //DynamicAnimation时在scrollViewDidScroll:内已经滑动
            [UIView animateWithDuration:kAnimateDuration animations:^{
                //ABS(self.selectedIndex - indexPath.item)>1 表示跨越至少 2 个 index 移动
                ABS(self.selectedIndex - indexPath.item)>1 ? [self updateLineFrameWithIndex:indexPath.row] : nil;
            } completion:^(BOOL finished) {
                if (needReset) self.lineScrollType = lineScrollType; //复位
            }];
        }
        
        NSInteger index = _maxPagesCountInShowArea-2;
        if (indexPath.row >= index) {
            [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        }
        
        [self.collectionMain scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    
}

static float oldOffsetX;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //需要随滑动而改变UI样式:LineScrollTypeDynamicAnimation/LineScrollTypeDynamicLinear在-scrollViewDidScroll:中处理
    if (scrollView == self.collectionMain && (self.lineScrollType == LineScrollTypeDynamicAnimation || self.lineScrollType == LineScrollTypeDynamicLinear)) {
        
        CGFloat x = scrollView.contentOffset.x ;
        int lineIndex = (x + kScreenWidth*0.5) / kScreenWidth;         //滑动切换index基准选择: kScreenWidth*0.5(半屏) 过半屏 index 值会+1
        _lineWidth = [self lineWidthWithsSelectedIndex:lineIndex]; //根据 index 值判断的静态宽度
        
        CGFloat changedW = _pageCellW*fabs(x-kScreenWidth*lineIndex)*2 / kScreenWidth; //line 改变的长度
        //changedW = (((NSString *)_titles[lineIndex]).length * (_titleFont.pointSize+2) + 10)*fabs(x-kScreenWidth*lineIndex)*2 / kScreenWidth;
        BOOL toLeft = (x > oldOffsetX) ;
        oldOffsetX = x;
        //线的实时滑动中心
        CGFloat centerX;
        //分页条的实时滑动角标
        int pageIndex;
        if (toLeft) {
            if ((x-kScreenWidth*lineIndex) > 0) { //未过半屏: 过半屏之后因为index = (x + kScreenWidth*0.5) / kScreenWidth;  所以 index 值会+1
                centerX = lineIndex * _pageCellW + _pageCellW/2 + changedW/2;
//                centerX = [self lineCenterXWithIndex:lineIndex halfNext:YES] + changedW/2;
            }else{ //划过半屏
                centerX = lineIndex * _pageCellW + _pageCellW/2 - changedW/2;
//                centerX = [self lineCenterXWithIndex:lineIndex halfNext:YES] - changedW/2;
            }
            pageIndex =  ABS(x-0.001)/kScreenWidth;
        }else{
            if ((x-kScreenWidth*lineIndex) < 0) { //未过半屏
                centerX = lineIndex * _pageCellW + _pageCellW/2 - changedW/2;
//                centerX = [self lineCenterXWithIndex:lineIndex halfNext:YES] - changedW/2;
            }else{  //划过半屏
                centerX = lineIndex * _pageCellW + _pageCellW/2 + changedW/2;
//                centerX = [self lineCenterXWithIndex:lineIndex halfNext:YES] + changedW/2;
            }
            pageIndex =  x/kScreenWidth;
        }
        
        if (self.lineScrollType == LineScrollTypeDynamicAnimation) {
            _line.frame = CGRectMake(0, _pageBarHeight-_lineHeight,  _lineWidth+changedW, _lineHeight);
        } else if (self.lineScrollType == LineScrollTypeDynamicLinear) {
            _line.frame = CGRectMake(0, _pageBarHeight-_lineHeight,  _lineWidth, _lineHeight);
        }
        
        _line.center = CGPointMake(centerX, _pageBarHeight-_lineHeight/2);
        
        
        //处理working中的 2 个分页标题实时属性的设置
        [self changePageTitlePropertyiesWithIndex:pageIndex andSrollX:x];
    }
    
    
    if (_lineColors) {
        //            _line.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:_line.bounds andColors:_lineColors];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat x = scrollView.contentOffset.x ;
    int index = (x + kScreenWidth*0.5) / kScreenWidth;         //滑动切换基准选择: kScreenWidth*0.5(半屏)
    
    //需要在滑动结束后改变UI样式:LineScrollTypeFinishedAnimation/LineScrollTypeFinishedLinear在-scrollViewDidScroll:中处理
    if (scrollView == self.collectionMain && (self.lineScrollType == LineScrollTypeFinishedAnimation || self.lineScrollType == LineScrollTypeFinishedLinear)) {
                
        if (self.lineScrollType == LineScrollTypeFinishedAnimation) {       //完成后的下划线动态动画
            CGPoint point =  [scrollView.panGestureRecognizer translationInView:self.view];
            [UIView animateWithDuration:kAnimateDuration animations:^{
                [self updateHalfLineFrameWithIndex:index direction:(point.x > 0)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:kAnimateDuration animations:^{
                    [self updateLineFrameWithIndex:index];
                }];
            }];
        }
        
        if (self.lineScrollType == LineScrollTypeFinishedLinear) {      //或者线性平滑移动
            [UIView animateWithDuration:kAnimateDuration animations:^{
                [self updateLineFrameWithIndex:index];
            }];
        }
        
    }
    
    NSInteger needScrollIndex = _maxPagesCountInShowArea-2;
    if (index >= needScrollIndex) {
        [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index - needScrollIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

/// 处理working中的 2 个分页标题实时属性的设置
/// @param pageIndex page 滑动时对应的 index
/// @param x SrollX
- (void)changePageTitlePropertyiesWithIndex:(int)pageIndex andSrollX:(CGFloat)x {
    
    //创建通用变量
    CGFloat xInScreen = x-kScreenWidth*pageIndex;  //一屏内的位移距离
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:pageIndex inSection:0];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:pageIndex+1 inSection:0];
    ItemCell *oldCell = (ItemCell *)[self.collectionPage cellForItemAtIndexPath:oldIndexPath];
    ItemCell *newCell = (ItemCell *)[self.collectionPage cellForItemAtIndexPath:newIndexPath];
    
    if (self.pageTitleFontChangeType == PageTitleFontChangeTypeScrolling) {
        CGFloat FontRuntimeDifferenceSize = xInScreen/kScreenWidth*(_titleSelectedFont.pointSize-_titleFont.pointSize);
        CGFloat _titleSelectedFontSize = _titleSelectedFont.pointSize;
        CGFloat _titleFontSize = _titleFont.pointSize;
        oldCell.titleLabel.font = [UIFont boldSystemFontOfSize:_titleSelectedFontSize-FontRuntimeDifferenceSize];
        newCell.titleLabel.font = [UIFont boldSystemFontOfSize:_titleFontSize+FontRuntimeDifferenceSize];
    }
    
    if (self.pageTitleColorChangeType == PageTitleColorChangeTypeScrolling) {
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
        //colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f 是错误写法,原色值里面已经包含了  x/255.0 的处理
        UIColor *runtimeColor0 = [UIColor colorWithRed:runingRed0 green:runingGreen0 blue:runingBlue0 alpha:1.0];
        UIColor *runtimeColor1 = [UIColor colorWithRed:runingred1 green:runinGreen1 blue:runingBlue1 alpha:1.0];
        oldCell.titleLabel.textColor = runtimeColor1;
        newCell.titleLabel.textColor = runtimeColor0;
    }
}

/** 系统API获取UIColor的RGBA值 */
- (NSArray *)getRGBValueFromColor:(UIColor *)color {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return @[@(red), @(green), @(blue), @(alpha)];
}

/** 更新/设置 下划线的 frame */
- (void)updateLineFrameWithIndex:(NSInteger)index {
    _lineWidth = [self lineWidthWithsSelectedIndex:index];
    _line.frame = CGRectMake(0, _pageBarHeight - _lineHeight, _lineWidth, _lineHeight);
    
//    CGFloat width = [self lineCenterXWithIndex:index halfNext:YES];
//    _line.center = CGPointMake(width, _pageBarHeight - _lineHeight/2);
    _line.center = CGPointMake((index * _pageCellW) + _pageCellW/2, _pageBarHeight - _lineHeight/2);

    if (_lineColors) {
        //_line.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:_line.bounds andColors:_lineColors];
    }
}

/** 加动画位移时的前一半动作 */
- (void)updateHalfLineFrameWithIndex:(NSInteger)index direction:(BOOL)isLeft {
    _lineWidth = [self lineWidthWithsSelectedIndex:index];
    _line.frame = CGRectMake(0, _pageBarHeight - _lineHeight, _lineWidth + _pageCellW, _lineHeight);
    _line.center = CGPointMake( isLeft ? ((index+1)*_pageCellW) : (index*_pageCellW), _pageBarHeight - _lineHeight/2);
//    _line.center = CGPointMake( isLeft ? [self lineCenterXWithIndex:index+1 halfNext:NO] : [self lineCenterXWithIndex:index halfNext:NO], _pageBarHeight - _lineHeight/2);

}

- (CGFloat)lineCenterXWithIndex:(NSInteger)index halfNext:(BOOL)halfNext {
    __block CGFloat centerX = 0;
    [_titles enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < index) {
            centerX = centerX + obj.length*(_titleFont.pointSize+2) + 10;
        } else {
            if (halfNext) {
                centerX = centerX + (obj.length*(_titleFont.pointSize+2) + 10)/2;
            }
            *stop = YES;
        }
    }];
    return centerX;
}

- (CGFloat)lineWidthWithsSelectedIndex:(NSInteger)index {
    
    self.selectedIndex = index;     //动态修改选中的 index -> KVO
    
    CGFloat adaptIconW = self.icons ? (15 + 6) : 0;  //15icon + 6margin
    switch (self.lineWidthType) {
        case LineWidthTypeStaticLong:
            _lineWidth = (_titles.count <= _maxPagesCountInShowArea) ? _pageMenuW / _titles.count : _pageMenuW / _maxPagesCountInShowArea;
            break;
        case LineWidthTypeDynamic:
            _lineWidth = ((NSString *)_titles[index]).length * (_titleFont.pointSize) + adaptIconW;
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
