//
//  ScanGUITwo.m
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/16.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#import "ScanGUITwo.h"


#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width


#pragma mark - 类的扩展

@interface ScanGUITwo ()
/*
 *   生成界面效果相关属性
 */
@property (nonatomic,strong) UIImageView *codeBoundImageView;//四角图片
@property (nonatomic,strong) UIImageView *line;
@property (nonatomic,strong) NSTimer *timer;

@end




#pragma mark - 类的实现

@implementation ScanGUITwo

#pragma mark - 懒加载

-(UIImageView *)codeBoundImageView
{
    if (!_codeBoundImageView)
    {
        //添加二维码扫描的边框,转化成可拉伸的图片
        UIImage *image = [UIImage imageNamed:@"qrcode_border"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 26, 26)];

        //设置frame
        _codeBoundImageView = [[UIImageView alloc] initWithImage:image];
        NSInteger w = SCREEN_WIDTH - 70 * 2;
        _codeBoundImageView.frame = CGRectMake(70, 70 + 70, w, w);
        
        //防止[动画line]超出边界
        [_codeBoundImageView addSubview:self.line];
        _codeBoundImageView.clipsToBounds = YES;
    }
    return _codeBoundImageView;
}

-(UIImageView *)line
{
    if (!_line)
    {
        _line = [[UIImageView alloc] initWithFrame:self.codeBoundImageView.bounds];
        [_line setImage:[UIImage imageNamed:@"qrcode_scanline_qrcode"]];
    }
    return _line;
}




#pragma mark - viewDidLoad 初始化

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //设置扫描区域
    CGFloat top = 140/SCREEN_HEIGHT;
    CGFloat left = 70/SCREEN_WIDTH;
    CGFloat width = (SCREEN_WIDTH -140)/SCREEN_WIDTH;
    CGFloat height = (SCREEN_WIDTH -140)/SCREEN_HEIGHT;
    ///top 与 left 互换  width 与 height 互换
    [self.output setRectOfInterest:CGRectMake(top, left, height, width)];
    
    //设置界面效果
    [self configView];
    
    //生成扫描区域全透明，周围半透明效果
    [self drawGUI];
}




#pragma mark - 封装方法调用集合

//【CGRectOffset】便捷的设置frame方法
-(void)changeImage:(NSTimer *)timer
{
    //微调改变frame,用以产生动画
    self.line.frame = CGRectOffset(self.line.frame, 0, 1.5);
    //判断是否超出界限，若超出，则返回开始位置重新进行动画
    if (self.line.frame.origin.y >= self.codeBoundImageView.frame.size.height)
    {
        self.line.frame = CGRectOffset(self.line.frame, 0, -self.codeBoundImageView.frame.size.height *2);
    }
}

//设置界面效果
-(void)configView
{
    [self.view addSubview:self.codeBoundImageView];
    
    //定时器实现line动画效果
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(changeImage:) userInfo:nil repeats:YES];
}

//生成扫描区域全透明，周围半透明效果
-(void)drawGUI
{
    //1，绘制一张不透明，周围半透明的图片
    //创建一张画布
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    //拿到画笔
    CGContextRef context = UIGraphicsGetCurrentContext();
    //现将整个图片涂成半透明
    CGContextSetRGBFillColor(context, 0, 0, 0, .7f);
    CGContextAddRect(context, self.view.bounds);
    CGContextFillPath(context);
    
    //将中间二维码部分涂成完全不透明的区域
    CGContextSetRGBFillColor(context, 1, 1, 1, 1.f);
    CGContextAddRect(context, self.codeBoundImageView.frame);
    CGContextFillPath(context);
    
    //绘图完成，生成图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //2，创建一个用于遮罩的mask层，mask层自身不显示，但是影响到把mask层作为属性的layer的显示，mask的每一点的透明度反作用到layer
    CALayer *mask = [[CALayer alloc] init];
    mask.bounds = self.view.bounds;
    mask.position = self.view.center;
    mask.contents = (__bridge id)image.CGImage;
    self.preview.mask = mask;
    self.preview.masksToBounds = YES;
}




#pragma mark - 重写父类 AVCaptureMetadataOutputObjectsDelegate 方法

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [self.session stopRunning];
        [self.timer setFireDate:[NSDate distantFuture]];//关闭定时器

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
              if (self.session != nil && _timer != nil)
              {
                  [self.session startRunning];
                  [_timer setFireDate:[NSDate date]];
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
    
    [_timer setFireDate:[NSDate distantFuture]];
    _timer = nil;
}


@end
