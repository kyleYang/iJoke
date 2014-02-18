//
//  FTSImageNewTableView.m
//  iJoke
//
//  Created by Kyle on 13-8-15.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSImageNewTableView.h"
#import "FTSDataMgr.h"
#import "FTSUserCenter.h"
#import "FTSNetwork.h"

@implementation FTSImageNewTableView

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
    [MobClick beginLogPageView:kUmeng_newImagepage];
    
    [self.tableView setRefreshTime:[FTSUserCenter objectValueForKey:kDftNewImageSaveTime]];
    
}

- (void)viewWillDisappear{
    [MobClick endLogPageView:kUmeng_newImagepage];
    [super viewWillDisappear];
    
}


- (BOOL)loadLocalDataNeedFresh{
    if (self.dataArray == nil) {
        
        self.dataArray = [[FTSDataMgr sharedInstance] arrayOfSaveNewImage];
        self.tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        self.hasMore = YES;
    }
   
    
    NSDate *lastUploadTs = [FTSUserCenter objectValueForKey:kDftNewImageSaveTime];
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    CGFloat flast = [lastUploadTs timeIntervalSinceReferenceDate];
    if (fNow - flast > kRefreshNewImageIntervalS) {
        return TRUE;
    }
    
    return FALSE;
    
}


-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (self.nTaskId >0 ) {
        BqsLog(@"loadNetworkDataMore bLoadMore = %d, taskid =%d ",bLoadMore, self.nTaskId);
        return;
    }
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        
        NSInteger imageId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Image *image = [self.dataArray objectAtIndex:0];
            imageId = image.imageId;
        }
        
        self.nTaskId = [FTSNetwork newImageFreshDownloader:self.downloader Target:self Sel:@selector(onLoadRefreshFinished:) Attached:nil imageId:imageId];
        [MobClick endEvent:kUmeng_newimage_fresh_event];
    }else{
        _curPage++;
        
        NSInteger imageId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Image *image = [self.dataArray lastObject];
            imageId = image.imageId;
        }
        
        self.nTaskId = [FTSNetwork newImageNextDownloader:self.downloader Target:self Sel:@selector(onLoadNextDataFinished:) Attached:nil imageId:imageId];
        [MobClick endEvent:kUmeng_hotimage_next_event label:[NSString stringWithFormat:@"%d",_curPage]];
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
    NSArray *array = [Image parseJsonData:cb.rspData];
    
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
    
    
    for (Image *word in array) {
        [self.tempArray addObject:word];
    }

    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    [[FTSDataMgr sharedInstance] saveNewImageArray:self.dataArray]; //save data use xml
   
    [FTSUserCenter setObjectValue:[NSDate date] forKey:kDftNewImageSaveTime];
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
        self.hasMore = YES;
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    if (!self.tempArray) {
        self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
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
    
    NSArray *array = [Image parseJsonData:cb.rspData];
    
    if (!array || [array count] == 0) {
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        self.hasMore = FALSE;
        if (self.detailController) {
            self.detailController.more =  self.hasMore;
        }
        
        return;
    }
    
    for (Image *image in array) {
        [self.tempArray addObject:image];
    }

    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    if (self.detailController) {
        [self.detailController setDataArray:self.dataArray more:self.hasMore];
    }
    
    [[FTSDataMgr sharedInstance] saveNewImageArray:self.dataArray]; //save data use xml

    
}




@end
