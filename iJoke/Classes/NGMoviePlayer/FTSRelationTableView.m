//
//  FTSRelationTableView.m
//  iJoke
//
//  Created by Kyle on 13-11-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSRelationTableView.h"
#import "FTSRelationTableCell.h"

#define kFreshOffSet -200

#define kAnimationTimeInterval .5
#define kAnimationHoldTimeInterval 1
#define kNoticeLabelHeight 50

@interface FTSRelationTableView()<pgFootViewDelegate,relationTableCellDelegate>


@property (nonatomic, strong, readwrite) UITableView *tableView;
//@property (nonatomic, strong, readwrite) ODRefreshControl *pullView;
//@property (nonatomic, strong, readwrite) PgLoadingFooterView *loadingMoreFootView;
//@property (nonatomic, strong) UILabel *noticeLabel;

@end

@implementation FTSRelationTableView
@synthesize delegate = _delegate;
@synthesize dataArray = _dataArray;
@synthesize hasMore = _hasMore;

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl
{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (nil == self) return nil;
    
    // create subview
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
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
    
    
//    // pull refresh
//    {
//        self.pullView = [[ODRefreshControl alloc] initInScrollView:self.tableView];
//        [self.pullView addTarget:self action:@selector(dataFresh:) forControlEvents:UIControlEventValueChanged];
//    }
    
    // loading more footer
//    {
//        self.loadingMoreFootView = [[PgLoadingFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds),kPgLoadingFooterView_H)];
//        self.loadingMoreFootView.backgroundColor = [UIColor clearColor];
//        self.loadingMoreFootView.delegate = self;
//        self.tableView.tableFooterView = self.loadingMoreFootView;;
//    }
    
    _hasMore = YES;
    _curPage = 0;
    // create downloade
    self.nTotalNum = -1;
    self.nTaskId = -1;
    return self;
    
    
}

#pragma
#pragma mark instance method

- (void)viewWillAppear{
    [super viewWillAppear];
    _hasMore = YES;
    
    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
        self.tableView.contentInset = UIEdgeInsetsMake(64+self.videoOffset, 0, 0, 0);
    }
    
    if(! [self loadLocalDataNeedFresh])
        return;
    [self performSelector:@selector(tableContentFrsh) withObject:nil afterDelay:1];
    
    
}

- (void)tableContentFrsh{
//    CGPoint tableOffset = self.tableView.contentOffset;
//    if (tableOffset.y > 40) {
//        return;
//    }
//    
//    [self.tableView setContentOffset:CGPointMake(0, kFreshOffSet) animated:YES];
}

- (void)dataFresh:(id)sender{
    [self loadNetworkDataMore:NO];
}

-(void)viewDidAppear {
    
    [super viewDidAppear];
    
}



-(void)viewWillDisappear {
    
    self.nTotalNum = -1;
    [super viewWillDisappear];
}


- (void)mainViewOnFont:(BOOL)value{
    if (value) {
        self.tableView.scrollsToTop = YES;
    }else{
        self.tableView.scrollsToTop = NO;
    }
}

#pragma mark
#pragma mark - network ops
- (BOOL)loadLocalDataNeedFresh{
    return TRUE;
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
}


#pragma mark
#pragma mark property
- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self.tableView reloadData];
    _loadMore = NO;
    
}

//- (void)setHasMore:(BOOL)hasMore{
//    
//    _hasMore = hasMore;
//    if (!_hasMore) {
//        [self.loadingMoreFootView setState:PgFootRefreshAllDown];
//    }else{
//        [self.loadingMoreFootView setState:PgFootRefreshNormal];
//    }
//    
//    
//}


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
    static NSString *identifier = @"cell";
    
    FTSRelationTableCell *cell = (FTSRelationTableCell *)[aTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[FTSRelationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if ([self.dataArray count] <= indexPath.row) {
        
        BqsLog(@"[self.dataArray count] = %d <= indexPath.row: = %d",[self.dataArray count],indexPath.row);
        return cell;
    }
    cell.delegate = self;
    Video *video = [self.dataArray objectAtIndex:indexPath.row];
    [cell configCellForVideo:video];
    
    return cell;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataArray count] <= indexPath.row) {
        
        BqsLog(@"[self.dataArray count] = %d <= indexPath.row: = %d",[self.dataArray count],indexPath.row);
        return 100;
    }
    
    Video *video = [self.dataArray objectAtIndex:indexPath.row];
    return [FTSRelationTableCell caculateHeighForVideo:video];

}

#pragma mark
#pragma mark relationTableCellDelegate

- (void)relationTable:(FTSRelationTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath{
    
    BqsLog(@"FTSRelationTableCell selectIndexPath:%@",indexPath);
    
    if ([_delegate respondsToSelector:@selector(relationTableView:selectIndex:)]) {
        
        [_delegate relationTableView:self selectIndex:indexPath.row];
    }
    
}


#pragma mark
#pragma mark PgFootMore
//- (void)footLoadMore
//{
//    if (self.loadingMoreFootView.state == PgFootRefreshAllDown) {
//        return;
//    }
//    [self loadMoreData];
//    
//}

//- (void)loadMoreData{
//    
//    if(self.loadingMoreFootView.state == PgFootRefreshAllDown){
//        return;
//    }
//    
//    _loadMore = YES;
//    
//    [self.loadingMoreFootView setState:PgFootRefreshLoading];
//    
//    [self loadNetworkDataMore:YES];
//}


#pragma mark
#pragma mark - UIScrollViewDelegate Methods
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if(!_loadMore) {
//        float maxoffset = scrollView.contentSize.height - CGRectGetHeight(scrollView.frame)+50;
//        if(maxoffset > 0 && scrollView.contentOffset.y >= maxoffset) {
//            BqsLog(@"trigger load more!, offsety: %.1f, contentsize.h: %.1f, maxoffset:%.1f", scrollView.contentOffset.y, scrollView.contentSize.height, maxoffset);
//            [self loadMoreData];
//        }
//        
//    }
//}





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