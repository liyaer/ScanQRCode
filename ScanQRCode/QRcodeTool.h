//
//  QRcodeTool.h
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/18.
//  Copyright © 2017年 杜文亮. All rights reserved.
//


/*
 *   二维码的生成和识别
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QRcodeTool : NSObject

/*
 *                              生成二维码，这里提供了两种方式
 
 *    方式一：1.2（图片尺寸放大）、1.3（图片颜色改变）
 
 *    方式二：2.2（图片尺寸放大）、2.3（图片颜色改变）
 
 */
#pragma mark - 生成二维码

/*
 *   1.1 直接使用滤镜生成的图片（只是为了观察原始二维码图片的大小，真实开发不会使用，因为缺点太明显）
 *   缺点：图片大小会根据str长度变化，成正比关系。若外界imageView的宽高远大于图片大小，会造成图片十分模糊
 */
+(UIImage *)useFilterImage:(NSString *)str;

/*
 *   1.2 在1.1的基础上，处理图片大小以适应imageView容器的大小，使图片保持清晰
 */
+(UIImage *)useFilterImage:(NSString *)str width:(CGFloat)width;

/**
 *   1.3 在1.2的基础上,生成一张彩色的二维码
 *
 *   @param str    传入你要生成二维码的数据
 *   @param backgroundColor    背景色
 *   @param mainColor    主颜色
 */
+(UIImage *)useFilterImage:(NSString *)str width:(CGFloat)width backgroundColor:(CIColor *)backgroundColor mainColor:(CIColor *)mainColor;

/**
 *   2.2 在1.0的基础上，处理图片大小以适应imageView容器的大小，使图片保持清晰
 *
 *   @param QRString  二维码内容
 *   @param sizeWidth 图片size（正方形）
 *
 *   @return  二维码图片
 */
+(UIImage *)createQRimageString:(NSString *)QRString sizeWidth:(CGFloat)sizeWidth;

/**
 *   2.3 在2.2的基础上,生成一张彩色的二维码
 *
 *   @param QRString  二维码内容
 *   @param sizeWidth 图片size（正方形）
 *   @param color     填充色(外界传进来颜色取值范围是0~1，我们需要使用的颜色取值范围是0~255，所以*255转化一下)
 *
 *   @return  二维码图片
 */
+(UIImage *)createQRimageString:(NSString *)QRString sizeWidth:(CGFloat)sizeWidth fillColor:(UIColor *)color;

#pragma mark - 生成一张带Logo的二维码(仅仅以1.2作为示例)

/**
 *  生成一张带有logo的二维码
 *
 *  @param str    传入你要生成二维码的数据
 *  @param logoImageName    logo的image名
 *  @param logoScaleToSuperView    logo相对于父视图的缩放比（取值范围：0-1，0，代表不显示，1，代表与父视图大小相同，注意设置的过大会导致二维码无法识别！）
 */
+(UIImage *)useFilterImage:(NSString *)str width:(CGFloat)width logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView;






/*
 *                              识别二维码的两种方式
 
 *   1，扫描二维码，获取其中内容
 
 *   2，不调用相机扫描，直接代码识别
 
 */
#pragma mark - 识别二维码

//这里是第二种（使用场景：存到手机里的二维码图片，无法用手机相机进行扫描，通过这种方式获取其中的内容）
+(NSString *)readQRCodeFromImage:(UIImage *)image;


@end
