//
//  HikPlayerViewController.h
//  flutter_plugin_ezviz
//
//  Created by JIAO on 2020/10/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HikPlayerViewController : UIViewController

@property(nonatomic,copy)NSString *deviceSerial;
@property(nonatomic,assign)NSInteger cameraNo;

@property(nonatomic,copy)NSString *verifyCode;

@end

NS_ASSUME_NONNULL_END
