# XXPageController

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](https://developer.apple.com/iphone/index.action)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)
[![CocoaPods](https://img.shields.io/cocoapods/v/XXPageController.svg?style=flat)](https://github.com/coderlinxx/XXPageController)

分页菜单加载控制器XXPageMenuController. 提供了多种不同的分页动态展示效果.

*2018年7月6日更新:

>https://www.jianshu.com/p/20845080a7a4

===================================================================


### 效果图:

![](https://github.com/coderlinxx/XXPageController/blob/master/demo.gif)

## 一. Installation 安装

#### CocoaPods
> pod 'XXPageController'   #iOS9 and later        

#### 手动安装
> 将工程内`XXPageMenuController`文件夹手动拽入项目中，导入头文件` #import "XXPageMenuController.h"

## 二. Use Example 使用方法

你只需要在需要加载分页控制器的前一页做像下面这种操作:

```Objective-C
XXPageMenuController *pageVc = [[XXPageMenuController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
[self.navigationController pushViewController:pageVc animated:YES];
```

在工程中实际使用时,可以灵活设置各属性:

```Objective-C
- (XXPageMenuController *)menuController {
    if (!_menuController) {
        _menuController = [[XXPageMenuController alloc] initWithTitles:self.pageTitles controllers:self.pageControllers onNavigationBar:NO];
        //_menuController.lineColors = @[UIColorFromRGB(0x858899),FN_Blue_Color];
        _menuController.lineColor = FN_Blue_Color;
        _menuController.lineHeight = 4;
        _menuController.lineStaticWidth = 6;
        _menuController.titleColor = UIColorFromRGB(0x858899);
        _menuController.titleSelectedColor = UIColorFromRGB(0x333333);
        _menuController.titleFont = FNMediumFontSize(15);
        _menuController.pageBarBgColor = [UIColor whiteColor];
        _menuController.pageBarHeight = pageBarHeight;
        _menuController.lineWidthType = LineWidthTypeStaticShort; ///<下划线长度取值类型
        _menuController.lineScrollType = LineScrollTypeDynamicAnimation; ///<下划线在条目切换时的动态表现类型
        _menuController.pageCellWidthType = PageCellWidthTypeWidthByStaticCount; ///<分页条目 cell 宽度取值类型
        _menuController.pageTitleFontChangeType = PageTitleFontChangeTypeScrollEndAnimation; ///<分页滑动时标题字体大小改变方式
        //因为这里是将pageMenuController添加到ParentController(self类)上的,所以要为pageMenuController设置父视图控制器
        //[_menuController setSuperViewController:self];
    }
    return _menuController;
}
```

##### PS:几种不同方式展示的所有代码都在 demo 里的 `Viewcontroller` 类`didSelectRowAtIndexPath:`方法内:

```Objective-C
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *pageVc;
    switch (indexPath.row) {
        case 0:
        {
            pageVc = [[XXPageMenuController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
        }
            break;
        case 1:
        {
            pageVc = [[XXPageMenuController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class]] onNavigationBar:NO];
        }
            break;
        case 2:
        {
            pageVc = [[XXPageMenuController alloc] initWithTitles:@[@"QQ",@"旺旺"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
        }
            break;
        default:
            pageVc = [[XXPageMenuController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信"] controllersClass:@[[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class]] onNavigationBar:NO];
            break;
    }
    [self.navigationController pushViewController:pageVc animated:YES];
}
```
还有不明白的详见 Demo, 里面写的很详细.
