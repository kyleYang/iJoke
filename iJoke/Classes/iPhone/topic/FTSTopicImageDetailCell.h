//
//  FTSTopicImageDetailCell.h
//  iJoke
//
//  Created by Kyle on 13-11-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "MptCotentCell.h"
#import "Downloader.h"
#import "FTSImageDetailHeadView.h"
#import "Image.h"

@protocol TopicImageDetailCellDelegate;

@interface FTSTopicImageDetailCell : MptCotentCell{
    NSInteger _curPage;
    BOOL _onceLoaded; //loading one time
    BOOL _reloading;
    BOOL _loadMore;
    BOOL _hasMore;
    Image *_image;
    id<TopicImageDetailCellDelegate> __weak_delegate _delegate;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak_delegate) id<TopicImageDetailCellDelegate> delegate;
@property (nonatomic, strong) Image *image;
@property (nonatomic, strong, readonly) FTSImageDetailHeadView *headView;
@property (nonatomic, assign) NSInteger curPage; //set curPage ,then load commit
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) Downloader *downloader;
@property (nonatomic, assign) int nTotalNum;
@property (nonatomic, assign) BOOL bLoadingMore;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) int nTaskId;
@property (nonatomic, strong) NSDate *dateLastRefreshTm;

@property (nonatomic, assign) CGFloat videoOffset; //particular for video commit , other commit can not be set;

@end


@protocol TopicImageDetailCellDelegate <NSObject>

@optional
- (void)topicImageDetailCell:(FTSTopicImageDetailCell *)cell popHeadView:(FTSImageDetailHeadView *)head atIndex:(NSUInteger)index;

@end