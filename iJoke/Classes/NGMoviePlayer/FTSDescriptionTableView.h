//
//  FTSDescriptionTableView.h
//  iJoke
//
//  Created by Kyle on 13-11-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "MptCotentCell.h"
#import "Video.h"


@protocol DescriptionTableViewDelegate;

@interface FTSDescriptionTableView : MptCotentCell{
    
    Video *_video;
    id<DescriptionTableViewDelegate> __weak_delegate _delegate;
    
}

@property (nonatomic, weak_delegate) id<DescriptionTableViewDelegate> delegate;
@property (nonatomic, strong) Video *video;
@property (nonatomic, assign) CGFloat videoOffset; //particular for video commit , other commit can not be set;

- (void)refreshRecordState;
@end


@protocol DescriptionTableViewDelegate <NSObject>

@optional

- (void)descriptionTableView:(FTSDescriptionTableView *)cell upVideo:(Video *)video;
- (void)descriptionTableView:(FTSDescriptionTableView *)cell downVideo:(Video *)video;
- (void)descriptionTableView:(FTSDescriptionTableView *)cell favVideo:(Video *)video addType:(BOOL)value; //vale: true for add and false for del favorite

- (void)reportMessageTableView:(FTSDescriptionTableView *)cell video:(Video *)video;


@end