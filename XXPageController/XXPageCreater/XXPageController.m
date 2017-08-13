
//  XXPageController.m
//  XXPageController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "XXPageController.h"
#import "ViewController.h"
@interface XXPageController ()<UICollectionViewDataSource,UICollectionViewDelegate>

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
/** 动态滑动时所记录的最后的 X 坐标 */
@property(nonatomic,assign)int lastPositionX;
/** 分页条滑动方向  默认值给 YES */
@property(nonatomic,assign)BOOL scrollToRight;

@property(nonatomic ,strong)NSArray *itemsArray;
@property(nonatomic, strong)NSArray *controllersClass;
@property(nonatomic, strong)NSArray *controllers;

@end

#define CollectionWidth (SCREEN_Width - 120)
#define SCREEN_Width ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_Height ([[UIScreen mainScreen] bounds].size.height)
#define ColorWithRGB(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

static NSString *pageBarCell = @"inxx_pageBarCell";
static NSString *mainCell = @"inxx_mainCell";

@implementation XXPageController

-(NSArray *)controllers{
    if (!_controllers) {
        NSMutableArray *controllers = [NSMutableArray array];
        [_controllersClass enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Class className = _controllersClass[idx];
            UIViewController *vc = [[className alloc] init];
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

- (void)addPageViewControllerToSuperViewController:(UIViewController *)viewController{
    [viewController.view addSubview:self.view];
    [viewController addChildViewController:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //将XXPageController对象的view被添加到另一个控制器的view上时就会发生if内的情况
    if (self.nextResponder && self.view.superview && self.view.superview == self.nextResponder) {
        UIViewController *controller = (UIViewController *)self.view.superview.nextResponder;
        //解决一个view上面放两个不同的collectionview的显示冲突
        controller.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //配置属性
    [self configProperties];
    
    [self addCollectionPage];
    [self addCollectionMain];
}

- (void)configProperties{
    
    //init default value
    _scrollToRight = YES;
    _lastPositionX = 0;
    
    _pageBarHeight = _pageBarHeight ? : 40;
    _pageBarBgColor = _pageBarBgColor ? : [UIColor greenColor];
    _lineColor = _lineColor ? : [UIColor blueColor];
    _titleFont = _titleFont ? : [UIFont systemFontOfSize:13];
    _titleColor = _titleColor ? : [UIColor colorWithWhite:0.15 alpha:1];
}

-(void)addCollectionPage{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGRect frame = _onNavigationBar ? CGRectMake(0, 0, CollectionWidth, _pageBarHeight) : CGRectMake(0, 64, self.view.bounds.size.width, _pageBarHeight);
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
        self.navigationItem.titleView = self.collectionPage;
        _lineWidth = (_itemsArray.count <= 3) ? CollectionWidth / _itemsArray.count : CollectionWidth / 3;
    }else{
        collection.backgroundColor = _pageBarBgColor;
        [self.view addSubview:self.collectionPage];
        _lineWidth = (_itemsArray.count <= 4) ? SCREEN_Width / _itemsArray.count : SCREEN_Width / 4;
    }
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, _pageBarHeight - 3, _lineWidth, 3)];
    _line.backgroundColor = _lineColor;
    [self.collectionPage addSubview:_line];
    [self.collectionPage bringSubviewToFront:_line];
}

-(void)addCollectionMain{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGRect frame = _onNavigationBar ? CGRectMake(0, 64, self.view.bounds.size.width,self.view.bounds.size.height - 64) : CGRectMake(0, CGRectGetMaxY(_collectionPage.frame), self.view.bounds.size.width, self.view.bounds.size.height - 64 - _pageBarHeight);
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

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.collectionPage) {
        CGFloat width ;
        if (_onNavigationBar) {
            width = (_itemsArray.count <= 3) ? CollectionWidth / _itemsArray.count : CollectionWidth / 3 ;
        }else{
            width = (_itemsArray.count <= 3) ? SCREEN_Width / _itemsArray.count : SCREEN_Width / 4 ;
        }
        return CGSizeMake(width, _pageBarHeight);
    }else{
        return collectionView.frame.size;
    }
}


#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.collectionPage) {
        ItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:pageBarCell forIndexPath:indexPath];
        [cell sizeToFit];
        [cell.titleLabel setText:self.itemsArray[indexPath.row]];
        [cell.titleLabel setFont:_titleFont];
        [cell.titleLabel setTextColor:_titleColor];
        return cell;
    }else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mainCell forIndexPath:indexPath];
        [cell.contentView addSubview:((UIViewController *)self.controllers[indexPath.row]).view];
        return cell;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.collectionPage) {
        [self.collectionMain scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            _line.frame = CGRectMake((0 + indexPath.row) *_lineWidth, _pageBarHeight - 3, _lineWidth, 3);
        }];
        
        if (_onNavigationBar) {
            if (indexPath.row >= 2) {
                [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            }
        }else{
            NSInteger row = indexPath.row;
            if (_scrollToRight == YES) {  //正向
                if (row >= 3) {
                    [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row - 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                }
            }else{  //反向
                if (  row <= 4 && row > 0) {
                    [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionMain) {
        CGFloat x = scrollView.contentOffset.x ;
        int index = (x + SCREEN_Width*0.5) / SCREEN_Width;
        [UIView animateWithDuration:0.25 animations:^{
            _line.frame = CGRectMake(index *_lineWidth, _pageBarHeight - 3, _lineWidth, 3);
        }];
        
        if (index >= 1) {
            [self.collectionPage scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.collectionMain) {
        int currentPostion = scrollView.contentOffset.x;
        if (currentPostion - _lastPositionX > 5) {
            _scrollToRight = YES;
        }else if(currentPostion - _lastPositionX < -5){
            _scrollToRight = NO;
        }
        _lastPositionX = currentPostion;
    }
}

-(void)dealloc{
    NSLog(@"dealloc : %@ ",self.class);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
