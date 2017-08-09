//
//  MainCell.m
//  XXPageController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "MainCell.h"
@interface MainCell ()

@end

@implementation MainCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        //config...
    }
    return self;
}

-(void)setIndexController:(UIViewController *)indexController{
    [_indexController.view removeFromSuperview];
    _indexController = indexController;
    _indexController.view.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_indexController.view];
    
    [self layoutSubviews];
//    [_indexController.view setFrame:self.bounds];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _indexController.view.frame = self.bounds;
}

@end
