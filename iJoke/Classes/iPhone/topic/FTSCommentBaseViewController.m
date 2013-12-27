//
//  FTSCommentBaseViewController.m
//  iJoke
//
//  Created by Kyle on 13-11-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommentBaseViewController.h"
#import "FTSCommentBaseTableCell.h"
#import "FTSLoadingCell.h"
#import "FTSEmptyCell.h"
#import "FTSUIOps.h"
#import "FTSUserInfoViewController.h"


#define kMtoolBarHeigh 50

@interface FTSCommentBaseViewController ()<pgFootViewDelegate,UIGestureRecognizerDelegate,CommentTableCellDelegate>


@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) PgLoadingFooterView *loadingMoreFootView;
@property (nonatomic, strong, readwrite) ODRefreshControl *pullView;
@property (nonatomic, strong, readwrite) UIInputToolbar *toolBar;
@property (nonatomic, strong, readwrite) UITextField *inputTextField;

@property (nonatomic, strong, readwrite) Downloader *downloader;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@end

@implementation FTSCommentBaseViewController
@synthesize dataArray = _dataArray;
@synthesize hasMore = _hasMore;
@synthesize inputTextField = _inputTextField;
@synthesize toolBar = _toolBar;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize panRecognizer = _panRecognizer;
@synthesize nTaskId = _nTaskId;



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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    Env *env = [Env sharedEnv];
    
    UIImage *revealLeftImagePortrait = [env cacheImage:@"content_navigationbar_back.png"];
    UIImage *revealLeftImageLandscape = [env cacheImage:@"content_navigationbar_back_highlighted.png"];
    
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_setting.png"];
    UIImage *revealRightImageLandscape = [env cacheImage:@"joke_nav_setting_down.png"];
    
    if(DeviceSystemMajorVersion() >=7){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars  = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
        
    }
    
    
    self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:revealLeftImageLandscape title:nil target:self action:@selector(backSuper:)];

    
    // create subview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds)-kMtoolBarHeigh) style:UITableViewStylePlain];
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
        //        self.tableView.tableFooterView = self.loadingMoreFootView;
    }
    
    self.toolBar = [[UIInputToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-kMtoolBarHeigh, CGRectGetWidth(self.view.bounds), kMtoolBarHeigh)];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.toolBar.delegate =(id<UIInputToolbarDelegate>)self;
    self.toolBar.textView.placeholder = NSLocalizedString(@"joke.comment.placeholder", nil);
    [self.view addSubview:self.toolBar];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    _tapRecognizer.delegate = self;
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    _panRecognizer.delegate = self;
    
    
    _hasMore = YES;
    _curPage = 0;
    // create downloade
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    
    self.nTotalNum = -1;
    self.nTaskId = -1;
 
    
    
}

- (void)dealloc{
    [self.downloader cancelAll];
    self.downloader = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma
#pragma mark instance method

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _hasMore = YES;
    _onceLoaded = NO;
    
    
    
    [self tableContentFrsh];
    //    [self performSelector:@selector(tableContentFrsh) withObject:nil afterDelay:1];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.toolBar clearText];
}


- (void)viewWillDisappear:(BOOL)animated{
    self.nTotalNum = -1;
    [self.downloader cancelAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:animated];
}

- (void)tableContentFrsh{
    [self dataFresh:nil];
}


- (void)dataFresh:(id)sender{
    [self loadNetworkDataMore:NO];
}



#pragma mark
#pragma mark - network ops
- (BOOL)loadLocalDataNeedFresh{
    return TRUE;
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
}


- (void)dataFresh{
    
}


#pragma mark keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect toolbarFrame = self.toolBar.frame;
                         toolbarFrame.origin.y = self.view.bounds.size.height - keyboardHeight - toolbarFrame.size.height;
                         self.toolBar.frame = toolbarFrame;
                         
                         //                         CGRect tableViewFrame = self.mTableView.frame;
                         //                         tableViewFrame.size.height = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - keyboardHeight;
                         //                         self.mTableView.frame = tableViewFrame;
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
    
    _keyboardIsShow = TRUE;
   
    [self.view addGestureRecognizer:_tapRecognizer];
    [self.view addGestureRecognizer:_panRecognizer];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect toolbarFrame = self.toolBar.frame;
        toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
        self.toolBar.frame = toolbarFrame;
        
        
    }completion:^(BOOL finished){
        
    }];
    
    
    [self.view removeGestureRecognizer:_tapRecognizer];
    [self.view removeGestureRecognizer:_panRecognizer];
    _keyboardIsShow = FALSE;
}


- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [self.toolBar resignFirstResponder];
}



#pragma mark
#pragma mark UIGestureRecognizerDelegate

#pragma mark
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if([self.toolBar pointInside:[touch locationInView:self.toolBar] withEvent:nil]){
        return NO;
    }
    

    return YES;
    
    
}




#pragma mark
#pragma mark property
- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    [self.tableView reloadData];
    
    if (_dataArray && [_dataArray count]!=0) {
        self.tableView.tableFooterView = self.loadingMoreFootView;
    }
    
    _loadMore = NO;
    
    
    if (!_hasMore) {
        [self.loadingMoreFootView setState:PgFootRefreshAllDown];
    }else{
        [self.loadingMoreFootView setState:PgFootRefreshNormal];
    }
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
#pragma mark CommentTableCellDelegate

- (void)commentTableCellUserInfoAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row >= [self.dataArray count]) {
        BqsLog(@"indexPath.row >= [self.dataArray count]: %d",[self.dataArray count]);
        return ;
    }
    
    Comment *comment = [self.dataArray objectAtIndex:indexPath.row];
    if (comment.user == nil) {
        BqsLog(@"commentTableCellUserInfoAtIndexPath comment user == nil");
        return;
    }
    
    FTSUserInfoViewController *infoViewController = [[FTSUserInfoViewController alloc] initWithUser:comment.user];
    [FTSUIOps flipNavigationController:self.navigationController.flipboardNavigationController pushNavigationWithController:infoViewController];
    
}

#pragma mark
#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray == nil || self.dataArray.count == 0) { //have no data, put notice
        return 1;
    }
    
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"comment";
    static NSString *loadingId = @"loading";
    static NSString *emptyId = @"empty";
    
    if ((self.dataArray == nil || self.dataArray.count == 0)&&!_onceLoaded) { //have not loading , give a loading notice
        FTSLoadingCell *lCell = (FTSLoadingCell *)[aTableView dequeueReusableCellWithIdentifier:loadingId];
        if (!lCell) {
            lCell = [[FTSLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingId];
        }
        
        return lCell;
        
    }else if((self.dataArray == nil || self.dataArray.count == 0)&&_onceLoaded){
        FTSEmptyCell *eCell = (FTSEmptyCell *)[aTableView dequeueReusableCellWithIdentifier:emptyId];
        if (!eCell) {
            eCell = [[FTSEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyId];
        }
        
        return eCell;
    }
    
    
    FTSCommentBaseTableCell *cell = (FTSCommentBaseTableCell *)[aTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FTSCommentBaseTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    if (indexPath.row >= [self.dataArray count]) {
        BqsLog(@"indexPath.row >= [self.dataArray count]: %d",[self.dataArray count]);
        return cell;
    }
    
    cell.numberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"joke.commit.numberfooler", nil),indexPath.row+1];
    Comment *comment = [self.dataArray objectAtIndex:indexPath.row];
    [cell configCellForComment:comment];
    
    return cell;
    
    
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.dataArray || self.dataArray.count == 0) { //have no data, put notice
        return 80;
    }
    
    if (indexPath.row >= [self.dataArray count]) {
        BqsLog(@"indexPath.row >= [self.dataArray count]: %d",[self.dataArray count]);
        return 0;
    }
    
    Comment *comment = [self.dataArray objectAtIndex:indexPath.row];
    return [FTSCommentBaseTableCell caculateHeighForComment:comment];
    
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


#pragma mark
#pragma mark DownloaderCallback
- (void)onLoadCommitListFinished:(DownloaderCallbackObj *)cb{
    
    _onceLoaded = YES;
    [self.pullView endRefreshing];
    
    if(nil == cb) {
        self.hasMore = TRUE;
        return;
    }
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopError:cb.error];
        self.hasMore = TRUE;
        return;
	}
    
    if (nil == self.tempArray) {
        self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    }
    NSArray *arry = [Comment parseJsonData:cb.rspData];
    if (!arry ||[arry count]== 0) {
        self.hasMore = FALSE;
    }else{
        self.hasMore = TRUE;
    }
    
    for (Comment *comment in arry) {
        [self.tempArray addObject:comment];
    }
    self.dataArray = self.tempArray;
    
}


- (void)commitCB:(DownloaderCallbackObj *)cb{
    
    _nTaskId = -1;
    
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
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.comment.add.success", nil)];
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    BqsLog(@"not exist time:%@",time);
    
    BOOL anonymous= FALSE;
    
    if([cb.attached isKindOfClass:[NSNumber class]]){
        anonymous = [((NSNumber *)cb.attached) boolValue];
    }
    BOOL isLogin = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (!isLogin) {
        anonymous = TRUE;
    }
    
    Comment *just = [[Comment alloc] init];
    just.comment = self.toolBar.textView.text;
    just.addtime = time;
    
    if (!anonymous) {
        User *user = [[User alloc] init];
        user.nikeName = [FTSUserCenter objectValueForKey:kDftUserNickName];
        user.userId = [FTSUserCenter intValueForKey:kDftUserId];
        user.icon = [FTSUserCenter objectValueForKey:kDftUserIcon];
        just.user = user;
    }
    
    
    if (nil == self.tempArray) {
        self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    }
    
    [self.tempArray addObject:just];
    
    self.dataArray = self.tempArray;
    
    [self.toolBar clearText];
    
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




#pragma mark UITextField Delegate Methods

-(void)inputButtonPressed:(NSString *)inputText anonymous:(BOOL)anonymous
{
    if (inputText == nil || [inputText length] ==0) {
        [self.toolBar resignFirstResponder];
        return;
    }else if ([inputText length] < 4){
        [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.comment.text.notice", nil)];
        return;
    }else if([inputText length] > 250){
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.comment.text.muchmor", nil)];
        return;
    }

    
    [self sendCommentText:inputText anonymous:anonymous];
    
}

- (void)sendCommentText:(NSString *)text anonymous:(BOOL)anonymous{
    
}


- (void)backSuper:(id)sender{
    
    [self.flipboardNavigationController popViewController];
    
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

- (BOOL)prefersStatusBarHidden
{
    return NO;
}


@end
