//
//  PlayerControlView.h
//  flutter_plugin_ezviz
//
//  Created by JIAO on 2020/10/9.
//

#import <UIKit/UIKit.h>
//#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum{
    PlayerControlTypeZoomIn = 0xff,
    PlayerControlTypeZoomOut,
    PlayerControlTypeLeft,
    PlayerControlTypeRight,
    PlayerControlTypeUp,
    PlayerControlTypeDown,
    PlayerControlTypeCenter,
    
} PlayerControlType;
@class PlayerControlView;
@protocol PlayerControlViewDelegate <NSObject>

- (void)playerControlView:(PlayerControlView *)view action:(PlayerControlType)type start:(BOOL)start;

- (void)playerControlView:(PlayerControlView *)view play:(UIButton *)btn;

//- (void)playerControlView:(PlayerControlView *)view StopAction:(PlayerControlType)type;
@end

@interface PlayerControlView : UIView

@property(nonatomic,weak)id<PlayerControlViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
