//
//  ImageViewController.m
//  XXPageController
//
//  Created by GoGo: 林祥星 on 2018/6/20.
//  Copyright © 2018年 pogo.inxx. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *v=[[UIView alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.navigationController.navigationBar.frame) + 50, 100, 100)];
    v.backgroundColor=[UIColor yellowColor];
    //v.layer.masksToBounds=YES;这行去掉
    v.layer.cornerRadius=10;
    v.layer.shadowColor=[UIColor redColor].CGColor;
    v.layer.shadowOffset=CGSizeMake(10, 10);
    v.layer.shadowOpacity=0.5;
    v.layer.shadowRadius=5;
    [self.view addSubview:v];
    
    
    
    UIImageView *imageV=[[UIImageView alloc] init];
    imageV.backgroundColor=[UIColor yellowColor];
    UIImage *image = [UIImage imageNamed:@"timg"];
    CGFloat width = self.view.bounds.size.width - 30;
    CGFloat heigth = width * image.size.height / image.size.width;
    imageV.frame = CGRectMake(10, CGRectGetMaxY(v.frame) + 50, width, heigth);
    [imageV setImage:image];
    
    imageV.layer.cornerRadius=10;
    imageV.layer.shadowColor=[UIColor redColor].CGColor;
    imageV.layer.shadowOffset=CGSizeMake(10, 10);
    imageV.layer.shadowOpacity=.5;
    imageV.layer.shadowRadius=10;
    [self.view addSubview:imageV];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
