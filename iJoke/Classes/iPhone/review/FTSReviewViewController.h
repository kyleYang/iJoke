//
//  FTSReviewViewController.h
//  iJoke
//
//  Created by Kyle on 13-11-4.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSBaseViewController.h"


enum ReviewType {
    ReviewTypeReject = -1,
    ReviewTypeSkip = 0,
    ReviewTypePass = 1
 };


@interface FTSReviewViewController : FTSBaseViewController{
    
    BOOL _reloading;
    BOOL _loadMore;
    BOOL _hasMore;
    BOOL _lastOne;
    NSInteger _curIndex;
    NSUInteger _pageNum;
}

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *tempArray;

@property (nonatomic, assign) int nTotalNum;
@property (nonatomic, assign) BOOL bLoadingMore;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) int nTaskId;
@property (nonatomic, strong) NSDate *dateLastRefreshTm;


@end
