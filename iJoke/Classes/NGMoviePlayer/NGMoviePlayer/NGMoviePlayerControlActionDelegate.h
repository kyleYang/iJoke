//
//  NGMoviePlayerControlViewDelegate.h
//  NGMoviePlayer
//
//  Created by Tretter Matthias on 13.03.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

typedef enum {
    NGMoviePlayerControlActionStartToPlay,
    NGMoviePlayerControlActionTogglePlayPause,
    NGMoviePlayerControlActionToggleZoomState,
    NGMoviePlayerControlActionToggleShowSetting,
    NGMoviePlayerControlActionToggleCancelHiden,
    NGMoviePlayerControlActionToggleContinueHiden,
    NGMoviePlayerControlActionToggleSetting,
    NGMoviePlayerControlActionToggleDownload,
    NGMoviePlayerControlActionBeginSkippingBackwards,
    NGMoviePlayerControlActionBeginSkippingForwards,
    NGMoviePlayerControlActionBeginScrubbing,
    NGMoviePlayerControlActionScrubbingValueChanged,
    NGMoviePlayerControlActionEndScrubbing,
    NGMoviePlayerControlActionEndSkipping,
    NGMoviePlayerControlActionVolumeChanged,
    NGMoviePlayerControlActionWillShowControls,
    NGMoviePlayerControlActionDidShowControls,
    NGMoviePlayerControlActionWillHideControls,
    NGMoviePlayerControlActionDidHideControls,
    NGMoviePlayerControlActionAirPlayMenuActivated
} NGMoviePlayerControlAction;


@protocol NGMoviePlayerControlActionDelegate <NSObject>

- (void)moviePlayerControl:(id)control didPerformAction:(NGMoviePlayerControlAction)action;

@optional  //for tableview data
- (NSUInteger)numberOfSectionNGVideoTableView:(NGVideoTableView *)tableView;
- (NSUInteger)NGVideoTableView:(NGVideoTableView *)tableView numberOfRowInSection:(NSUInteger)section;
- (NSString *)NGVideoTableView:(NGVideoTableView *)tableView titleInIndexPath:(NSIndexPath *)indexPath;
- (void)NGVideoTableView:(NGVideoTableView *)tableView didSelectIndexPath:(NSIndexPath *)indexPath;



@end