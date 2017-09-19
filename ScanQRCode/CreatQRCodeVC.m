//
//  CreatQRCodeVC.m
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/18.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#import "CreatQRCodeVC.h"
#import "QRcodeTool.h"

@interface CreatQRCodeVC ()

@end

@implementation CreatQRCodeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //生成二维码
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 300, 300)];
//    imgView.image = [QRcodeTool useFilterImage:@"突突突，冒蓝火的加特林~"];
//    imgView.image = [QRcodeTool useFilterImage:@"突突突，冒蓝火的加特林~" width:200.0];
//    imgView.image = [QRcodeTool useFilterImage:@"突突突，冒蓝火的加特林~" width:200.0 backgroundColor:[CIColor colorWithRed:0 green:0 blue:1] mainColor:[CIColor colorWithRed:1 green:0 blue:0]];
//    imgView.image = [QRcodeTool createQRimageString:@"突突突，冒蓝火的加特林~" sizeWidth:200.0];
//    imgView.image = [QRcodeTool createQRimageString:@"突突突，冒蓝火的加特林~" sizeWidth:200.0 fillColor:[UIColor colorWithRed:0.7 green:0 blue:0 alpha:1.0]];//注意这里的alpha参数设置是无效的哦
    [self.view addSubview:imgView];
    
    imgView.layer.shadowOffset = CGSizeMake(0, 0.5);  // 设置阴影的偏移量
    imgView.layer.shadowRadius = 1;  // 设置阴影的半径
    imgView.layer.shadowColor = [UIColor blackColor].CGColor; // 设置阴影的颜色为黑色
    imgView.layer.shadowOpacity = 0.3; // 设置阴影的不透明度
    
    //给二维码添加Logo的两种方法（效果等价，但有着本质区别）
    imgView.image = [QRcodeTool useFilterImage:@"突突突，冒蓝火的加特林~" width:200.0 logoImageName:@"logo" logoScaleToSuperView:0.2];
    
//    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
//    logo.image = [UIImage imageNamed:@"logo"];
//    logo.center = CGPointMake(150, 150);
//    [imgView addSubview:logo];
    

    //识别二维码
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 320, 36)];
    label.text = [QRcodeTool readQRCodeFromImage:imgView.image];
    [self.view addSubview:label];
}

@end
