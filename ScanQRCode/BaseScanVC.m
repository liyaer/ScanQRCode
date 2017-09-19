//
//  BaseScanVC.m
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/16.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#import "BaseScanVC.h"




@interface BaseScanVC ()<AVCaptureMetadataOutputObjectsDelegate>

@end




@implementation BaseScanVC

#pragma mark - 懒加载

-(AVCaptureDevice *)device
{
    if (!_device)
    {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

-(AVCaptureDeviceInput *)input
{
    if (!_input)
    {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

-(AVCaptureMetadataOutput *)output
{
    if (!_output)
    {
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}

-(AVCaptureSession *)session
{
    if (!_session)
    {
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    return _session;
}

-(AVCaptureVideoPreviewLayer *)preview
{
    if (!_preview)
    {
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _preview.frame = self.view.layer.bounds;//可以设置扫描范围
    }
    return _preview;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //判断当前设备是否可以调用相机
    if (self.device)
    {
        //连接输入和输出
        if ([self.session canAddInput:self.input])
        {
            [self.session addInput:self.input];
        }
        
        if ([self.session canAddOutput:self.output])
        {
            [self.session addOutput:self.output];
        }
        
        //设置条码类型
        self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
        
        //添加扫描画面
        [self.view.layer insertSublayer:self.preview atIndex:0];
        
        //开始扫描
        [self.session startRunning];
    }
    else
    {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前设备无法调用相机！" preferredStyle:UIAlertControllerStyleAlert];
        [alter addAction:[UIAlertAction actionWithTitle:@"朕知道了" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alter animated:YES completion:nil];
    }
}




#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"=======扫描结果：%@",stringValue);
        
        //个人理解：这是被扫描的二维码出现在我们扫描框中的位置（注意是相对于扫描狂的位置）
        NSArray *arry = metadataObject.corners;
        for (id temp in arry)
        {
            NSLog(@"==================%@",temp);
        }
    }
    else
    {
        NSLog(@"无扫描结果！");
    }
}


@end
