//
//  FTSTopicViewCell.h
//  iJoke
//
//  Created by Kyle on 13-11-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSDetailBaseView.h"

@protocol TopicViewCellDelegate;

@interface FTSTopicViewCell : FTSDetailBaseView
{
    id<TopicViewCellDelegate> __weak_delegate _delegate;
    NSUInteger _section;
    NSArray *_dataArray;
}

@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, weak_delegate) id<TopicViewCellDelegate> delegate;

@end




@protocol TopicViewCellDelegate <NSObject>

- (void)TopicViewCell:(FTSTopicViewCell *)cell selectSection:(NSUInteger)section atIndex:(NSUInteger)index;


@end
