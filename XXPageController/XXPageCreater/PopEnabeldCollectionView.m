//
//  PopEnabeldCollectionView.m
//  XXPageController
//
//  Created by 林祥兴 on 16/1/29.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "PopEnabeldCollectionView.h"

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
