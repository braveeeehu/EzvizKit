//
//  EZLivePlayViewController.m
//  EZOpenSDKDemo
//
//  Created by DeJohn Dong on 15/10/28.
//  Copyright © 2015年 Ezviz. All rights reserved.
//

#if !TARGET_IPHONE_SIMULATOR

#import <sys/sysctl.h>
#import <mach/mach.h>
#import <Photos/Photos.h>
#import "EZLivePlayViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "Toast+UIView.h"
#import <Masonry/Masonry.h>
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import <EZOpenSDKFramework/EZStreamPlayer.h>
#import "UIButton+DDKit.h"
#import "UIView+DDKit.h"
#import "UIImage+RCImage.h"
#import "MBProgressHUD.h"
#import "FullControlView.h"
#import "UIButton+ImageTitlePosition.h"
#define MinimumZoomScale 1.0
#define MaximumZoomScale 4.0


@interface EZLivePlayViewController ()<EZPlayerDelegate, UIAlertViewDelegate,EZStreamPlayerDelegate,UIScrollViewDelegate,FullControlViewDelegate>
{
    NSOperation *op;
    BOOL _isPressed;
}

@property (nonatomic) BOOL isOpenSound;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic) NSTimeInterval seconds;
@property (nonatomic, strong) CALayer *orangeLayer;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) EZPlayer *player;
@property (nonatomic, strong) EZPlayer *talkPlayer;
@property (nonatomic, strong) EZStreamPlayer *streamPlayer;
@property (nonatomic) BOOL isStartingTalk;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, weak) IBOutlet UIButton *playerPlayButton;
@property (nonatomic, weak) IBOutlet UIView *playerView;
@property (nonatomic, weak) IBOutlet UIView *toolBar;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UIButton *controlButton;
@property (nonatomic, weak) IBOutlet UIButton *talkButton;
@property (nonatomic, weak) IBOutlet UIButton *captureButton;
@property (nonatomic, weak) IBOutlet UIButton *localRecordButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *streamPlayBtn;
@property (nonatomic, weak) IBOutlet UIButton *voiceButton;
@property (nonatomic, weak) IBOutlet UIButton *qualityButton;
@property (nonatomic, weak) IBOutlet UIButton *emptyButton;
@property (nonatomic, weak) IBOutlet UIButton *largeButton;
@property (nonatomic, weak) IBOutlet UIButton *largeBackButton;
@property (nonatomic, weak) IBOutlet UIView *ptzView;
@property (nonatomic, weak) IBOutlet UIButton *ptzCloseButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzControlButton;
@property (nonatomic, weak) IBOutlet UIView *qualityView;
@property (nonatomic, weak) IBOutlet UIButton *highButton;
@property (nonatomic, weak) IBOutlet UIButton *middleButton;
@property (nonatomic, weak) IBOutlet UIButton *lowButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzUpButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzLeftButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzDownButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzRightButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ptzViewContraint;
@property (nonatomic, weak) IBOutlet UILabel *localRecordLabel;
@property (nonatomic, weak) IBOutlet UIView *talkView;
@property (nonatomic, weak) IBOutlet UIButton *talkCloseButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *talkViewContraint;
@property (nonatomic, weak) IBOutlet UIImageView *speakImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *localRecrodContraint;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *cloudTip;
@property (weak, nonatomic) IBOutlet UIButton *cloudBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentHDStatus;
@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, weak) MBProgressHUD *voiceHud;
@property (nonatomic, strong) EZCameraInfo *cameraInfo;
@property (weak, nonatomic) IBOutlet UILabel *streamTypeLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *zoomSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *zoomInBtn;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutBtn;
@property (weak, nonatomic) IBOutlet UIView *controllBgView;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

@property (weak, nonatomic) IBOutlet UIImageView *downTwinkle;
@property (weak, nonatomic) IBOutlet UIImageView *rightTwinkle;
@property (weak, nonatomic) IBOutlet UIImageView *upTwinkle;
@property (weak, nonatomic) IBOutlet UIImageView *leftTwinkle;

@property(nonatomic,strong) FullControlView *controlView;

@property (weak, nonatomic) IBOutlet UIView *fullPtzView;
@end

@implementation EZLivePlayViewController

- (void)dealloc
{
    NSLog(@"%@ dealloc", self.class);
    [EZOpenSDK releasePlayer:_player];
    [EZOpenSDK releasePlayer:_talkPlayer];
}

- (void)setupCustomNavigationBar{
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage rcImageNamed:@"large_back_btn"] forState:UIControlStateNormal];
    [back setBackgroundColor:[UIColor clearColor]];
    [back addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    [back setFrame:CGRectMake(0, 0, 44, 44)];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backItem;
}
- (void)pop:(id)sender{
    NSLog(@"点击_返回");
    [EZOpenSDK releasePlayer:_player];
    [EZOpenSDK releasePlayer:_talkPlayer];
    [self dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.isAutorotate = YES;
    [self setupCustomNavigationBar];
    self.view.backgroundColor = [UIColor blackColor];
    self.isStartingTalk = NO;
    self.ptzView.hidden = YES;
    self.talkView.hidden = YES;
    [EZOpenSDK initLibWithAppKey:@""];
    self.talkButton.enabled = self.deviceInfo.isSupportTalk;
    self.controlButton.enabled = self.deviceInfo.isSupportPTZ;
    self.captureButton.enabled = NO;
    self.localRecordButton.enabled = NO;
    
    self.controllBgView.layer.cornerRadius = 120;
    self.controllBgView.layer.masksToBounds = true;
    
    [self.recordBtn setImage:[[UIImage imageNamed:@"video"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [self.zoomInBtn setImagePosition:KSImagePositionTop spacing:4];
    [self.zoomOutBtn setImagePosition:KSImagePositionTop spacing:4];
    [self.recordBtn setImagePosition:KSImagePositionTop spacing:0];
    [self.talkButton setImagePosition:KSImagePositionTop spacing:0];
    [self.captureButton setImagePosition:KSImagePositionTop spacing:0];
    if (_url)
    {
        _player = [EZOpenSDK createPlayerWithUrl:_url];
    }
    else if([self.deviceInfo.deviceType containsString:@"CAS"]) //hub
    {
        //        _cameraInfo = [[EZCameraInfo alloc]init]; //兼容demo之前的业务逻辑，手动填充了cameraInfo，实际开发直接传入序列号和通道号生成EZPlayer即可
        //        _cameraInfo.deviceSerial = _hubCoDevSerial;
        //        _cameraInfo.cameraNo = _cameraNo;
        _player = [EZOpenSDK createPlayerWithDeviceSerial:_cameraInfo.deviceSerial cameraNo:_cameraInfo.cameraNo];
    }
    else
    {
        for (EZCameraInfo *info in self.deviceInfo.cameraInfo) {
            if(info.cameraNo == _cameraNo) {
                _cameraInfo = info;
                break;
            }
        }
        if(!_cameraInfo) {
            [UIView dd_showMessage:@"未找到相关设备"];
        }else {
            _player = [EZOpenSDK createPlayerWithDeviceSerial:_cameraInfo.deviceSerial cameraNo:_cameraNo];
            [_player setPlayVerifyCode:self.verifyCode];
            [_player setPlayerView:_playerView];
            [_player startRealPlay];
            //        _player = [EZOpenSDK createPlayerWithUrl:@"ezopen://INJTII@open.ys7.com/E67570906/1.hd.live"];
            _talkPlayer = [EZOpenSDK createPlayerWithDeviceSerial:_cameraInfo.deviceSerial cameraNo:_cameraNo];
            if (_cameraInfo.videoLevel == 2)
            {
                [self.qualityButton setTitle: @"高清" forState:UIControlStateNormal];
            }
            else if (_cameraInfo.videoLevel == 1)
            {
                [self.qualityButton setTitle: @"均衡" forState:UIControlStateNormal];
            }
            else
            {
                [self.qualityButton setTitle:@"流畅" forState:UIControlStateNormal];
            }
        }
    }
    if (_cameraInfo.cameraNo == 0 || [self.deviceInfo.deviceType containsString:@"CAS"]) { //不支持清晰度切换
        self.qualityButton.hidden = YES;
    }
    
    self.title = _deviceInfo.deviceName;

    [self hidenWatchFunc];
    
    //#if DEBUG
    //    if (!_url)
    //    {
    //        //抓图接口演示代码
    //        [EZOpenSDK captureCamera:_cameraInfo.deviceSerial cameraNo:_cameraInfo.cameraNo completion:^(NSString *url, NSError *error) {
    //            NSLog(@"[%@] capture cameraNo is [%d] url is %@, error is %@", _cameraInfo.deviceSerial, (int)_cameraInfo.cameraNo, url, error);
    //        }];
    //    }
    //#endif
    
    _player.delegate = self;
    _talkPlayer.delegate = self;
    //判断设备是否加密，加密就从demo的内存中获取设备验证码填入到播放器的验证码接口里，本demo只处理内存存储，本地持久化存储用户自行完成
    //    if (self.deviceInfo.isEncrypt)
    //    {
    //        NSString *verifyCode = [[GlobalKit shareKit].deviceVerifyCodeBySerial objectForKey:self.deviceInfo.deviceSerial];
    //        [_player setPlayVerifyCode:verifyCode];
    //        [_talkPlayer setPlayVerifyCode:verifyCode];
    //    }
    [_player setPlayerView:_playerView];
    _controlView = [[NSBundle bundleForClass:NSClassFromString(@"FlutterPluginEzvizPlugin")] loadNibNamed:NSStringFromClass([FullControlView class]) owner:self options:nil].firstObject;
    _controlView.delegate = self;
    _controlView.hidden = true;
    [_playerView addSubview:_controlView];
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(_playerView);
        make.height.mas_equalTo(90);
    }];
    
    BOOL hdStatus = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"EZVideoPlayHardDecodingStatus_%@", self.deviceInfo.deviceSerial]];
    [_player setHDPriority:hdStatus];
    [_player startRealPlay];
    
    if(!_loadingView){
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView.hidesWhenStopped = YES;
    }
    [self.view insertSubview:_loadingView aboveSubview:self.playerView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@14);
        make.centerX.mas_equalTo(self.playerView.mas_centerX);
        make.centerY.mas_equalTo(self.playerView.mas_centerY);
    }];
    [self.loadingView startAnimating];
    
    self.largeBackButton.hidden = YES;
    _isOpenSound = NO;
    [_player closeSound];
    
    [self.controlButton dd_centerImageAndTitle];
    [self.talkButton dd_centerImageAndTitle];
    [self.captureButton dd_centerImageAndTitle];
    [self.localRecordButton dd_centerImageAndTitle];
    
    [self.voiceButton setImage:[UIImage rcImageNamed:@"preview_unvoice_btn_sel"] forState:UIControlStateHighlighted];
    [self addLine];
    
    self.localRecordLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.localRecordLabel.layer.cornerRadius = 12.0f;
    self.localRecordLabel.layer.borderWidth = 1.0f;
    self.localRecordLabel.clipsToBounds = YES;
    self.playButton.enabled = NO;
    
    
    self.scrollView.minimumZoomScale = MinimumZoomScale;
    self.scrollView.maximumZoomScale = MaximumZoomScale;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.pagingEnabled = NO;
    
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:26.f/255.f green:28.f/255.f blue:30.f/255.f alpha:1.f];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.ptzViewContraint.constant = self.bottomView.frame.size.height;
    self.talkViewContraint.constant = self.ptzViewContraint.constant;
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideQualityView) object:nil];
    //结束本地录像
    if(self.localRecordButton.selected)
    {
        [_player stopLocalRecordExt:^(BOOL ret) {
            
            NSLog(@"%d", ret);
            
            [_recordTimer invalidate];
            _recordTimer = nil;
            self.localRecordLabel.hidden = YES;
            [self saveRecordToPhotosAlbum:_filePath];
            _filePath = nil;
        }];
    }
    
    NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    [super viewDidDisappear:animated];
    [_player stopRealPlay];
    if (_talkPlayer)
    {
        [_talkPlayer stopVoiceTalk];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void) hidenWatchFunc {
    
    if ([self.deviceInfo.category isEqualToString:@"KW1"]) {
        self.qualityButton.alpha = 0.5;
        self.cloudBtn.alpha = 0.5;
        self.talkButton.alpha = 0.5;
        self.controlButton.alpha = 0.5;
        self.cloudTip.alpha = 0.5;
        
        self.qualityButton.userInteractionEnabled = NO;
        self.cloudBtn.userInteractionEnabled = NO;
        self.talkButton.userInteractionEnabled = NO;
        self.controlButton.userInteractionEnabled = NO;
        self.cloudTip.userInteractionEnabled = NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    self.navigationController.navigationBarHidden = NO;
    self.toolBar.hidden = NO;
    self.largeBackButton.hidden = YES;
    self.bottomView.hidden = NO;
    self.localRecrodContraint.constant = 10;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
       toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.navigationController.navigationBarHidden = YES;
        self.localRecrodContraint.constant = 50;
        self.toolBar.hidden = YES;
        self.largeBackButton.hidden = NO;
        self.bottomView.hidden = YES;
    }
}

- (IBAction)pressed:(id)sender {
    
}

#pragma mark -----FullControlViewDelegate
- (void)playAction:(UIButton *)sender {
    [self playButtonClicked:nil];
}

- (void)muteAction:(UIButton *)sender {
    [self voiceButtonClicked:nil];
}

- (void)captureAction:(UIButton *)sender {
    [self capture:nil];
}

-(void)videoAction:(UIButton *)sender {
    [self localButtonClicked:nil];
}

-(void)ptzAction:(UIButton *)sender {
    _fullPtzView.hidden = !sender.selected;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.alertViewStyle == UIAlertViewStyleSecureTextInput)
    {
        if (buttonIndex == 1)
        {
            NSString *checkCode = [alertView textFieldAtIndex:0].text;
            if (!self.isStartingTalk)
            {
                [self.player setPlayVerifyCode:checkCode];
                [self.player startRealPlay];
            }
            else
            {
                [self.talkPlayer setPlayVerifyCode:checkCode];
                [self.talkPlayer startVoiceTalk];
            }
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            [self showSetPassword];
            return;
        }
    }
}

#pragma mark - PlayerDelegate Methods
//该方法废弃于v4.8.8版本，底层库不再支持。请使用getStreamFlow方法
- (void)player:(EZPlayer *)player didReceivedDataLength:(NSInteger)dataLength
{
    CGFloat value = dataLength/1024.0;
    NSString *fromatStr = @"%.1f KB/s";
    if (value > 1024)
    {
        value = value/1024;
        fromatStr = @"%.1f MB/s";
    }
    
    [_emptyButton setTitle:[NSString stringWithFormat:fromatStr,value] forState:UIControlStateNormal];
}


- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error
{
    NSLog(@"player: %@, didPlayFailed: %@", player, error);
    //如果是需要验证码或者是验证码错误
    if (error.code == EZ_SDK_NEED_VALIDATECODE) {
        [self showSetPassword];
        return;
    } else if (error.code == EZ_SDK_VALIDATECODE_NOT_MATCH) {
        [self showRetry];
        return;
    } else if (error.code == EZ_SDK_NOT_SUPPORT_TALK) {
        [UIView dd_showDetailMessage:[NSString stringWithFormat:@"播放失败 %d", (int)error.code]];
        [self.voiceHud hide:YES];
        return;
    }
    else
    {
        if ([player isEqual:_player])
        {
            [_player stopRealPlay];
        }
        else
        {
            [_talkPlayer stopVoiceTalk];
        }
    }
    
    [UIView dd_showDetailMessage:[NSString stringWithFormat:@"播放失败 %d", (int)error.code]];
    [self.voiceHud hide:YES];
    [self.loadingView stopAnimating];
    self.messageLabel.text = [NSString stringWithFormat:@"%@(%d)", @"播放失败", (int)error.code];
    //    if (error.code > 370000)
    {
        self.messageLabel.hidden = NO;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
        self.speakImageView.alpha = 0.0;
        self.talkViewContraint.constant = self.bottomView.frame.size.height;
        [self.bottomView setNeedsUpdateConstraints];
        [self.bottomView layoutIfNeeded];
    }
                     completion:^(BOOL finished) {
        self.speakImageView.alpha = 0;
        self.talkView.hidden = YES;
    }];
}

- (void)player:(EZPlayer *)player didReceivedMessage:(NSInteger)messageCode
{
    NSLog(@"player: %@, didReceivedMessage: %d", player, (int)messageCode);
    if (messageCode == PLAYER_REALPLAY_START)
    {
        self.captureButton.enabled = YES;
        self.localRecordButton.enabled = YES;
        NSLog(@"%i",self.deviceInfo.isSupportZoom);
        self.zoomInBtn.enabled = self.deviceInfo.isSupportZoom;
        self.zoomOutBtn.enabled = self.deviceInfo.isSupportZoom;
        [self.loadingView stopAnimating];
        self.playButton.enabled = YES;
        [self.playButton setImage:[UIImage rcImageNamed:@"preview_stopplay_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage rcImageNamed:@"preview_stopplay_btn"] forState:UIControlStateNormal];
        _isPlaying = YES;
        
        if (!_isOpenSound)
        {
            [_player closeSound];
        }
        self.messageLabel.hidden = YES;
        
        //        switch ([self.player getHDPriorityStatus]) {
        //
        //            case 1:
        //                self.currentHDStatus.hidden = NO;
        //                self.currentHDStatus.text = @"当前解码状态: 软解码";
        //                break;
        //            case 2:
        //                self.currentHDStatus.hidden = NO;
        //                self.currentHDStatus.text = @"当前解码状态: 硬解码";
        //                break;
        //            default:
        //                break;
        //        }
        
        //        [self showStreamFetchType];
        
        NSLog(@"GetInnerPlayerPort:%d", [self.player getInnerPlayerPort]);
        NSLog(@"GetStreamFetchType:%d", [self.player getStreamFetchType]);
    }
    else if(messageCode == PLAYER_VOICE_TALK_START)
    {
        self.messageLabel.hidden = YES;
        [_player closeSound];
        //        [_talkPlayer changeTalkingRouteMode:NO];
        self.isStartingTalk = NO;
        [self.voiceHud hide:YES];
        [self.bottomView bringSubviewToFront:self.talkView];
        self.talkView.hidden = NO;
        self.speakImageView.alpha = 0;
        self.speakImageView.highlighted = self.deviceInfo.isSupportTalk == 1;
        self.speakImageView.userInteractionEnabled = self.deviceInfo.isSupportTalk == 3;
        [UIView animateWithDuration:0.3
                         animations:^{
            self.talkViewContraint.constant = 0;
            self.speakImageView.alpha = 1.0;
            [self.bottomView setNeedsUpdateConstraints];
            [self.bottomView layoutIfNeeded];
        }
                         completion:^(BOOL finished) {
        }];
    }
    else if (messageCode == PLAYER_VOICE_TALK_END)
    {
        //对讲结束开启声音
        if (_isOpenSound) {
            [_player openSound];
        }
    }
    else if (messageCode == PLAYER_NET_CHANGED)
    {
        [_player stopRealPlay];
        [_player startRealPlay];
    }
}

#pragma mark - ValidateCode Methods

- (void)showSetPassword
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入视频图片加密密码"
                                                        message: @"您的视频已加密，请输入密码进行查看，初始密码为机身标签上的验证码，如果没有验证码，请输入ABCDEF（密码区分大小写)"
                                                       delegate:self
                                              cancelButtonTitle: @"取消"
                                              otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView show];
}

- (void)showRetry
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"温馨提示"
                                                        message: @"设备密码错误"
                                                       delegate:self
                                              cancelButtonTitle: @"取消"
                                              otherButtonTitles:@"重试", nil];
    [alertView show];
}

- (void) showStreamFetchType
{
    int type = [self.player getStreamFetchType];
    
    if (type >= 0)
    {
        self.streamTypeLabel.hidden = NO;
        switch (type) {
            case 0:
                self.streamTypeLabel.text = @"取流方式：流媒体";
                break;
            case 1:
                self.streamTypeLabel.text = @"取流方式：P2P";
                break;
            case 2:
                self.streamTypeLabel.text = @"取流方式：内网直连";
                break;
            case 3:
                self.streamTypeLabel.text = @"取流方式：外网直连";
                break;
            case 8:
                self.streamTypeLabel.text = @"取流方式：反向直连";
                break;
            case 9:
                self.streamTypeLabel.text = @"取流方式：NetSDK";
                break;
            default:
                self.streamTypeLabel.text = @"取流方式：unknown";
                break;
        }
    }
}

#pragma mark - Action Methods

- (IBAction)ptzStop:(UIButton *)sender {
    
    EZPTZCommand command;
    if(sender.tag == 333)
    {
        command = EZPTZCommandLeft;
    }
    else if (sender.tag == 222)
    {
        command = EZPTZCommandDown;
    }
    else if (sender.tag == 444)
    {
        command = EZPTZCommandRight;
    }
    else {
        command = EZPTZCommandUp;
    }
    [EZOpenSDK controlPTZ:_cameraInfo.deviceSerial
                 cameraNo:_cameraInfo.cameraNo
                  command:command
                   action:EZPTZActionStop
                    speed:1
                   result:^(NSError *error) {
        NSLog(@"error is %@", error);
        self.leftTwinkle.hidden = true;
        self.upTwinkle.hidden = true;
        self.downTwinkle.hidden = true;
        self.rightTwinkle.hidden = true;
    }];
    
}
- (IBAction)ptzStart:(UIButton *)sender {
    
    EZPTZCommand command;
    UIView *view;
    if(sender.tag == 333)
    {
        command = EZPTZCommandLeft;
        view = self.leftTwinkle;
    }
    else if (sender.tag == 222)
    {
        command = EZPTZCommandDown;
        view = self.downTwinkle;
    }
    else if (sender.tag == 444)
    {
        command = EZPTZCommandRight;
        view = self.rightTwinkle;
    }
    else {
        command = EZPTZCommandUp;
        view = self.upTwinkle;
    }
    [EZOpenSDK controlPTZ:_cameraInfo.deviceSerial
                 cameraNo:_cameraInfo.cameraNo
                  command:command
                   action:EZPTZActionStart
                    speed:1
                   result:^(NSError *error) {
        NSLog(@"error is %@", error);
        if(!error) {
            view.hidden = false;
        }
        
    }];
}
- (IBAction)zoomInStopAction:(id)sender {
    [EZOpenSDK controlPTZ:_cameraInfo.deviceSerial
                 cameraNo:_cameraInfo.cameraNo
                  command:EZPTZCommandZoomIn
                   action:EZPTZActionStop
                    speed:1
                   result:^(NSError *error) {
        NSLog(@"error is %@", error);
    }];
}
- (IBAction)zoomOutStopAction:(id)sender {
    [EZOpenSDK controlPTZ:_cameraInfo.deviceSerial
                 cameraNo:_cameraInfo.cameraNo
                  command:EZPTZCommandZoomOut
                   action:EZPTZActionStop
                    speed:1
                   result:^(NSError *error) {
        NSLog(@"error is %@", error);
    }];
}
- (IBAction)zoomInAction:(id)sender {
    [EZOpenSDK controlPTZ:_cameraInfo.deviceSerial
                 cameraNo:_cameraInfo.cameraNo
                  command:EZPTZCommandZoomIn
                   action:EZPTZActionStart
                    speed:1
                   result:^(NSError *error) {
        NSLog(@"error is %@", error);
    }];
    
}
- (IBAction)zoomOutAction:(id)sender {
    [EZOpenSDK controlPTZ:_cameraInfo.deviceSerial
                 cameraNo:_cameraInfo.cameraNo
                  command:EZPTZCommandZoomOut
                   action:EZPTZActionStart
                    speed:1
                   result:^(NSError *error) {
        NSLog(@"error is %@", error);
    }];
}



- (IBAction)large:(id)sender
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _controlView.hidden = false;
    [_playerView bringSubviewToFront:_controlView];
}

- (IBAction)largeBack:(id)sender
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.scrollView);
        make.width.mas_equalTo(_playerView.mas_height).multipliedBy(16.0/9);
    }];
    _controlView.hidden = true;
    _fullPtzView.hidden = true;
    _controlView.ptzBtn.selected = false;
}

- (IBAction)capture:(id)sender
{
    UIImage *image = [_player capturePicture:100];
    [self saveImageToPhotosAlbum:image];
}

- (IBAction)talkButtonClicked:(id)sender
{
    if (self.deviceInfo.isSupportTalk != 1 && self.deviceInfo.isSupportTalk != 3)
    {
        [self.view makeToast: @"设备不支持对讲"
                    duration:1.5
                    position:@"center"];
        return;
    }
    
    __weak EZLivePlayViewController *weakSelf = self;
    [self checkMicPermissionResult:^(BOOL enable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (enable)
            {
                if (!weakSelf.voiceHud) {
                    weakSelf.voiceHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                weakSelf.voiceHud.labelText =  @"正在开启对讲，请稍候...";
                weakSelf.isStartingTalk = YES;
                
                [weakSelf.talkPlayer setPlayVerifyCode:self.verifyCode];
                
                [weakSelf.talkPlayer startVoiceTalk];
            }
            else
            {
                [weakSelf.view makeToast: @"未开启麦克风权限"
                                duration:1.5
                                position:@"center"];
            }
        });
    }];
    
    
    
}

- (IBAction)voiceButtonClicked:(id)sender
{
    if(_isOpenSound){
        [_player closeSound];
        [self.voiceButton setImage:[UIImage rcImageNamed:@"preview_unvoice_btn_sel"] forState:UIControlStateHighlighted];
        [self.voiceButton setImage:[UIImage rcImageNamed:@"preview_unvoice_btn"] forState:UIControlStateNormal];
    }
    else
    {
        [_player openSound];
        [self.voiceButton setImage:[UIImage rcImageNamed:@"preview_voice_btn_sel"] forState:UIControlStateHighlighted];
        [self.voiceButton setImage:[UIImage rcImageNamed:@"preview_voice_btn"] forState:UIControlStateNormal];
    }
    _isOpenSound = !_isOpenSound;
    self.controlView.muteBtn.selected = _isOpenSound;
}

- (IBAction)playButtonClicked:(id)sender
{
    if(_isPlaying)
    {
        [_player stopRealPlay];
        [_playerView setBackgroundColor:[UIColor blackColor]];
        [self.playButton setImage:[UIImage rcImageNamed:@"preview_play_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage rcImageNamed:@"preview_play_btn"] forState:UIControlStateNormal];
        self.localRecordButton.enabled = NO;
        self.captureButton.enabled = NO;
        self.playerPlayButton.hidden = NO;
        self.zoomInBtn.enabled = NO;
        self.zoomOutBtn.enabled = NO;
    }
    else
    {
        [_player startRealPlay];
        self.playerPlayButton.hidden = YES;
        [self.playButton setImage:[UIImage rcImageNamed:@"preview_stopplay_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage rcImageNamed:@"preview_stopplay_btn"] forState:UIControlStateNormal];
        [self.loadingView startAnimating];
    }
    _isPlaying = !_isPlaying;

    self.controlView.playBtn.selected = !_isPlaying;
    [self.controlView enable:_isPlaying];
}

- (IBAction)qualityButtonClicked:(id)sender
{
    if(self.qualityButton.selected)
    {
        self.qualityView.hidden = YES;
    }
    else
    {
        self.qualityView.hidden = NO;
        //停留5s以后隐藏视频质量View.
        [self performSelector:@selector(hideQualityView) withObject:nil afterDelay:5.0f];
    }
    self.qualityButton.selected = !self.qualityButton.selected;
}

- (void)hideQualityView
{
    self.qualityButton.selected = NO;
    self.qualityView.hidden = YES;
}

- (IBAction)qualitySelectedClicked:(id)sender
{
    
    [self closeTalkView:nil];
    
    BOOL result = NO;
    EZVideoLevelType type = EZVideoLevelLow;
    if (sender == self.highButton)
    {
        type = EZVideoLevelHigh;
    }
    else if (sender == self.middleButton)
    {
        type = EZVideoLevelMiddle;
    }
    else
    {
        type = EZVideoLevelLow;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [EZOpenSDK setVideoLevel:_cameraInfo.deviceSerial
                    cameraNo:_cameraInfo.cameraNo
                  videoLevel:type
                  completion:^(NSError *error) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if (error)
        {
            [self.view makeToast:[NSString stringWithFormat:@"%@", error.description]];
            return;
        }
        [weakSelf.player stopRealPlay];
        
        _cameraInfo.videoLevel = type;
        if (sender == weakSelf.highButton)
        {
            [weakSelf.qualityButton setTitle: @"高清" forState:UIControlStateNormal];
        }
        else if (sender == weakSelf.middleButton)
        {
            [weakSelf.qualityButton setTitle: @"均衡" forState:UIControlStateNormal];
        }
        else
        {
            [weakSelf.qualityButton setTitle: @"流畅" forState:UIControlStateNormal];
        }
        if (result)
        {
            [weakSelf.loadingView startAnimating];
        }
        weakSelf.qualityView.hidden = YES;
        [weakSelf.player startRealPlay];
    }];
}

- (IBAction)ptzControlButtonTouchDown:(id)sender
{
    EZPTZCommand command;
    NSString *imageName = nil;
    if(sender == self.ptzLeftButton)
    {
        command = EZPTZCommandLeft;
        imageName = @"ptz_left_sel";
    }
    else if (sender == self.ptzDownButton)
    {
        command = EZPTZCommandDown;
        imageName = @"ptz_bottom_sel";
    }
    else if (sender == self.ptzRightButton)
    {
        command = EZPTZCommandRight;
        imageName = @"ptz_right_sel";
    }
    else {
        command = EZPTZCommandUp;
        imageName = @"ptz_up_sel";
    }
    [self.ptzControlButton setImage:[UIImage rcImageNamed:imageName] forState:UIControlStateDisabled];
    EZCameraInfo *cameraInfo = [_deviceInfo.cameraInfo firstObject];
    [EZOpenSDK controlPTZ:cameraInfo.deviceSerial
                 cameraNo:cameraInfo.cameraNo
                  command:command
                   action:EZPTZActionStart
                    speed:2
                   result:^(NSError *error) {
        NSLog(@"error is %@", error);
    }];
}

- (IBAction)ptzControlButtonTouchUpInside:(id)sender
{
    EZPTZCommand command;
    if(sender == self.ptzLeftButton)
    {
        command = EZPTZCommandLeft;
    }
    else if (sender == self.ptzDownButton)
    {
        command = EZPTZCommandDown;
    }
    else if (sender == self.ptzRightButton)
    {
        command = EZPTZCommandRight;
    }
    else {
        command = EZPTZCommandUp;
    }
    [self.ptzControlButton setImage:[UIImage rcImageNamed:@"ptz_bg"] forState:UIControlStateDisabled];
    EZCameraInfo *cameraInfo = [_deviceInfo.cameraInfo firstObject];
    [EZOpenSDK controlPTZ:cameraInfo.deviceSerial
                 cameraNo:cameraInfo.cameraNo
                  command:command
                   action:EZPTZActionStop
                    speed:3.0
                   result:^(NSError *error) {
    }];
}

- (IBAction)ptzViewShow:(id)sender
{
    self.ptzView.hidden = NO;
    [self.bottomView bringSubviewToFront:self.ptzView];
    self.ptzControlButton.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
        self.ptzViewContraint.constant = 0;
        self.ptzControlButton.alpha = 1.0;
        [self.bottomView setNeedsUpdateConstraints];
        [self.bottomView layoutIfNeeded];
    }
                     completion:^(BOOL finished) {
    }];
}

- (IBAction)closePtzView:(id)sender
{
    [UIView animateWithDuration:0.3
                     animations:^{
        self.ptzControlButton.alpha = 0.0;
        self.ptzViewContraint.constant = self.bottomView.frame.size.height;
        [self.bottomView setNeedsUpdateConstraints];
        [self.bottomView layoutIfNeeded];
    }
                     completion:^(BOOL finished) {
        self.ptzControlButton.alpha = 0;
        self.ptzView.hidden = YES;
    }];
}

- (IBAction)closeTalkView:(id)sender
{
    [_talkPlayer stopVoiceTalk];
    [UIView animateWithDuration:0.3
                     animations:^{
        self.speakImageView.alpha = 0.0;
        self.talkViewContraint.constant = self.bottomView.frame.size.height;
        [self.bottomView setNeedsUpdateConstraints];
        [self.bottomView layoutIfNeeded];
    }
                     completion:^(BOOL finished) {
        self.speakImageView.alpha = 0;
        self.talkView.hidden = YES;
    }];
}

- (IBAction)localButtonClicked:(id)sender
{
    //结束本地录像

    if(self.localRecordButton.selected || self.controlView.videoBtn.selected)
    {
        [_player stopLocalRecordExt:^(BOOL ret) {
            
            NSLog(@"%d", ret);
            //
            [_recordTimer invalidate];
            _recordTimer = nil;
            self.localRecordLabel.hidden = YES;
            [self saveRecordToPhotosAlbum:_filePath];
            _filePath = nil;
        }];
    }
    else
    {
        //开始本地录像
        NSString *path = @"/OpenSDK/EzvizLocalRecord";
        
        NSArray * docdirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * docdir = [docdirs objectAtIndex:0];
        
        NSString * configFilePath = [docdir stringByAppendingPathComponent:path];
        if(![[NSFileManager defaultManager] fileExistsAtPath:configFilePath]){
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:configFilePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
        }
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        dateformatter.dateFormat = @"yyyyMMddHHmmssSSS";
        _filePath = [NSString stringWithFormat:@"%@/%@.mp4",configFilePath,[dateformatter stringFromDate:[NSDate date]]];
        
        self.localRecordLabel.text = @"  00:00";
        
        if (!_recordTimer)
        {
            _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
        }
        
        [_player startLocalRecordWithPathExt:_filePath];
        
        self.localRecordLabel.hidden = NO;
        _seconds = 0;
    }
    self.localRecordButton.selected = !(self.localRecordButton.selected || self.controlView.videoBtn.selected);
    self.controlView.videoBtn.selected = self.localRecordButton.selected;
}

- (IBAction)clickCloudBtn:(id)sender {
    
    [EZOpenSDK openCloudPage:self.deviceInfo.deviceSerial channelNo:_cameraInfo.cameraNo];
}

- (void)timerStart:(NSTimer *)timer
{
    NSInteger currentTime = ++_seconds;
    self.localRecordLabel.text = [NSString stringWithFormat:@"  %02d:%02d", (int)currentTime/60, (int)currentTime % 60];
    if (!_orangeLayer)
    {
        _orangeLayer = [CALayer layer];
        _orangeLayer.frame = CGRectMake(10.0, 8.0, 8.0, 8.0);
        _orangeLayer.cornerRadius = 4.0f;
    }
    if(currentTime % 2 == 0)
    {
        [_orangeLayer removeFromSuperlayer];
    }
    else
    {
        [self.localRecordLabel.layer addSublayer:_orangeLayer];
    }
}

- (IBAction)talkPressed:(id)sender
{
    if (!_isPressed)
    {
        self.speakImageView.highlighted = YES;
        [self.talkPlayer audioTalkPressed:YES];
    }
    else
    {
        self.speakImageView.highlighted = NO;
        [self.talkPlayer audioTalkPressed:NO];
    }
    _isPressed = !_isPressed;
}

#pragma mark - Private Methods

- (void) checkMicPermissionResult:(void(^)(BOOL enable)) retCb
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (authStatus)
    {
        case AVAuthorizationStatusNotDetermined://未决
        {
            AVAudioSession *avSession = [AVAudioSession sharedInstance];
            [avSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted)
                {
                    if (retCb)
                    {
                        retCb(YES);
                    }
                }
                else
                {
                    if (retCb)
                    {
                        retCb(NO);
                    }
                }
            }];
        }
            break;
            
        case AVAuthorizationStatusRestricted://未授权，家长限制
        case AVAuthorizationStatusDenied://未授权
            if (retCb)
            {
                retCb(NO);
            }
            break;
            
        case AVAuthorizationStatusAuthorized://已授权
            if (retCb)
            {
                retCb(YES);
            }
            break;
            
        default:
            if (retCb)
            {
                retCb(NO);
            }
            break;
    }
}

- (void)saveImageToPhotosAlbum:(UIImage *)savedImage
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized)
            {
                UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
            }
        }];
    }
    else
    {
        if (status == PHAuthorizationStatusAuthorized)
        {
            UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
        }
    }
}

- (void)saveRecordToPhotosAlbum:(NSString *)path
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized)
            {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
            }
        }];
    }
    else
    {
        if (status == PHAuthorizationStatusAuthorized)
        {
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
        }
    }
}

// 指定回调方法
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = nil;
    if (!error) {
        message = @"已保存至手机相册";
    }
    else
    {
        message = [error description];
    }
    [UIView dd_showMessage:message];
}

- (void)addLine
{
    for (UIView *view in self.toolBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]])
        {
            [view removeFromSuperview];
        }
    }
    CGFloat averageWidth = [UIScreen mainScreen].bounds.size.width/5.0;
    UIImageView *lineImageView1 = [UIView dd_instanceVerticalLine:20 color:[UIColor grayColor]];
    lineImageView1.frame = CGRectMake(averageWidth, 7, lineImageView1.frame.size.width, lineImageView1.frame.size.height);
    [self.toolBar addSubview:lineImageView1];
    UIImageView *lineImageView2 = [UIView dd_instanceVerticalLine:20 color:[UIColor grayColor]];
    lineImageView2.frame = CGRectMake(averageWidth * 2, 7, lineImageView2.frame.size.width, lineImageView2.frame.size.height);
    [self.toolBar addSubview:lineImageView2];
    UIImageView *lineImageView3 = [UIView dd_instanceVerticalLine:20 color:[UIColor grayColor]];
    lineImageView3.frame = CGRectMake(averageWidth * 3, 7, lineImageView3.frame.size.width, lineImageView3.frame.size.height);
    [self.toolBar addSubview:lineImageView3];
    UIImageView *lineImageView4 = [UIView dd_instanceVerticalLine:20 color:[UIColor grayColor]];
    lineImageView4.frame = CGRectMake(averageWidth * 4, 7, lineImageView4.frame.size.width, lineImageView4.frame.size.height);
    [self.toolBar addSubview:lineImageView4];
}


#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.playerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    if (scrollView.zoomScale > 1.0f)
    {
        self.zoomSizeLabel.text = [NSString stringWithFormat:@"%0.1fX", scrollView.zoomScale];
        self.zoomSizeLabel.hidden = NO;
        return;
    }
    
    self.zoomSizeLabel.hidden = YES;
}

#pragma mark - Stream Player

- (IBAction)clickStreamBtn:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        self.streamPlayer = [EZStreamPlayer createPlayerWithDeviceSerial:self.deviceInfo.deviceSerial cameraNo:self.cameraInfo.cameraNo];
        self.streamPlayer.delegate = self;
        
        [self.streamPlayer setVerifyCode:self.verifyCode];
        [self.streamPlayer startRealPlay];
    }
    else {
        [self.streamPlayer stopRealPlay];
        [self.streamPlayer destoryPlayer];
        self.streamPlayer = nil;
    }
}

- (void)streamPlayer:(EZStreamPlayer *)player didPlayFailed:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.streamPlayBtn.selected = NO;
        [self.navigationController.view makeToast:[NSString stringWithFormat:@"ErrorCode:%ld", (long)error.code]];
    });
    
    [self.streamPlayer stopRealPlay];
    [self.streamPlayer destoryPlayer];
    self.streamPlayer = nil;
}

- (void)streamPlayer:(EZStreamPlayer *)player didReceivedMessage:(EZStreamPlayerMsgType)msgType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *msg;
        switch (msgType) {
            case EZStreamPlayerMsgTypeRealPlayStart:
                msg = @"开启预览成功";
                break;
            case EZStreamPlayerMsgTypeRealPlayClose:
                msg = @"关闭预览成功";
                break;
            case EZStreamPlayerMsgTypePlayBackStart:
                msg = @"开启设备回放成功";
                break;
            case EZStreamPlayerMsgTypePlayBackClose:
                msg = @"关闭设备回放成功";
                break;
            default:
                break;
        }
        [self.navigationController.view makeToast:msg];
    });
}

- (void)streamPlayer:(EZStreamPlayer *)player didReceivedData:(EZStreamDataType)dataType data:(int8_t *)data length:(int)dataLength
{
    if (dataType == EZStreamDataTypeHeader) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController.view makeToast:@"开始写入文件"];
        });
    }
    else if (dataType == EZStreamDataTypeStreamEnd)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.streamPlayBtn.selected = NO;
        });
        
        [self.streamPlayer stopDevicePlayback];
        [self.streamPlayer destoryPlayer];
        self.streamPlayer = nil;
    }
}

@end

#endif
