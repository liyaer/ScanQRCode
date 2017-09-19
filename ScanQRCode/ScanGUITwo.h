//
//  ScanGUITwo.h
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/16.
//  Copyright © 2017年 杜文亮. All rights reserved.
//


/*
 *   控制器：带界面的扫描方式二
 *   思路：-!- AVCaptureVideoPreviewLayer扫描画面设置全屏，AVCaptureMetadataOutput设置扫描范围
          -!- 这里设置透明的方式和方式一好像不同，关于设置图层这块，方式一和方式二都不是完全理解，闲暇时一定要搞懂
 *   图片：未成型的带四角框的透明图，需要对图片进行拉伸后，才能使用
 */

#import "BaseScanVC.h"

@interface ScanGUITwo : BaseScanVC

@end
