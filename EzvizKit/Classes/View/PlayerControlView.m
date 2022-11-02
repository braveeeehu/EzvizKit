//
//  PlayerControlView.m
//  flutter_plugin_ezviz
//
//  Created by JIAO on 2020/10/9.
//

#import "PlayerControlView.h"
#import "UIImage+RCImage.h"

#import <Masonry/Masonry.h>

@interface PlayerControlView()
@property(nonatomic,strong)UIButton *centerBtn;
@end


@implementation PlayerControlView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UIView *zoomIn = [self createSubViewWithImageName:@"hik_video_max" title:@"放大" type:PlayerControlTypeZoomIn];
        [self addSubview:zoomIn];

        [zoomIn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo( self.mas_left);
            make.width.mas_equalTo(self.mas_width).multipliedBy(0.5);
            make.top.mas_equalTo(self.mas_top);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.3);
        }];
        
        UIView *zoomOut = [self createSubViewWithImageName:@"hik_video_min" title:@"缩小" type:PlayerControlTypeZoomOut]; 
        [self addSubview:zoomOut];
        [zoomOut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(zoomIn.mas_right);
            make.width.mas_equalTo(self.mas_width).multipliedBy(0.5);
            make.top.mas_equalTo(self.mas_top);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.3);
        }];
        
        
        [self createDirectControlView];
        
    }
    return self;
}

- (void)createDirectControlView{
    UIView *bgView = [[UIView alloc]init];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.left.bottom.equalTo(self);
        make.height.mas_equalTo(self.mas_height).multipliedBy(0.7);
    }];
    UIView *backgroundView = [[UIView alloc] init];
    [backgroundView setContentMode:UIViewContentModeScaleAspectFit];
    [backgroundView setUserInteractionEnabled:YES];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    [bgView addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bgView);
        make.height.width.mas_equalTo(bgView.mas_width).multipliedBy(0.8);
    }];
    
    float rate   = 1.6f;
    float whrate = 30.f/69.f;
    float margin = 10.f;
    
    //上按钮
    UIButton *up     = [self directButton:PlayerControlTypeUp];
    UIButton *down   = [self directButton:PlayerControlTypeDown];
    UIButton *left   = [self directButton:PlayerControlTypeLeft];
    UIButton *right  = [self directButton:PlayerControlTypeRight];
    UIButton *center = [self centerButton];
_centerBtn = center;
    [backgroundView addSubview:up];
    [backgroundView addSubview:down];
    [backgroundView addSubview:left];
    [backgroundView addSubview:right];
    [backgroundView addSubview:center];
    
    
    [up mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(backgroundView.mas_centerX);
        make.width.mas_equalTo(backgroundView.mas_width).multipliedBy(1.f/rate);
        make.height.mas_equalTo(backgroundView.mas_height).multipliedBy(whrate/rate);
        make.top.mas_equalTo(backgroundView.mas_top).mas_offset(margin);
    }];
    
    [down mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(backgroundView.mas_centerX);
        make.width.mas_equalTo(backgroundView.mas_width).multipliedBy(1.f/rate);
        make.height.mas_equalTo(backgroundView.mas_height).multipliedBy(whrate/rate);
        
        make.bottom.mas_equalTo(backgroundView.mas_bottom).mas_offset(-margin);
    }];
    
    [left mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backgroundView.mas_left).mas_offset(margin);
        make.height.mas_equalTo(backgroundView.mas_height).multipliedBy(1.f/rate);
        make.width.mas_equalTo(backgroundView.mas_width).multipliedBy(whrate/rate);
        make.centerY.mas_equalTo(backgroundView.mas_centerY);
    }];
    
    [right mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(backgroundView.mas_right).mas_offset(-margin);
        make.height.mas_equalTo(backgroundView.mas_height).multipliedBy(1.f/rate);
        make.width.mas_equalTo(backgroundView.mas_width).multipliedBy(whrate/rate);
        make.centerY.mas_equalTo(backgroundView.mas_centerY);
    }];
    
    [center mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(backgroundView);
        make.width.height.mas_equalTo(backgroundView.mas_width).multipliedBy(0.4);
//        make.height.mas_equalTo(backgroundView.mas_height).multipliedBy(0.4);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [_centerBtn.layer setCornerRadius:self.frame.size.width*0.8*0.4/2.f];
    [_centerBtn.layer setMasksToBounds:YES];
}

- (UIButton *)centerButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage rcImageNamed:@"ptz_pause.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage rcImageNamed:@"ptz_play.png"] forState:UIControlStateSelected];
    [button setBackgroundColor:[UIColor colorWithRed:60.f/255.f green:65.f/255.f blue:69.f/255.f alpha:1]];
    [button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


- (UIButton *)directButton:(PlayerControlType)direction{
    NSString *imageName = nil;
    NSString *hightImageName = nil;
    switch (direction) {
        case PlayerControlTypeUp:
            imageName = @"ptz_ctrl_up";
            hightImageName = @"ptz_ctrl_up_sel";
            break;
        case PlayerControlTypeDown:
            imageName = @"ptz_ctrl_down";
            hightImageName = @"ptz_ctrl_down_sel";
            break;
        case PlayerControlTypeLeft:
            imageName = @"ptz_ctrl_left";
            hightImageName = @"ptz_ctrl_left_sel";
            break;
        case PlayerControlTypeRight:
            imageName = @"ptz_ctrl_right";
            hightImageName = @"ptz_ctrl_right_sel";
            break;
        default:
            break;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage rcImageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage rcImageNamed:hightImageName] forState:UIControlStateHighlighted];
    button.tag = direction;
    [button addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:direction];
    return button;
}


- (UIView *)createSubViewWithImageName:(NSString *)imageName title:(NSString *)title type:(PlayerControlType )type{
    UIButton *bgView = [UIButton buttonWithType:UIButtonTypeCustom];
    bgView.tag = type;
    [bgView addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchDown];
    [bgView addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];

    
    UIImageView *imgView = [[UIImageView alloc]init];
    imgView.image = [UIImage rcImageNamed:imageName];
    [bgView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bgView);
        make.height.width.mas_equalTo(30);
    }];
    
    UILabel *titleLb = [[UILabel alloc]init];
    titleLb.font = [UIFont systemFontOfSize:16];
    titleLb.textColor = [UIColor whiteColor];
    titleLb.textAlignment = NSTextAlignmentCenter;
    titleLb.text = title;
    [bgView addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bgView);
        make.height.mas_equalTo(20);
        make.top.equalTo(imgView.mas_bottom).offset(5);
    }];
    return  bgView;
    
}

- (void)startAction:(UIButton *)btn{
    if(_delegate && [_delegate respondsToSelector:@selector(playerControlView:action:start:)]) {
        [_delegate playerControlView:self action:(PlayerControlType)btn.tag start:YES];
    }
}

- (void)stopAction:(UIButton *)btn{
    if(_delegate && [_delegate respondsToSelector:@selector(playerControlView:action:start:)]) {
        [_delegate playerControlView:self action:(PlayerControlType)btn.tag start:NO];
    }
}

- (void)playAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    if(_delegate && [_delegate respondsToSelector:@selector(playerControlView:play:)]) {
        [_delegate playerControlView:self play:btn];
    }
}
@end
