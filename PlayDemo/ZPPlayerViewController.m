//
//  MyPlayerViewController.m
//  PlayDemo
//
//  Created by HZP on 2017/5/25.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "QYPlayerController.h"
#import "ZPPlayerViewController.h"
#import "ZPVideoInfo.h"
#import "ZPVideoProgressBar.h"
#import "DCPathButton.h"
#import "ZPTools.h"
#import "MBProgressHUD.h"
#import "ZPVideoInfoView.h"
#import <objc/runtime.h>


#define KIPhone_AVPlayerRect_mwidth 320
#define KIPhone_AVPlayerRect_mheight 180

/**动画时长*/
static const NSTimeInterval kZPAnimationDuration = 0.2f;
/**
 *  按钮大小比例
 *  设置为1/6表示按钮大小为平面宽度的六分之一
 */
static const CGFloat kZPButtonSizeScale = 1.0f / 5;
/**
 *  子控件之间的间隔
 */
static const CGFloat kZPPlayerViewSubViewMargin = 5.0f;
/**进度条高度*/
static const CGFloat kProgressBarHeight = 5.0f;
/**
 *  状态弹出框的现实时长
 */
static const NSTimeInterval kHUDAppearanceDuration = 1.0f;
@interface ZPPlayerViewController () <QYPlayerControllerDelegate, ZPVideoProgressBarDelegate, DCPathButtonDelegate>
/**
 *  播放器
 */
@property (nonatomic, weak) QYPlayerController *playController;
/**
 *  全屏按钮
 */
@property (nonatomic, weak) UIButton *fullScreenBtn;
/**
 *  还原按钮
 */
@property (nonatomic, weak) UIButton *originalScreenBtn;
/**
 *  播放按钮
 */
@property (nonatomic, weak) UIButton *playBtn;
/**
 *  暂停按钮
 */
@property (nonatomic, weak) UIButton *pauseBtn;
/**
 *  进度条
 */
@property (nonatomic, weak) ZPVideoProgressBar *progressBar;
/**
 *  悬浮按钮
 */
@property (nonatomic, weak) DCPathButton *suspendBtn;
/**
 *  截图控件
 */
@property (nonatomic, weak) UIView *screenShotView;
/**
 *  显示截图
 */
@property (nonatomic, weak) UIImageView *screenShotImageView;
/*
//保存截图按钮
@property (nonatomic, weak) UIButton *saveImageButton;
//分享截图按钮
@property (nonatomic, weak) UIButton *shareImageButton;
 */
/**
 *  是否正在播放
 */
@property (nonatomic, assign, getter = isPlaying) BOOL playing;
/**
 *  是否全屏播放
 */
@property (nonatomic, assign, getter = isFullScreen) BOOL fullScreen;
/**
 *  是否静音播放
 */
@property (nonatomic, assign, getter = isMute) BOOL mute;


@end

@implementation ZPPlayerViewController

#pragma mark - Controller life cycle method
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSubView];
    [self initPlayerState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    QYPlayerController *playController = [QYPlayerController sharedInstance];
    if ([playController isPlaying]) {
        [playController stopPlayer];
    }
    [self removeSubView];
    self.playController.view.transform = CGAffineTransformIdentity;
    NSLog(@"player controller dealloc");
}

#pragma mark - Set Player State
-(void)initPlayerState {
    self.playing = YES;
    self.mute = NO;
    self.fullScreen = NO;
}

#pragma mark - Setter
/**
 *  设置播放状态
 */
-(void)setPlaying:(BOOL)playing {
    _playing = playing;
    if (playing) {
        if (!self.playController.isPlaying) {
            [self.playController play];
        }
        NSLog(@"play");
    } else {
        if (self.playController.isPlaying) {
            [self.playController pause];
        }
        NSLog(@"pause");
    }
    self.playBtn.hidden = playing;
    self.pauseBtn.hidden = !playing;
}

/**
 *  设置全屏状态
 */
-(void)setFullScreen:(BOOL)isfullScreen {
    _fullScreen = isfullScreen;
    
    //1. 设置两个按钮状态
    self.fullScreenBtn.hidden = isfullScreen;
    self.originalScreenBtn.hidden = !isfullScreen;
    
    //2.设置屏幕显示比例
    /**原始比例*/
    CGAffineTransform transform = CGAffineTransformIdentity;
    //全屏
    if (isfullScreen) {
        //1.旋转
        transform = CGAffineTransformRotate(transform, M_PI_2);
        //2.平移
        CGPoint playerCenter = self.playController.view.center;
        CGPoint screenCenter = [[[UIApplication sharedApplication] keyWindow] center];
        CGFloat tx = screenCenter.y - playerCenter.y;
        CGFloat ty = screenCenter.x - playerCenter.x;
        transform = CGAffineTransformTranslate(transform, tx, ty);
        //3.放大
        CGSize playerSize = self.playController.view.bounds.size;
        CGSize screenSize = [[[UIApplication sharedApplication] keyWindow] bounds].size;
        CGFloat scale = MIN(screenSize.width / playerSize.height, screenSize.height / playerSize.width);
        transform = CGAffineTransformScale(transform, scale, scale);
    }
    [UIView animateWithDuration:kZPAnimationDuration animations:^{
        self.playController.view.transform = transform;
    }];
}

-(void)setMute:(BOOL)mute {
    _mute = mute;
    [self.playController setMute:mute];
}

#pragma mark - Create subView
/**
 *  添加子控件
 */
-(void)createSubView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createBasePlayerController];
    [self createFullScreenBtn];
    [self creatOriginalScreenBtn];
    [self createPlayBtn];
    [self createCloseButton];
    [self createPauseBtn];
    [self createSuspendButton];
    [self createScreenShootView];
    
    
    [self createVideoInfoView];
}
/**
 *  添加播放器
 */
- (void)createBasePlayerController {
    CGRect playFrame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width/KIPhone_AVPlayerRect_mwidth*KIPhone_AVPlayerRect_mheight);
    QYPlayerController *playController = [QYPlayerController sharedInstance];
    playController.delegate = self;
    [playController setPlayerFrame:playFrame];
    
    ZPVideoInfo *videoInfo = self.videoInfo;
    [playController openPlayerByAlbumId:videoInfo.aID tvId:videoInfo.tvID isVip:videoInfo.isVip];
    [self.view addSubview:playController.view];
    self.playController = playController;
}

/**
 *  添加全屏按钮
 */
-(void)createFullScreenBtn {
    UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat fullScreenBtnW = playerSize.height * kZPButtonSizeScale;
    CGFloat fullScreenBtnH = fullScreenBtnW;
    CGFloat fullScreenBtnX = playerSize.width - fullScreenBtnW;
    CGFloat fullScreenBtnY = playerSize.height - fullScreenBtnH;
    fullScreenBtn.frame = CGRectMake(fullScreenBtnX, fullScreenBtnY, fullScreenBtnW, fullScreenBtnH);
    [fullScreenBtn addTarget:self action:@selector(showFullScreen) forControlEvents:UIControlEventTouchUpInside];
    [fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
//    [fullScreenBtn setBackgroundColor:[UIColor greenColor]];
    [self.playController.view addSubview:fullScreenBtn];
    self.fullScreenBtn = fullScreenBtn;
}
/**
 *  添加取消全屏按钮
 */
-(void)creatOriginalScreenBtn {
    UIButton *originalScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat btnW = playerSize.height * kZPButtonSizeScale;
    CGFloat btnH = btnW;
    CGFloat btnX = playerSize.width - btnW;
    CGFloat btnY = playerSize.height - btnH;
    originalScreenBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [originalScreenBtn addTarget:self action:@selector(cancelFullScreen) forControlEvents:UIControlEventTouchUpInside];
    [originalScreenBtn setTitle:@"恢复" forState:UIControlStateNormal];
//    [originalScreenBtn setBackgroundColor:[UIColor redColor]];
    originalScreenBtn.hidden = YES;
    [self.playController.view addSubview:originalScreenBtn];
    self.originalScreenBtn = originalScreenBtn;
}
/**
 *  添加播放按钮
 */
-(void)createPlayBtn {
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat btnW = playerSize.height * kZPButtonSizeScale;
    CGFloat btnH = btnW;
    CGFloat btnX = 0;
    CGFloat btnY = playerSize.height - btnH;
    playBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
//    [playBtn setBackgroundColor:[UIColor greenColor]];
    [self.playController.view addSubview:playBtn];
    self.playBtn = playBtn;
}
/**
 *  添加暂停按钮
 */
-(void)createPauseBtn {
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat btnW = playerSize.height * kZPButtonSizeScale;
    CGFloat btnH = btnW;
    CGFloat btnX = 0;
    CGFloat btnY = playerSize.height - btnH;
    pauseBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
//    [pauseBtn setBackgroundColor:[UIColor redColor]];
    [self.playController.view addSubview:pauseBtn];
    self.pauseBtn = pauseBtn;
}

-(void) createCloseButton {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat btnW = playerSize.height * kZPButtonSizeScale;
    CGFloat btnH = btnW;
    CGFloat btnX = playerSize.width - btnW;
    CGFloat btnY = 0;
    closeBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [closeBtn addTarget:self action:@selector(closePlayerView) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    //    [pauseBtn setBackgroundColor:[UIColor redColor]];
    [self.playController.view addSubview:closeBtn];

}
/**
 *  添加进度条
 */
-(void)createProgressBar {
    ZPVideoProgressBar *progressBar = [ZPVideoProgressBar videoProgressWithMaxValue:[self.playController duration] minValue:0.0f progressColor:[UIColor brownColor] bufferColor:[UIColor grayColor] backgoundColor:[UIColor whiteColor] sliderButtonColor:[UIColor greenColor]];
//    progressBar.backgroundColor = [UIColor redColor];
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat progressBarW = playerSize.width - 2 * (self.playBtn.bounds.size.width + kZPPlayerViewSubViewMargin);
    CGFloat progressBarH = self.playBtn.bounds.size.height;
    CGFloat progressBarX = self.playBtn.bounds.size.width + kZPPlayerViewSubViewMargin;
    CGFloat progressBarY = playerSize.height - progressBarH;
    progressBar.frame = CGRectMake(progressBarX, progressBarY, progressBarW, progressBarH);
    progressBar.delegate = self;

    [self.playController.view addSubview:progressBar];
    progressBar.layer.zPosition = 1;
    [self.playController.view bringSubviewToFront:progressBar];
    self.progressBar = progressBar;
}

/**
 *  添加悬浮按钮
 *  图标后期还要替换掉
 */
-(void) createSuspendButton
{
    //1.主悬浮按钮
    DCPathButton *suspendBtn = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"chooser-button-tab"] highlightedImage:[UIImage imageNamed:@"chooser-button-tab-highlighted"]];
    
    //设置位置
    CGSize playerSize = self.playController.view.bounds.size;
    CGPoint suspendBtnCenter = CGPointMake(playerSize.width - suspendBtn.bounds.size.width / 2, playerSize.height / 2);
    suspendBtn.dcButtonCenter = suspendBtnCenter;
    
    suspendBtn.bloomDirection = kDCPathButtonBloomDirectionLeft;
    suspendBtn.delegate = self;
//    suspendBtn.allowSounds = NO;
    suspendBtn.bloomRadius = 60.0f;
    suspendBtn.allowCenterButtonRotation = YES;
    suspendBtn.allowSubItemRotation = YES;
    [self.playController.view addSubview:suspendBtn];
    self.suspendBtn = suspendBtn;
    
    //2.设置子按钮
    //2.1.截屏
    DCPathItemButton *screenShootBtn = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-camera"] highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-camera-highlighted"] backgroundImage:[UIImage imageNamed:@"chooser-moment-button"] backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    DCPathItemButton *itemBtn2 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-music"] highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-music-highlighted"] backgroundImage:[UIImage imageNamed:@"chooser-moment-button"] backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    DCPathItemButton *itemBtn3 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-place"]  highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-place-highlighted"] backgroundImage:[UIImage imageNamed:@"chooser-moment-button"] backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    DCPathItemButton *itemBtn4 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-sleep"] highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-sleep-highlighted"] backgroundImage:[UIImage imageNamed:@"chooser-moment-button"] backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    DCPathItemButton *itemBtn5 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-thought"] highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-thought-highlighted"] backgroundImage:[UIImage imageNamed:@"chooser-moment-button"] backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    [suspendBtn addPathItems:@[screenShootBtn, itemBtn2, itemBtn3, itemBtn4, itemBtn5]];
}


static const CGFloat ScreenShootViewBtnWidth = 50.0f;
static const CGFloat ScreenShootViewScale = 0.2f;
-(void) createScreenShootView {
    CGSize playerViewSize = self.playController.view.bounds.size;
    
    //1.外部view
    CGFloat screenShotViewW = playerViewSize.width * ScreenShootViewScale + ScreenShootViewBtnWidth;
    CGFloat screenShotViewH = playerViewSize.height * ScreenShootViewScale;
    CGFloat screenShotViewX = 0.0;
    CGFloat screenShotViewY = 0.0;
    CGRect screenShotViewFrame = CGRectMake(screenShotViewX, screenShotViewY, screenShotViewW, screenShotViewH);
    UIView *screenShotView = [[UIView alloc]initWithFrame:screenShotViewFrame];
    screenShotView.hidden = YES;
//    screenShotView.backgroundColor = [UIColor redColor];
    [self.playController.view addSubview:screenShotView];
    self.screenShotView = screenShotView;
    
    //2.显示的imageview
    CGFloat imageViewW = playerViewSize.width * ScreenShootViewScale;
    CGFloat imageViewH = playerViewSize.height * ScreenShootViewScale;
    CGFloat imageViewX = 0.0;
    CGFloat imageViewY = 0.0;
    CGRect imageViewFrame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
    UIImageView *screenShotImageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
    [screenShotView addSubview:screenShotImageView];
    self.screenShotImageView = screenShotImageView;
    
    CGFloat btnW = ScreenShootViewBtnWidth;
    CGFloat btnH = screenShotViewH / 2;
    CGFloat btnX = imageViewW;
    CGFloat saveImageBtnY = 0;
    CGFloat shareImageBtnY = imageViewH / 2;
    
    //3.保存截图按钮
    UIButton *saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveImageBtn.frame = CGRectMake(btnX, saveImageBtnY, btnW, btnH);
    [saveImageBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveImageBtn addTarget:self action:@selector(saveScreenShotPhoto) forControlEvents:UIControlEventTouchUpInside];
    [screenShotView addSubview:saveImageBtn];
//    saveImageBtn.backgroundColor = [UIColor blueColor];
    
    //4.分享截图按钮
    UIButton *shareImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareImageBtn.frame = CGRectMake(btnX, shareImageBtnY, btnW, btnH);
    [shareImageBtn setTitle:@"分享" forState:UIControlStateNormal];
    [shareImageBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [screenShotView addSubview:shareImageBtn];
//    shareImageBtn.backgroundColor = [UIColor greenColor];
}

static const CGFloat StatuesBarHeight = 20.0f;

-(void)createVideoInfoView {
    ZPVideoInfoView *infoView = [[ZPVideoInfoView alloc]init];
    infoView.info = self.videoInfo;
//    infoView.backgroundColor = [UIColor blueColor];
    CGSize windowSize = [UIApplication sharedApplication].keyWindow.bounds.size;
    CGFloat infoViewW = windowSize.width;
    CGFloat infoViewH = windowSize.height - self.playController.view.bounds.size.height;
    CGFloat infoViewX = 0;
    CGFloat infoViewY = self.playController.view.bounds.size.height + StatuesBarHeight;
    infoView.frame = CGRectMake(infoViewX, infoViewY, infoViewW, infoViewH);
    [self.view addSubview:infoView];
    [self.view sendSubviewToBack:infoView];
}

-(void)removeSubView {
    [self.fullScreenBtn removeFromSuperview];
    [self.originalScreenBtn removeFromSuperview];
    [self.playBtn removeFromSuperview];
    [self.pauseBtn removeFromSuperview];
    [self.progressBar removeFromSuperview];
    [self.suspendBtn removeFromSuperview];
    [self.screenShotView removeFromSuperview];
    [self.screenShotImageView removeFromSuperview];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - User interative
/**
 *  关闭弹出的这个播放器
 */
-(void)closePlayerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  截屏
 */
-(void)screenShoot {
    //debug
    //查看QYPlayerController里面有什么属性
    /*
    unsigned int count = 0;
    Ivar *members = class_copyIvarList([self.playController class], &count);
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        const char *memberName = ivar_getName(var);
        const char *memberType = ivar_getTypeEncoding(var);
        //依次打印属性名称和属性类型
        NSLog(@"%s----%s", memberName, memberType);
    }
     */
    //debug
    //隐藏按钮图标等子控件
    [self hideAllSubview];
    //截图
    UIImage *screenShotImage = nil;
    screenShotImage = [ZPTools screenShotsInStream:self.playController.view];
    //恢复按钮图标等子控件
    [self 	showAllSubview];
    //保存到相册库
    //[self saveImageToPhotosAlbum:screenShotImage];
    
    self.screenShotImageView.image = screenShotImage;
    self.screenShotView.hidden = NO;
    self.screenShotView.alpha = 1.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0f animations:^{
            self.screenShotView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.screenShotView.hidden = YES;
        }];
    });
    
}

-(void)shareImage:(UIImage*)image{
    
}

-(void)saveScreenShotPhoto {
    UIImage *screenShotImage = self.screenShotImageView.image;
    [self saveImageToPhotosAlbum:screenShotImage];
}

/**
 *  将照片存到相册
 */
-(void)saveImageToPhotosAlbum:(UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
/**
 *   相册保存回调函数
 */
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *savingResultText = nil;
    if (error) {
        savingResultText = @"保存失败";
    } else {
        savingResultText = @"保存成功";
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = savingResultText;
    [hud hideAnimated:YES afterDelay:kHUDAppearanceDuration];
//    NSLog(@"%@", savingResultText);
}

/**
 *  全屏显示
 */
-(void)showFullScreen {
    NSLog(@"full screen button did click");
    if (self.isFullScreen) return;
    self.fullScreen = YES;
}

/**
 *  取消全屏显示
 */
-(void)cancelFullScreen {
    NSLog(@"cancel full screen button did click");
    if (!self.isFullScreen) return;
    self.fullScreen = NO;
}
/**
 *  播放
 */
-(void)play {
    NSLog(@"play button did click");
    if (self.isPlaying) return;
    self.playing = YES;
}
/**
 *  暂停
 */
-(void)pause {
    NSLog(@"pause button did click");
    if (!self.isPlaying) return;
    self.playing = NO;
}

/**
 *  静音
 */
-(void)muteSound {
    NSLog(@"mute button did click");
    if (self.isMute) return;
    self.mute = YES;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"静音";
    [hud hideAnimated:YES afterDelay:kHUDAppearanceDuration];
}
/**
 *  取消静音
 */
-(void)cancelMute {
    NSLog(@"cancel mute button did click");
    if (!self.isMute) return;
    self.mute = NO;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"取消静音";
    [hud hideAnimated:YES afterDelay:kHUDAppearanceDuration];

}

-(void) clickMuteButton {
    if (self.isMute) {
        [self cancelMute];
    } else {
        [self muteSound];
    }
}
#pragma mark - Other method
static bool kIsFullScreen;
/**
 *  隐藏所有子控件
 */
-(void)hideAllSubview {
    kIsFullScreen = self.fullScreenBtn.isHidden;
    self.fullScreenBtn.hidden = YES;
    self.originalScreenBtn.hidden = YES;
    self.playBtn.hidden = YES;
    self.pauseBtn.hidden = YES;
    self.progressBar.hidden = YES;
    self.suspendBtn.hidden = YES;
}
/**
 *  显示所有子控件
 */
-(void)showAllSubview {
    if (kIsFullScreen) {
        self.fullScreenBtn.hidden = YES;
        self.originalScreenBtn.hidden = NO;
    } else {
        self.fullScreenBtn.hidden = NO;
        self.originalScreenBtn.hidden = YES;
    }
    //根据播放器播放状态显示播放
    if (self.playController.isPlaying) {
        self.playBtn.hidden = YES;
        self.pauseBtn.hidden = NO;
    } else {
        self.playBtn.hidden = NO;
        self.pauseBtn.hidden = YES;
    }
    self.progressBar.hidden = NO;
    self.suspendBtn.hidden = NO;
}

#pragma mark - QYPlayerControllerDelegate

-(void)onContentStartPlay:(QYPlayerController *)player {
    [self createProgressBar];
}

-(void)playbackTimeChanged:(QYPlayerController *)player {
    NSLog(@"buffval = %f, curVal = %f", player.playableDuration, player.currentPlaybackTime);
    [self.progressBar setBufferValue:player.playableDuration];
    if (!self.progressBar.isDraging) {
        [self.progressBar setProgressValue:player.currentPlaybackTime];
    }
    //[self.progressBar setBufferrValue:player.playableDuration];
}

#pragma mark - ZPVideoProgressBarDelegate
-(void)videoProgressEndSlidingWithValue:(id)value {
    [self.playController seekToTime:[value doubleValue]];
}


#pragma mark - DCPathButtomDelegate
- (void)pathButton:(DCPathButton *)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
    switch (itemButtonIndex) {
        case 0:
            NSLog(@"screen shoot button did click");
            [self screenShoot];
            break;
        case 1:
            NSLog(@"set mute button did click");
            [self clickMuteButton];
            break;
    }
}

@end
//-(void)pathButton:(DCPathButton*)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {

//}
