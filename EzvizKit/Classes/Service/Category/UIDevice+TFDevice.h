//
//  UIDevice+TFDevice.h
//  LPCam
//
//  Created by zhaoguo on 2019/6/19.
//  Copyright © 2019 zhaoguo. All rights reserved.
//

#ifndef UIDevice_TFDevice_h
#define UIDevice_TFDevice_h

#import <UIKit/UIKit.h>
@interface UIDevice (TFDevice)
/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

#endif /* UIDevice_TFDevice_h */
