//
//  FTSDetailBaseViewController.h
//  iJoke
//
//  Created by Kyle on 13-8-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MptContentScrollView.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "Downloader.h"
#import "HMPopMsgView.h"
#import "FTSNetwork.h"

@protocol FTSCommitBaseViewControllerDelegate;

@interface FTSCommitBaseViewController : UIViewController<scrollDataSource,scrollDelegate>{
    NSArray *_dataArray;
    BOOL _more; //has more
    NSUInteger _displayIndex; // commit page display index;
    
    id<FTSCommitBaseViewControllerDelegate> __weak_delegate _baseDelegate;
}

@property (nonatomic, weak_delegate) id<FTSCommitBaseViewControllerDelegate> baseDelegate;
@property (nonatomic, strong, readonly) NSArray *dataArray;
@property (nonatomic, assign) BOOL more;
@property (nonatomic, assign) NSUInteger displayIndex;
@property (nonatomic, strong) Downloader *downloader;
@property (nonatomic, strong) MptContentScrollView *contentView;


- (id)initWithDataArray:(NSArray*)array hasMore:(BOOL)value curIndex:(NSUInteger)index;
- (void)setDataArray:(NSArray *)dataArray more:(BOOL)more; //set property

- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView;
- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index;

- (void)reportMessage;
- (void)reportMessageCB:(DownloaderCallbackObj *)cb;
@end


@protocol FTSCommitBaseViewControllerDelegate <NSObject>

- (void)commitViewControllerPopViewController:(FTSCommitBaseViewController *)viewController offset:(NSIndexPath*)indexPath;

@end
