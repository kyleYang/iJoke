//
//  FTSTopicVideoDetailViewController.m
//  iJoke
//
//  Created by Kyle on 13-12-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTopicVideoDetailViewController.h"
#import "PgLoadingFooterView.h"
#import "FTSVideoTableCell.h"
#import "FTSMoviePlayerViewController.h"
#import "Msg.h"
#import "FTSUIOps.h"

#define kRelationMaxNum 30

@interface FTSTopicVideoDetailViewController ()<UITableViewDataSource,UITableViewDelegate,pgFootViewDelegate,FTSVideoTableCellDelegate,MoviePlayerViewControllerDelegate>{
    BOOL _loadMore;
    NSIndexPath *_playedIndexPath;
}

@property (nonatomic, strong)  NSIndexPath *playedIndexPath;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PgLoadingFooterView *loadingMoreFootView;

@property (nonatomic, assign) int nTotalNum;
@property (nonatomic, assign) BOOL bLoadingMore;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) NSDate *dateLastRefreshTm;

@end

@implementation FTSTopicVideoDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(DeviceSystemMajorVersion() >=7){
        self.automaticallyAdjustsScrollViewInsets = YES;
        
    }
    
    // create subview
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.scrollsToTop = YES;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    // pull refresh
//    {
//        self.pullView = [[ODRefreshControl alloc] initInScrollView:self.tableView];
//        self.pullView.backgroundColor = RGBA(250, 250, 250, 1.0);
//        [self.pullView addTarget:self action:@selector(dataFresh:) forControlEvents:UIControlEventValueChanged];
//    }
    
    // loading more footer
    {
        self.loadingMoreFootView = [[PgLoadingFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds),kPgLoadingFooterView_H)];
        self.loadingMoreFootView.backgroundColor = RGBA(250, 250, 250, 1.0);
        self.loadingMoreFootView.delegate = self;
        self.tableView.tableFooterView = self.loadingMoreFootView;;
    }
    
    _hasMore = YES;
    _curPage = 0;
    // create downloade
    self.nTotalNum = -1;
    _nTaskId = -1;


    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    _hasMore = YES;
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_topic_video_detail];
    
    if (DeviceSystemMajorVersion()>=7) {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    
    __weak FTSTopicVideoDetailViewController *weakSelf =self;
    [_tableView addPullToRefreshActionHandler:^{
        [weakSelf dataFresh:nil];
    }];
    NSDate *lastUploadTs = [FTSUserCenter objectValueForKey:[NSString stringWithFormat:kDftTopicVideoDetailSaveTimeId, _topic.topicId]];
    [self.tableView setRefreshTime:lastUploadTs];
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_topic_video_detail];
    self.nTotalNum = -1;
    [super viewWillDisappear:animated];
}



#pragma
#pragma mark instance method

- (void)loadLocalDataNeedFresh{
    
    
    NSDate *lastUploadTs = [FTSUserCenter objectValueForKey:[NSString stringWithFormat:kDftTopicVideoDetailSaveTimeId, _topic.topicId]];
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    CGFloat flast = [lastUploadTs timeIntervalSinceReferenceDate];
    
    BOOL reFresh = FALSE;
    if (fNow - flast > kRefreshTopicVideoDetailIntervalS) {
        reFresh =  TRUE;
    }
    
    if (reFresh) {
        
        [self loadNetworkDataMore:NO];
        
    }else{
        
        if (self.dataArray == nil) {
            
            self.dataArray = [[FTSDataMgr sharedInstance] arrayOfSaveTpoicVideoDetailForId:_topic.topicId];
            self.tempArray = [NSMutableArray arrayWithArray:self.dataArray];
            self.hasMore = YES;
        }
    }

}




#pragma mark
#pragma mark - network ops

- (void)dataFresh:(id)sender{
    
    [self loadNetworkDataMore:NO];
}


-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (_nTaskId >0) {
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
        
        _nTaskId = [FTSNetwork topicVideoFreshDownloader:self.downloader Target:self Sel:@selector(onLoadRefreshFinished:) Attached:nil videoId:videoId topicID:_topic.topicId];
        [MobClick endEvent:kUmeng_topicvideo_fresh_event];
    }else{
        _curPage++;
        
        NSInteger videoId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Video *video = [self.dataArray lastObject];
            videoId = video.videoId;
        }
        
        _nTaskId = [FTSNetwork topicVideoNextDownloader:self.downloader Target:self Sel:@selector(onLoadNextDataFinished:) Attached:nil videoId:videoId topicID:_topic.topicId];
        [MobClick endEvent:kUmeng_topicvideo_next_event label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
}


-(void)onLoadRefreshFinished:(DownloaderCallbackObj*)cb {
    BqsLog(@"FTSWordsTableView onLoadDataFinished:%@",cb);
    _nTaskId = -1;
    
    [self.tableView stopRefreshAnimation];
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    
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
    
    [[FTSDataMgr sharedInstance] saveTpoicVideoDetailArray:self.dataArray froId:_topic.topicId]; //save data use xml
    [FTSUserCenter setObjectValue:[NSDate date] forKey:[NSString stringWithFormat:kDftTopicVideoDetailSaveTimeId, _topic.topicId]];
    [self.tableView setRefreshTime:[NSDate date]];
    
    if (msg.freshSize == 0) {
        
        [self noticeMessageNSString:NSLocalizedString(@"joke.content.nofresh", nil)];
        
    }else{
        [self noticeMessageNSString:[NSString stringWithFormat:NSLocalizedString(@"joke.content.freshnumber", nil),msg.freshSize]];
        
    }
    
    
}



-(void)onLoadNextDataFinished:(DownloaderCallbackObj*)cb {
    BqsLog(@"FTSWordsTableView onLoadDataFinished:%@",cb);
    
    _nTaskId = -1;
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
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
    
    [[FTSDataMgr sharedInstance] saveTpoicVideoDetailArray:self.dataArray froId:_topic.topicId]; //save data use xml
    
}



#pragma mark
#pragma mark property
- (void)reloadData{
    [self.tableView reloadData];
}

- (void)setHasMore:(BOOL)hasMore{
    
    _hasMore = hasMore;
    if (!_hasMore) {
        [self.loadingMoreFootView setState:PgFootRefreshAllDown];
    }else{
        [self.loadingMoreFootView setState:PgFootRefreshNormal];
    }
    
    
}


#pragma mark
#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIden = @"cellId";
    FTSVideoTableCell *cell = (FTSVideoTableCell *)[aTableView dequeueReusableCellWithIdentifier:cellIden];
    if (!cell) {
        cell = [[FTSVideoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
    }
    
    cell.delegate = self;
    
    Video *info = [self.dataArray objectAtIndex:indexPath.row];
    
    [cell configCellForVideo:info];
    
    return cell;
}



-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Video *info = [self.dataArray objectAtIndex:indexPath.row];
    
    return [FTSVideoTableCell caculateHeighForVideo:info];
    
}


#pragma mark
#pragma mark WordTableCellDelegate

#pragma mark MptAVPlayerViewController_Callback
- (void)moviePlayerViewController:(FTSMoviePlayerViewController *)ctl didFinishWithResult:(NGMoviePlayerResult)result error:(NSError *)error{
    
    NSString *resultString = @"";
    
    switch (result) {
        case NGMoviePlayerCancelled:
            resultString = NSLocalizedString(@"detail.progrome.player.cancle", nil);
            break;
        case NGMoviePlayerFinished:
            resultString = NSLocalizedString(@"detail.progrome.player.fininsh", nil);
            break;
        case NGMoviePlayerURLError:
            resultString = NSLocalizedString(@"detail.progrome.player.urleror", nil);
            break;
        case NGMoviePlayerFailed:
            resultString = NSLocalizedString(@"detail.progrome.player.failed", nil);
            break;
        default:
            break;
    }
//    [ctl dismissViewControllerAnimated:YES completion:^{}];
    
    [self.flipboardNavigationController popViewController];
}



- (void)videoTableCell:(FTSVideoTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"videoTableCell selectIndexPath indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    BOOL isWifi = [FTSUserCenter BoolValueForKey:kDftNetTypeWifi];
    if (!isWifi) {
        self.playedIndexPath = indexPath;
        [HMPopMsgView showChaoseAlertError:nil Msg:NSLocalizedString(@"title.network.3G.play", self) delegate:self];
        return;
    }

    
    Video *info = [self.dataArray objectAtIndex:indexPath.row];
    
    NSMutableArray *videoArray = [NSMutableArray arrayWithArray:self.dataArray];
    BOOL hasBefore = YES;
    while ([videoArray count] > kRelationMaxNum) {
        
        Video *temp = nil;
        
        if (hasBefore) {
            temp = [videoArray objectAtIndex:0];
            if (temp == info) {
                hasBefore = FALSE;
            }else{
                [videoArray removeObjectAtIndex:0];
            }
            
        }else{
            [videoArray removeLastObject];
        }
        
    }
    
    
    FTSMoviePlayerViewController *playViewController = [[FTSMoviePlayerViewController alloc] initWithVideo:info videoArray:videoArray];
    playViewController.delegate = self;
//    [self.flipboardNavigationController presentViewController:playViewController animated:YES completion:^{}];
    [self.flipboardNavigationController pushViewController:playViewController];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    BqsLog(@"alertView didClick Button at index:%d",buttonIndex);
    if (buttonIndex == 1) {
        if (self.playedIndexPath == nil) {
            BqsLog(@"Error playedIndexPath  == nil");
            return ;
        }
        
        if ([self.dataArray count] <= self.playedIndexPath.row) {
            BqsLog(@"videoTableCell selectIndexPath indexPath:%@ > [self.dataArray count]:%d",self.playedIndexPath,self.dataArray.count);
            return;
        }
        
        
        Video *info = [self.dataArray objectAtIndex:self.playedIndexPath.row];
        
        NSMutableArray *videoArray = [NSMutableArray arrayWithArray:self.dataArray];
        BOOL hasBefore = YES;
        while ([videoArray count] > kRelationMaxNum) {
            
            Video *temp = nil;
            
            if (hasBefore) {
                temp = [videoArray objectAtIndex:0];
                if (temp == info) {
                    hasBefore = FALSE;
                }else{
                    [videoArray removeObjectAtIndex:0];
                }
                
            }else{
                [videoArray removeLastObject];
            }
            
        }
        
        
        FTSMoviePlayerViewController *playViewController = [[FTSMoviePlayerViewController alloc] initWithVideo:info videoArray:videoArray];
        playViewController.delegate = self;
        //    [self.flipboardNavigationController presentViewController:playViewController animated:YES completion:^{}];
        [self.flipboardNavigationController pushViewController:playViewController];

        
        
    }
    
    
}

#pragma mark
#pragma mark PgFootMore
- (void)footLoadMore
{
    if (self.loadingMoreFootView.state == PgFootRefreshAllDown) {
        return;
    }
    [self loadMoreData];
    
}

- (void)loadMoreData{
    
    if(self.loadingMoreFootView.state == PgFootRefreshAllDown){
        return;
    }
    
    _loadMore = YES;
    
    [self.loadingMoreFootView setState:PgFootRefreshLoading];
    
    [self loadNetworkDataMore:YES];
}


#pragma mark
#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_loadMore) {
        float maxoffset = scrollView.contentSize.height - CGRectGetHeight(scrollView.frame)+50;
        if(maxoffset > 0 && scrollView.contentOffset.y >= maxoffset) {
            BqsLog(@"trigger load more!, offsety: %.1f, contentsize.h: %.1f, maxoffset:%.1f", scrollView.contentOffset.y, scrollView.contentSize.height, maxoffset);
            [self loadMoreData];
        }
        
    }
}





#pragma mark pgFootViewDelegate
- (NSString *)messageTxtForState:(PgFootRefreshState)state
{
    int itemNum = [self.dataArray count];
    
    if (state == PgFootRefreshNormal) {
        if (itemNum == 0) {
            return [NSString stringWithFormat:NSLocalizedString(@"dota.more.noresult", nil)];
        }else{
            return [NSString stringWithFormat:NSLocalizedString(@"dota.more.normal", nil),itemNum];
        }
    }else if(state == PgFootRefreshLoading){
        return NSLocalizedString(@"dota.more.loading", nil);
    }else if(state ==  PgFootRefreshAllDown){
        if (itemNum == 0) {
            return [NSString stringWithFormat:NSLocalizedString(@"dota.more.noresult", nil)];
        }else{
            return [NSString stringWithFormat:NSLocalizedString(@"dota.more.done", nil),itemNum];
        }
    }
    return @"";
}

- (void)loadingFootViewDidClickMore:(PgLoadingFooterView *)foot{
    
}




@end
