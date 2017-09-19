//
//  ScanGUIThree.h
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/16.
//  Copyright © 2017年 杜文亮. All rights reserved.
//


/*
 *   控制器：带界面的扫描方式三（最笨、最直观的办法）
 *   思路：-!- AVCaptureVideoPreviewLayer扫描画面设置全屏，AVCaptureMetadataOutput设置扫描范围
          -!- 将非扫描区域用4个半透明的View遮盖
 *   图片：根据给的图片类型进行设置（参考方式一和方式二中的图片类型）
 */

#import "BaseScanVC.h"

@interface ScanGUIThree : BaseScanVC

@end
