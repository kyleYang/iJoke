//
//  FTSActionBaseViewController.h
//  iJoke
//
//  Created by Kyle on 13-11-13.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgLoadingFooterView.h"
#import "ODRefreshControl.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "Downloader.h"
#import "HMPopMsgView.h"
#import "FTSUserCenter.h"
#import "FTSDataMgr.h"
#import "MBProgressHUD.h"
#import "FTSNetwork.h"
#import "Msg.h"
#import "Review.h"
#import "CustomUIBarButtonItem.h"
#import "YFJLeftSwipeDeleteTableView.h"
#import "FTSUIOps.h"
#import "FTSCommentImageViewController.h"
#import "FTSCommentWordsViewController.h"
#import "FTSMoviePlayerViewController.h"


@interface FTSActionBaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,pgFootViewDelegate,MoviePlayerViewControllerDelegate>{
    
    BOOL _reloading;
    BOOL _loadMore;
    BOOL _hasMore;
    int _nTaskId;
    BOOL _onceLoaded;
    NSUInteger _curPage;
    NSMutableArray *_dataArray;
    
}

@property (nonatomic, strong) Downloader *downloader;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong, readonly) YFJLeftSwipeDeleteTableView *tableView;
@property (nonatomic, strong, readonly) ODRefreshControl *pullView;
@property (nonatomic, strong, readonly) PgLoadingFooterView *loadingMoreFootView;
@property (nonatomic, strong, readonly) MBProgressHUD *progressHUD;


@property (nonatomic, assign) int nTotalNum;
@property (nonatomic, assign) BOOL bLoadingMore;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) int nTaskId;
@property (nonatomic, strong) NSDate *dateLastRefreshTm;

-(void)loadLocalDataNeedFresh;
-(void)loadNetworkDataMore:(BOOL)bLoadMore;

@end
