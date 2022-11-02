//
//  UIImage+RCImage.m
//  智能监管
//
//  Created by shaoshun liu on 2020/7/22.
//

#import "UIImage+RCImage.h"
@implementation UIImage (RCImage)

//改变图片颜色

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f); //宽高 1.0只要有值就够了
    UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);//在这段上下文中获取到颜色UIColor
    CGContextFillRect(context, rect);//用这个颜色填充这个上下文
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)rcImageNamed:(NSString *)name {
//    return [self imageNamed:name];
    return [self imageNamed:name inBundle:[NSBundle bundleForClass:NSClassFromString(@"FlutterPluginEzvizPlugin")] compatibleWithTraitCollection:nil];
}
@end
