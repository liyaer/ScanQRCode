//
//  ScanGUIThree.m
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/16.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#import "ScanGUIThree.h"


#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define toTop (SCREEN_HEIGHT -200)/2
#define toLeft (SCREEN_WIDTH -200)/2


#pragma mark - 类的扩展

@interface ScanGUIThree ()

@end




#pragma mark - 类的实现

@implementation ScanGUIThree

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatAlphaView:CGRectMake(0, 0, SCREEN_WIDTH, toTop)];//top
    [self creatAlphaView:CGRectMake(0, toTop, toLeft, 200)];//left
    [self creatAlphaView:CGRectMake(0, toTop +200, SCREEN_WIDTH, toTop +200)];//bottom
    [self creatAlphaView:CGRectMake(toLeft +200, toTop, toLeft, 200)];//right
    
    //缩小扫描范围至上面4个View围成的框框中
    self.output.rectOfInterest = CGRectMake(toTop /SCREEN_HEIGHT, toLeft /SCREEN_WIDTH, 200 /SCREEN_HEIGHT, 200 /SCREEN_WIDTH);
}




#pragma mark - 封装方法调用集合

-(void)creatAlphaView:(CGRect)rect
{
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view addSubview:view];
}



@end
