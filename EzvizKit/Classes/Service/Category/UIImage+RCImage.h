//
//  UIImage+RCImage.h
//  智能监管
//
//  Created by shaoshun liu on 2020/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (RCImage)
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)rcImageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
