//
//  FTSWordsHotTableView.m
//  iJoke
//
//  Created by Kyle on 13-8-15.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSWordsHotTableView.h"

@implementation FTSWordsHotTableView

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
    [MobClick beginLogPageView:kUmeng_hotwordpage];
}

- (void)viewWillDisappear{
    [MobClick endLogPageView:kUmeng_hotwordpage];
    [[FTSDataMgr sharedInstance] saveHotWordsArray:self.dataArray]; //save data use xml
    [super viewWillDisappear];
    
}

/**
 *	readlocal data,returen value need refresh
 *
 *	@return	BOOL
 */

- (BOOL)loadLocalDataNeedFresh{
    if (self.dataArray == nil) {
        self.dataArray = [[FTSDataMgr sharedInstance] arrayOfSaveHotWords];
        self.tempArray = [NSMutableArray arrayWithArray:self.dataArray];
    }
    
    CGFloat lastUploadTs = [FTSUserCenter floatValueForKey:kDftHotWordsSaveTime];
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    
    if (fNow - lastUploadTs > kRefreshHotWordIntervalS) {
        return TRUE;
    }
    
    return FALSE;
    
}

/**
 *	network
 *
 *	@param	bLoadMore	true:loadmore false:fresh
 */

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        
        NSInteger wordId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Words *words = [self.dataArray objectAtIndex:0];
            wordId = words.wordId;
        }
        
        self.nTaskId = [FTSNetwork newWordsFreshDownloader:self.downloader Target:self Sel:@selector(onLoadRefreshFinished:) Attached:nil wordId:wordId];
        [MobClick endEvent:kUmeng_hotword_fresh_event];
    }else{
        _curPage++;
        
        NSInteger wordId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Words *words = [self.dataArray lastObject];
            wordId = words.wordId;
        }
        
        self.nTaskId = [FTSNetwork newWordsNextDownloader:self.downloader Target:self Sel:@selector(onLoadNextDataFinished:) Attached:nil wordId:wordId];
        [MobClick endEvent:kUmeng_hotword_next_event label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
}


//-(void)onLoadRefreshFinished:(DownloaderCallbackObj*)cb {
//    BqsLog(@"FTSWordsTableView onLoadDataFinished:%@",cb);
//    
//    [self.pullView endRefreshing];
//    if(nil == cb) return;
//    
//    if(nil != cb.error || 200 != cb.httpStatus) {
//		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
//        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
//        return;
//	}
//    
//    self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
//    WordStruct *wordStruct = [WordStruct parseJsonData:cb.rspData];
//    
//    if (!wordStruct||!wordStruct.dataArray) {
//        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
//        return;
//    }
//    
//    for (Words *word in wordStruct.dataArray) {
//        [self.tempArray addObject:word];
//    }
//    self.dataArray = self.tempArray;
//    
//    [[FTSDataMgr sharedInstance] saveHotWordsArray:self.dataArray]; //save data use xml
//    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
//    [FTSUserCenter setFloatVaule:fNow forKey:kDftHotWordsSaveTime];
//    
//    
//}
//
//
//
//-(void)onLoadNextDataFinished:(DownloaderCallbackObj*)cb {
//    BqsLog(@"FTSWordsTableView onLoadDataFinished:%@",cb);
//    
//    if(nil == cb) return;
//    
//    if(nil != cb.error || 200 != cb.httpStatus) {
//		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
//        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
//        return;
//	}
//    if (!self.tempArray) {
//        self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
//    }
//    
//    WordStruct *wordStruct = [WordStruct parseJsonData:cb.rspData];
//    
//    if (!wordStruct||!wordStruct.dataArray) {
//        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
//        self.hasMore = FALSE;
//        if (self.detailController) {
//            self.detailController.more =  self.hasMore;
//        }
//        
//        return;
//    }
//    
//    if ([wordStruct.dataArray count] == 0) { //did not has more
//        self.hasMore = FALSE;
//        if (self.detailController) {
//            self.detailController.more =  self.hasMore;
//        }
//        return;
//    }
//    
//    
//    for (Words *word in wordStruct.dataArray) {
//        [self.tempArray addObject:word];
//    }
//    self.dataArray = self.tempArray;
//    
//    
//    if (self.detailController) {
//        [self.detailController setDataArray:self.dataArray more:self.hasMore];
//    }
//    
//    [[FTSDataMgr sharedInstance] saveHotWordsArray:self.dataArray]; //save data use xml
//    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
//    [FTSUserCenter setFloatVaule:fNow forKey:kDftHotWordsSaveTime];
//    
//    
//}

@end
