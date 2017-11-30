//
//  ScanGUIOne.m
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/16.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#import "ScanGUIOne.h"

/**
 *  屏幕 高 宽 边界
 */
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_BOUNDS  [UIScreen mainScreen].bounds

#define TOP (SCREEN_HEIGHT-220)/2
#define LEFT (SCREEN_WIDTH-220)/2

#define kScanRect CGRectMake(LEFT, TOP, 220, 220)


#pragma mark - 类的扩展

@interface ScanGUIOne ()
{
    int num;//控制line的移动距离
    BOOL upOrdown;//控制line的移动方向
    NSTimer * timer;
    CAShapeLayer *cropLayer;
}
@property (nonatomic, strong) UIImageView * line;

@end




#pragma mark - 类的实现

@implementation ScanGUIOne

#pragma mark - viewDidLoad 初始化

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置扫描区域
    CGFloat top = TOP/SCREEN_HEIGHT;
    CGFloat left = LEFT/SCREEN_WIDTH;
    CGFloat width = 220/SCREEN_WIDTH;
    CGFloat height = 220/SCREEN_HEIGHT;
    ///top 与 left 互换  width 与 height 互换
    [self.output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    //设置界面效果
    [self configView];
    //绘制四周半透明，扫描区域全透明
    [self setCropRect:kScanRect];
}




#pragma mark - 封装方法调用集合

//设置界面效果
-(void)configView
{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:kScanRect];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+10, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    upOrdown = NO;
    num =0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(lineAnimationSport) userInfo:nil repeats:YES];
}

//常规的完成line动画的方法，需要增加num、upOrdown属性辅助；方式二是一种便捷的方法，可以参考
-(void)lineAnimationSport
{
    if (upOrdown == NO)
    {
        num ++;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (2*num == 200)
        {
            upOrdown = YES;
        }
    }
    else
    {
        num --;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (num == 0)
        {
            upOrdown = NO;
        }
    }
}

//绘制四周半透明，扫描区域全透明
- (void)setCropRect:(CGRect)cropRect
{
    //设置Path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    //交给CAShapeLayer绘制Path
    cropLayer = [[CAShapeLayer alloc] init];
    [cropLayer setPath:path];
    [cropLayer setFillRule:kCAFillRuleEvenOdd];//奇偶填充，奇填偶不填（对于此处来说，二者交叉区域是cropRect，视为偶；非交叉区域视为奇）
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.5];

    //在某个图层上显示绘制内容
    [self.preview addSublayer:cropLayer];
//    [self.view.layer addSublayer:cropLayer];这两个两个图层都可以实现效果
}




#pragma mark - 重写父类 AVCaptureMetadataOutputObjectsDelegate 方法

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        [self.session stopRunning];//停止扫描
        [timer setFireDate:[NSDate distantFuture]];//关闭定时器
        
        //获取扫描结果
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"=======扫描结果：%@",stringValue);
        
        //个人理解：这是被扫描的二维码出现在我们扫描框中的位置（注意是相对于扫描狂的位置）
        NSArray *arry = metadataObject.corners;
        for (id temp in arry)
        {
            NSLog(@"==================%@",temp);
        }
        
        //展示扫描结果
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:stringValue preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            //开始下一次扫描
            if (self.session != nil && timer != nil)
            {
                [self.session startRunning];
                [timer setFireDate:[NSDate date]];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSLog(@"无扫描结果！");
    }
}




#pragma mark - 释放定时器

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (timer)
    {
        if ([timer isValid])
        {
            [timer invalidate];
        }
        timer = nil;
    }
}


@end
