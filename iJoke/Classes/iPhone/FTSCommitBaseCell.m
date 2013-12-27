//
//  FTSDetailBaseCell.m
//  iJoke
//
//  Created by Kyle on 13-8-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommitBaseCell.h"
#import "FTSCommentBaseTableCell.h"
#import "FTSLoadingCell.h"
#import "FTSEmptyCell.h"
#import "FTSUIOps.h"
#import "FTSUserInfoViewController.h"

#define kMtoolBarHeigh 50


@interface FTSCommitBaseCell()<pgFootViewDelegate,UIGestureRecognizerDelegate,CommentTableCellDelegate>


@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) PgLoadingFooterView *loadingMoreFootView;
@property (nonatomic, strong, readwrite) ODRefreshControl *pullView;
@property (nonatomic, strong, readwrite) UIInputToolbar *toolBar;
@property (nonatomic, strong, readwrite) UITextField *inputTextField;

@property (nonatomic, strong, readwrite) Downloader *downloader;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@end

@implementation FTSCommitBaseCell

@synthesize dataArray = _dataArray;
@synthesize hasMore = _hasMore;
@synthesize inputTextField = _inputTextField;
@synthesize toolBar = _toolBar;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize panRecognizer = _panRecognizer;
@synthesize inputDelegate = _inputDelegate;

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl
{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (nil == self) return nil;
    
    // create subview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.bounds),  CGRectGetHeight(self.bounds)-kMtoolBarHeigh) style:UITableViewStylePlain];
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
    [self addSubview:self.tableView];
    
    // pull refresh
    {
        self.pullView = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [self.pullView addTarget:self action:@selector(dataFresh:) forControlEvents:UIControlEventValueChanged];
    }

    
    // loading more footer
    {
        self.loadingMoreFootView = [[PgLoadingFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds),kPgLoadingFooterView_H)];
        self.loadingMoreFootView.backgroundColor = [UIColor clearColor];
        self.loadingMoreFootView.delegate = self;
//        self.tableView.tableFooterView = self.loadingMoreFootView;
    }
    
    self.toolBar = [[UIInputToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-kMtoolBarHeigh, CGRectGetWidth(self.bounds), kMtoolBarHeigh)];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.toolBar.delegate =(id<UIInputToolbarDelegate>)self;
    self.toolBar.textView.placeholder = NSLocalizedString(@"joke.comment.placeholder", nil);;
    [self addSubview:self.toolBar];
    
  
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
    return self;
    
    
}

- (void)dealloc{
    [self.downloader cancelAll];
    self.downloader = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.toolBar.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-kMtoolBarHeigh, CGRectGetWidth(self.bounds), kMtoolBarHeigh);
    //    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
}

#pragma
#pragma mark instance method

- (void)viewWillAppear{
    [super viewWillAppear];
    _hasMore = YES;
    _onceLoaded = NO;
    
    
    
    [self tableContentFrsh];
//    [self performSelector:@selector(tableContentFrsh) withObject:nil afterDelay:1];

}



- (void)viewWillDisappear{
   
    [self.downloader cancelAll];
     self.nTotalNum = -1;
    self.tableView.tableFooterView = nil;
    [super viewWillDisappear];
}

- (void)tableContentFrsh{
    [self dataFresh:nil];
}


- (void)dataFresh:(id)sender{
    [self loadNetworkDataMore:NO];
}


-(void)viewDidAppear {
    [super viewDidAppear];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.toolBar clearText];
    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
        self.tableView.contentInset = UIEdgeInsetsMake(64+self.videoOffset, 0, 0, 0);
    }
    
}





- (void)mainViewOnFont:(BOOL)value{
    if (value) {
        self.tableView.scrollsToTop = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];        
    }else{
        self.tableView.scrollsToTop = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        
    }
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
                         toolbarFrame.origin.y = self.bounds.size.height - keyboardHeight - toolbarFrame.size.height;
                         self.toolBar.frame = toolbarFrame;
                         
//                         CGRect tableViewFrame = self.mTableView.frame;
//                         tableViewFrame.size.height = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - keyboardHeight;
//                         self.mTableView.frame = tableViewFrame;
                     }
                     completion:^(BOOL finished) {

                     }
     ];
    
    _keyboardIsShow = TRUE;
    if ([_inputDelegate respondsToSelector:@selector(CommitBaseCellkeyboardWillShow)]) {
        
        [_inputDelegate CommitBaseCellkeyboardWillShow];
    }
    
    [self addGestureRecognizer:_tapRecognizer];
    [self addGestureRecognizer:_panRecognizer];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect toolbarFrame = self.toolBar.frame;
        toolbarFrame.origin.y = self.bounds.size.height - toolbarFrame.size.height;
        self.toolBar.frame = toolbarFrame;

        
    }completion:^(BOOL finished){
        
    }];
    
    if ([_inputDelegate respondsToSelector:@selector(CommitBaseCellkeyboardWillShow)]) {
        
        [_inputDelegate CommitBaseCellkeyboardWillHidden];
    }
    
    [self removeGestureRecognizer:_tapRecognizer];
    [self removeGestureRecognizer:_panRecognizer];
    _keyboardIsShow = FALSE;
}




- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [self.toolBar resignFirstResponder];
}

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
    [FTSUIOps flipNavigationController:self.parCtl.navigationController.flipboardNavigationController pushNavigationWithController:infoViewController];

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







@end
