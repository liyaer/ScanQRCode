//
//  QRcodeTool.m
//  ScanQRCode
//
//  Created by 杜文亮 on 2017/9/18.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#import "QRcodeTool.h"

@implementation QRcodeTool

#pragma mark - 生成二维码原理

/*
 *   1.0 使用CIFilter生成CIImage类型二维码图片（1.0是生成二维码的原理、本质）
 */
+ (CIImage *)createQRForString:(NSString *)qrString
{
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

/*
 *   1.1 直接使用滤镜生成的图片（只是为了观察原始二维码图片的大小，真实开发不会使用，因为缺点太明显）
 *   缺点：图片大小会根据str长度变化，成正比关系。若外界imageView的宽高远大于图片大小，会造成图片十分模糊
 */
+(UIImage *)useFilterImage:(NSString *)str
{
    UIImage *filterImage = [UIImage imageWithCIImage:[self createQRForString:str]];
    NSLog(@"=======%f",filterImage.size.width);//打印图片原始大小
    return filterImage;
}

#pragma mark - 对原始二维码图片的处理（放大、上颜色）

/*
 *   1.2 在1.1的基础上，处理图片大小以适应imageView容器的大小，使图片保持清晰
 */
+(UIImage *)useFilterImage:(NSString *)str width:(CGFloat)width
{
    CIImage *filterCIImage = [self createQRForString:str];
    NSLog(@"=======%f",filterCIImage.extent.size.width);//打印图片原始大小
    CGFloat scale = width / filterCIImage.extent.size.width;
    CIImage *outputImage = [filterCIImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];// 放大图片以适应容器大小
    return [UIImage imageWithCIImage:outputImage];
}

/**
 *   1.3 在1.2的基础上,生成一张彩色的二维码
 *
 *   @param str    传入你要生成二维码的数据
 *   @param backgroundColor    背景色
 *   @param mainColor    主颜色
 */
+(UIImage *)useFilterImage:(NSString *)str width:(CGFloat)width backgroundColor:(CIColor *)backgroundColor mainColor:(CIColor *)mainColor
{
    //先进行放大处理
    UIImage *filterImage = [self useFilterImage:str width:width];
    
    // 4、创建彩色过滤器(彩色的用的不多)
    CIFilter * color_filter = [CIFilter filterWithName:@"CIFalseColor"];
    
    // 设置默认值
    [color_filter setDefaults];
    
    // 5、KVC 给私有属性赋值
    [color_filter setValue:filterImage.CIImage forKey:@"inputImage"];
    
    // 6、需要使用 CIColor
    [color_filter setValue:backgroundColor forKey:@"inputColor0"];
    [color_filter setValue:mainColor forKey:@"inputColor1"];
    
    // 7、设置输出
    CIImage *colorImage = [color_filter outputImage];
    
    NSLog(@"==============%f---------%f",colorImage.extent.size.width,[UIImage imageWithCIImage:colorImage].size.width);
    return [UIImage imageWithCIImage:colorImage];
}

/**
 *   2.2 在1.0的基础上，处理图片大小以适应imageView容器的大小，使图片保持清晰
 *
 *   @param QRString  二维码内容
 *   @param sizeWidth 图片size（正方形）
 *
 *   @return  二维码图片
 */
+(UIImage *)createQRimageString:(NSString *)QRString sizeWidth:(CGFloat)sizeWidth
{
    return [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:QRString] withSize:sizeWidth];
}

/**
 *   2.3 在2.2的基础上,生成一张彩色的二维码
 *
 *   @param QRString  二维码内容
 *   @param sizeWidth 图片size（正方形）
 *   @param color     填充色(外界传进来颜色取值范围是0~1，我们需要使用的颜色取值范围是0~255，所以*255转化一下)
 *
 *   @return  二维码图片
 */
+(UIImage *)createQRimageString:(NSString *)QRString sizeWidth:(CGFloat)sizeWidth fillColor:(UIColor *)color
{
    CIImage *ciimage = [self createQRForString:QRString];
    UIImage *qrcode = [self createNonInterpolatedUIImageFormCIImage:ciimage withSize:sizeWidth];
    if (color)
    {
        CGFloat R, G, B;
        
        CGColorRef colorRef = [color CGColor];
        long numComponents = CGColorGetNumberOfComponents(colorRef);
        
        if (numComponents == 4)//外界传进来的颜色有效并且转换成功
        {
            const CGFloat *components = CGColorGetComponents(colorRef);
            R = components[0] *255.0;
            G = components[1] *255.0;
            B = components[2] *255.0;
        }
        else//转换失败，取黑色默认值（一般不会执行else）
        {
            R = 255.0;
            G = 255.0;
            B = 255.0;
        }
        
        UIImage *customQrcode = [self imageBlackToTransparent:qrcode withRed:R andGreen:G andBlue:B];
        return customQrcode;
    }
    return qrcode;
}

//定制图片大小，最后将CIImage转化成UIImage（让图片大小适应我们imageView容器大小，以保持图片清晰）
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

//给黑白二维码上颜色
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue
{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++)
    {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)
        {
            // 修改主体内容颜色（改成下面的代码，会将图片转成想要的颜色）
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
            
            //            ptr[0] = 0;//透明（为了避免相互影响，0和1，2，3同时只能存在一种，即要么透明，要么有颜色）
        }
        else
        {
            // 修改底板颜色(这里设置的话全局生效，想要局部差异化的实现，需要重新增加底板颜色参数，再进行封装)
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = 130; //R，0~255
            ptr[2] = 255; //G
            ptr[1] = 255; //B
            
            //            ptr[0] = 0;//透明（为了避免相互影响，0和1，2，3同时只能存在一种，即要么透明，要么有颜色）
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

#pragma mark - 生成一张带Logo的二维码(仅仅以1.2作为示例)

/**
 *  生成一张带有logo的二维码
 *
 *  @param str    传入你要生成二维码的数据
 *  @param logoImageName    logo的image名
 *  @param logoScaleToSuperView    logo相对于父视图的缩放比（取值范围：0-1，0，代表不显示，1，代表与父视图大小相同，注意设置的过大会导致二维码无法识别！）
 */
+(UIImage *)useFilterImage:(NSString *)str width:(CGFloat)width logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView
{
    //先进行放大处理
    UIImage *filterImage = [self useFilterImage:str width:width];
    return [self addLogoImageToQRImage:filterImage logoImageName:logoImageName logoScaleToSuperView:logoScaleToSuperView];
}

/*
 *                               添加中间小图标
 *    本质：将两张图片绘制到一起，最终返回一张图片
 *    这个方法可以在上面生成二维码的任何一种方法（1.2、1.3、2.2、2.3）里调用，实现添加Logo的效果，这里仅仅以上面一种方法来示例

 *    等价效果：在外界承载QRImage的ImageView上再添加一个承载LogoImage的ImageView，但是和这里的绘制有着本质区别
 */
+(UIImage *)addLogoImageToQRImage:(UIImage *)QRImage logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView
{
    // 开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(QRImage.size);
    
    // 把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [QRImage drawInRect:CGRectMake(0, 0, QRImage.size.width, QRImage.size.height)];
    
    // 再把小图片画上去
    NSString *icon_imageName = logoImageName;
    UIImage *icon_image = [UIImage imageNamed:icon_imageName];
    CGFloat icon_imageW = QRImage.size.width * logoScaleToSuperView;
    CGFloat icon_imageH = QRImage.size.height * logoScaleToSuperView;
    CGFloat icon_imageX = (QRImage.size.width - icon_imageW) * 0.5;
    CGFloat icon_imageY = (QRImage.size.height - icon_imageH) * 0.5;
    
    [icon_image drawInRect:CGRectMake(icon_imageX, icon_imageY, icon_imageW, icon_imageH)];
    
    // 获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    
    return final_image;
}





#pragma mark - 读取图片二维码

/**
 *  读取图片中二维码信息
 *
 *  @param image 图片
 *
 *  @return 二维码内容
 */
+(NSString *)readQRCodeFromImage:(UIImage *)image
{
    NSData *data = UIImagePNGRepresentation(image);
    CIImage *ciimage = [CIImage imageWithData:data] ? : image.CIImage;//这样写保证无论方式一还是方式二生成的QRImage，都可以被识别
    /*
     *   1.1、1.2、1.3是通过[UIImage imageWithCIImage:outputImage]返回的Image(image.CIImage != nil)，此时执行上面两句代码返回nil,但是可以通过image.CIImage来直接获取到CIImage类型的对象
     
     *   2.2、2.3、带Logo的生成都是对图片进行了处理的，不是使用[UIImage imageWithCIImage:outputImage]直接得到的Image（所以image.CIImage == nil），可以通过上面两句代码获取到CIImage类型的对象
     */
    if (ciimage)
    {
        CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}] options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        NSArray *resultArr = [qrDetector featuresInImage:ciimage];
        if (resultArr.count >0)
        {
            CIFeature *feature = resultArr[0];
            CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
            NSString *result = qrFeature.messageString;
            
            return result;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}



@end
