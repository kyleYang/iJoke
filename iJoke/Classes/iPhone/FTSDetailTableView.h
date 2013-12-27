//
//  FTSDetailTableView.h
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSDetailBaseView.h"
#import "PgLoadingFooterView.h"
#import "ODRefreshControl.h"

@interface FTSDetailTableView : FTSDetailBaseView<UITableViewDataSource,UITableViewDelegate>{
    
    BOOL _reloading;
    BOOL _loadMore;
    BOOL _hasMore;
    
}


@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) ODRefreshControl *pullView;
@property (nonatomic, strong, readonly) PgLoadingFooterView *loadingMoreFootView;


@property (nonatomic, assign) int nTotalNum;
@property (nonatomic, assign) BOOL bLoadingMore;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) int nTaskId;
@property (nonatomic, strong) NSDate *dateLastRefreshTm;


- (void)noticeMessageNSString:(NSString *)message;

@end
