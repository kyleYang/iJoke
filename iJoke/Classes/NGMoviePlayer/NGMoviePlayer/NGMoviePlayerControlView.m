//
//  NGMoviePlayerControlView.m
//  NGMoviePlayer
//
//  Created by Tretter Matthias on 13.03.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGMoviePlayerControlView.h"
#import "NGMoviePlayerControlView+NGPrivate.h"
#import "NGMoviePlayerControlActionDelegate.h"
#import "NGScrubber.h"
#import "NGVideoType.h"
#import "NGVideoTableView.h"
#import "NGVolumeControl.h"
#import "NGMoviePlayerFunctions.h"
#import "NGMoviePlayerLayout.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "FTSUserCenter.h"
#import "Video.h"

#define kTableViewWidth 200
#define kTableViewAnmationInterval 0.25

@interface NGMoviePlayerControlView ()<NGVideoTypeDelegate,NGVideoTableViewDelegate> {
    BOOL _statusBarHidden;
}

@property (nonatomic, readonly, getter = isPlayingLivestream) BOOL playingLivestream;

// Properties from NGMoviePlayerControlView+NGPrivate
@property (nonatomic, strong) NGMoviePlayerLayout *layout;
@property (nonatomic, strong, readwrite) UIView *topControlsView;
@property (nonatomic, strong, readwrite) UIView *bottomControlsView;
@property (nonatomic, strong, readwrite) UIView *topControlsContainerView;
@property (nonatomic, strong, readwrite) UIImageView *settingControlsView;
@property (nonatomic, strong, readwrite) UIButton *playPauseControl;
@property (nonatomic, strong, readwrite) NGScrubber *scrubberControl;
@property (nonatomic, strong, readwrite) UIButton *rewindControl;
@property (nonatomic, strong, readwrite) UIButton *forwardControl;
@property (nonatomic, strong, readwrite) UILabel *currentTimeLabel;
@property (nonatomic, strong, readwrite) UILabel *remainingTimeLabel;
@property (nonatomic, strong, readwrite) NGVolumeControl *volumeControl;
@property (nonatomic, strong, readwrite) UIControl *airPlayControlContainer;
@property (nonatomic, strong, readwrite) MPVolumeView *airPlayControl;
@property (nonatomic, strong, readwrite) UIButton *settingControl;
@property (nonatomic, strong, readwrite) UIButton *tableViewOptionControl;
@property (nonatomic, strong, readwrite) UILabel *videoTitle;
@property (nonatomic, strong, readwrite) UIButton *zoomControl;

@property (nonatomic, assign, readwrite) BOOL stepExpaned;
@property (nonatomic, assign, readwrite) BOOL tableShow;
@property (nonatomic, strong, readwrite) NGVideoType *videoType;
@property (nonatomic, strong, readwrite) NGVideoTableView *videoTableView;
@end


@implementation NGMoviePlayerControlView
@synthesize stepExpaned = _stepExpaned;
@synthesize tableShow = _tableShow;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _topControlsView = [[UIView alloc] initWithFrame:CGRectZero];
        _topControlsView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6f];
        _topControlsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_topControlsView];

        _topControlsContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _topControlsContainerView.backgroundColor = [UIColor clearColor];
        [_topControlsView addSubview:_topControlsContainerView];

        _bottomControlsView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bottomControlsView.userInteractionEnabled = YES;
        _bottomControlsView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bottomControlsView];
        
        _settingControlsView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _settingControlsView.userInteractionEnabled = YES;
        _settingControlsView.backgroundColor = [UIColor clearColor];
        UIImage *settingImage = [UIImage imageNamed:@"NGMoviePlayer.bundle/settingbg"];
        if ([settingImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            settingImage = [settingImage resizableImageWithCapInsets:UIEdgeInsetsMake(30.f, 30.f, 30.f, 30.f)];
        } else {
            settingImage = [settingImage stretchableImageWithLeftCapWidth:50 topCapHeight:50];
        }
        _settingControlsView.image = settingImage;
        [self addSubview:_settingControlsView];

        _volumeControl = [[NGVolumeControl alloc] initWithFrame:CGRectZero];
        _volumeControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_volumeControl addTarget:self action:@selector(handleVolumeChanged:) forControlEvents:UIControlEventValueChanged];
        if (UI_USER_INTERFACE_IDIOM()  == UIUserInterfaceIdiomPhone) {
            _volumeControl.sliderHeight = 130.f;
        }
        // volume control needs to get added to self instead of bottomControlView because otherwise the expanded slider
        // doesn't receive any touch events
        [self addSubview:_volumeControl];


        // We use the MPVolumeView just for displaying the AirPlay icon
        
        _rewindControl = [UIButton buttonWithType:UIButtonTypeCustom];
        _rewindControl.frame = CGRectMake(60.f, 10.f, 40.f, 40.f);
        _rewindControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _rewindControl.showsTouchWhenHighlighted = YES;
        [_rewindControl setImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/prevtrack"] forState:UIControlStateNormal];
        [_rewindControl addTarget:self action:@selector(handleRewindButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_rewindControl addTarget:self action:@selector(handleRewindButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_rewindControl addTarget:self action:@selector(handleRewindButtonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_bottomControlsView addSubview:_rewindControl];

        _forwardControl = [UIButton buttonWithType:UIButtonTypeCustom];
        _forwardControl.frame = _rewindControl.frame;
        _forwardControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        _forwardControl.showsTouchWhenHighlighted = YES;
        [_forwardControl setImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/nexttrack"] forState:UIControlStateNormal];
        [_forwardControl addTarget:self action:@selector(handleForwardButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_forwardControl addTarget:self action:@selector(handleForwardButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_forwardControl addTarget:self action:@selector(handleForwardButtonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_bottomControlsView addSubview:_forwardControl];

        _playPauseControl = [UIButton buttonWithType:UIButtonTypeCustom];
        _playPauseControl.frame = CGRectMake(0.f, 0.f, 44.f, 44.f);
        _playPauseControl.contentMode = UIViewContentModeCenter;
        _playPauseControl.showsTouchWhenHighlighted = YES;
        _playPauseControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_playPauseControl addTarget:self action:@selector(handlePlayPauseButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomControlsView addSubview:_playPauseControl];

        _scrubberControl = [[NGScrubber alloc] initWithFrame:CGRectZero];
        _scrubberControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_scrubberControl addTarget:self action:@selector(handleBeginScrubbing:) forControlEvents:UIControlEventTouchDown];
        [_scrubberControl addTarget:self action:@selector(handleScrubbingValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_scrubberControl addTarget:self action:@selector(handleEndScrubbing:) forControlEvents:UIControlEventTouchUpInside];
        [_scrubberControl addTarget:self action:@selector(handleEndScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
        [_bottomControlsView addSubview:_scrubberControl];

        _zoomControl = [UIButton buttonWithType:UIButtonTypeCustom];
        _zoomControl.showsTouchWhenHighlighted = YES;
        _zoomControl.contentMode = UIViewContentModeCenter;
        [_zoomControl addTarget:self action:@selector(handleZoomButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_topControlsView addSubview:_zoomControl];
        
        _settingControl = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingControl.showsTouchWhenHighlighted = YES;
        _settingControl.frame = (CGRect) { .size = CGSizeMake(70.f, 60.f) };
//        _settingControl.contentMode = UIViewContentModeCenter;
        [_settingControl setBackgroundImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/videoType"] forState:UIControlStateNormal];
        [_settingControl setBackgroundImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/videoTypedown"] forState:UIControlStateHighlighted];
        [_settingControl addTarget:self action:@selector(handleSettingButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_topControlsView addSubview:_settingControl];
        
        _tableViewOptionControl = [UIButton buttonWithType:UIButtonTypeCustom];
//        _tableViewOptionControl.showsTouchWhenHighlighted = YES;
        _tableViewOptionControl.frame = (CGRect) { .size = CGSizeMake(30.f, 30.f) };
//        _tableViewOptionControl.contentMode = UIViewContentModeCenter;
        [_tableViewOptionControl setBackgroundImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/table_show"] forState:UIControlStateNormal];
        [_tableViewOptionControl addTarget:self action:@selector(handleTableViewOptionButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_settingControlsView addSubview:_tableViewOptionControl];
        
        //no need airplay this version ---- kyle yang
//        if ([AVPlayer instancesRespondToSelector:@selector(allowsAirPlayVideo)]) {
//            _airPlayControl = [[MPVolumeView alloc] initWithFrame:(CGRect) { .size = CGSizeMake(38.f, 22.f) }];
//            _airPlayControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
//            _airPlayControl.contentMode = UIViewContentModeCenter;
//            _airPlayControl.showsRouteButton = YES;
//            _airPlayControl.showsVolumeSlider = NO;
//            
//            _airPlayControlContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 60.f, 44.f)];
//            _airPlayControl.center = CGPointMake(_airPlayControlContainer.frame.size.width/2.f, _airPlayControlContainer.frame.size.height/2.f - 2.f);
//            [_airPlayControlContainer addTarget:self action:@selector(handleAirPlayButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//            [_airPlayControlContainer addSubview:_airPlayControl];
//            [_settingControlsView addSubview:_airPlayControlContainer];
//        }

        
        
        _videoTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _videoTitle.backgroundColor = [UIColor clearColor];
        _videoTitle.textColor = [UIColor whiteColor];
        _videoTitle.shadowColor = [UIColor blackColor];
        _videoTitle.shadowOffset = CGSizeMake(0.f, 1.f);
        _videoTitle.font = [UIFont boldSystemFontOfSize:15.];
        _videoTitle.textAlignment = UITextAlignmentCenter;
        _videoTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_topControlsView addSubview:_videoTitle];
    

        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _currentTimeLabel.backgroundColor = [UIColor clearColor];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.shadowColor = [UIColor blackColor];
        _currentTimeLabel.shadowOffset = CGSizeMake(0.f, 1.f);
        _currentTimeLabel.font = [UIFont boldSystemFontOfSize:13.];
        _currentTimeLabel.textAlignment = UITextAlignmentRight;
        _currentTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [_bottomControlsView addSubview:_currentTimeLabel];

        _remainingTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _remainingTimeLabel.backgroundColor = [UIColor clearColor];
        _remainingTimeLabel.textColor = [UIColor whiteColor];
        _remainingTimeLabel.shadowColor = [UIColor blackColor];
        _remainingTimeLabel.shadowOffset = CGSizeMake(0.f, 1.f);
        _remainingTimeLabel.font = [UIFont boldSystemFontOfSize:13.];
        _remainingTimeLabel.textAlignment = UITextAlignmentLeft;
        _remainingTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_bottomControlsView addSubview:_remainingTimeLabel];

        _statusBarHidden = [UIApplication sharedApplication].statusBarHidden;

        _controlStyle = NGMoviePlayerControlStyleInline;
        _scrubbingTimeDisplay = NGMoviePlayerControlScrubbingTimeDisplayPopup;
        
        _stepExpaned = NO;
        _tableShow = NO;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)setAlpha:(CGFloat)alpha {
    // otherwise the airPlayButton isn't positioned correctly on first show-up
    if (alpha > 0.f) {
        [self setNeedsLayout];
    }

    [super setAlpha:alpha];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.layout layoutTopControlsViewWithControlStyle:self.controlStyle];
    [self.layout layoutBottomControlsViewWithControlStyle:self.controlStyle];
    [self.layout layoutControlsWithControlStyle:self.controlStyle];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.volumeControl.expanded) {
        return [super pointInside:point withEvent:event];
    }
    
    BOOL insideTopControlsView = CGRectContainsPoint(self.topControlsView.frame, point);
    BOOL insideBottomControlsView = CGRectContainsPoint(self.bottomControlsView.frame, point);
    BOOL insideSettinControlsView = CGRectContainsPoint(self.settingControlsView.frame, point);
    
    BOOL insideTableView = NO;
    if (_tableShow) {
        insideTableView = CGRectContainsPoint(self.videoTableView.frame, point);
    }
    BOOL insideVideoType = NO;
    if (_stepExpaned) {
        insideVideoType = CGRectContainsPoint(self.videoType.frame, point);
    }
    
    if (!(insideTopControlsView||insideBottomControlsView||insideSettinControlsView)) {
        
        if (_tableShow && !insideTableView) {
            [self handleTableViewOptionButtonPress:nil];
            return YES;
        }
        if (_stepExpaned && !insideVideoType) {
            [self handleSettingButtonPress:nil];
            return YES;
        }
        
        
    }
    
   
    
   
    return  insideTableView||insideVideoType||insideTopControlsView || insideBottomControlsView||insideSettinControlsView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGMoviePlayerControlView
////////////////////////////////////////////////////////////////////////

- (void)setControlStyle:(NGMoviePlayerControlStyle)controlStyle {
    _controlStyle = controlStyle;
    [self.layout updateControlStyle:controlStyle];
}

- (void)setLayout:(NGMoviePlayerLayout *)layout {
    if (layout != _layout) {
        _layout = layout;
    }

    [layout updateControlStyle:self.controlStyle];
}

- (void)setScrubbingTimeDisplay:(NGMoviePlayerControlScrubbingTimeDisplay)scrubbingTimeDisplay {
    if (scrubbingTimeDisplay != _scrubbingTimeDisplay) {
        _scrubbingTimeDisplay = scrubbingTimeDisplay;

        self.scrubberControl.showPopupDuringScrubbing = (scrubbingTimeDisplay == NGMoviePlayerControlScrubbingTimeDisplayPopup);
    }
}

- (void)setPlayableDuration:(NSTimeInterval)playableDuration {
    self.scrubberControl.playableValue = playableDuration;
}

- (NSTimeInterval)playableDuration {
    return self.scrubberControl.playableValue;
}

- (void)updateScrubberWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    self.currentTimeLabel.text = NGMoviePlayerGetTimeFormatted(currentTime);
    self.remainingTimeLabel.text = [NSString stringWithFormat:@"/%@",NGMoviePlayerGetTimeFormatted(duration)];

    [self.scrubberControl setMinimumValue:0.];
    [self.scrubberControl setMaximumValue:duration];
    [self.scrubberControl setValue:currentTime];
}

- (void)updateButtonsWithPlaybackStatus:(BOOL)isPlaying {
    UIImage *image = nil;

    if (self.controlStyle == NGMoviePlayerControlStyleInline) {
        image = isPlaying ? [UIImage imageNamed:@"NGMoviePlayer.bundle/pause"] : [UIImage imageNamed:@"NGMoviePlayer.bundle/play"];
    } else {
        image = isPlaying ? [UIImage imageNamed:@"NGMoviePlayer.bundle/pauseFullscreen"] : [UIImage imageNamed:@"NGMoviePlayer.bundle/playFullscreen"];
    }

    [self.playPauseControl setImage:image forState:UIControlStateNormal];
}

- (void)updateButtonsWithPlayBufferEnable:(BOOL)playAble{ //update button state when play can play,sometimes the buffer is empty
    
    [self updateButtonsWithPlaybackStatus:playAble];
    
    if (playAble) {
        _forwardControl.enabled = YES;
    }else{
        _playPauseControl.enabled = NO;
    }
    
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)handlePlayPauseButtonPress:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionTogglePlayPause];
}

- (void)handleRewindButtonTouchDown:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionBeginSkippingBackwards];
}

- (void)handleRewindButtonTouchUp:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionEndSkipping];
}

- (void)handleForwardButtonTouchDown:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionBeginSkippingForwards];
}

- (void)handleForwardButtonTouchUp:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionEndSkipping];
}

- (void)handleZoomButtonPress:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionToggleZoomState];
}

- (void)handleSettingButtonPress:(id)sender {
    if (_controlStyle == NGMoviePlayerControlStyleInline) {
        return;
    }
    
    if (_tableShow) {
        [self handleTableViewOptionButtonPress:nil];
    
    }
    
    
    if (self.videoType == nil) {
        self.videoType = [[NGVideoType alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-150, CGRectGetMaxY(self.topControlsContainerView.frame), 150, 40)];
        self.videoType.delegate = self;
        [self addSubview:self.videoType];
        self.videoType.alpha = 0.0f;
        _stepExpaned = YES;
        [UIView animateWithDuration:0.25 animations:^(void){
            self.videoType.alpha = 1.0f;
        }];
        
    }else{
        [UIView animateWithDuration:0.25 animations:^(void){
            self.videoType.alpha = 0.0f;
            _stepExpaned = NO;
        } completion:^(BOOL finish){
            [self.videoType removeFromSuperview];
            self.videoType = nil;
            
        }];
    }
    
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionToggleShowSetting];
}



- (void)NGVideoType:(NGVideoType *)type didSelectAtIndex:(NSUInteger)index{
    int playStep = [FTSUserCenter intValueForKey:kScreenPlayType];
    
    [UIView animateWithDuration:0.25 animations:^(void){
        self.videoType.alpha = 0.0f;
    } completion:^(BOOL finish){
        [self.videoType removeFromSuperview];
        self.videoType = nil;
        _stepExpaned = NO;
    }];

    if (playStep == index) {
               
        return;

    }
    [FTSUserCenter setIntValue:index forKey:kScreenPlayType];
    NSString *vidoStep = @"";
    switch (index) {
        case VideoScreenNormal:
            vidoStep = NSLocalizedString(@"settin.video.qulity.one", nil);
            break;
        case VideoScreenClear:
            vidoStep = NSLocalizedString(@"settin.video.qulity.two", nil);
            break;
        case VideoScreenHD:
            vidoStep = NSLocalizedString(@"settin.video.qulity.three", nil);
            break;
            
        default:
            break;
    }
    [self.settingControl setTitle:vidoStep forState:UIControlStateNormal];
    
    
    [self.delegate moviePlayerControl:nil didPerformAction:NGMoviePlayerControlActionToggleSetting];
}


- (void)NGVideoTypeHidedn{
    
    if (self.videoType != nil) {
        [self.videoType removeFromSuperview];
        self.videoType = nil;
        _stepExpaned = NO;
    }
    
}

- (void)videoPlayListRecovery{
    
//    if (!self.videoTableView.hidden) {
//        self.videoTableView.hidden = YES;
//    }
    
}

- (void)handleDownloadButtonPress:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionToggleDownload];
}

- (void)handleTableViewOptionButtonPress:(id)sender{
    if (_controlStyle == NGMoviePlayerControlStyleInline) {
        return;
    }
    
    if (self.videoType != nil) {
        
        [self.videoType removeFromSuperview];
        self.videoType = nil;
        _stepExpaned = NO;
    }
    
    if (self.videoTableView == nil) {
        self.videoTableView = [[NGVideoTableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds), CGRectGetMaxY(self.topControlsContainerView.frame), kTableViewWidth, CGRectGetHeight(self.bounds)-CGRectGetMaxY(self.topControlsContainerView.frame)-CGRectGetHeight(self.bottomControlsView.frame))];
        self.videoTableView.hidden = YES;
        self.videoTableView.delegate = self;
        [self addSubview:self.videoTableView];
    }
    
    if (!_tableShow) {
        
        self.videoTableView.hidden = FALSE;
        _tableShow = YES;
        
        CGRect __block frame = self.videoTableView.frame;
        frame.origin.x = CGRectGetWidth(self.bounds);
        self.videoTableView.frame = frame;
        
        [UIView animateWithDuration:kTableViewAnmationInterval animations:^(void){
            
            frame.origin.x = frame.origin.x - kTableViewWidth;
            self.videoTableView.frame = frame;
            
            frame = _settingControlsView.frame;
            frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(_settingControl.frame) - kTableViewWidth+10;
            _settingControlsView.frame =frame;
            
        }completion:^(BOOL finished){
            [_tableViewOptionControl setBackgroundImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/table_hidden"] forState:UIControlStateNormal];
        }];
        [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionToggleCancelHiden];
        
    }else{
        
        CGRect __block frame = self.videoTableView.frame;
        frame.origin.x = CGRectGetWidth(self.bounds)-kTableViewWidth;
        self.videoTableView.frame = frame;
        
        [UIView animateWithDuration:kTableViewAnmationInterval animations:^(void){
            _tableShow = NO;
            frame.origin.x = CGRectGetWidth(self.bounds);
            self.videoTableView.frame = frame;
            
            frame = _settingControlsView.frame;
            frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(_settingControl.frame)+10;
            _settingControlsView.frame =frame;
            
        } completion:^(BOOL finished){
            [_tableViewOptionControl setBackgroundImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/table_show"] forState:UIControlStateNormal];
            self.videoTableView.hidden = YES;
            [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionToggleContinueHiden];
        }];

        
    }
    
    
}

- (void)handleBeginScrubbing:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionBeginScrubbing];
}

- (void)handleScrubbingValueChanged:(id)sender {
    if (self.scrubbingTimeDisplay == NGMoviePlayerControlScrubbingTimeDisplayCurrentTime) {
        self.currentTimeLabel.text = NGMoviePlayerGetTimeFormatted(self.scrubberControl.value);
        self.remainingTimeLabel.text =[NSString stringWithFormat:@"/%@",NGMoviePlayerGetTimeFormatted(self.scrubberControl.maximumValue)];
    }

    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionScrubbingValueChanged];
}

- (void)handleEndScrubbing:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionEndScrubbing];
}

- (void)handleVolumeChanged:(id)sender {
    [self.delegate moviePlayerControl:sender didPerformAction:NGMoviePlayerControlActionVolumeChanged];
}

- (void)handleAirPlayButtonPress:(id)sender {
    // forward touch event to airPlay-button
    for (UIView *subview in self.airPlayControl.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;

            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }

    [self.delegate moviePlayerControl:self.airPlayControl didPerformAction:NGMoviePlayerControlActionAirPlayMenuActivated];
}


#pragma mark
#pragma NGVideoTableViewDelegate

- (NSUInteger)NGVideoTableView:(NGVideoTableView *)tableView numberOfRowInSection:(NSUInteger)section{
    if ([self.delegate respondsToSelector:@selector(NGVideoTableView:numberOfRowInSection:)]) {
        
        return [self.delegate NGVideoTableView:tableView numberOfRowInSection:section];
    }
    return 0;
    
}
- (NSString *)NGVideoTableView:(NGVideoTableView *)tableView titleInIndexPath:(NSIndexPath *)indexPath{
    NSString *title = NSLocalizedString(@"video.tableview.notitle", nil);
    
    if ([_delegate respondsToSelector:@selector(NGVideoTableView:titleInIndexPath:)]) {
        title = [_delegate NGVideoTableView:tableView titleInIndexPath:indexPath];
    }

    return title;
    
}


- (void)NGVideoTableView:(NGVideoTableView *)tableView didSelectIndexPath:(NSIndexPath *)indexPath{
    if ([_delegate respondsToSelector:@selector(NGVideoTableView:didSelectIndexPath:)]) {
        
        [_delegate NGVideoTableView:tableView didSelectIndexPath:indexPath];
    }
}

@end
