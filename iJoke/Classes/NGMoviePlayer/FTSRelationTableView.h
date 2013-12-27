//
//  FTSRelationTableView.h
//  iJoke
//
//  Created by Kyle on 13-11-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "MptCotentCell.h"
#import "PgLoadingFooterView.h"
#import "ODRefreshControl.h"

@protocol relationTableViewDelegate;

@interface FTSRelationTableView : MptCotentCell<UITableViewDataSource,UITableViewDelegate>{
    
    BOOL _reloading;
    BOOL _loadMore;
    BOOL _hasMore;
    NSInteger _curPage;
    id<relationTableViewDelegate> __weak_delegate _delegate;
}

@property (nonatomic, weak_delegate) id<relationTableViewDelegate> delegate;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, assign) int nTotalNum;
@property (nonatomic, assign) BOOL bLoadingMore;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) int nTaskId;
@property (nonatomic, strong) NSDate *dateLastRefreshTm;

@property (nonatomic, assign) CGFloat videoOffset; //particular for video commit , other commit can not be set;

@end


@protocol relationTableViewDelegate <NSObject>

@optional
- (void)relationTableView :(FTSRelationTableView *)tableView selectIndex:(NSUInteger )index;



@end