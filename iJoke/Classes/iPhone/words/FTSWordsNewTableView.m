//
//  FTSWordsNewTableView.m
//  iJoke
//
//  Created by Kyle on 13-8-15.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSWordsNewTableView.h"

@implementation FTSWordsNewTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)viewWillAppear{
    [super viewWillAppear];
    [MobClick beginLogPageView:kUmeng_newwordpage];
    [self.tableView setRefreshTime:[FTSUserCenter objectValueForKey:kDftNewWordsSaveTime]];
}

- (void)viewWillDisappear{
    [MobClick endLogPageView:kUmeng_newwordpage];
    
    [[FTSDataMgr sharedInstance] saveNewWordsArray:self.dataArray]; //save data use xml    
    [super viewWillDisappear];
    
}

 /**
  *	readlocal data,returen value need refresh
  *
  *	@return	BOOL
  */

- (BOOL)loadLocalDataNeedFresh{
    
    if (self.dataArray == nil) {
        self.dataArray = [[FTSDataMgr sharedInstance] arrayOfSaveNewWords];
        self.tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        self.hasMore = YES;
    }
       
    NSDate *lastUploadTs = [FTSUserCenter objectValueForKey:kDftNewWordsSaveTime];
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    CGFloat flast = [lastUploadTs timeIntervalSinceReferenceDate];
    if (fNow - flast > kRefreshNewWordIntervalS) {
        return TRUE;
    }
    
    return FALSE;
    
}

- (void)resaveDataArray{
    
     [[FTSDataMgr sharedInstance] saveNewWordsArray:self.dataArray]; //save data use xml,not need save time
}

 /**
  *	network
  *
  *	@param	bLoadMore	true:loadmore false:fresh
  */

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (self.nTaskId >0 ) {
        BqsLog(@"loadNetworkDataMore bLoadMore = %d, taskid =%d ",bLoadMore, self.nTaskId);
        return;
    }
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        
        NSInteger wordId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Words *words = [self.dataArray objectAtIndex:0];
            wordId = words.wordId;
        }
        
        self.nTaskId = [FTSNetwork newWordsFreshDownloader:self.downloader Target:self Sel:@selector(onLoadRefreshFinished:) Attached:nil wordId:wordId];
        [MobClick endEvent:kUmeng_newsword_fresh_event];
    }else{
        _curPage++;
        
        NSInteger wordId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Words *words = [self.dataArray lastObject];
            wordId = words.wordId;
        }
        
        self.nTaskId = [FTSNetwork newWordsNextDownloader:self.downloader Target:self Sel:@selector(onLoadNextDataFinished:) Attached:nil wordId:wordId];
        [MobClick endEvent:kUmeng_newword_next_event label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
}


-(void)onLoadRefreshFinished:(DownloaderCallbackObj*)cb {
    BqsLog(@"FTSWordsTableView onLoadDataFinished:%@",cb);
    self.nTaskId = -1;
    
    [self.tableView stopRefreshAnimation];;
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    

    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {
        self.hasMore = YES;
        [HMPopMsgView showPopMsgError:cb.error Msg:msg.msg Delegate:nil];
        return;
    }

    self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    NSArray *array = [Words parseJsonData:cb.rspData];
    
    if (array == nil) {
        self.hasMore = NO;
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"joke.content.nomessage", nil) Delegate:nil];
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        return;
    }
    if (array.count == 0) {
        [self noticeMessageNSString:NSLocalizedString(@"joke.content.nofresh", nil)];
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        return;
    }
    
    
    for (Words *word in array) {
        [self.tempArray addObject:word];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    [[FTSDataMgr sharedInstance] saveNewWordsArray:self.dataArray]; //save data use xml
    [FTSUserCenter setObjectValue:[NSDate date] forKey:kDftNewWordsSaveTime];
    [self.tableView setRefreshTime:[NSDate date]];
    
//    "joke.content.nofresh" = "暂无更新，欢迎发表新的";
//    "joke.content.freshnumber" = "更新了 %d 条";
    
    if (msg.freshSize == 0) {
        
        [self noticeMessageNSString:NSLocalizedString(@"joke.content.nofresh", nil)];
        
    }else{
        [self noticeMessageNSString:[NSString stringWithFormat:NSLocalizedString(@"joke.content.freshnumber", nil),msg.freshSize]];

    }
   
}



-(void)onLoadNextDataFinished:(DownloaderCallbackObj*)cb {
    BqsLog(@"FTSWordsTableView onLoadDataFinished:%@",cb);
    self.nTaskId = -1;
    [self.tableView stopRefreshAnimation];;
    
    if(nil == cb) {
        self.hasMore = YES;
        return;
    }
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        self.hasMore = YES;
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {
        self.hasMore = YES;
        [HMPopMsgView showPopMsgError:cb.error Msg:msg.msg Delegate:nil];
        return;
    }

    
    if (!self.tempArray) {
        self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    }
    
    NSArray *array = [Words parseJsonData:cb.rspData];
    
    if (!array || [array count] == 0) {
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        self.hasMore = FALSE;
        if (self.detailController) {
            self.detailController.more =  self.hasMore;
        }
        
        return;
    }
    
    for (Words *word in array) {
        [self.tempArray addObject:word];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    if (self.detailController) {
        [self.detailController setDataArray:self.dataArray more:self.hasMore];
    }
    
    [[FTSDataMgr sharedInstance] saveNewWordsArray:self.dataArray]; //save data use xml    
    
}





@end
