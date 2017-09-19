//
//  ScanGUIOne.h
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/16.
//  Copyright © 2017年 杜文亮. All rights reserved.
//


/*
 *   控制器：带界面的扫描方式一
 *   思路：-!- AVCaptureVideoPreviewLayer扫描画面设置全屏，AVCaptureMetadataOutput设置扫描范围
          -!- 构造扫描范围全透明，四周半透明的图层，覆盖在整个扫描画面上，完成效果
 *   图片：成型的带四角框的透明图，可以直接使用
 */

#import "BaseScanVC.h"

@interface ScanGUIOne : BaseScanVC

@end
