//
//  FTSVideoNewTableView.m
//  iJoke
//
//  Created by Kyle on 13-9-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSVideoNewTableView.h"
#import "FTSDataMgr.h"
#import "Msg.h"

@implementation FTSVideoNewTableView

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
    [MobClick beginLogPageView:kUmeng_NewVideoPage];
    [self.tableView setRefreshTime:[FTSUserCenter objectValueForKey:kDftNewVideoSaveTime]];
}

- (void)viewWillDisappear{
    [MobClick endLogPageView:kUmeng_NewVideoPage];
    
    [[FTSDataMgr sharedInstance] saveNewVideoArray:self.dataArray]; //save data use xml
    [super viewWillDisappear];
    
}

/**
 *	readlocal data,returen value need refresh
 *
 *	@return	BOOL
 */

- (BOOL)loadLocalDataNeedFresh{
    
    if (self.dataArray == nil) {
        self.dataArray = [[FTSDataMgr sharedInstance] arrayOfSaveNewVideo];
        self.tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        self.hasMore = YES;
    }
    
    NSDate *lastUploadTs = [FTSUserCenter objectValueForKey:kDftNewVideoSaveTime];
    
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    CGFloat flast = [lastUploadTs timeIntervalSinceReferenceDate];

    
    if (fNow -flast> kRefreshNewVideoIntervalS) {
        return TRUE;
    }
    
    return FALSE;
    
}

- (void)resaveDataArray{
    
    [[FTSDataMgr sharedInstance] saveNewVideoArray:self.dataArray]; //save data use xml,not need save time
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
        
        NSInteger videoId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Video *video = [self.dataArray objectAtIndex:0];
            videoId = video.videoId;
        }
        
        self.nTaskId = [FTSNetwork newVideoFreshDownloader:self.downloader Target:self Sel:@selector(onLoadRefreshFinished:) Attached:nil videoId:videoId];
        [MobClick endEvent:kUmeng_newsvideo_fresh_event];
    }else{
        _curPage++;
        
        NSInteger videoId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Video *video = [self.dataArray lastObject];
            videoId = video.videoId;
        }
        
        self.nTaskId = [FTSNetwork newVideoNextDownloader:self.downloader Target:self Sel:@selector(onLoadNextDataFinished:) Attached:nil videoId:videoId];
        [MobClick endEvent:kUmeng_newvideo_next_event label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
}


-(void)onLoadRefreshFinished:(DownloaderCallbackObj*)cb {
    BqsLog(@"FTSWordsTableView onLoadDataFinished:%@",cb);
    
    self.nTaskId = -1;
    
    
    [self.tableView stopRefreshAnimation];
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
    NSArray *array = [Video parseJsonData:cb.rspData];
    
    if (array == nil) {
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        return;
    }
    
    for (Video *video in array) {
        [self.tempArray addObject:video];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    [[FTSDataMgr sharedInstance] saveNewVideoArray:self.dataArray]; //save data use xml
    [FTSUserCenter setObjectValue:[NSDate date] forKey:kDftNewVideoSaveTime];
    [self.tableView setRefreshTime:[NSDate date]];
    
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
    if (!self.tempArray) {
        self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    }
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {
        [HMPopMsgView showPopMsgError:cb.error Msg:msg.msg Delegate:nil];
        return;
    }
    
    NSArray *array = [Video parseJsonData:cb.rspData];
    
    if (array == nil) {
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        self.hasMore = FALSE;
        //        if (self.detailController) {
        //            self.detailController.more =  self.hasMore;
        //        }
        
        return;
    }
    
    if ([array count] == 0) { //did not has more
        self.hasMore = FALSE;
        //        if (self.detailController) {
        //            self.detailController.more =  self.hasMore;
        //        }
        return;
    }
    
    
    for (Video *video in array) {
        [self.tempArray addObject:video];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    //    if (self.detailController) {
    //        [self.detailController setDataArray:self.dataArray more:self.hasMore];
    //    }
    
    [[FTSDataMgr sharedInstance] saveNewVideoArray:self.dataArray]; //save data use xml
    
    
}



@end
