#import "NGMoviePlayerView.h"
#import "NGVolumeControl.h"
#import "NGMoviePlayerLayerView.h"
#import "NGMoviePlayerControlView.h"
#import "NGMoviePlayerControlView+NGPrivate.h"
#import "NGMoviePlayerPlaceholderView.h"
#import "NGMoviePlayerControlActionDelegate.h"
#import "NGMoviePlayerVideoGravity.h"
#import "NGScrubber.h"
#import "NGVideoTableView.h"
#import "NGMoviePlayerFunctions.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


#define kIndicatorFadeTimn 0.15
#define kSpeedUpFadeTime 0.25

#define kNGControlVisibilityDuration        5.
#define kMinVolumeChangeLength 10
#define kMinVideoChangeLength 20
#define kMaxTimeInterVal (1*60) // 1 minutes


static char playerLayerReadyForDisplayContext;


@interface NGMoviePlayerView () <UIGestureRecognizerDelegate> {
    BOOL _statusBarVisible;
    UIStatusBarStyle _statusBarStyle;
    BOOL _shouldHideControls;
    float _preTimer;
}

@property (nonatomic, strong, readwrite) NGMoviePlayerControlView *controlsView;  // re-defined as read/write
@property (nonatomic, strong) NGMoviePlayerLayerView *playerLayerView;
@property (nonatomic, strong) UIWindow *externalWindow;
@property (nonatomic, strong) UIView *externalScreenPlaceholder;
@property (nonatomic, strong) UIView *videoOverlaySuperview;

@property (nonatomic, copy) NSString *deviceOutputType;
@property (nonatomic, copy) NSString *airplayDeviceName;


@property (nonatomic, assign) CGPoint initialTouchLocation;
@property (nonatomic, assign) CGPoint previousTouchLocation;
@property (nonatomic, assign) NGPanDirection panDirection;

@property (nonatomic, readonly, getter = isAirPlayVideoActive) BOOL airPlayVideoActive;


@end


@implementation NGMoviePlayerView
@synthesize videoName = _videoName;
@dynamic playerLayer;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];

        [self setup];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame name:(NSString *)name{
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        _videoName = name;
        [self setup];
    }
    
    return self;
    
}


- (void)dealloc {
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[_playerLayerView layer];

    [_placeholderView removeFromSuperview];
    [_playerLayerView removeFromSuperview];
    [playerLayer removeFromSuperlayer];
    [playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];

    [_externalScreenPlaceholder removeFromSuperview];
    [_videoOverlaySuperview removeFromSuperview];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutControls) object:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject KVO
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &playerLayerReadyForDisplayContext) {
        BOOL readyForDisplay = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];

        if (self.playerLayerView.layer.opacity == 0.f && readyForDisplay) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];

            animation.duration = kNGFadeDuration;
            animation.fromValue = [NSNumber numberWithFloat:0.];
            animation.toValue = [NSNumber numberWithFloat:1.];
            animation.removedOnCompletion = NO;

            self.playerLayerView.layer.opacity = 1.f;
            [self.playerLayerView.layer addAnimation:animation forKey:nil];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) {
        [self.playerLayer.player pause];
    }

    [super willMoveToSuperview:newSuperview];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        [self.playerLayer.player pause];
    }

    [super willMoveToWindow:newWindow];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGMoviePlayerView Properties
////////////////////////////////////////////////////////////////////////

- (void)setDelegate:(id<NGMoviePlayerControlActionDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
    }

    self.controlsView.delegate = delegate;
}

- (void)setControlsVisible:(BOOL)controlsVisible {
    [self setControlsVisible:controlsVisible animated:NO];
}

- (void)speedUpTimeByUserShow:(BOOL)show{
    float curTime = self.controlsView.scrubberControl.value;
    BOOL value =  curTime>_preTimer?YES:FALSE;
    
    self.speedView.timeLabel.text = NGMoviePlayerGetTimeFormatted((NSTimeInterval)curTime);;
    self.speedView.speedUp = value;
    self.activityView.alpha = 0.0f;
    self.speedView.center = self.center;
    
    _preTimer = curTime;
    
    if (show) {
        [self bringSubviewToFront:self.speedView];
        if (self.speedView.alpha != 0.0f) {
            return;
        }
        [UIView animateWithDuration:kSpeedUpFadeTime animations:^(void){self.speedView.alpha = 0.8f;}];

    }else{
        [self sendSubviewToBack:self.speedView];
        if (self.speedView.alpha == 0.0f) {
            return;
        }
        [UIView animateWithDuration:kSpeedUpFadeTime animations:^(void){self.speedView.alpha = 0.0f;}];
    }
    
    
}

- (void)activityViewShow:(BOOL)value{
    
    if (self.speedView.alpha != 0.0f) {
        return;
    }
    
    if (value) {
        [self bringSubviewToFront:self.activityView];
//        [self.controlsView updateButtonsWithPlayBufferEnable:NO];
        self.activityView.center = self.center;
        NSLog(@"center x:%0.1f y:%0.1f",self.center.x,self.center.y);
        if (self.activityView.alpha != 0.0f) {
            return;
        }
        [UIView animateWithDuration:kIndicatorFadeTimn animations:^(void){self.activityView.alpha = 0.8f;}];
    }else{
        [self sendSubviewToBack:self.activityView];
//        [self.controlsView updateButtonsWithPlayBufferEnable:YES];
        if (self.activityView.alpha == 0.0f) {
            return;
        }
        [UIView animateWithDuration:kIndicatorFadeTimn animations:^(void){self.activityView.alpha = 0.0f;}];
    }
  
    
}

- (void)setVideoName:(NSString *)videoName{
    if (_videoName == videoName) return;
    _videoName = videoName;
    _controlsView.videoTitle.text = _videoName;
    ((NGMoviePlayerPlaceholderView *)_placeholderView).infoText = _videoName;
}

- (void)setControlsVisible:(BOOL)controlsVisible animated:(BOOL)animated {
    
    
    if (controlsVisible) {
        [self bringSubviewToFront:self.controlsView];
    } else {
        [self.controlsView.volumeControl setExpanded:NO animated:YES];
    }

    if (controlsVisible != _controlsVisible) {
        _controlsVisible = controlsVisible;

        NSTimeInterval duration = animated ? kNGFadeDuration : 0.;
        NGMoviePlayerControlAction willAction = controlsVisible ? NGMoviePlayerControlActionWillShowControls : NGMoviePlayerControlActionWillHideControls;
        NGMoviePlayerControlAction didAction = controlsVisible ? NGMoviePlayerControlActionDidShowControls : NGMoviePlayerControlActionDidHideControls;

        [self.delegate moviePlayerControl:self.controlsView didPerformAction:willAction];

        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutControls) object:nil];
        // Doesn't work on device (doesn't fade but jumps from alpha 0 to 1) -> currently deactivated
        // rasterization fades out the view as a whole instead of setting alpha on each subview
        // it's similar to setting UIViewGroupOpacity, but only for this particular view
        // self.controlsView.scrubberControl.layer.shouldRasterize = YES;
        // self.controlsView.scrubberControl.layer.rasterizationScale = [UIScreen mainScreen].scale;

        [UIView animateWithDuration:duration
                              delay:0.
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.controlsView.alpha = controlsVisible ? 1.f : 0.f;
                         } completion:^(BOOL finished) {
                             [self restartFadeOutControlsViewTimer];
                             [self.delegate moviePlayerControl:self.controlsView didPerformAction:didAction];

                             //self.controlsView.scrubberControl.layer.shouldRasterize = NO;
                         }];

        if (self.controlStyle == NGMoviePlayerControlStyleFullscreen) {
            if (animated) {
                [[UIApplication sharedApplication] setStatusBarHidden:(!controlsVisible) withAnimation:UIStatusBarAnimationFade];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:(!controlsVisible) withAnimation:UIStatusBarAnimationNone];
            }
        }
    }
}

- (void)setPlaceholderView:(UIView *)placeholderView {
    if (placeholderView != _placeholderView) {
        [_placeholderView removeFromSuperview];
        _placeholderView = placeholderView;
        _placeholderView.frame = self.bounds;
        _placeholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_placeholderView];
    }
}

- (void)hidePlaceholderViewAnimated:(BOOL)animated {
    self.backgroundColor = [UIColor blackColor];

    if (animated) {
        [UIView animateWithDuration:kNGFadeDuration
                         animations:^{
                             self.placeholderView.alpha = 0.f;
                         } completion:^(BOOL finished) {
                             [self.placeholderView removeFromSuperview];
                         }];
    } else {
        [self.placeholderView removeFromSuperview];
    }
}

- (void)showPlaceholderViewAnimated:(BOOL)animated {
    if ([self.placeholderView isKindOfClass:[NGMoviePlayerPlaceholderView class]]) {
        NGMoviePlayerPlaceholderView *placeholderView = (NGMoviePlayerPlaceholderView *)self.placeholderView;
        placeholderView.frame = self.bounds;
        if (self.controlStyle == NGMoviePlayerControlStyleInline) {
             placeholderView.backBtn.hidden = YES;
        }else if(self.controlStyle == NGMoviePlayerControlStyleFullscreen){
             placeholderView.backBtn.hidden = NO;
        }
       
        [placeholderView resetToInitialState];
    }

    if (animated) {
        self.placeholderView.alpha = 0.f;
        [self addSubview:self.placeholderView];
        [UIView animateWithDuration:kNGFadeDuration
                         animations:^{
                             self.placeholderView.alpha = 1.f;
                         }];
    } else {
        self.placeholderView.alpha = 1.f;
        [self addSubview:self.placeholderView];
    }
}

- (void)setControlStyle:(NGMoviePlayerControlStyle)controlStyle {
    if (controlStyle != self.controlsView.controlStyle) {
        self.controlsView.controlStyle = controlStyle;
        [self.controlsView updateButtonsWithPlaybackStatus:self.playerLayer.player.rate > 0.f];

        BOOL isIPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;

        // hide status bar in fullscreen, restore to previous state
        if (controlStyle == NGMoviePlayerControlStyleFullscreen) {
            [[UIApplication sharedApplication] setStatusBarStyle: (isIPad ? UIStatusBarStyleBlackOpaque : UIStatusBarStyleBlackTranslucent)];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle];
            [[UIApplication sharedApplication] setStatusBarHidden:!_statusBarVisible withAnimation:UIStatusBarAnimationFade];
        }
    }

    self.controlsVisible = NO;
}

- (NGMoviePlayerControlStyle)controlStyle {
    return self.controlsView.controlStyle;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)[self.playerLayerView layer];
}

- (NGMoviePlayerScreenState)screenState {
    if (self.externalWindow != nil) {
        return NGMoviePlayerScreenStateExternal;
    } else if (self.airPlayVideoActive) {
        return NGMoviePlayerScreenStateAirPlay;
    } else {
        return NGMoviePlayerScreenStateDevice;
    }
}

- (UIView *)externalScreenPlaceholder {
    if(_externalScreenPlaceholder == nil) {
        BOOL isIPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;

        _externalScreenPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/playerBackground"]];
        _externalScreenPlaceholder.userInteractionEnabled = YES;
        _externalScreenPlaceholder.frame = self.bounds;
        _externalScreenPlaceholder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        UIView *externalScreenPlaceholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, (isIPad ? 280 : 140))];

        UIImageView *externalScreenPlaceholderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isIPad ? @"NGMoviePlayer.bundle/wildcatNoContentVideos@2x" : @"NGMoviePlayer.bundle/wildcatNoContentVideos")]];
        externalScreenPlaceholderImageView.frame = CGRectMake((320-externalScreenPlaceholderImageView.image.size.width)/2, 0, externalScreenPlaceholderImageView.image.size.width, externalScreenPlaceholderImageView.image.size.height);
        [externalScreenPlaceholderView addSubview:externalScreenPlaceholderImageView];

        UILabel *externalScreenLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, externalScreenPlaceholderImageView.frame.size.height + (isIPad ? 15 : 5), 262, 30)];
        externalScreenLabel.font = [UIFont systemFontOfSize:(isIPad ? 26.0f : 20.0f)];
        externalScreenLabel.textAlignment = UITextAlignmentCenter;
        externalScreenLabel.backgroundColor = [UIColor clearColor];
        externalScreenLabel.textColor = [UIColor darkGrayColor];
        externalScreenLabel.text = self.airPlayVideoActive ? self.airplayDeviceName : @"VGA";
        [externalScreenPlaceholderView addSubview:externalScreenLabel];

        UILabel *externalScreenDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, externalScreenLabel.frame.origin.y + (isIPad ? 35 : 20), 320, 30)];
        externalScreenDescriptionLabel.font = [UIFont systemFontOfSize:(isIPad ? 14.0f : 10.0f)];
        externalScreenDescriptionLabel.textAlignment = UITextAlignmentCenter;
        externalScreenDescriptionLabel.backgroundColor = [UIColor clearColor];
        externalScreenDescriptionLabel.textColor = [UIColor lightGrayColor];
        externalScreenDescriptionLabel.text = [NSString stringWithFormat:@"Dieses Video wird über %@ wiedergegeben.", externalScreenLabel.text];
        [externalScreenPlaceholderView addSubview:externalScreenDescriptionLabel];

        externalScreenPlaceholderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        externalScreenPlaceholderView.center = _externalScreenPlaceholder.center;

        [_externalScreenPlaceholder addSubview:externalScreenPlaceholderView];
    }

    return _externalScreenPlaceholder;
}

- (CGFloat)topControlsViewHeight {
    return CGRectGetMaxY(self.controlsView.topControlsView.frame);
}

- (CGFloat)bottomControlsViewHeight {
    CGFloat height = CGRectGetHeight(self.controlsView.frame);

    return  height - CGRectGetMinY(self.controlsView.bottomControlsView.frame) + 2*(height - CGRectGetMaxY(self.controlsView.bottomControlsView.frame));
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGMoviePlayerView UI Update
////////////////////////////////////////////////////////////////////////

- (void)updateWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    if (!isnan(currentTime) && !isnan(duration)) {
        [self.controlsView updateScrubberWithCurrentTime:currentTime duration:duration];
    }
}

- (void)updateWithPlaybackStatus:(BOOL)isPlaying {
    [self.controlsView updateButtonsWithPlaybackStatus:isPlaying];

    _shouldHideControls = isPlaying;
}

- (void)addVideoOverlayView:(UIView *)overlayView {
    if (overlayView != nil) {
        if (_videoOverlaySuperview == nil) {
            UIView *superview = self.playerLayerView.superview;

            _videoOverlaySuperview = [[UIView alloc] initWithFrame:superview.bounds];
            _videoOverlaySuperview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [superview insertSubview:_videoOverlaySuperview aboveSubview:self.playerLayerView];
        }

        [self.videoOverlaySuperview addSubview:overlayView];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Controls
////////////////////////////////////////////////////////////////////////

- (void)stopFadeOutControlsViewTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutControls) object:nil];
}

- (void)restartFadeOutControlsViewTimer {
    [self stopFadeOutControlsViewTimer];
    
    if (self.controlStyle == NGMoviePlayerControlStyleInline) {
        return;
    }

    [self performSelector:@selector(fadeOutControls) withObject:nil afterDelay:kNGControlVisibilityDuration];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - External Screen (VGA)
////////////////////////////////////////////////////////////////////////

- (void)setupExternalWindowForScreen:(UIScreen *)screen {
    if (screen != nil) {
        self.externalWindow = [[UIWindow alloc] initWithFrame:screen.applicationFrame];
        self.externalWindow.hidden = NO;
        self.externalWindow.clipsToBounds = YES;

        if (screen.availableModes.count > 0) {
            UIScreenMode *desiredMode = [screen.availableModes objectAtIndex:screen.availableModes.count-1];
            screen.currentMode = desiredMode;
        }

        self.externalWindow.screen = screen;
        [self.externalWindow makeKeyAndVisible];
    } else {
        [self.externalWindow removeFromSuperview];
        [self.externalWindow resignKeyWindow];
        self.externalWindow.hidden = YES;
        self.externalWindow = nil;
    }
}

- (void)updateViewsForCurrentScreenState {
    [self positionViewsForState:self.screenState];

    [self setControlsVisible:NO];

    if (self.placeholderView.superview == nil) {
        int64_t delayInSeconds = 1.;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self setControlsVisible:YES animated:YES];
        });
    }
}

- (void)positionViewsForState:(NGMoviePlayerScreenState)screenState {
    UIView *viewBeneathOverlayViews = self.playerLayerView;

    switch (screenState) {
        case NGMoviePlayerScreenStateExternal: {
            self.playerLayerView.frame = self.externalWindow.bounds;
            [self.externalWindow addSubview:self.playerLayerView];
            [self insertSubview:self.externalScreenPlaceholder belowSubview:self.placeholderView];
            viewBeneathOverlayViews = self.externalScreenPlaceholder;
            break;
        }

        case NGMoviePlayerScreenStateAirPlay: {
            self.playerLayerView.frame = self.bounds;
            [self insertSubview:self.playerLayerView belowSubview:self.placeholderView];
            [self insertSubview:self.externalScreenPlaceholder belowSubview:self.placeholderView];
            viewBeneathOverlayViews = self.externalScreenPlaceholder;
            break;
        }

        case NGMoviePlayerScreenStateDevice:
        default: {
            self.playerLayerView.frame = self.bounds;
            [self insertSubview:self.playerLayerView belowSubview:self.placeholderView];
            [self.externalScreenPlaceholder removeFromSuperview];
            self.externalScreenPlaceholder = nil;
            break;
        }
    }

    UIView *superview = self.playerLayerView.superview;

    self.videoOverlaySuperview.frame = self.playerLayerView.frame;
    [superview insertSubview:self.videoOverlaySuperview aboveSubview:viewBeneathOverlayViews];

    [self bringSubviewToFront:self.controlsView];
    [self bringSubviewToFront:self.placeholderView];
}

- (void)externalScreenDidConnect:(NSNotification *)notification {
    UIScreen *screen = [notification object];

    [self setupExternalWindowForScreen:screen];
    [self positionViewsForState:self.screenState];
}

- (void)externalScreenDidDisconnect:(NSNotification *)notification {
    [self setupExternalWindowForScreen:nil];
    [self positionViewsForState:self.screenState];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate
////////////////////////////////////////////////////////////////////////

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.controlsVisible || self.placeholderView.alpha > 0.f) {
        id playButton = nil;

        if (self.controlsView.volumeControl.expanded||self.controlsView.stepExpaned||self.controlsView.tableShow) {
            return NO;
        }

        if ([self.placeholderView respondsToSelector:@selector(playButton)]) {
            playButton = [self.placeholderView performSelector:@selector(playButton)];
        }
    
        // We here rely on the fact that nil terminates a list, because playButton can be nil
        // ATTENTION: DO NOT CONVERT THIS TO MODERN OBJC-SYNTAX @[]
        NSArray *controls = [NSArray arrayWithObjects:self.controlsView.topControlsView, self.controlsView.bottomControlsView, self.controlsView.settingControlsView,playButton, nil];

        // We dont want to to hide the controls when we tap em
        for (UIView *view in controls) {
            if ([view pointInside:[touch locationInView:view] withEvent:nil]) {
                return NO;
            }
        }
    }

    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews{
    self.activityView.center = self.center;
    self.speedView.center = self.center;
}


- (void)setup {
    self.controlStyle = NGMoviePlayerControlStyleInline;
    _controlsVisible = NO;
    _statusBarVisible = ![UIApplication sharedApplication].statusBarHidden;
    _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;

    // Player Layer
    _playerLayerView = [[NGMoviePlayerLayerView alloc] initWithFrame:self.bounds];
    _playerLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _playerLayerView.alpha = 0.f;

    [self.playerLayer addObserver:self
                       forKeyPath:@"readyForDisplay"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:&playerLayerReadyForDisplayContext];

    // Controls
    _controlsView = [[NGMoviePlayerControlView alloc] initWithFrame:self.bounds];
    _controlsView.alpha = 1.0f;
    [self addSubview:_controlsView];
    
    _controlsView.videoTitle.text = _videoName;

    [_controlsView.volumeControl addTarget:self action:@selector(volumeControlValueChanged:) forControlEvents:UIControlEventValueChanged];

    // Placeholder
    NGMoviePlayerPlaceholderView *placeholderView = [[NGMoviePlayerPlaceholderView alloc] initWithFrame:self.bounds];
    [placeholderView addPlayButtonTarget:self action:@selector(handlePlayButtonPress:)];
    [placeholderView addBackButtonTarget:self action:@selector(handlebackButtonPress:)];
    placeholderView.infoText = _videoName;
    _placeholderView = placeholderView;
    placeholderView.backBtn.hidden = YES;
    [self addSubview:_placeholderView];
    
   
    
    self.activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    self.activityView.center = self.center;
    self.activityView.backgroundColor = [UIColor blackColor];
    self.activityView.layer.cornerRadius = 5.0;
    self.activityView.layer.masksToBounds = YES;
    UIActivityIndicatorView *indicatro = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityView addSubview:indicatro];
    [indicatro startAnimating];
    
    CGRect frame = indicatro.frame;
    frame.origin.x = 10;
    frame.origin.y = 20;
    indicatro.frame = frame;
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(indicatro.frame)+20, 0, CGRectGetWidth(self.activityView.frame)-CGRectGetMaxX(indicatro.frame)-10, CGRectGetHeight(self.activityView.frame))];
    text.backgroundColor = [UIColor clearColor];
    text.font = [UIFont systemFontOfSize:14.0f];
    text.textColor = [UIColor whiteColor];
    text.text = @"加载中....";
    [self.activityView addSubview:text];
    [self addSubview:self.activityView];
    self.activityView.alpha = 0.0f;
    
    
    self.speedView = [[NGSpeedUpView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    self.speedView.backgroundColor = [UIColor blackColor];
    self.speedView.layer.cornerRadius = 8.0;
    self.speedView.layer.masksToBounds = YES;
    self.speedView.alpha = 0.0f;
    [self addSubview:self.speedView];
    
    
    // Gesture Recognizer for self
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:doubleTapGestureRecognizer];

    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    singleTapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:singleTapGestureRecognizer];
    
    UIPanGestureRecognizer *volumeSwipGestureRecongnizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(volumeSelfSwipGestureRecongnizer:)];
    volumeSwipGestureRecongnizer.delegate = self;
    [self addGestureRecognizer:volumeSwipGestureRecongnizer];

    // Gesture Recognizer for controlsView
    doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.delegate = self;
    [self.controlsView addGestureRecognizer:doubleTapGestureRecognizer];

    singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    singleTapGestureRecognizer.delegate = self;
    [self.controlsView addGestureRecognizer:singleTapGestureRecognizer];
    
    volumeSwipGestureRecongnizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(volumeCotnrolSwipGestureRecongnizer:)];
    volumeSwipGestureRecongnizer.delegate = self;
    [self.controlsView addGestureRecognizer:volumeSwipGestureRecongnizer];


    // Check for external screen
    if ([UIScreen screens].count > 1) {
        for (UIScreen *screen in [UIScreen screens]) {
            if (screen != [UIScreen mainScreen]) {
                [self setupExternalWindowForScreen:screen];
                break;
            }
        }

        NSAssert(self.externalWindow != nil, @"External screen counldn't be determined, no window was created");
    }

    [self positionViewsForState:self.screenState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalScreenDidConnect:) name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalScreenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
    
    _preTimer = self.controlsView.scrubberControl.value;
}

- (void)fadeOutControls {
    if (_shouldHideControls && self.screenState == NGMoviePlayerScreenStateDevice) {
        [self setControlsVisible:NO animated:YES];
    }
}

- (BOOL)isAirPlayVideoActive {
    if ([AVPlayer instancesRespondToSelector:@selector(isAirPlayVideoActive)]) {
        
        CFDictionaryRef currentRouteDescriptionDictionary = nil;
        UInt32 dataSize = sizeof(currentRouteDescriptionDictionary);
        AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dataSize, &currentRouteDescriptionDictionary);
        
        self.deviceOutputType = nil;
        self.airplayDeviceName = nil;
        if(currentRouteDescriptionDictionary) {
            CFArrayRef outputs = CFDictionaryGetValue(currentRouteDescriptionDictionary, kAudioSession_AudioRouteKey_Outputs);
            if(outputs!=nil &&CFArrayGetCount(outputs) > 0) {
                CFDictionaryRef currentOutput = CFArrayGetValueAtIndex(outputs, 0);
                
                //Get the output type (will show airplay / hdmi etc
                CFStringRef outType = CFDictionaryGetValue(currentOutput, kAudioSession_AudioRouteKey_Type);
                
                //If you're using Apple TV as your ouput - this will get the name of it (Apple TV Kitchen) etc
                CFStringRef outName = CFDictionaryGetValue(currentOutput, @"RouteDetailedDescription_Name");
                
                self.deviceOutputType = (__bridge NSString *)outType;
                self.airplayDeviceName = (__bridge NSString *)outName;
            }
        }

        
        return self.playerLayer.player.airPlayVideoActive;
    }

    return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if ((tap.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
        if (self.placeholderView.alpha == 0.f) {
            // Toggle control visibility on single tap
            [self setControlsVisible:!self.controlsVisible animated:YES];
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if ((tap.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
        if (self.placeholderView.alpha == 0.f) {
            // Toggle video gravity on double tap
            self.playerLayer.videoGravity = NGAVLayerVideoGravityNext(self.playerLayer.videoGravity);
            // BUG: otherwise the video gravity doesn't change immediately
            self.playerLayer.bounds = self.playerLayer.bounds;
        }
    }
}

- (void)volumeSelfSwipGestureRecongnizer:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self handleSelfVolumeGestureBeganWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self handleSelfVolumeGestureChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self handleSelfPanGestureEndedWithRecognizer:recognizer];
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self handleSelfPanGestureEndedWithRecognizer:recognizer];
            break;
            
        default:
        {
            
        }
            break;
    }
}

- (void)volumeCotnrolSwipGestureRecongnizer:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self handleContainVolumeGestureBeganWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self handleContainfVolumeGestureChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self handleContainPanGestureEndedWithRecognizer:recognizer];
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self handleContainPanGestureEndedWithRecognizer:recognizer];
            break;
            
        default:
        {
            
        }
            break;
    }
}


#pragma mark - volumeGesture



- (void)handleSelfVolumeGestureBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    self.panDirection = NGPanDirection_NONE;
    self.initialTouchLocation = [recognizer locationInView:self];
    self.previousTouchLocation = self.initialTouchLocation;
}

- (void)handleSelfVolumeGestureChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchLocation = [recognizer locationInView:self];
    CGFloat deltaY = currentTouchLocation.y - self.previousTouchLocation.y;
    CGFloat deltaX = currentTouchLocation.x - self.previousTouchLocation.x;
    CGFloat offset;
    CGFloat precent;
    
    if (self.panDirection == NGPanDirection_NONE) { //find morve direct
        if (ABS(deltaX)>ABS(deltaY) && ABS(deltaX)>kMinVideoChangeLength) {
            self.panDirection = NGPanDirection_LEFT;
            [self.controlsView.scrubberControl sendActionsForControlEvents:UIControlEventTouchDown];
        }else if (ABS(deltaY)>ABS(deltaX) && ABS(deltaY)>kMinVolumeChangeLength) {
            self.panDirection = NGPanDirection_UP;
        }else{
            return;
        }
    }
    
    if (self.panDirection == NGPanDirection_LEFT) {
        offset = deltaX;
        if (ABS(offset)<kMinVideoChangeLength) {
            return;
        }
        precent = offset/CGRectGetWidth(self.bounds);
        [self videoAddPercent:precent];
        
    }else if (self.panDirection == NGPanDirection_UP){
        offset = deltaY;
        if (ABS(offset)<kMinVolumeChangeLength) {
            return;
        }
        
        precent = offset/CGRectGetHeight(self.bounds);
        [self volumeAddPercent:precent];
    }
    
    self.previousTouchLocation = currentTouchLocation;
    

}

- (void)handleSelfPanGestureEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (self.panDirection == NGPanDirection_LEFT) {
        [self.controlsView.scrubberControl sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)handleContainVolumeGestureBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    self.initialTouchLocation = [recognizer locationInView:self.controlsView];
    self.previousTouchLocation = self.initialTouchLocation;
}

- (void)handleContainfVolumeGestureChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchLocation = [recognizer locationInView:self.controlsView];
    CGFloat deltaY = currentTouchLocation.y - self.previousTouchLocation.y;
    CGFloat deltaX = currentTouchLocation.x - self.previousTouchLocation.x;
    CGFloat offset;
    CGFloat precent;
    
    if (self.panDirection == NGPanDirection_NONE) {
        if (ABS(deltaX)>ABS(deltaY) && ABS(deltaX)>kMinVideoChangeLength) {
            self.panDirection = NGPanDirection_LEFT;
            [self.controlsView.scrubberControl sendActionsForControlEvents:UIControlEventTouchDown];
        }
        if (ABS(deltaY)>ABS(deltaX) && ABS(deltaY)>kMinVolumeChangeLength) {
            self.panDirection = NGPanDirection_UP;
        }
    }
    
    if (self.panDirection == NGPanDirection_LEFT) {
        offset = deltaX;
        if (ABS(offset)<kMinVideoChangeLength) {
            return;
        }
        precent = offset/CGRectGetWidth(self.bounds);
        [self videoAddPercent:precent];
        
    }else if (self.panDirection == NGPanDirection_UP){
        offset = deltaY;
        if (ABS(offset)<kMinVolumeChangeLength) {
            return;
        }
        
        precent = offset/CGRectGetHeight(self.bounds);
        [self volumeAddPercent:precent];
    }
    
    
    self.previousTouchLocation = currentTouchLocation;
    
    
}

- (void)handleContainPanGestureEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (self.panDirection == NGPanDirection_LEFT) {
        [self.controlsView.scrubberControl sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}



- (void)setSystemVolume:(float)systemVolume {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    musicPlayer.volume = systemVolume;
}

- (float)systemVolume {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    return musicPlayer.volume;
}

- (void)volumeAddPercent:(CGFloat)precent{
    CGFloat curVolume = [self systemVolume] - precent;
    curVolume = MAX(0,MIN(curVolume, 1.0));
    [self setSystemVolume:curVolume];
}



- (void)videoAddPercent:(CGFloat)percent{
    
    
    NGScrubber *slider = self.controlsView.scrubberControl;
    
    float value = slider.value;
    float addValue = 0;
    
    
    addValue = percent*MIN(slider.maximumValue, kMaxTimeInterVal) ;
    value = value+addValue;
    value = MIN(slider.maximumValue,MAX(value, 0));
    self.controlsView.scrubberControl.value = value;
    [self.controlsView.scrubberControl sendActionsForControlEvents:UIControlEventValueChanged];
    
}


- (void)handlePlayButtonPress:(id)playControl {
    [self.delegate moviePlayerControl:playControl didPerformAction:NGMoviePlayerControlActionStartToPlay];
}

- (void)handlebackButtonPress:(id)playControl{
    [self.delegate moviePlayerControl:playControl didPerformAction:NGMoviePlayerControlActionToggleZoomState];
}

- (void)volumeControlValueChanged:(id)sender {
    [self restartFadeOutControlsViewTimer];
}

@end
