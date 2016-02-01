//
//  XXPageController.h
//  XXPageController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXPageController : UIViewController

/**
 *  滑动到相应 index 位置时才去创建相应控制器的分页创建方式
 *
 *  @param titlesArray      标题数组
 *  @param controllersClass 要创建的控制器类名数组
 *
 *  @return 栈顶控制管理器
 */
-(instancetype) initWithTitles:(NSArray *)titlesArray controllersClass:(NSArray *)controllersClass onNavigationBar:(BOOL)onNavigationBar;

@end
