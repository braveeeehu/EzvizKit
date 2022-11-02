//
//  EZLivePlayViewController.h
//  EZOpenSDKDemo
//
//  Created by DeJohn Dong on 15/10/28.
//  Copyright © 2015年 Ezviz. All rights reserved.
//

#import <UIKit/UIKit.h>


#if !TARGET_IPHONE_SIMULATOR

#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#endif

@interface EZLivePlayViewController : UIViewController

#if !TARGET_IPHONE_SIMULATOR

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) EZDeviceInfo *deviceInfo;
@property(nonatomic,copy)NSString *deviceSerial;
@property(nonatomic,copy)NSString *verifyCode;
@property (nonatomic) NSInteger cameraNo;


- (void)imageSavedToPhotosAlbum:(UIImage *)image
       didFinishSavingWithError:(NSError *)error
                    contextInfo:(void *)contextInfo;
#endif

@end



