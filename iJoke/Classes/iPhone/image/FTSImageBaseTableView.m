//
//  FTSImageBaseTableView.m
//  iJoke
//
//  Created by Kyle on 13-8-15.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSImageBaseTableView.h"
#import "FTSImageTableCell.h"
#import "HMImagePopManager.h"
#import "FTSUIOps.h"
#import "FTSNetwork.h"
#import "FTSDataMgr.h"
#import "FTSDatabaseMgr.h"


@interface FTSImageBaseTableView()<FTSImageTableCellDelegate,HMImagePopManagerDelegate,ImagePopControllerDataSource,ImagePopControllerDelegate,ImageDetailViewControllerDelegate,FTSCommitBaseViewControllerDelegate>{
    NSInteger _shareRow;
}

@property (nonatomic, strong) HMImagePopManager *popMange;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;


@end


@implementation FTSImageBaseTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
    FTSImageTableCell *cell = (FTSImageTableCell *)[aTableView dequeueReusableCellWithIdentifier:cellIden];
    if (!cell) {
        cell = [[FTSImageTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
    }
    cell.delegate = self;
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row];
    
    [cell configCellForImage:info];
    
    return cell;
}



-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row];
    
    return [FTSImageTableCell caculateHeighForImage:info];
    
    
}



#pragma mark
#pragma mark FTSImageTableCellDelegate

- (void)imageTableCell:(FTSImageTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath{
    self.detailController = [[FTSImageDetailViewController alloc] initWithDataArray:self.dataArray hasMore:self.hasMore curIndex:indexPath.row];
    self.detailController.delegate = self;
    self.detailController.baseDelegate = self;
    self.detailController.managedObjectContext =self.managedObjectContext;
    
    //    MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:self.detailController];
    
    [FTSUIOps flipNavigationController:self.parCtl.navigationController.rdv_tabBarController.revealController.flipboardNavigationController pushNavigationWithController:self.detailController];
    
}

- (void)imageTableCell:(FTSImageTableCell *)cell shareIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"share indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row];
    
    if ([info.imageArray count] == 0) {
        BqsLog(@"[info.imageArray count] == 0");
        return;
    }
    
    Picture *piture = [info.imageArray objectAtIndex:0];
    
    if ([cell.imageViews count] == 0) {
        BqsLog(@"[cell.imageViews count] == 0");
        return;
    }
    
    _shareRow = indexPath.row;
    
    JKImageCellImageView *imageView = [cell.imageViews objectAtIndex:0];
    
    [UMSocialSnsService presentSnsIconSheetView:self.parCtl
                                         appKey:[Env sharedEnv].umengId
                                      shareText:piture.content
                                     shareImage:imageView.imageView.image
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,UMShareToQzone,UMShareToSina,UMShareToQQ,UMShareToTencent,UMShareToWechatSession,nil]
                                       delegate:(id<UMSocialUIDelegate>)self];
    
    
    
}


-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    
    if (response.responseCode == UMSResponseCodeSuccess) {
        
        if ([self.dataArray count] <= _shareRow) {
            BqsLog(@"share _shareRow:%d > [self.dataArray count]:%d",_shareRow,self.dataArray.count);
            return;
        }
        Image *info = [self.dataArray objectAtIndex:_shareRow];
        [FTSNetwork shareCountDownloader:self.downloader Target:self Sel:@selector(shareCountCB:) Attached:nil artId:info.imageId type:ImageSectionType];
    }
    
}


#pragma mark
#pragma mark FTSImageTableCellDelegate


- (FTSRecord *)imageRecordFroImageTableCellImage:(Image *)image{
    return [FTSDatabaseMgr judgeRecordImage:image managedObjectContext:self.managedObjectContext];
}


- (void)imageTableCell:(FTSImageTableCell *)cell touchImageIndex:(NSIndexPath *)indexPath{
    
    self.detailController = [[FTSImageDetailViewController alloc] initWithDataArray:self.dataArray hasMore:self.hasMore curIndex:indexPath.row];
    self.detailController.delegate = self;
    self.detailController.baseDelegate = self;
    self.detailController.managedObjectContext = self.managedObjectContext;
    
    [FTSUIOps flipNavigationController:self.parCtl.navigationController.rdv_tabBarController.revealController.flipboardNavigationController pushNavigationWithController:self.detailController];
    return;
    
    
}

- (void)imageTableCell:(FTSImageTableCell *)cell userInfoIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"userInfoIndexPath indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row];
    
    if (info.user == nil) {
        BqsLog(@"wordsDetailHeadViewUserInfo word.user == nil");
        return;
    }
    
    FTSUserInfoViewController *infoViewController = [[FTSUserInfoViewController alloc] initWithUser:info.user];
    [FTSUIOps flipNavigationController:self.parCtl.navigationController.rdv_tabBarController.revealController.flipboardNavigationController pushNavigationWithController:infoViewController];
    
}



- (void)imageTableCell:(FTSImageTableCell *)cell upIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"down indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row];
    
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(downWordsCB:) Attached:indexPath artId:info.imageId type:ImageSectionType upDown:1];
    [FTSDatabaseMgr jokeAddRecordImage:info upType:iJokeUpDownUp managedObjectContext:self.managedObjectContext];
   
    
    //    info.up++;
    
    //    if (!cell) {
    //        BqsLog(@"upWordsCB tableView did not contain cell at indexPath:%@",indexPath);
    //        return ;
    //    }
    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}
- (void)imageTableCell:(FTSImageTableCell *)cell downIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"down indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row];
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(downWordsCB:) Attached:indexPath artId:info.imageId type:ImageSectionType upDown:-1];
    [FTSDatabaseMgr jokeAddRecordImage:info upType:iJokeUpDownDown managedObjectContext:self.managedObjectContext];
    
    //    info.down++;
    
    //    if (!cell) {
    //        BqsLog(@"upWordsCB tableView did not contain cell at indexPath:%@",indexPath);
    //        return ;
    //    }
    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


- (void)imageTableCell:(FTSImageTableCell *)cell favIndexPath:(NSIndexPath *)indexPath addType:(BOOL)value{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"fav indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row];
    
    BOOL login  = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (!login) { //save local
        
        if (value) {
            if([[FTSDataMgr sharedInstance] addOneJokeSave:info]){
                [FTSDatabaseMgr jokeAddRecordImage:info favorite:TRUE managedObjectContext:self.managedObjectContext];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.add.success", nil)];
                [cell refreshRecordState];
                return;
            }
        }else{
            
            if([[FTSDataMgr sharedInstance] removeOneJoke:info]){
                [FTSDatabaseMgr jokeAddRecordImage:info favorite:FALSE managedObjectContext:self.managedObjectContext];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.del.success", nil)];
                [cell refreshRecordState];
                return;
                
            }
        }
        
    }else{
        
        if (value) {
            [FTSNetwork addFavoriteDownloader:self.downloader Target:self Sel:@selector(addFavCB:) Attached:indexPath artId:info.imageId type:ImageSectionType];
        }else{
            [FTSNetwork delFavoriteDownloader:self.downloader Target:self Sel:@selector(delFavCB:) Attached:indexPath artId:info.imageId type:ImageSectionType];
        }
    }
    
    
}



- (void)shareCountCB:(DownloaderCallbackObj *)cb{
    BqsLog(@"FTSWordsTableView share count:%@",cb);
    
    return ; //share count down always be ture,not
    
    
}


- (void)upWordsCB:(DownloaderCallbackObj *)cb{
    BqsLog(@"FTSWordsTableView upWordsCB:%@",cb);
    
    return ; //up or down always be ture,not
    
    
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
   
    if (!msg.code) {
        [HMPopMsgView showPopMsg:msg.msg];
        return;
    }
    
    if (![cb.attached isKindOfClass:[NSIndexPath class]]) {
        
        BqsLog(@"attacth is not kind of NSIndexPath");
        
        return;
        
    }
    NSIndexPath *indexPath = (NSIndexPath *)cb.attached;
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"addFavCB attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.useraction.collect.add.success", nil)];
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
    [FTSDatabaseMgr jokeAddRecordImage:info favorite:TRUE managedObjectContext:self.managedObjectContext];
    
    FTSImageTableCell *cell = (FTSImageTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        BqsLog(@"addFavCB tableView did not contain cell at indexPath:%@",indexPath);
        return ;
    }
    [cell refreshRecordState];
    
    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}


- (void)delFavCB:(DownloaderCallbackObj *)cb{
    
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];

    if (!msg.code) {
        [HMPopMsgView showPopMsg:msg.msg];
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
    [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.useraction.collect.del.success", nil)];
    
    Image *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
    [FTSDatabaseMgr jokeAddRecordImage:info favorite:FALSE managedObjectContext:self.managedObjectContext];
    
    
    FTSImageTableCell *cell = (FTSImageTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell) {
        BqsLog(@"addFavCB tableView did not contain cell at indexPath:%@",indexPath);
        return ;
    }
    [cell refreshRecordState];
    
    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
    //
}





#pragma mark
#pragma mark WordsDetailViewControllerDelegate

- (void)FTSImageDetailViewControllerLoadMore:(FTSImageDetailViewController *)viewControll{
    
    [self loadNetworkDataMore:TRUE];
}


#pragma mark
#pragma mark FTSCommitBaseViewControllerDelegate

- (void)commitViewControllerPopViewController:(FTSCommitBaseViewController *)viewController offset:(NSIndexPath *)indexPath{
    
    
    
    BqsLog(@"commitViewControllerPopViewController offset:%@",indexPath);
    
    NSIndexPath *nIndex = nil;
    
    if (indexPath.row >=[self.dataArray count]) {
        nIndex = [NSIndexPath indexPathForRow:([self.dataArray count]-1) inSection:0];
    }else{
        nIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    }
    
    
    [self.tableView scrollToRowAtIndexPath:nIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self.tableView reloadData];
    
    //    __weak_delegate FTSWordsBaseTableView *wself = self;
    
    
    
    [viewController.flipboardNavigationController popViewControllerWithCompletion:^(void){
        
    }];
    
    
}





@end
