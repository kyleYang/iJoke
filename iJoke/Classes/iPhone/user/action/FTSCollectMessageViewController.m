//
//  FTSCollectMessageViewController.m
//  iJoke
//
//  Created by Kyle on 13-11-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCollectMessageViewController.h"
#import "FTSCollectImageCell.h"
#import "FTSCollectWordsCell.h"
#import "FTSCollectVideoCell.h"

@interface FTSCollectMessageViewController ()<collectWordsCellDelegate,CollectImageCellDelegate,FTSCollectVideoCellDelegate>{
    
    BOOL _login;
    NSIndexPath *_playedIndexPath;
    
}

@property (nonatomic, strong) NSIndexPath *playedIndexPath;

@property (nonatomic, strong, readwrite) User *user;

@end

@implementation FTSCollectMessageViewController
@synthesize user = _user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUser:(User *)info{
    self = [super init];
    if (self) {
        self.user = info;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    Env *env = [Env sharedEnv];
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_option.png"];
    UIImage *revealRightImageLandscape = [env cacheImage:@"joke_nav_option.png"];
    self.navigationItem.rightBarButtonItem = [CustomUIBarButtonItem initWithImage:revealRightImagePortrait eventImg:revealRightImageLandscape title:nil target:self action:@selector(editTable:)];
    
    //    "joke.useraciton.collect.mytitle" = "我的收藏";
    //    "joke.useraction.collect.noname" = "本地收藏";
    
    _login = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    
    
    NSString *userName = NSLocalizedString(@"joke.useraction.collect.noname", nil);;
    if (_user != nil) {
        
        self.navigationItem.rightBarButtonItem = nil;
        
        userName = _user.nikeName;;
        if (userName == nil || userName.length == 0) {
            userName = _user.userName;
        }
        if (userName == nil || userName.length == 0) {
            userName = NSLocalizedString(@"joke.useraction.publish.noname", nil);
        }
        
        
    }else{
        if (_login) {
            userName = NSLocalizedString(@"joke.useraciton.collect.mytitle", nil);
        }
    }
    self.navigationItem.title = userName;
    
    
    
}

- (void)editTable:(id)sender{
    
    if (self.tableView.isEditing) {
        [self.tableView setEditing:FALSE animated:YES];
    }else{
        [self.tableView setEditing:YES animated:YES];
    }
    
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
    }else{
        
        if (!_login) { //not login ,load local data;
            self.dataArray = [FTSDataMgr sharedInstance].collectArray ;
            self.hasMore = FALSE;
            return;
        }else{
            
            CGFloat lastUploadTs = [FTSUserCenter floatValueForKey:kDftCollectMessageSaveTimeId];
            const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
            if (fNow - lastUploadTs > kRefreshCollectMessageIntervalS) {
                [self loadNetworkDataMore:NO];
            }else{
                self.dataArray = [FTSDataMgr sharedInstance].collectArray;
                self.tempArray = [NSMutableArray arrayWithArray:self.dataArray];
                self.hasMore = TRUE;
                return;
                
            }
        }
        
    }
    
}


-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (_nTaskId >0) {
        return;
    }
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        self.tempArray = nil;
    }else{
        _curPage ++;
    }
    
    if (_user != nil) {
         _nTaskId = [FTSNetwork collectInfoDownloader:self.downloader Target:self Sel:@selector(onLoadDownloadFinished:) Attached:nil page:_curPage userId:[_user stringOfUserId]];
    }else if (_login){
        _nTaskId = [FTSNetwork collectInfoDownloader:self.downloader Target:self Sel:@selector(onLoadDownloadFinished:) Attached:nil page:_curPage userId:nil];
    }else {
        [self.pullView endRefreshing];
        return;
    }
   
    [MobClick endEvent:kUmeng_user_collect_download primarykey:[NSString stringWithFormat:@"%d",_curPage]];
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
        FTSCollectWordsCell *cell = (FTSCollectWordsCell *)[aTableView dequeueReusableCellWithIdentifier:noIdentifier];
        if (cell == nil) {
            cell = [[FTSCollectWordsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noIdentifier];
        }
        cell.delegate = self;
        return cell;
    }
    
    id joke = [self.dataArray objectAtIndex:indexPath.row];
    if ([joke isKindOfClass:[Words class]]) {
        FTSCollectWordsCell *cell = (FTSCollectWordsCell *)[aTableView dequeueReusableCellWithIdentifier:wordsIdentifier];
        if (cell == nil) {
            cell = [[FTSCollectWordsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:wordsIdentifier];
        }
        cell.delegate = self;
        [cell configCellForWords:(Words *)joke];
        return cell;
        
    }else if([joke isKindOfClass:[Image class]]){
        
        FTSCollectImageCell *cell = (FTSCollectImageCell *)[aTableView dequeueReusableCellWithIdentifier:imageIdentifier];
        if (cell == nil) {
            cell = [[FTSCollectImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageIdentifier];
        }
        cell.delegate = self;
        [cell configCellForImage:(Image *)joke];
        return cell;
        
        
    }else if([joke isKindOfClass:[Video class]]){
        
        FTSCollectVideoCell *cell = (FTSCollectVideoCell *)[aTableView dequeueReusableCellWithIdentifier:videoIdentifier];
        if (cell == nil) {
            cell = [[FTSCollectVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoIdentifier];
        }
        cell.delegate = self;
        [cell configCellForVideo:(Video *)joke];
        return cell;
    }else{
        BqsLog(@"FTSActionBaseViewController cellForRowAtIndexPath joke class not know");
        FTSCollectWordsCell *cell = (FTSCollectWordsCell *)[aTableView dequeueReusableCellWithIdentifier:noIdentifier];
        if (cell == nil) {
            cell = [[FTSCollectWordsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noIdentifier];
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
        
        return [FTSCollectWordsCell caculateHeighForWords:(Words *)joke];
        
        
    }else if([joke isKindOfClass:[Image class]]){
        return [FTSCollectImageCell caculateHeighForImage:(Image *)joke];
        
    }else if([joke isKindOfClass:[Video class]]){
        return [FTSCollectVideoCell caculateHeighForVideo:(Video *)joke];
        
    }else{
        BqsLog(@"FTSActionBaseViewController joke class not know");
        return 0;
    }
    
    return 0;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_user != nil) {
        return NO;
    }
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    
        // Delete the row from the data source
        
        if ([_dataArray count] <= indexPath.row) {
            
            BqsLog(@"commitEditingStyle [_dataArray count] <= indexPath.row");
            
            return;
        }

        
        if (_user == nil && _login) {
            
            
            id joke = [_dataArray objectAtIndex:indexPath.row];
            if ([joke isKindOfClass:[Words class]]) {
                [FTSNetwork delFavoriteDownloader:self.downloader Target:self Sel:@selector(delFavCB:) Attached:indexPath artId:((Words *)joke).wordId type:WordsSectionType];
                
            }else if([joke isKindOfClass:[Image class]]){
                [FTSNetwork delFavoriteDownloader:self.downloader Target:self Sel:@selector(delFavCB:) Attached:indexPath artId:((Image *)joke).imageId type:ImageSectionType];
            }else if([joke isKindOfClass:[Video class]]){
                [FTSNetwork delFavoriteDownloader:self.downloader Target:self Sel:@selector(delFavCB:) Attached:indexPath artId:((Video *)joke).videoId type:VideoSectionType];
            }
            
            
        }else if(!_login){
            
            id joke = [_dataArray objectAtIndex:indexPath.row];
            if ([joke isKindOfClass:[Words class]]) {
                [[FTSDataMgr sharedInstance] addFavoritedWords:(Words *)joke addType:FALSE];
            }else if([joke isKindOfClass:[Image class]]){
                [[FTSDataMgr sharedInstance] addFavoritedImages:(Image *)joke addType:FALSE];
            }else if([joke isKindOfClass:[Video class]]){
                [[FTSDataMgr sharedInstance] addFavoritedVideo:(Video *)joke addType:FALSE];
            }

            
            [_dataArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[FTSDataMgr sharedInstance] saveCollectMessageArray:self.dataArray];
            self.hasMore = FALSE;
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)collectSelectAtIndexPath:(NSIndexPath *)indexPath{
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
        [self.flipboardNavigationController pushViewController:playViewController];
//        [self.flipboardNavigationController presentViewController:playViewController animated:YES completion:^{}];
    }else{
        BqsLog(@"FTSActionBaseViewController joke class not know");
        return ;
    }
    
    return ;
    
}



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
    
    [self.flipboardNavigationController popViewController];
//    [ctl dismissViewControllerAnimated:YES completion:^{}];
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



#pragma mark
#pragma mark downloadcallback
- (void)delFavCB:(DownloaderCallbackObj *)cb{
    
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    [HMPopMsgView showPopMsg:msg.msg];
    if (!msg.code) {
        
        return;
    }
    
    if (![cb.attached isKindOfClass:[NSIndexPath class]]) {
        
        BqsLog(@"attacth is not kind of NSIndexPath");
        
        return;
        
    }
    NSIndexPath *indexPath = (NSIndexPath *)cb.attached;
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"delFavCB attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    id joke = [_dataArray objectAtIndex:indexPath.row];
    if ([joke isKindOfClass:[Words class]]) {
       [[FTSDataMgr sharedInstance] addFavoritedWords:(Words *)joke addType:FALSE];
    }else if([joke isKindOfClass:[Image class]]){
        [[FTSDataMgr sharedInstance] addFavoritedImages:(Image *)joke addType:FALSE];
    }else if([joke isKindOfClass:[Video class]]){
        [[FTSDataMgr sharedInstance] addFavoritedVideo:(Video *)joke addType:FALSE];
    }
    
    [_dataArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [[FTSDataMgr sharedInstance] saveCollectMessageArray:self.dataArray];
}



-(void)onLoadDownloadFinished:(DownloaderCallbackObj*)cb{
    
    _onceLoaded = YES;
    
    [self.progressHUD hide:YES];
    [self.pullView endRefreshing];
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
        [HMPopMsgView showPopMsgError:nil Msg:NSLocalizedString(@"joke.useraction.nocollect", nil) Delegate:nil];
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
        
        [[FTSDataMgr sharedInstance] saveCollectMessageArray:self.dataArray];
        float currett = (float)[NSDate timeIntervalSinceReferenceDate];
        [FTSUserCenter setFloatVaule:currett forKey:kDftCollectMessageSaveTimeId];
    }
    
}


@end
