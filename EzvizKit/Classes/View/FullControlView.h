//
//  FullControlView.h
//  flutter_plugin_ezviz
//
//  Created by hujiao on 2021/10/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FullControlViewDelegate <NSObject>

- (void)playAction:(UIButton *)sender;
- (void)captureAction:(UIButton *)sender ;
- (void)ptzAction:(UIButton *)sender ;
- (void)videoAction:(UIButton *)sender;
- (void)muteAction:(UIButton *)sender ;
@end


@interface FullControlView : UIView
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *ptzBtn;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property(nonatomic,weak)id<FullControlViewDelegate>  delegate;

- (void)enable: (bool)e;

@end

NS_ASSUME_NONNULL_END
