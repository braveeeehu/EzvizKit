//
//  HikPlayerViewController.m
//  flutter_plugin_ezviz
//
//  Created by JIAO on 2020/10/9.
//

#import "HikPlayerViewController.h"
#import "UIDevice+TFDevice.h"
#import "UIImage+RCImage.h"
#import "PlayerControlView.h"
//#import "RCMeasure.h"
#import "EZLivePlayViewController.h"
#import <Masonry/Masonry.h>

#if !TARGET_IPHONE_SIMULATOR

#import <EZOpenSDKFramework/EZOpenSDKFramework.h>


@interface HikPlayerViewController ()<PlayerControlViewDelegate,EZPlayerDelegate>
@property (nonatomic, strong) EZPlayer *player;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIView *playerBgView;
@property (nonatomic,strong)PlayerControlView         *controlView;
@property (nonatomic,strong)UIButton         *fullScreenBtn;
@property (strong, nonatomic) UIActivityIndicatorView     *indicatorView;

@end

@implementation HikPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];



    [self.view setBackgroundColor:[UIColor colorWithRed:27.f/255.f green:29.f/255.f blue:31.f/255.f alpha:1.f]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:26.f/255.f green:28.f/255.f blue:30.f/255.f alpha:1.f];
    [self setupCustomNavigationBar];
    [self.view addSubview:self.controlView];
    [self.view addSubview:self.playerBgView];
    if (UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[UIDevice currentDevice].orientation)) {
        [self.navigationController.navigationBar setHidden:YES];
        [self update2Landscape];
    }else{
        [self.navigationController.navigationBar setHidden:NO];
        [self update2Portait];
    }
    _player = [[EZOpenSDK class] createPlayerWithDeviceSerial:self.deviceSerial cameraNo:self.cameraNo];
    _player.delegate = self;
    [_player setPlayVerifyCode:self.verifyCode];
    [_player setPlayerView:self.playerView];
    [_player startRealPlay];
    [self.playerView bringSubviewToFront:_fullScreenBtn];
}
- (void)setupCustomNavigationBar{

    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage rcImageNamed:@"hik_back"] forState:UIControlStateNormal];
    [back setBackgroundColor:[UIColor clearColor]];
    [back addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    [back setFrame:CGRectMake(0, 0, 44, 44)];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backItem;
}
- (void)pop:(id)sender{
    NSLog(@"点击_返回");
    [_player destoryPlayer];
    [self dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }];
}
- (void)update2Landscape{
    [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(0);
        make.left.mas_equalTo(self.view.mas_left);
    }];
    [self.playerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [_fullScreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.playerView.mas_right).mas_offset(-5);
        make.bottom.mas_equalTo(self.playerView.mas_bottom).mas_offset(-8);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
    }];
}

- (void)update2Portait{
    [self.playerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(self.view.mas_top);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_width).multipliedBy(480.f/720.f);
    }];
    [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.playerView.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    [_fullScreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.playerView.mas_right).mas_offset(-5);
        make.bottom.mas_equalTo(self.playerView.mas_bottom).mas_offset(-8);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
    }];
}

- (void)fullScreenAction{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [self startFullScreen];
    }else{
        [self endFullScreen];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [UIView animateWithDuration:duration animations:^{
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            [self.navigationController.navigationBar setHidden:NO];
        }else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
            [self.navigationController.navigationBar setHidden:YES];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
                [self update2Portait];
            }else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
                [self update2Landscape];
            }
        }
    }];
}


-(void)startFullScreen
{
    [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];

}
-(void)endFullScreen
{
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];

}

#pragma mark -EZPlayerDelegate
- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error {
    NSLog(@"error...%@",error);
}


- (void)player:(EZPlayer *)player didReceivedMessage:(NSInteger)messageCode {
    //    PLAYER_REALPLAY_START = 1,        //直播开始
    //    PLAYER_VIDEOLEVEL_CHANGE = 2,     //直播流清晰度切换中
    //    PLAYER_STREAM_RECONNECT = 3,
    if(messageCode == PLAYER_REALPLAY_START) {
        [self.indicatorView stopAnimating];
    }else if (messageCode == PLAYER_VIDEOLEVEL_CHANGE || messageCode == PLAYER_STREAM_RECONNECT) {
        [self.indicatorView startAnimating];
    }
}

#pragma mark -PlayerControlViewDelegate
- (void)playerControlView:(PlayerControlView *)view action:(PlayerControlType)type start:(BOOL)start {

        [[EZOpenSDK class] controlPTZ:self.deviceSerial
                     cameraNo:self.cameraNo
                      command:[self commandFromType:type]
                       action:start?EZPTZActionStart:EZPTZActionStop
                        speed:1.0
                       result:^(NSError *error) {
            NSLog(@"error..%@",error);
        }];

}

- (void)playerControlView:(PlayerControlView *)view play:(UIButton *)btn {
    if(btn.selected) {
        [self.player stopRealPlay];
    }else {
        [self.indicatorView startAnimating];
        [self.player startRealPlay];
    }
}


- (EZPTZCommand)commandFromType:(PlayerControlType)type{
    switch (type) {
        case PlayerControlTypeUp:
            return EZPTZCommandUp;
        case PlayerControlTypeDown:
            return EZPTZCommandDown;
        case PlayerControlTypeLeft:
            return EZPTZCommandLeft;
        case PlayerControlTypeRight:
            return EZPTZCommandRight;
        case PlayerControlTypeZoomIn:
            return EZPTZCommandZoomIn;
        case PlayerControlTypeZoomOut:
            return EZPTZCommandZoomOut;

        default:
            return EZPTZCommandLeft;
            break;
    }
}
#pragma mark lazy load
-(UIView *)controlView {
    if(!_controlView) {
        _controlView = [[PlayerControlView alloc] init];
        _controlView.delegate = self;
        _controlView.backgroundColor = [UIColor blackColor];
    }
    return _controlView;
}

- (UIView *)playerBgView {
    if(!_playerBgView) {

        _playerBgView = [[UIView alloc]init];

        _playerView = [[UIView alloc]init];
        _playerView.backgroundColor = [UIColor blackColor];
        [_playerBgView addSubview:_playerView];
        [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_playerBgView);
        }];

        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_playerBgView addSubview:_indicatorView];
        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_playerBgView);
        }];
        [_indicatorView hidesWhenStopped];
        [_indicatorView startAnimating];

        UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [fullScreenBtn setBackgroundColor:[UIColor clearColor]];
        [fullScreenBtn setImage:[UIImage rcImageNamed:@"hik_video_fullscreen"] forState:UIControlStateNormal];
        [fullScreenBtn addTarget:self action:@selector(fullScreenAction) forControlEvents:UIControlEventTouchUpInside];
        [_playerBgView addSubview:fullScreenBtn];
        _fullScreenBtn = fullScreenBtn;

    }
    return _playerBgView;
}

@end



#endif
