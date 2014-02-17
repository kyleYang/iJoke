//
//  FTSCommentBaseViewController.h
//  iJoke
//
//  Created by Kyle on 13-11-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgLoadingFooterView.h"
#import "Downloader.h"
#import "UMSocial.h"
#import "UIInputToolbar.h"
#import "UIScrollView+UzysCircularProgressPullToRefresh.h"
#import "CustomUIBarButtonItem.h"
#import "FTSDataMgr.h"
#import "Msg.h"
#import "HMPopMsgView.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "Comment.h"
#import "FTSUserCenter.h"

@interface FTSCommentBaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    NSInteger _curPage;
    BOOL _onceLoaded; //loading one time
    BOOL _reloading;
    BOOL _loadMore;
    BOOL _hasMore;
    BOOL _keyboardIsShow;
    int _nTaskId;
    
}


@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, assign) NSInteger curPage; //set curPage ,then load commit
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) PgLoadingFooterView *loadingMoreFootView;
@property (nonatomic, strong, readonly) UIInputToolbar *toolBar;
@property (nonatomic, strong, readonly) UITextField *inputTextField;

@property (nonatomic, strong, readonly) Downloader *downloader;
@property (nonatomic, assign) int nTotalNum;
@property (nonatomic, assign) BOOL bLoadingMore;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) int nTaskId;
@property (nonatomic, strong) NSDate *dateLastRefreshTm;

@property (nonatomic, assign) CGFloat videoOffset; //particular for video commit , other commit can not be set;

- (void)commitCB:(DownloaderCallbackObj *)cb;
- (void)onLoadCommitListFinished:(DownloaderCallbackObj *)cb;

- (void)sendCommentText:(NSString *)text anonymous:(BOOL)anonymous;//should rewirte

@end
