//
//  FullControlView.m
//  flutter_plugin_ezviz
//
//  Created by hujiao on 2021/10/21.
//

#import "FullControlView.h"

@interface FullControlView()

@end

@implementation FullControlView

- (IBAction)playAction:(UIButton *)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(playAction:)] ) {
        [_delegate playAction:sender];
        sender.selected = !sender.selected;
        
    }
    
}
- (IBAction)captureAction:(UIButton *)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(captureAction:)] ) {
        [_delegate captureAction:sender];
    }
    
}
- (IBAction)ptzAction:(UIButton *)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(ptzAction:)] ) {
        sender.selected = !sender.selected;
        [_delegate ptzAction:sender];
    }
    
    
}
- (IBAction)videoAction:(UIButton *)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(videoAction:)] ) {
        [_delegate videoAction:sender];
    }
}

- (IBAction)muteAction:(UIButton *)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(muteAction:)] ) {
        [_delegate muteAction:sender];
        sender.selected = !sender.selected;
    }
    
}

- (void)enable: (bool)e{
    _ptzBtn.enabled = e;
    _muteBtn.enabled = e;
//    _playBtn.enabled = e;
    _videoBtn.enabled = e;
    _captureBtn.enabled = e;
    
}
@end
