//
//  FTSReviewViewController.m
//  iJoke
//
//  Created by Kyle on 13-11-4.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSReviewViewController.h"
#import "Downloader.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "HMPopMsgView.h"
#import "PKRevealController.h"
#import "CustomUIBarButtonItem.h"
#import "MBProgressHUD.h"
#import "FTSNetwork.h"
#import "FTSReviewContentView.h"
#import "Review.h"
#import "Msg.h"

#define kBarHeight 70


@interface FTSReviewViewController ()<ReviewContentViewDelegate>

@property (nonatomic, strong) Downloader *downloader;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FTSReviewContentView *contentView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong) Words *words;
@property (nonatomic, strong) Image *image;

@end

@implementation FTSReviewViewController
@synthesize curIndex = _curIndex;
@synthesize words = _words;
@synthesize image = _image;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = NSLocalizedString(@"joke.category.verify", nil);
    }
    return self;
}
- (void)dealloc{
    [self.downloader cancelAll];
    self.downloader = nil;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    Env *env= [Env sharedEnv];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_option.png"];
    //    UIImage *revealLeftImageLandscape = [env cacheImage:@"joke_nav_option_down.png"];
    
    UIImage *revealLeftImagePortrait = [env cacheImage:@"joke_nav_setting.png"];
    //    UIImage *revealRightImageLandscape = [env cacheImage:@"joke_nav_setting_down.png"];
    
    if (self.navigationController.rdv_tabBarController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:nil title:nil target:self action:@selector(showLeftView:)];
        
    }
    
    if (self.navigationController.rdv_tabBarController.revealController.type & PKRevealControllerTypeRight)
    {
        self.navigationItem.rightBarButtonItem = [CustomUIBarButtonItem initWithImage:revealRightImagePortrait eventImg:nil title:nil target:self action:@selector(showRgihtView:)];
    }

    
    
    
    if(DeviceSystemMajorVersion() >=7){
        
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars  = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
        
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-kBarHeight)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = FALSE;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[FTSReviewContentView alloc] initWithFrame:self.scrollView.bounds];
    self.contentView.delegate = self;
    [self.scrollView addSubview:self.contentView];
    
    
    
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-kBarHeight, CGRectGetWidth(self.view.bounds), kBarHeight)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:toolBar];
    
    UIButton *passBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 106, 50)];
    [passBtn setBackgroundImage:[[Env sharedEnv] cacheImage:@"review_ding_normal.png"] forState:UIControlStateNormal];
    [passBtn setBackgroundImage:[[Env sharedEnv] cacheImage:@"review_ding_select.png"] forState:UIControlStateHighlighted];
    passBtn.backgroundColor = [UIColor clearColor];
    [passBtn addTarget:self action:@selector(pass:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:passBtn];
    
    UIButton *rejectBtn  = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(passBtn.frame)+4, CGRectGetMinY(passBtn.frame), CGRectGetWidth(passBtn.frame), CGRectGetHeight(passBtn.frame))];
    [rejectBtn setBackgroundImage:[[Env sharedEnv] cacheImage:@"review_cai_normal.png"] forState:UIControlStateNormal];
    [rejectBtn setBackgroundImage:[[Env sharedEnv] cacheImage:@"review_cai_select.png"] forState:UIControlStateHighlighted];
    rejectBtn.backgroundColor = [UIColor clearColor];
    [rejectBtn addTarget:self action:@selector(reject:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:rejectBtn];
    
    UIButton *skipBtn  = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rejectBtn.frame)+4, CGRectGetMinY(passBtn.frame), CGRectGetWidth(passBtn.frame), CGRectGetHeight(passBtn.frame))];
    [skipBtn setBackgroundImage:[[Env sharedEnv] cacheImage:@"review_next_normal.png"] forState:UIControlStateNormal];
    [skipBtn setBackgroundImage:[[Env sharedEnv] cacheImage:@"review_next_hilight.png"] forState:UIControlStateHighlighted];
    skipBtn.backgroundColor = [UIColor clearColor];
    [skipBtn addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:skipBtn];
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD .mode = MBProgressHUDModeIndeterminate;
    self.progressHUD .animationType = MBProgressHUDAnimationZoom;
    self.progressHUD .screenType = MBProgressHUDSectionScreen;
    self.progressHUD .opacity = 0.5;
    self.progressHUD .labelText = NSLocalizedString(@"review.laoding.once.title", nil);
    [self.view addSubview:self.progressHUD ];
    [self.progressHUD  hide:YES];

    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    _curIndex = -1;
    _pageNum = 0;
    self.hasMore = TRUE;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_ReviewPage];
    _curIndex = -1;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_nTaskId > 0) {
        return;
    }
    
    _nTaskId  = [FTSNetwork reviewFreshDownloader:self.downloader Target:self Sel:@selector(onLoadRefreshFinished:) Attached:nil];
    [MobClick endEvent:kUmeng_review_fresh_event];
    _pageNum = 0;
    [self.progressHUD show:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.downloader cancelAll];
    _nTaskId = -1;
    [super viewDidDisappear:animated];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_ReviewPage];
    [super viewWillDisappear:animated];
}



- (void)loadMore
{
    if (_nTaskId > 0) {
        BqsLog(@" review next is runing");
        return;
    }
    
    NSInteger wordId = 0;
    
    if (self.dataArray != nil && [self.dataArray count] !=0) {
        id joke = [_dataArray lastObject];
        if ([joke isKindOfClass:[Words class]]) {
            
            wordId = ((Words*)joke).wordId;
    
            
        }else  if ([joke isKindOfClass:[Image class]]) {
            
            wordId = ((Image*)joke).imageId;
          
            
        }else{
            BqsLog(@"set content find a wrong class");
        }

    }

    _pageNum ++;
    [MobClick endEvent:kUmeng_review_fresh_event label:[NSString stringWithFormat:@"%d", _pageNum]];
    _nTaskId = [FTSNetwork reviewNextDownloader:self.downloader Target:self Sel:@selector(onLoadNextDataFinished:) Attached:nil wordId:wordId];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark property
- (void)setDataArray:(NSArray *)dataArray{
    if(dataArray == nil ||[dataArray count] == 0){
        [HMPopMsgView showPopMsgError:nil Msg:NSLocalizedString(@"review.loading.nomore", nil) Delegate:nil];
        return;
    }
    
    _dataArray = dataArray;
    _loadMore = NO;
    _hasMore = YES;
    self.curIndex = 0;
    
    
}

- (void)setCurIndex:(NSInteger)curIndex{
    if (_curIndex == curIndex)
        return;
    
    _curIndex = curIndex;
    
    if(_dataArray == nil ||[_dataArray count] == 0){
        [HMPopMsgView showPopMsgError:nil Msg:NSLocalizedString(@"review.loading.nomore", nil) Delegate:nil];
        return;
    }

    
    if (_curIndex >= [_dataArray count] - 3) {
        BqsLog(@"load next data for preview");
        [self loadMore];
    }
    
    if (_curIndex >= [_dataArray count]) {
        _curIndex = [_dataArray count] -1;
        _lastOne = TRUE;
        BqsLog(@"come to the last one ");
        
        if (self.hasMore && _nTaskId >0) {
            self.progressHUD.labelText = NSLocalizedString(@"review.loading.next.title", nil);
            [self.progressHUD show:YES];

        }
        
    }
    id joke = [_dataArray objectAtIndex:_curIndex];
    if ([joke isKindOfClass:[Words class]]) {
        
        self.words = (Words*)joke;
        self.image = nil;
        
    }else  if ([joke isKindOfClass:[Image class]]) {
        
        self.image = (Image*)joke;
        self.words = nil;
        
    }else{
        BqsLog(@"set content find a wrong class");
    }
    
    
    
}


- (void)setWords:(Words *)words{

    if (_words == words)
        return;
    _words = words;
    if (_words == nil)
        return;
    
    CGFloat heigh = [self.contentView configCellForWords:_words];
    if (heigh == 0) {
        BqsLog(@"height == 0,no need to change");
        return;
    }
    
    CGSize size = self.scrollView.contentSize;
    size.height = heigh;
    self.scrollView.contentSize = size;
}

- (void)setImage:(Image *)image{

    if (_image == image)
        return;
    _image = image;
    
    if (_image == nil)
        return;
    
    CGFloat heigh = [self.contentView configCellForImage:_image];
    if (heigh == 0) {
        BqsLog(@"height == 0,no need to change");
        return;
    }
    CGRect frame = self.contentView.frame;
    frame.size.height = heigh;
    self.contentView.frame = frame;
    
    CGSize size = self.scrollView.contentSize;
    size.height = heigh;
    self.scrollView.contentSize = size;
}



#pragma mark
#pragma mark selector

- (void)pass:(id)sender
{
    NSUInteger jokeId = 0;
    if (_words == nil) {
        jokeId = _image.imageId;
    }else if(_image == nil){
        jokeId = _words.wordId;
    }
    [FTSNetwork reviewAuditorDownloader:self.downloader Target:self Sel:@selector(auditorFinished:) Attached:nil wordId:jokeId type:ReviewTypePass];
    self.curIndex = self.curIndex+1;
    
}


- (void)reject:(id)sender
{
    NSUInteger jokeId = 0;
    if (_words == nil) {
        jokeId = _image.imageId;
    }else if(_image == nil){
        jokeId = _words.wordId;
    }
    [FTSNetwork reviewAuditorDownloader:self.downloader Target:self Sel:@selector(auditorFinished:) Attached:nil wordId:jokeId type:ReviewTypeReject];
    self.curIndex = self.curIndex+1;
    
}


- (void)skip:(id)sender
{
    NSUInteger jokeId = 0;
    if (_words == nil) {
        jokeId = _image.imageId;
    }else if(_image == nil){
        jokeId = _words.wordId;
    }
    [FTSNetwork reviewAuditorDownloader:self.downloader Target:self Sel:@selector(auditorFinished:) Attached:nil wordId:jokeId type:ReviewTypeSkip];
    self.curIndex = self.curIndex+1;

    
    
}

#pragma mark
#pragma mark ReviewContentViewDelegate

#pragma mark
#pragma mark DownloadCallback

- (void)onLoadRefreshFinished:(DownloaderCallbackObj *)cb{
    BqsLog(@"FTSReviewViewController WordStruct:%@",cb);
    
    [self.progressHUD hide:YES];
    _nTaskId = -1;
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    
    self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    NSArray *reviewList = [Review parseJsonData:cb.rspData];
    
    if (reviewList == nil || [reviewList count] == 0) {
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        self.hasMore = FALSE;
        [HMPopMsgView showPopMsgError:nil Msg:NSLocalizedString(@"review.loading.nomore", nil) Delegate:nil];
        return;
    }
    
    for (id message in reviewList) {
        [self.tempArray addObject:message];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    if (msg.freshSize == 0) {
        [self noticeMessageNSString:NSLocalizedString(@"joke.content.nofresh", nil)];
        
    }else{
        [self noticeMessageNSString:[NSString stringWithFormat:NSLocalizedString(@"joke.content.freshnumber", nil),msg.freshSize]];
        
    }

}

-(void)onLoadNextDataFinished:(DownloaderCallbackObj*)cb {
    BqsLog(@"FTSReviewViewController onLoadDataFinished:%@",cb);
    
    [self.progressHUD hide:YES];
    _nTaskId = -1;
    
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
    
    NSArray *reviewList = [Review parseJsonData:cb.rspData];
    
    if (reviewList == nil || [reviewList count] == 0) {
        BqsLog(@"reviewList or reviewList is Null");
        self.hasMore = FALSE;
        [HMPopMsgView showPopMsgError:nil Msg:NSLocalizedString(@"review.loading.nomore", nil) Delegate:nil];
        return;
    }
    
    for (id message in reviewList) {
        [self.tempArray addObject:message];
    }
    self.hasMore = YES;
    
    if (_lastOne == TRUE) {
        
        self.curIndex = self.curIndex + 1;
        _lastOne = FALSE;
        
    }
    
}

- (void)auditorFinished:(DownloaderCallbackObj*)cb{
    //can do nothing, just post the request
    
}

#pragma mark
#pragma mark barbutton method
- (void)showLeftView:(id)sender{
    
    if (self.navigationController.rdv_tabBarController.revealController.focusedController == self.navigationController.rdv_tabBarController.revealController.rightViewController)
    {
        [self.navigationController.rdv_tabBarController.revealController showViewController:self.navigationController.rdv_tabBarController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.rdv_tabBarController.revealController showViewController:self.navigationController.rdv_tabBarController.revealController.leftViewController];
    }

    
}
- (void)showRgihtView:(id)sender
{
    if (self.navigationController.rdv_tabBarController.revealController.focusedController == self.navigationController.revealController.leftViewController)
    {
        [self.navigationController.rdv_tabBarController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.rdv_tabBarController.revealController showViewController:self.navigationController.revealController.rightViewController];
    }
}


@end
