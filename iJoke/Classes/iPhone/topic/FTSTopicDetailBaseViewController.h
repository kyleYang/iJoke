//
//  FTSTopicDetailBaseViewController.h
//  iJoke
//
//  Created by Kyle on 13-11-26.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSBaseViewController.h"
#import "FTSDataMgr.h"
#import "FTSUserCenter.h"
#import "Topic.h"
#import "FTSNetwork.h"
#import "MBProgressHUD.h"
#import "Downloader.h"
#import "HMPopMsgView.h"

@interface FTSTopicDetailBaseViewController : FTSBaseViewController{
    
    NSInteger _nTaskId;
    BOOL _hasMore; //has more
    Topic *_topic;
    NSArray *_dataArray;
    NSUInteger _curPage;
}

- (id)initWithTopic:(Topic *)atopic;
- (void)loadLocalDataNeedFresh;
- (void)reloadData;
- (void)dataFresh:(id)sender;

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong, readonly) Topic *topic;
@property (nonatomic, strong) Downloader *downloader;

@end
