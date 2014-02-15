//
//  NGMoviePlayerViewController.m
//  NGMoviePlayerDemo
//
//  Created by Tretter Matthias on 13.03.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "FTSMoviePlayerViewController.h"
#import "Video.h"
#import "HMPopMsgView.h"
//#import "HumDotaVideoManager.h"
#import "FTSUserCenter.h"
#import "FTSDataMgr.h"
#import "SDSegmentedControl.h"
#import "MptContentScrollView.h"
#import "FTSVideoCommentTableView.h"
#import "FTSRelationTableView.h"
#import "FTSDescriptionTableView.h"
#import "FTSNetwork.h"
#import "Downloader.h"
#import "HMPopMsgView.h"
#import "Msg.h"
#import "FTSDatabaseMgr.h"

#define kScreenHeighOff 180

#define kSegmentControlHeiht 35

@interface FTSMoviePlayerViewController ()<scrollDataSource,scrollDelegate,CommitBaseCellDelegate,UIGestureRecognizerDelegate,relationTableViewDelegate,DescriptionTableViewDelegate,UIActionSheetDelegate> {
    NSUInteger activeCount_;
    NSString *_strUrl;
    NSString *_title;
    CGFloat _offset;
}

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NGMoviePlayer *moviePlayer;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) NSString *strUrl;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL usedDone;
@property (nonatomic, strong) UIView *otherView;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *downButton;
@property (nonatomic, strong) UILabel *descript;
@property (nonatomic, strong) UILabel *helpMsg;
@property (nonatomic, strong) SDSegmentedControl *segmentedControl;
@property (nonatomic, strong) MptContentScrollView *contentView;

@property (nonatomic, strong) UIView *maskView; //for keybord show

@property (nonatomic, strong) FTSVideoCommentTableView *commentCell;
@property (nonatomic, strong) FTSRelationTableView *relateCell;
@property (nonatomic, strong) FTSDescriptionTableView *descriptionCell;

@property (nonatomic, assign) NSInteger videoIndex;

@property (nonatomic,strong) Downloader *downloader;


@end

@implementation FTSMoviePlayerViewController

@synthesize containerView = _containerView;
@synthesize moviePlayer = _moviePlayer;
@synthesize usedDone = _usedDone;
@synthesize strUrl = _strUrl;
@synthesize title = _title;
@synthesize videoIndex = _videoIndex;
@synthesize video = _video;
@synthesize dataArray = _dataArray;

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)dealloc{
    [self.downloader cancelAll];
    self.downloader = nil;
}


- (id)initWithVideo:(Video *)vide{
    self =[super init];
    if (self) {
        _video = vide;
    }
    return self;
    
}

- (id)initWithVideo:(Video *)vide videoArray:(NSArray*)array{
    self =[super init];
    if (self) {
        _video = vide;
        _dataArray = array;
    }
    return self;
}

- (id)initWithUrl:(NSString *)url title:(NSString *)title{
    self = [super init];
    if (self) {
        _strUrl = url;
        _title = title;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _usedDone =  FALSE;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    VideoScreenStatus videoState= [FTSUserCenter intValueForKey:kScreenPlayType];
    if(_video != nil){
        switch (videoState) {
            case VideoScreenNormal:
                _strUrl = _video.flv;
                break;
            case VideoScreenClear:
                _strUrl = _video.mp4;
                break;
            case VideoScreenHD:
                _strUrl = self.video.hd2;
                break;
            default:
                _strUrl = _video.mp4;
                break;
        }
        _title = _video.title;
        
    }
    
    _offset = 0;
    if (DeviceSystemMajorVersion()>=7) {
        _offset = 20;
    }
    
    
    
    self.moviePlayer = [[NGMoviePlayer alloc] initWithURL:[NSURL URLWithString:_strUrl] title:_title];
    self.moviePlayer.autostartWhenReady = YES;
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, _offset, self.view.bounds.size.width,kScreenHeighOff)];
    self.containerView.backgroundColor = [UIColor underPageBackgroundColor];
    
    self.moviePlayer.delegate = self;
    [self.moviePlayer addToSuperview:self.containerView withFrame:self.containerView.bounds];
    
    
    
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,_offset, 49, 44)];
    
    [self.backBtn setBackgroundImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/demoback"] forState:UIControlStateNormal];
    [self.backBtn setBackgroundImage:[UIImage imageNamed:@"NGMoviePlayer.bundle/demobackdown"] forState:UIControlStateHighlighted];
    //    backBtn.showsTouchWhenHighlighted = YES;
    self.backBtn.backgroundColor = [UIColor clearColor];
    [self.backBtn addTarget:self action:@selector(backMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.otherView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.containerView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.containerView.frame))];
    [self.view addSubview:self.otherView];
    
    //    "video.detail.title" = "详情";
    //    "video.detail.comment" = "评论"
    //    "video.detail.tuijian" = "推荐";
    
    self.segmentedControl = [[SDSegmentedControl alloc] initWithItems:@[NSLocalizedString(@"video.detail.title", nil),NSLocalizedString(@"video.detail.comment", nil),NSLocalizedString(@"video.detail.tuijian", nil)]];
    self.segmentedControl.frame = CGRectMake(0, 0, CGRectGetWidth(self.otherView.frame), kSegmentControlHeiht);
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    [self.segmentedControl addTarget:self action:@selector(sectionChanged:) forControlEvents:UIControlEventValueChanged];
    [self.otherView addSubview:self.segmentedControl];
    
    self.contentView = [[MptContentScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.segmentedControl.frame), CGRectGetWidth(self.otherView.frame), CGRectGetHeight(self.otherView.frame)-CGRectGetMaxY(self.segmentedControl.frame))];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.otherView addSubview:self.contentView];
    
    
    
    
    
    //    self.downButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-55, 5, 40, 40)];
    //    [self.downButton addTarget:self action:@selector(moviePlayerDidDownload:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.otherView addSubview:self.downButton];
    //    [self.downButton setBackgroundImage:[[Env sharedEnv] cacheImage:@"video_download.png"] forState:UIControlStateNormal];
    //    [self.downButton setBackgroundImage:[[Env sharedEnv] cacheImage:@"video_download_down.png"] forState:UIControlStateHighlighted];
    //
    //
    //    self.favButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.downButton.frame)-55, 2, 40, 40)];
    //    [self.otherView  addSubview:self.favButton];
    //    [self.favButton addTarget:self action:@selector(addFavVideo:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.favButton setBackgroundImage:[[Env sharedEnv] cacheImage:@"video_addFav.png"] forState:UIControlStateNormal];
    //    [self.favButton setBackgroundImage:[[Env sharedEnv] cacheImage:@"video_addFav_did.png"] forState:UIControlStateSelected];
    //
    //
    //    self.descript = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.favButton.frame)+10, CGRectGetWidth(self.otherView.bounds)-2*10 , 0)];
    //    self.descript.font = [UIFont systemFontOfSize:16.0f];
    //    self.descript.numberOfLines = 0;
    //    self.descript.backgroundColor = [UIColor clearColor];
    //    [self.otherView addSubview:self.descript];
    //
    //    self.helpMsg = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.descript.frame), CGRectGetMaxY(self.descript.frame)+10, CGRectGetWidth(self.descript.frame) , 0)];
    //    self.helpMsg.font = [UIFont systemFontOfSize:16.0f];
    //    self.helpMsg.numberOfLines = 0;
    //    self.helpMsg.backgroundColor = [UIColor clearColor];
    //    [self.otherView addSubview:self.helpMsg];
    
    [self.view addSubview:self.containerView];
    
    [self.view addSubview:self.backBtn];
    
    
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
}


#pragma mark
#pragma mark view

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.segmentedControl.selectedSegmentIndex = 1;
    self.contentView.dataSource = self;
    self.contentView.delegate = self;
    [self.contentView setCurrentItemIndex:1 animation:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kNetworkStateChangeTo3G object:nil]
    ;
    
    if(self.video){
        self.favButton.selected = FALSE; //[[HumDotaDataMgr instance] judgeFavVideo:self.video];
        
        CGSize size = [self.video.summary sizeWithFont:self.descript.font constrainedToSize:CGSizeMake(self.descript.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect frame = self.descript.frame;
        frame.size.height = size.height;
        self.descript.frame = frame;
        self.descript.text = self.video.summary;
        
        size = [NSLocalizedString(@"detail.progrome.player.help", nil) sizeWithFont:self.helpMsg.font constrainedToSize:CGSizeMake(self.helpMsg.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        frame = self.helpMsg.frame;
        frame.size.height = size.height;
        frame.origin.y = (CGRectGetWidth(self.descript.frame)==0?0:10)+CGRectGetMaxY(self.descript.frame);
        self.helpMsg.frame = frame;
        self.helpMsg.text = NSLocalizedString(@"detail.progrome.player.help", nil);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkStateChangeTo3G object:nil];
    [self.downloader cancelAll];
    [super viewWillDisappear:animated];
    
}

#pragma mark
#pragma mark scrollDataSource scrollDelegate
- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
    return self.segmentedControl.numberOfSegments;
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    
    static NSString *dscripId = @"descell";
    static NSString *commintId = @"commintcell";
    static NSString *relationId = @"relationcell";
    
    if (index == 0) {
        FTSDescriptionTableView *cell = (FTSDescriptionTableView *)[scrollView dequeueCellWithIdentifier:dscripId];
        if (cell == nil) {
            cell = [[FTSDescriptionTableView alloc] initWithFrame:frame withIdentifier:dscripId withController:self];
        }
        self.descriptionCell = cell;
        cell.delegate = self;
        cell.videoOffset = -64;
        cell.video = _video;
        return cell;
        
    }else if(index == 1){
        
        FTSVideoCommentTableView *cell = (FTSVideoCommentTableView *)[scrollView dequeueCellWithIdentifier:commintId];
        if (cell == nil) {
            cell = [[FTSVideoCommentTableView alloc] initWithFrame:frame withIdentifier:commintId withController:self];
        }
        self.commentCell = cell;
        cell.videoOffset = -64;
        cell.video = _video;
        cell.inputDelegate = self;
        return cell;
        
    }else if(index == 2){
        
        FTSRelationTableView *cell = (FTSRelationTableView *)[scrollView dequeueCellWithIdentifier:relationId];
        if (cell == nil) {
            cell = [[FTSRelationTableView alloc] initWithFrame:frame withIdentifier:relationId withController:self];
        }
        cell.videoOffset = -64;
        cell.dataArray = _dataArray;
        cell.delegate = self;
        self.relateCell = cell;
        return cell;
        
    }
    
    return nil;
    
}


- (void)sectionChanged:(id)sender{
    
    [self.contentView setCurrentItemIndex:self.segmentedControl.selectedSegmentIndex animation:YES];
}

- (void)scrollView:(MptContentScrollView *)scrollView curIndex:(NSInteger)index
{
    if (index >= self.segmentedControl.numberOfSegments) {
        BqsLog(@"index = %d > self.segmentedControl.numberOfSegments = %d",index, self.segmentedControl.numberOfSegments);
        return;
    }
    self.segmentedControl.selectedSegmentIndex = index;
}




#pragma mark
#pragma mark DescriptionTableViewDelegate

- (FTSRecord *)recordForDescriptionTableViewVideo:(Video *)video{
    
    return [FTSDatabaseMgr judgeRecordVideo:video managedObjectContext:self.managedObjectContext];
}


- (void)descriptionTableView:(FTSDescriptionTableView *)cell upVideo:(Video *)video{
    if (video == nil) {
        BqsLog(@"descriptionTableView upVideo video == nil");
        return;
    }
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(downWordsCB:) Attached:_video artId:_video.videoId type:VideoSectionType upDown:1];
    [FTSDatabaseMgr jokeAddRecordVideo:_video upType:iJokeUpDownUp managedObjectContext:self.managedObjectContext];

    
    
}
- (void)descriptionTableView:(FTSDescriptionTableView *)cell downVideo:(Video *)video{
    
    if (video == nil) {
        BqsLog(@"descriptionTableView downVideo video == nil");
        return;
    }
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(downWordsCB:) Attached:_video artId:_video.videoId type:VideoSectionType upDown:-1];
    [FTSDatabaseMgr jokeAddRecordVideo:_video upType:iJokeUpDownDown managedObjectContext:self.managedObjectContext];
    
}
- (void)descriptionTableView:(FTSDescriptionTableView *)cell favVideo:(Video *)video addType:(BOOL)value{ //vale: true for add and false for del favorite
    if (video == nil) {
        BqsLog(@"descriptionTableView favVideo video == nil");
        return;
    }
    
    BOOL login  = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (!login) { //save local
        
        if (value) {
            if([[FTSDataMgr sharedInstance] addOneJokeSave:_video]){
                [FTSDatabaseMgr jokeAddRecordVideo:_video favorite:TRUE managedObjectContext:self.managedObjectContext];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.add.success", nil)];
                [cell refreshRecordState];
                return;
            }
        }else{
            
            if([[FTSDataMgr sharedInstance] removeOneJoke:_video]){
                [FTSDatabaseMgr jokeAddRecordVideo:_video favorite:FALSE managedObjectContext:self.managedObjectContext];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.del.success", nil)];
                [cell refreshRecordState];
                return;
                
            }
        }
        
    }else{
        
        if (value) {
            [FTSNetwork addFavoriteDownloader:self.downloader Target:self Sel:@selector(addFavCB:) Attached:_video artId:_video.videoId type:VideoSectionType];
        }else{
            [FTSNetwork delFavoriteDownloader:self.downloader Target:self Sel:@selector(delFavCB:) Attached:_video artId:_video.videoId type:VideoSectionType];
        }
    }
    
    
}

- (void)reportMessageTableView:(FTSDescriptionTableView *)cell video:(Video *)video{
    if (video == nil) {
        BqsLog(@"reportMessageTableView favVideo video == nil");
        return;
    }
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"joke.comment.report", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"joke.navigation.report", nil), nil];
    [actionSheet showInView:self.view];
    
}


#pragma mark
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 ) { //click report
        
        [self reportMessage];
        
    }
    
}

- (void)reportMessage{
    
    Video *video = self.descriptionCell.video;
    
#ifdef iJokeAdministratorVersion
    
    [FTSNetwork deleteMessageDownloader:self.downloader Target:self Sel:@selector(reportMessageCB:) Attached:nil artId:video.videoId type:VideoSectionType];
#else
    
   [FTSNetwork reportMessageDownloader:self.downloader Target:self Sel:@selector(reportMessageCB:) Attached:nil artId:video.videoId type:VideoSectionType];
#endif
    
    
   
}

- (void)reportMessageCB:(DownloaderCallbackObj *)cb{
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    
    if (!msg.code) {
        [HMPopMsgView showPopMsg:msg.msg];
        return;
    }else{
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.comment.report.ok", nil)];
    }
    
    
}


- (void)downWordsCB:(DownloaderCallbackObj *)cb{
    
    BqsLog(@"FTSWordsTableView upWordsCB:%@",cb);
    
    return ; //up or down always be ture
    
    
}

- (void)addFavCB:(DownloaderCallbackObj *)cb{
    
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
    
    if (![cb.attached isKindOfClass:[Video class]]) {
        
        BqsLog(@"add favorite attacth is not kind of Video");
        
        return;
        
    }
    
    Video *info = (Video *)cb.attached; //should set data and save data
    [FTSDatabaseMgr jokeAddRecordVideo:info favorite:TRUE managedObjectContext:self.managedObjectContext];
    
    [self.descriptionCell refreshRecordState];
    
    
}

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
    
    if (![cb.attached isKindOfClass:[Video class]]) {
        
        BqsLog(@"delete favorite attacth is not kind of Video");
        
        return;
        
    }
    
    Video *info = (Video *)cb.attached; //should set data and save data
    [FTSDatabaseMgr jokeAddRecordVideo:info favorite:FALSE managedObjectContext:self.managedObjectContext];
    
    [self.descriptionCell refreshRecordState];
    
    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
    //
}




#pragma mark
#pragma mark relationTableViewDelegate

- (void)relationTableView:(FTSRelationTableView *)tableView selectIndex:(NSUInteger)index{
    
    BqsLog(@"FTSRelationTableView selectIndex:%d",index);
    
    if (index >= [_dataArray count]) {
        
        BqsLog(@"FTSRelationTableView index = %d >= [_dataArray count] = %d", index, [_dataArray count]);
        
        return;
        
    }
    
    Video *video = [_dataArray objectAtIndex:index];
    self.video = video;
    
}


#pragma mark
#pragma mark CommitBaseCellDelegate

- (void)CommitBaseCellkeyboardWillShow{
    BqsLog(@"CommitBaseCellkeyboardWillShow");
    
    if (self.maskView == nil) {
        
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.containerView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.containerView.frame)+CGRectGetHeight(self.segmentedControl.frame))];
        self.maskView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
        tapRecognizer.delegate = self;
        
        [self.maskView addGestureRecognizer:tapRecognizer];
        
    }
    [self.view insertSubview:self.maskView belowSubview:self.backBtn];
    
    
}

- (void)CommitBaseCellkeyboardWillHidden{
    BqsLog(@"CommitBaseCellkeyboardWillHidden");
    
    [self.maskView removeFromSuperview];
    
}


- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [self.commentCell.toolBar resignFirstResponder];
}



#pragma mark
#pragma mark porperty

- (void)setVideo:(Video *)video{
    if (_video == video) return;
    
    _video = video;
    VideoScreenStatus videoState= [FTSUserCenter intValueForKey:kScreenPlayType];
    if(_video != nil){
        switch (videoState) {
            case VideoScreenNormal:
                _strUrl = _video.flv;
                break;
            case VideoScreenClear:
                _strUrl = _video.mp4;
            case VideoScreenHD:
                _strUrl = self.video.hd2;
            default:
                _strUrl = _video.mp4;
                break;
        }
        _title = _video.title;
        self.moviePlayer.videoName = _title;
        [self.moviePlayer setURL:[NSURL URLWithString:_strUrl]];
        
    }
    
    self.commentCell.video = _video;
    self.descriptionCell.video = _video;
    
}



#pragma mark - Notifications
- (void)orientationDidChangeNotification:(NSNotification *)notification
{
    //    UIDeviceOrientation orientation = [[ UIDevice currentDevice ] orientation ];
    //    [self updateToOrientation:orientation];
}
- (void)backMethod:(id)sender{
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(moviePlayerViewController:didFinishWithResult:error:)]) {
        [_delegate moviePlayerViewController:self didFinishWithResult:NGMoviePlayerCancelled error:nil];
    }
}

- (void)networkChanged:(NSNotification *)notification
{
    [self.moviePlayer pause];
   
    [HMPopMsgView showChaoseAlertError:nil Msg:NSLocalizedString(@"tilt.newtwork.3G.continue", self) delegate:self];
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    BqsLog(@"alertView didClick Button at index:%d",buttonIndex);
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
        [self backMethod:nil];
        
    }else if(buttonIndex == 1){
        [self.moviePlayer play];
    }
    
    
}




////////////////////////////////////////////////////////////////////////
#pragma mark - NGMoviePlayer
////////////////////////////////////////////////////////////////////////


- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didChangeControlStyle:(NGMoviePlayerControlStyle)controlStyle {
    
    if (controlStyle == NGMoviePlayerControlStyleInline) {
        _usedDone = FALSE;
        [self updateToOrientation:UIDeviceOrientationPortrait];
        
    } else {
        [self updateToOrientation:UIDeviceOrientationLandscapeLeft];
        _usedDone = YES;
    }
}


- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didFailToLoadURL:(NSURL *)URL {
    NSLog(@"moviePlayer didFailToLoadURL : %@", URL);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(moviePlayerViewController:didFinishWithResult:error:)]) {
        [_delegate moviePlayerViewController:self didFinishWithResult:NGMoviePlayerURLError error:nil];
    }
}


- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didChangePlaybackRate:(float)rate {
    NSLog(@"PlaybackRate chagned %f", rate);
}

- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didFinishPlaybackOfURL:(NSURL *)URL {
    NSLog(@"Playbackfinished with Player: %@", moviePlayer);
    if (self.video != nil && self.dataArray != nil) { //load next
        NSInteger index = [self.dataArray indexOfObject:self.video];
        if (index>=0 && index <[self.dataArray count]-1) {
            BqsLog(@"current play index:%d",index);
            self.video = [self.dataArray objectAtIndex:index+1];
            return ;
        }
        
        
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(moviePlayerViewController:didFinishWithResult:error:)]) {
        [_delegate moviePlayerViewController:self didFinishWithResult:NGMoviePlayerFinished error:nil];
    }
}

- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didChangeStatus:(AVPlayerStatus)playerStatus {
    NSLog(@"Status chaned: %d", playerStatus);
}
//
//- (void)moviePlayerDidDownload:(NGMoviePlayer *)moviePlayer{
//    
//    
//    BOOL haveNet = [FTSUserCenter BoolValueForKey:kDftHaveNetWork];
//    if (!haveNet) {
//        [HMPopMsgView showAlterError:nil Msg:NSLocalizedString(@"detail.video.download.nonetwork", nil) Delegate:self];
//        return;
//    }
//    
//    VideoScreenStatus videoState= [FTSUserCenter intValueForKey:kScreenPlayType];
//    
//    
//    BOOL isWifi = [FTSUserCenter BoolValueForKey:kDftNetTypeWifi];
//    if (!isWifi) {
//        [HMPopMsgView showAlterError:nil Msg:NSLocalizedString(@"detail.video.3G.download", nil) Delegate:self];
//        return;
//    }
//    
//    //    TaskStatusSuccess = 1,
//    //    TaskStatusAlready = 2,
//    //    TaskStatusExist = 3,
//    //    TaskStatusFailed = 4,
//    
//    //    "video.download.already.downloaded" = "该视频已经存在,请进入视频管理界面管理";
//    //    "video.download.already.downloading" = "该视频已经在下载列表,请进入视频管理界面管理";
//    //    "video.download.addsuccess" = "添加下载视频成功,请进入视频管理界面管理";
//    //    "video.download.failed" = "添加下载视频失败,请稍后重试";
//    //    "video.download.unknow" = "未知错误,请稍后重试";
//    AddVideoTaskStatus addStatus ;
//    NSString *tipsNSString = nil;
//    if(self.video){
//        addStatus  =  [[HumDotaVideoManager instance] addDownloadTaskForVideo:self.video withStep:videoState];
//    }else{
//        tipsNSString = NSLocalizedString(@"video.download.already.downloaded", nil);
//        [HMPopMsgView showPopMsgError:nil Msg:tipsNSString Delegate:nil];
//        NSLog(@"download not news or video");
//        return;
//    }
//    
//    switch (addStatus) {
//        case TaskStatusSuccess:
//            tipsNSString = NSLocalizedString(@"video.download.addsuccess", nil);
//            break;
//        case TaskStatusAlready:
//            tipsNSString = NSLocalizedString(@"video.download.already.downloading", nil);
//            break;
//        case TaskStatusExist:
//            tipsNSString = NSLocalizedString(@"video.download.already.downloaded", nil);
//            break;
//        case TaskStatusFailed:
//            tipsNSString = NSLocalizedString(@"video.download.failed", nil);
//            break;
//        default:
//            tipsNSString = NSLocalizedString(@"video.download.unknow", nil);
//            break;
//    }
//    
//    [HMPopMsgView showPopMsgError:nil Msg:tipsNSString Delegate:nil];
//    
//    
//    
//}

- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didPlayStep:(int)setp initialPlaybackTime:(NSTimeInterval)initialPlaybackTime{
    
    
    VideoScreenStatus videoState= [FTSUserCenter intValueForKey:kScreenPlayType];
    if(self.video){
        switch (videoState) {
            case VideoScreenNormal:
                _strUrl = self.video.flv;
                break;
            case VideoScreenClear:
                _strUrl = self.video.mp4;
            case VideoScreenHD:
                _strUrl = self.video.hd2;
            default:
                _strUrl = self.video.mp4;
                break;
        }
        
    }
    [self.moviePlayer setURL:[NSURL URLWithString:_strUrl] initialPlaybackTime:initialPlaybackTime];
    
    
    
}

- (NSUInteger)moviePlayer:(NGMoviePlayer *)moviePlayer numberOfRowInSection:(NSUInteger)section{
    
    return [self.dataArray count];
    
}
- (NSString *)moviePlayer:(NGMoviePlayer *)moviePlayer titleInIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row >= self.dataArray.count) {
        
        return NSLocalizedString(@"video.tableview.notitle", nil);
    }
    
    Video *titleVideo = [self.dataArray objectAtIndex:indexPath.row];
    
    NSString *title = NSLocalizedString(@"videoldetail.tuijian.notilte", nil);
    
    if (titleVideo.title != nil && titleVideo.title.length > 0) {
        title = titleVideo.title;
    }else if(titleVideo.summary != nil && titleVideo.summary.length > 0){
        title = titleVideo.summary;
    }
    return title;

}
- (void)moviePlayer:(NGMoviePlayer *)moviePlayer didSelectIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row >= self.dataArray.count) {
        BqsLog(@"moviePlayer dataArray < didSelectIndexPath = %@",indexPath);
        return ;
    }
    self.video = [self.dataArray objectAtIndex:indexPath.row];
    
}


- (void)addFavVideo:(id)sender{
    
}


- (void)updateToOrientation:(UIDeviceOrientation)orientation
{
    //    if (_usedDone) {
    //        return;
    //    }
    
    CGRect bounds = [[ UIScreen mainScreen ] bounds ];
    CGRect videoBounds = [[ UIScreen mainScreen ] bounds ];
    CGAffineTransform t;
    CGFloat r = 0;
    switch (orientation ) {
        case UIDeviceOrientationLandscapeRight:
            r = -(M_PI / 2);
            break;
        case UIDeviceOrientationLandscapeLeft:
            r  = M_PI / 2;
            break;
        default :
            break;
    }
    if( r != 0 ){
        
        CGSize sz = bounds.size;
        bounds.size.width = sz.height;
        bounds.size.height = sz.width;
        videoBounds = bounds;
        
        t = CGAffineTransformMakeRotation( r );
        
        self.backBtn.hidden = YES;
        
        UIApplication *application = [ UIApplication sharedApplication ];
        
        self.containerView.bounds = videoBounds;
        self.containerView.center = CGPointMake(CGRectGetHeight(bounds)/2, CGRectGetWidth(bounds)/2-(DeviceSystemMajorVersion()>=7?0:20));
        
        
        [UIView animateWithDuration:[ application statusBarOrientationAnimationDuration ] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
            self.containerView.transform = t;
//            self.containerView.bounds = videoBounds;
            //            self.containerView.center = CGPointMake(CGRectGetWidth(videoBounds)/2, CGRectGetHeight(videoBounds)/2);
            //            self.otherView.frame = CGRectMake(0, CGRectGetMaxY(self.containerView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.containerView.frame));
        }completion:^(BOOL finish){
            //            self.containerView.center = CGPointMake(CGRectGetWidth(videoBounds)/2, CGRectGetHeight(videoBounds)/2);
        }];
        [application setStatusBarOrientation:(UIInterfaceOrientation)orientation animated: YES ];
        
        
        //        videoBounds.origin.y = -120;
        //        videoBounds.origin.y = -140;
        
    }else{
        CGSize sz = bounds.size;
        bounds.size.width = sz.width;
        bounds.size.height = sz.height;
        
        videoBounds.size.width = sz.width;
        videoBounds.size.height = kScreenHeighOff;
        //        self.wantsFullScreenLayout = NO;
        //        videoBounds.origin.y = 20;
        
        t = CGAffineTransformMakeRotation( r );
        
        UIApplication *application = [ UIApplication sharedApplication ];
        
        self.containerView.bounds = videoBounds;
        self.containerView.center = CGPointMake(CGRectGetWidth(videoBounds)/2, CGRectGetHeight(videoBounds)/2+_offset);
        
        [UIView animateWithDuration:[ application statusBarOrientationAnimationDuration ] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
            //            self.view.transform = t;
            //            self.view.bounds = bounds;
            //            self.view.center = CGPointMake(CGRectGetWidth(bounds)/2, CGRectGetHeight(bounds)/2);
            
            self.containerView.transform = t;
            
            //            self.otherView.frame = CGRectMake(0, CGRectGetMaxY(self.containerView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.containerView.frame));
        }completion:^(BOOL finish){
            //           self.containerView.frame = videoBounds;
            //            CGRect frme = self.backBtn.frame;
            //            frme.origin.y = 20;
            //            self.backBtn.frame = frme;
            self.backBtn.hidden = NO;
            //            [self setAdPosition:CGPointMake(AD_POS_CENTER, AD_POS_REWIND)];
        }];
        [application setStatusBarOrientation:(UIInterfaceOrientation)orientation animated: YES ];
        
        
    }
    
    
}




///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark rotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
};

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}



@end