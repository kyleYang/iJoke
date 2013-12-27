//
//  NGMoviePlayerDelegate.h
//  NGMoviePlayer
//
//  Created by Philip Messlehner on 06.03.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGMoviePlayerControlStyle.h"
#import <AVFoundation/AVFoundation.h>


@class NGMoviePlayer;


@protocol NGMoviePlayerDelegate <NSObject>

@optional

- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didStartPlaybackOfURL:(NSURL *)URL;
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didFailToLoadURL:(NSURL *)URL;
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didFinishPlaybackOfURL:(NSURL *)URL;
- (void)moviePlayerDidPausePlayback:(NGMoviePlayer *)moviePlayer;
- (void)moviePlayerDidResumePlayback:(NGMoviePlayer *)moviePlayer;

- (void)moviePlayerDidBeginScrubbing:(NGMoviePlayer *)moviePlayer;
- (void)moviePlayerDidEndScrubbing:(NGMoviePlayer *)moviePlayer;

- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didChangeStatus:(AVPlayerStatus)playerStatus;
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didChangePlaybackRate:(float)rate;
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didChangeAirPlayActive:(BOOL)airPlayVideoActive;
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didChangeControlStyle:(NGMoviePlayerControlStyle)controlStyle;
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didUpdateCurrentTime:(NSTimeInterval)currentTime;

- (void)moviePlayerDidDownload:(NGMoviePlayer *)moviePlayer;
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didPlayStep:(int)setp initialPlaybackTime:(NSTimeInterval)initialPlaybackTime;



- (NSUInteger)moviePlayer:(NGMoviePlayer *)moviePlayer numberOfRowInSection:(NSUInteger)section;
- (NSString *)moviePlayer:(NGMoviePlayer *)moviePlayer titleInIndexPath:(NSIndexPath *)indexPath;
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didSelectIndexPath:(NSIndexPath *)indexPath;

@end