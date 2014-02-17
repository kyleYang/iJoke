//
//  FTSDetailBaseCell.h
//  iJoke
//
//  Created by Kyle on 13-8-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "MptCotentCell.h"
#import "PgLoadingFooterView.h"
#import "UIScrollView+UzysCircularProgressPullToRefresh.h"
#import "Downloader.h"
#import "UMSocial.h"
#import "UIInputToolbar.h"
#import "FTSUserCenter.h"
#import "FTSUserInfoViewController.h"
#import "FTSUIOps.h"
#import "HMPopMsgView.h"

@protocol CommitBaseCellDelegate;

@interface FTSCommitBaseCell : MptCotentCell<UITableViewDataSource,UITableViewDelegate>{
    
    NSInteger _curPage;
    BOOL _onceLoaded; //loading one time
    BOOL _reloading;
    BOOL _loadMore;
    BOOL _hasMore;
    BOOL _keyboardIsShow;
    id<CommitBaseCellDelegate> __weak_delegate _inputDelegate;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak_delegate) id<CommitBaseCellDelegate> inputDelegate;

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

- (void)sendCommentText:(NSString *)text anonymous:(BOOL)anonymous;//should rewirte


@end

@protocol CommitBaseCellDelegate <NSObject>

- (void)CommitBaseCellkeyboardWillShow;
- (void)CommitBaseCellkeyboardWillHidden;

@end

