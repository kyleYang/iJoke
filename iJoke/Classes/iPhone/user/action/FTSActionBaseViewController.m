//
//  FTSActionBaseViewController.m
//  iJoke
//
//  Created by Kyle on 13-11-13.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSActionBaseViewController.h"


#define kFreshOffSet -200

@interface FTSActionBaseViewController ()

@property (nonatomic, strong, readwrite) YFJLeftSwipeDeleteTableView *tableView;
@property (nonatomic, strong, readwrite) ODRefreshControl *pullView;
@property (nonatomic, strong, readwrite) PgLoadingFooterView *loadingMoreFootView;
@property (nonatomic, strong, readwrite) MBProgressHUD *progressHUD;
@end

@implementation FTSActionBaseViewController
@synthesize nTaskId = _nTaskId;
@synthesize dataArray = _dataArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (DeviceSystemMajorVersion() >= 7) {
        
        self.automaticallyAdjustsScrollViewInsets = YES;
        
    }
    Env *env = [Env sharedEnv];
    UIImage *revealLeftImagePortrait = [env cacheImage:@"content_navigationbar_back.png"];
    UIImage *revealLeftImageLandscape = [env cacheImage:@"content_navigationbar_back_highlighted.png"];
    
    
    
    self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:revealLeftImageLandscape title:nil target:self action:@selector(backSuper:)];
    
       
    
    self.tableView = [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
    {
        self.pullView = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [self.pullView addTarget:self action:@selector(dataFresh:) forControlEvents:UIControlEventValueChanged];
    }
    
    // loading more footer
    {
        self.loadingMoreFootView = [[PgLoadingFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds),kPgLoadingFooterView_H)];
        self.loadingMoreFootView.backgroundColor = [UIColor clearColor];
        self.loadingMoreFootView.delegate = self;
        self.tableView.tableFooterView = self.loadingMoreFootView;;
    }
    
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD .mode = MBProgressHUDModeIndeterminate;
    self.progressHUD .animationType = MBProgressHUDAnimationZoom;
    self.progressHUD .screenType = MBProgressHUDSectionScreen;
    self.progressHUD .opacity = 0.5;
    self.progressHUD .labelText = NSLocalizedString(@"joke.useraction.message.freshing", nil);
    [self.view addSubview:self.progressHUD ];
    [self.progressHUD  hide:YES];
    
    _onceLoaded = FALSE;
    _hasMore = YES;
    _curPage = 0;
    // create downloade
    self.nTotalNum = -1;
    self.nTaskId = -1;
    
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
}


- (void)backSuper:(id)sender{
    
    [self.flipboardNavigationController popViewController];
    
}



#pragma
#pragma mark instance method

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _hasMore = YES;
    
    //    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
    //        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    //    }
    
    if (_onceLoaded) {
        return;
    }
    [self loadLocalDataNeedFresh];
    
    
}



- (void)dataFresh:(id)sender{
    [self loadNetworkDataMore:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}



-(void)viewWillDisappear:(BOOL)animated {
    
    self.nTotalNum = -1;
    [super viewWillDisappear:animated];
}




#pragma mark
#pragma mark - network ops
- (void)loadLocalDataNeedFresh{
    
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
}


#pragma mark
#pragma mark property
- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    [self.tableView reloadData];
    _loadMore = NO;
    
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}



@end
