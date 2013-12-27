//
//  FTSPubulishMessageViewController.m
//  iJoke
//
//  Created by Kyle on 13-11-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSPubulishMessageViewController.h"
#import "FTSPublishImageCell.h"
#import "FTSPublishVideoCell.h"
#import "FTSPublishWordsCell.h"

@interface FTSPubulishMessageViewController ()<PublishImageCellDelegate,PublishWordsCellDelegate,PublishVideoCellDelegate>{
    NSIndexPath *_playedIndexPath;
    
}

@property (nonatomic, strong) NSIndexPath *playedIndexPath;
@property (nonatomic, strong, readwrite) User *user;

@end

@implementation FTSPubulishMessageViewController
@synthesize user = _user;

- (id)initWithUser:(User *)info{
    self = [super init];
    if (self) {
        self.user = info;
    }
    return self;
}



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
    NSString *userName =  NSLocalizedString(@"joke.useraciton.publish.mytitle", nil);
    if (_user != nil) {
        
         userName = _user.nikeName;;
        if (userName == nil || userName.length == 0) {
            userName = _user.userName;
        }
        if (userName == nil || userName.length == 0) {
            userName = NSLocalizedString(@"joke.useraction.publish.noname", nil);
        }
        
        
    }
    self.navigationItem.title = userName;
    
}


-(void)viewWillAppear:(BOOL)animated {
    _hasMore = YES;
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_user_collect_check];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_user_collect_check];
    self.nTotalNum = -1;
    [super viewWillDisappear:animated];
}



- (void)loadLocalDataNeedFresh{
    
    if(self.dataArray != nil){
        BqsLog(@"have once load");
        return;
    }
        
    if (_user != nil) {
        [self loadNetworkDataMore:NO];
        return;
    }else{
        
            
            CGFloat lastUploadTs = [FTSUserCenter floatValueForKey:kDftPublishMessageSaveTimeId];
            const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
            if (fNow - lastUploadTs > kRefreshPublishMessageIntervalS) {
                [self loadNetworkDataMore:NO];
            }else{
                self.dataArray = [FTSDataMgr sharedInstance].publishArray;
                self.tempArray = [NSMutableArray arrayWithArray:self.dataArray];
                self.hasMore = TRUE;
                return;
                
            }
    }
    
 
    
}


-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (_nTaskId >0) {
        BqsLog(@"loadNetworkDataMore _nTaskId = %d,",_nTaskId);
        return;
    }
    
    if (!bLoadMore) {
        _curPage = 0;
        self.hasMore = YES;
    
        if (_user == nil) {
            _nTaskId = [FTSNetwork publishTopInfoDownloader:self.downloader Target:self Sel:@selector(onLoadTopDownloadFinished:) Attached:nil userId:nil];
        }else{
            _nTaskId = [FTSNetwork publishTopInfoDownloader:self.downloader Target:self Sel:@selector(onLoadTopDownloadFinished:) Attached:nil userId:[_user stringOfUserId]];
        }
    }else{
        _curPage ++;
        
        NSString *lastId = nil;
        
        id joke = [self.dataArray lastObject];
        if ([joke isKindOfClass:[Words class]]) {
            lastId = [(Words *)joke stringOfId];
        }else if([joke isKindOfClass:[Image class]]){
            lastId = [(Image *)joke stringOfId];
        }else if ([joke isKindOfClass:[Video class]]){
            lastId = [(Video *)joke stringOfId];
        }
        
        if (_user == nil) {
            _nTaskId = [FTSNetwork publishNextInfoDownloader:self.downloader Target:self Sel:@selector(onLoadNextDownloadFinished:) Attached:nil jokeId:lastId userId:nil];
        }else{
           _nTaskId = [FTSNetwork publishNextInfoDownloader:self.downloader Target:self Sel:@selector(onLoadNextDownloadFinished:) Attached:nil jokeId:lastId userId:[_user stringOfUserId]];
            
        }

        
    }
    
    [MobClick endEvent:kUmeng_user_publish_download primarykey:[NSString stringWithFormat:@"%d",_curPage]];
    [self.progressHUD show:YES];

}


#pragma mark
#pragma mark UITableViewDataSource UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *wordsIdentifier = @"words";
    static NSString *imageIdentifier = @"image";
    static NSString *videoIdentifier = @"video";
    static NSString *noIdentifier = @"noclass";
    if (indexPath.row >= [self.dataArray count]) {
        BqsLog(@"FTSActionBaseViewController cellForRowAtIndexPath indexPath.row :%d >= [self.dataArray count] : %d",indexPath.row,[self.dataArray count]);
        FTSPublishWordsCell *cell = (FTSPublishWordsCell *)[aTableView dequeueReusableCellWithIdentifier:noIdentifier];
        if (cell == nil) {
            cell = [[FTSPublishWordsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noIdentifier];
        }
        cell.delegate = self;
        return cell;
    }
    
    id joke = [self.dataArray objectAtIndex:indexPath.row];
    if ([joke isKindOfClass:[Words class]]) {
        FTSPublishWordsCell *cell = (FTSPublishWordsCell *)[aTableView dequeueReusableCellWithIdentifier:wordsIdentifier];
        if (cell == nil) {
            cell = [[FTSPublishWordsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wordsIdentifier];
        }
        cell.delegate = self;
        [cell configCellForWords:(Words *)joke];
        return cell;
        
    }else if([joke isKindOfClass:[Image class]]){
        
        FTSPublishImageCell *cell = (FTSPublishImageCell *)[aTableView dequeueReusableCellWithIdentifier:imageIdentifier];
        if (cell == nil) {
            cell = [[FTSPublishImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageIdentifier];
        }
        cell.delegate = self;
        [cell configCellForImage:(Image *)joke];
        return cell;
        
        
    }else if([joke isKindOfClass:[Video class]]){
        
        FTSPublishVideoCell *cell = (FTSPublishVideoCell *)[aTableView dequeueReusableCellWithIdentifier:videoIdentifier];
        if (cell == nil) {
            cell = [[FTSPublishVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoIdentifier];
        }
        cell.delegate = self;
        [cell configCellForVideo:(Video *)joke];
        return cell;
    }else{
        BqsLog(@"FTSActionBaseViewController cellForRowAtIndexPath joke class not know");
        FTSPublishWordsCell *cell = (FTSPublishWordsCell *)[aTableView dequeueReusableCellWithIdentifier:noIdentifier];
        if (cell == nil) {
            cell = [[FTSPublishWordsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noIdentifier];
        }
        cell.delegate = self;
        return cell;
    }
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= [self.dataArray count]) {
        BqsLog(@"FTSActionBaseViewController indexPath.row :%d >= [self.dataArray count] : %d",indexPath.row,[self.dataArray count]);
        return 0;
    }
    
    id joke = [self.dataArray objectAtIndex:indexPath.row];
    if ([joke isKindOfClass:[Words class]]) {
        
        return [FTSPublishWordsCell caculateHeighForWords:(Words *)joke];
        
        
    }else if([joke isKindOfClass:[Image class]]){
        return [FTSPublishImageCell caculateHeighForImage:(Image *)joke];
        
    }else if([joke isKindOfClass:[Video class]]){
        return [FTSPublishVideoCell caculateHeighForVideo:(Video *)joke];
        
    }else{
        BqsLog(@"FTSActionBaseViewController joke class not know");
        return 0;
    }
    
    return 0;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        return;
        
        [_dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)publishSelectAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= [self.dataArray count]) {
        BqsLog(@"didSelectRowAtIndexPath indexPath.row :%d >= [self.dataArray count] : %d",indexPath.row,[self.dataArray count]);
        return ;
    }
    
    id joke = [self.dataArray objectAtIndex:indexPath.row];
    if ([joke isKindOfClass:[Words class]]) {
        FTSCommentWordsViewController *wordsComment = [[FTSCommentWordsViewController alloc] initWithNibName:nil bundle:nil];
        wordsComment.words = (Words *)joke;
        [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:wordsComment];
        return ;
        
        
    }else if([joke isKindOfClass:[Image class]]){
        FTSCommentImageViewController *imageComment = [[FTSCommentImageViewController alloc] initWithNibName:nil bundle:nil];
        imageComment.image = (Image *)joke;
        [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:imageComment];
        return ;
        
    }else if([joke isKindOfClass:[Video class]]){
        
        BOOL isWifi = [FTSUserCenter BoolValueForKey:kDftNetTypeWifi];
        if (!isWifi) {
            self.playedIndexPath = indexPath;
            [HMPopMsgView showChaoseAlertError:nil Msg:NSLocalizedString(@"title.network.3G.play", self) delegate:self];
            return;
        }

        
        FTSMoviePlayerViewController *playViewController = [[FTSMoviePlayerViewController alloc] initWithVideo:(Video*)joke videoArray:@[joke]];
        playViewController.delegate = self;
        
//        [self.flipboardNavigationController presentViewController:playViewController animated:YES completion:^{}];
       [self.flipboardNavigationController pushViewController:playViewController];
    }else{
        BqsLog(@"FTSActionBaseViewController joke class not know");
        return ;
    }
    
    return ;
    
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
        
        id joke = [self.dataArray objectAtIndex:self.playedIndexPath.row];
        if(![joke isKindOfClass:[Video class]]){
            BqsLog(@"[joke isKindOfClass:[Video class]] = %@",joke);
            return;
        }
        
        
        FTSMoviePlayerViewController *playViewController = [[FTSMoviePlayerViewController alloc] initWithVideo:(Video*)joke videoArray:@[joke]];
        playViewController.delegate = self;
        [self.flipboardNavigationController pushViewController:playViewController];
        
        
    }
    
    
}




-(void)onLoadTopDownloadFinished:(DownloaderCallbackObj*)cb{
    
    _onceLoaded = YES;
    [self.pullView endRefreshing];
    [self.progressHUD hide:YES];
    _nTaskId = -1;
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {
        self.hasMore = FALSE;
        [HMPopMsgView showPopMsgError:cb.error Msg:msg.msg Delegate:nil];
        return;
    }
    
    
    NSArray *reviewList = [Review parseJsonData:cb.rspData];
    
    if (reviewList == nil || [reviewList count] == 0) {
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        self.hasMore = FALSE;
        [HMPopMsgView showPopMsgError:nil Msg:NSLocalizedString(@"jole.useraction.nofollow", nil) Delegate:nil];
        return;
    }
    
    
    self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    
    for (id message in reviewList) {
        [self.tempArray addObject:message];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    if (_user == nil) {
        
        [[FTSDataMgr sharedInstance] savePublishMessageArray:self.dataArray];
        float currett = (float)[NSDate timeIntervalSinceReferenceDate];
        [FTSUserCenter setFloatVaule:currett forKey:kDftPublishMessageSaveTimeId];
    }
    
}


-(void)onLoadNextDownloadFinished:(DownloaderCallbackObj*)cb{
    
    _onceLoaded = YES;
    [self.pullView endRefreshing];
    [self.progressHUD hide:YES];
    _nTaskId = -1;
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {
        self.hasMore = FALSE;
        [HMPopMsgView showPopMsgError:cb.error Msg:msg.msg Delegate:nil];
        return;
    }
    
    
    NSArray *reviewList = [Review parseJsonData:cb.rspData];
    
    if (reviewList == nil || [reviewList count] == 0) {
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        self.hasMore = FALSE;
//        [HMPopMsgView showPopMsgError:nil Msg:NSLocalizedString(@"joke.useraction.nocollect", nil) Delegate:nil];
        return;
    }
    
    if (!self.tempArray) {
        self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    }
    
    
    for (id message in reviewList) {
        [self.tempArray addObject:message];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    if (_user == nil) {
        
        [[FTSDataMgr sharedInstance] savePublishMessageArray:self.dataArray];
        float currett = (float)[NSDate timeIntervalSinceReferenceDate];
        [FTSUserCenter setFloatVaule:currett forKey:kDftPublishMessageSaveTimeId];
    }

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
