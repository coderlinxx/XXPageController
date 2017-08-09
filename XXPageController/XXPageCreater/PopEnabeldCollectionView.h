//
//  PopEnabeldCollectionView.h
//  XXPageController
//
//  Created by 林祥兴 on 16/1/29.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  此子类的主要目的: iOS横向滚动的scrollView和系统pop手势返回冲突的解决办法,如果您使用了自定义的UINavigationController或者自定义了UINavigationBar 的返回按钮,那么此类必须使用
 */
@interface PopEnabeldCollectionView : UICollectionView<UIGestureRecognizerDelegate>

@end
