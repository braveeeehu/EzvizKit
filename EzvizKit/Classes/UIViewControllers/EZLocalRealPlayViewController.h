//
//  EZLocalRealPlayViewController.h
//  EZOpenSDKDemo
//
//  Created by linyong on 2017/8/16.
//  Copyright © 2017年 Ezviz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZHCNetDeviceInfo;

@interface EZLocalRealPlayViewController : UIViewController

@property (nonatomic,strong) EZHCNetDeviceInfo *deviceInfo;
@property (nonatomic,assign) NSInteger cameraNo;//通道号


@end
