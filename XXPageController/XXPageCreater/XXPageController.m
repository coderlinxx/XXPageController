
//  XXPageController.m
//  XXPageController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "XXPageController.h"
#import "ItemCell.h"
#import "MainCell.h"
#import "ViewController.h"
#import "PopEnabeldCollectionView.h"
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

#define CollectionWidth (SCREEN_Width-120)
#define SCREEN_Width ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_Height ([[UIScreen mainScreen] bounds].size.height)
#define ColorWithRGB(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

static NSString *pageBarCell = @"pageBarCell";
static NSString *mainCell = @"mainCellmainCell";

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
        _pageBarHeight = 40;
    }
    return self;
}
/**
 自动创建全部控制器的分页创建方式
 */
- (instancetype)initWithTitles:(NSArray *)titlesArray controllers:(NSArray *)controllers onNavigationBar:(BOOL)onNavigationBar{
    if (self == [super init]) {
        self.onNavigationBar = onNavigationBar;
        self.itemsArray = titlesArray;
        self.controllers = controllers;
        _pageBarHeight = 40;
    }
    return self;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    //init default value
    _scrollToRight = YES;
    _lastPositionX = 0;
    
    [self addCollectionPage];
    [self addCollectionMain];
}

-(void)addCollectionPage{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGRect frame;
    if (_onNavigationBar) {
        frame = CGRectMake(0, 0, CollectionWidth, _pageBarHeight);
    }else{
        frame = CGRectMake(0, 64, self.view.bounds.size.width, _pageBarHeight);
    }
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
        if (_itemsArray.count <= 3) {
            _lineWidth = CollectionWidth / _itemsArray.count;
        }else{
            _lineWidth = CollectionWidth / 3;
        }
    }else{
        collection.backgroundColor = _pageBarBgColor ? : [UIColor greenColor];
        [self.view addSubview:self.collectionPage];
        if (_itemsArray.count <= 4) {
            _lineWidth = SCREEN_Width / _itemsArray.count;
        }else{
            _lineWidth = SCREEN_Width / 4;
        }
    }
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, _pageBarHeight - 3, _lineWidth, 3)];
    _line.backgroundColor = _lineColor ? : [UIColor blueColor];
    [self.collectionPage addSubview:_line];
    [self.collectionPage bringSubviewToFront:_line];
    
}

-(void)addCollectionMain{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGRect frame;
    if (_onNavigationBar) {
        frame = CGRectMake(0, 64, self.view.bounds.size.width,self.view.bounds.size.height - 64);
    }else{
        frame = CGRectMake(0, CGRectGetMaxY(_collectionPage.frame), self.view.bounds.size.width, self.view.bounds.size.height - 64 - _pageBarHeight);
    }
    
    PopEnabeldCollectionView *collection = [[PopEnabeldCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collection.backgroundColor = [UIColor greenColor];
    collection.dataSource = self;
    collection.delegate = self;
    collection.pagingEnabled = YES;
    collection.scrollEnabled = YES;
    collection.bounces = NO;   //禁止左右弹簧拉伸
    collection.showsHorizontalScrollIndicator = NO;
    [collection registerClass:[MainCell class] forCellWithReuseIdentifier:mainCell];
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

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
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
        [cell.titleLabel setFont:_titleFont ? : [UIFont systemFontOfSize:13]];
        [cell.titleLabel setTextColor:_titleColor ? : [UIColor colorWithWhite:0.15 alpha:1]];
        return cell;
    }else{
        MainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mainCell forIndexPath:indexPath];
        [cell setIndexController:self.controllers[indexPath.row]];
        NSLog(@"indexController.view.frame = %@",NSStringFromCGRect(cell.indexController.view.frame));
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
