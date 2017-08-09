//
//  ItemCell.m
//  XXPageController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "ItemCell.h"

@interface ItemCell ()

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

//-(void)layoutSubviews{
//    [super layoutSubviews];
//    self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//}

@end
