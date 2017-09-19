//
//  BaseScanVC.h
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/16.
//  Copyright © 2017年 杜文亮. All rights reserved.
//


/*
 *   控制器：扫描二维码的基础代码（不带界面效果，方便查看原理）
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface BaseScanVC : UIViewController

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@end
