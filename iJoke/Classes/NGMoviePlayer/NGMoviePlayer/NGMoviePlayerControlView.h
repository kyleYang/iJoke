//
//  NGMoviePlayerControlView.h
//  NGMoviePlayer
//
//  Created by Tretter Matthias on 13.03.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGMoviePlayerControlStyle.h"
#import "NGWeak.h"


@class NGMoviePlayerLayout;
@class NGVideoTableView;
@protocol NGMoviePlayerControlActionDelegate;


@interface NGMoviePlayerControlView : UIView

@property (nonatomic, ng_weak) id<NGMoviePlayerControlActionDelegate> delegate;

@property (nonatomic, strong, readonly) NGVideoTableView *videoTableView;

/** Controls whether the player controls are currently in fullscreen- or inlinestyle */
@property (nonatomic, assign) NGMoviePlayerControlStyle controlStyle;

@property (nonatomic, assign) NGMoviePlayerControlScrubbingTimeDisplay scrubbingTimeDisplay;

@property (nonatomic, readonly) NSArray *topControlsViewButtons;
@property (nonatomic, assign) NSTimeInterval playableDuration;
@property (nonatomic, readonly, getter = isAirPlayButtonVisible) BOOL airPlayButtonVisible;


/******************************************
 @name Updating
 ******************************************/

- (void)updateScrubberWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;
- (void)updateButtonsWithPlaybackStatus:(BOOL)isPlaying;
- (void)updateButtonsWithPlayBufferEnable:(BOOL)playAble;
- (void)NGVideoTypeHidedn;
- (void)videoPlayListRecovery;
@end
