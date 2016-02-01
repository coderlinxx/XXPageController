//
//  ItemCell.m
//  XXPageController
//
//  Created by 林祥兴 on 16/1/21.
//  Copyright © 2016年 pogo.林祥星. All rights reserved.
//

#import "ItemCell.h"

@interface ItemCell ()
@property(nonatomic,weak)UILabel *titleLabel;
@end

@implementation ItemCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self creatUI];
    }
    return self;
}

- (void)creatUI{
    UILabel *labelName = [[UILabel alloc] init];
    labelName.textColor =  [UIColor colorWithWhite:0.15 alpha:1];
    labelName.font = [UIFont systemFontOfSize:13];
    labelName.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = labelName;
    [self.contentView addSubview:self.titleLabel];
}

-(void)setTitleString:(NSString *)titleString{
    _titleString = titleString;
    _titleLabel.text = titleString;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
