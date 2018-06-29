//
//  Header.h
//  XXPageController
//
//  Created by GoGo: 林祥星 on 2018/6/28.
//  Copyright © 2018年 pogo.inxx. All rights reserved.
//

#ifndef Header_h
#define Header_h

#define ScreenW ([[UIScreen mainScreen] bounds].size.width)
#define ScreenH ([[UIScreen mainScreen] bounds].size.height)

#define kStatusBar_Height  [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBar_Height 44
#define kNavAndStatus_Height (kStatusBar_Height + kNavBar_Height)
#define isIPhoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size)) //是否是iphoneX
//底部安全高度
#define kBottom_Safe_Height (isIPhoneX ? 34 : 0)
//系统手势高度
#define kSystem_Gesture_Height (isIPhoneX ? 17 : 0)

#endif /* Header_h */
