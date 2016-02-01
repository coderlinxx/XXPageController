# XXPageController
一个用简单的方式实现的标准的类似网易新闻APP分页效果的分页加载控制器.提供了两种不同的分页展示效果:

分页栏在 NavigationBar 上还是不在 NavigationBar 上.

全用UICollectionView来实现的,比较浅显易懂.只是在实现的时候多注意了一些细节.

####效果图:

![](https://github.com/coderlinxx/XXPageController/blob/master/demo.gif)

####集成方法:

//你只需要在需要加载分页控制器的前一页做像下面这种操作:

```Object-C
XXPageController *pageVc = [[XXPageController alloc] initWithTitles:@[@"QQ",@"旺旺",@"微信",@"腾讯",@"阿里",@"天猫",@"淘宝",@"大姨妈"] controllersClass:@[[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class],[PageCell2Controller class]] onNavigationBar:YES];
[self.navigationController pushViewController:pageVc animated:YES];
```

//几种不同方式展示的所有代码都在 demo 里的 `Viewcontroller` 类`didSelectRowAtIndexPath:`方法内:

```Object-C
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
