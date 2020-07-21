# XXPageController

[![CocoaPods](https://img.shields.io/cocoapods/v/XXPageController.svg?style=flat)](https://github.com/coderlinxx/XXPageController)

分页加载控制器XXPageMenuController.提供了多种不同的分页动态展示效果.

*2018年7月6日更新:

>https://www.jianshu.com/p/20845080a7a4

===================================================================


分页栏在 NavigationBar 上还是不在 NavigationBar 上.

全用UICollectionView来实现的,比较浅显易懂.只是在实现的时候多注意了一些细节.

### 效果图:

![](https://github.com/coderlinxx/XXPageController/blob/master/demo.gif)

## 一. Installation 安装

#### CocoaPods
> pod 'XXPageCreater'   #iOS9 and later        

#### 手动安装
> 将工程内`XXPageCreater`文件夹手动拽入项目中，导入头文件` #import "XXPageController.h"

## 二. Use Example 使用方法

你只需要在需要加载分页控制器的前一页做像下面这种操作:

```Objective-C
XXPageController *pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
[self.navigationController pushViewController:pageVc animated:YES];
```

##### PS:几种不同方式展示的所有代码都在 demo 里的 `Viewcontroller` 类`didSelectRowAtIndexPath:`方法内:

```Objective-C
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *pageVc;
    switch (indexPath.row) {
        case 0:
        {
            pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
        }
            break;
        case 1:
        {
            pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class]] onNavigationBar:NO];
        }
            break;
        case 2:
        {
            pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
        }
            break;
        default:
            pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信"] controllersClass:@[[PageCell1Controller class],[PageCell1Controller class],[PageCell1Controller class]] onNavigationBar:NO];
            break;
    }
    [self.navigationController pushViewController:pageVc animated:YES];
}
```
还有不明白的详见 Demo, 里面写的很详细.
