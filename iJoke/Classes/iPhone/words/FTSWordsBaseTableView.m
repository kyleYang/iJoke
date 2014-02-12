//
//  FTSWordsTableView.m
//  iJoke
//
//  Created by Kyle on 13-8-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSWordsBaseTableView.h"
#import "FTSUIOps.h"
#import "Msg.h"

@interface FTSWordsBaseTableView()<WordTableCellDelegate,WordsDetailViewControllerDelegate,FTSCommitBaseViewControllerDelegate>{
    NSInteger _shareRow;
}



@end


@implementation FTSWordsBaseTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}




- (void)resaveDataArray{ //save data ,when reload data array;
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
    FTSWordsTableCell *cell = (FTSWordsTableCell *)[aTableView dequeueReusableCellWithIdentifier:cellIden];
    if (!cell) {
        cell = [[FTSWordsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
    }
    
    cell.delegate = self;
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row];
   
    [cell configCellForWords:info];
    
    return cell;
}



-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row];
    
    return [FTSWordsTableCell caculateHeighForWords:info];
    
}


#pragma mark
#pragma mark WordTableCellDelegate

- (void)wordsTableCell:(FTSWordsTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath{
    
    self.detailController = [[FTSWordsDetailViewController alloc] initWithDataArray:self.dataArray hasMore:self.hasMore curIndex:indexPath.row];
    self.detailController.delegate = self;
    self.detailController.baseDelegate = self;
    
//    MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:self.detailController];
    
    [FTSUIOps flipNavigationController:self.parCtl.navigationController.rdv_tabBarController.revealController.flipboardNavigationController pushNavigationWithController:self.detailController];

}


- (void)wordsTableCell:(FTSWordsTableCell *)cell shareIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"share indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    _shareRow = indexPath.row;
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row];
    
    
    [UMSocialSnsService presentSnsIconSheetView:self.parCtl
                                         appKey:nil
                                      shareText:info.content
                                     shareImage:nil
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatTimeline,UMShareToQzone,UMShareToTencent,UMShareToWechatSession,UMShareToQQ,nil]
                                       delegate:(id<UMSocialUIDelegate>)self];
}


- (void)wordsTableCell:(FTSWordsTableCell *)cell commitIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"commit indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }

}

- (void)wordsTableCell:(FTSWordsTableCell *)cell userInfoIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"userInfoIndexPath indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row];
    
    if (info.user == nil) {
        BqsLog(@"wordsDetailHeadViewUserInfo word.user == nil");
        return;
    }
    
    FTSUserInfoViewController *infoViewController = [[FTSUserInfoViewController alloc] initWithUser:info.user];
    [FTSUIOps flipNavigationController:self.parCtl.navigationController.rdv_tabBarController.revealController.flipboardNavigationController pushNavigationWithController:infoViewController];

}

- (void)wordsTableCell:(FTSWordsTableCell *)cell upIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"up indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row];
  
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(upWordsCB:) Attached:indexPath artId:info.wordId type:WordsSectionType upDown:1];
    
  
//    if (!cell) {
//        BqsLog(@"upWordsCB tableView did not contain cell at indexPath:%@",indexPath);
//        return ;
//    }
//    
//    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];

    
    
}
- (void)wordsTableCell:(FTSWordsTableCell *)cell downIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"down indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row];
    
   [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(downWordsCB:) Attached:indexPath artId:info.wordId type:WordsSectionType upDown:-1];
    
   //    if (!cell) {
//        BqsLog(@"upWordsCB tableView did not contain cell at indexPath:%@",indexPath);
//        return ;
//    }
//    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];

    
    
}
- (void)wordsTableCell:(FTSWordsTableCell *)cell favIndexPath:(NSIndexPath *)indexPath addType:(BOOL)value{
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"fav indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row];
    
    BOOL login  = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (!login) { //save local
        
        if (value) {
            if([[FTSDataMgr sharedInstance] addOneJokeSave:info]){
                [[FTSDataMgr sharedInstance] addFavoritedWords:info addType:TRUE];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.add.success", nil)];
                [cell refreshRecordState];
                return;
            }
        }else{
        
            if([[FTSDataMgr sharedInstance] removeOneJoke:info]){
                [[FTSDataMgr sharedInstance] addFavoritedWords:info addType:FALSE];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.del.success", nil)];
                [cell refreshRecordState];
                return;

            }
        }
        
    }else{
        
        if (value) {
            [FTSNetwork addFavoriteDownloader:self.downloader Target:self Sel:@selector(addFavCB:) Attached:indexPath artId:info.wordId type:WordsSectionType];
        }else{
            [FTSNetwork delFavoriteDownloader:self.downloader Target:self Sel:@selector(delFavCB:) Attached:indexPath artId:info.wordId type:WordsSectionType];
        }
    }
    
    
    
}

#pragma mark 
#pragma mark UMSocialUIDelegate

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    
    if (response.responseCode == UMSResponseCodeSuccess) {
        
        if ([self.dataArray count] <= _shareRow) {
            BqsLog(@"share _shareRow:%d > [self.dataArray count]:%d",_shareRow,self.dataArray.count);
            return;
        }
         Words *info = [self.dataArray objectAtIndex:_shareRow];
        [FTSNetwork shareCountDownloader:self.downloader Target:self Sel:@selector(shareCountCB:) Attached:nil artId:info.wordId type:WordsSectionType];
    }
    
}

#pragma mark
#pragma mark WordsDetailViewControllerDelegate

- (void)FTSWordsDetailViewControllerLoadMore:(FTSWordsDetailViewController *)viewControll{
    
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





#pragma mark
#pragma mark DownloaderCallback
- (void)shareCountCB:(DownloaderCallbackObj *)cb{
    BqsLog(@"FTSWordsTableView share count:%@",cb);
    
    return ; //share count down always be ture,not

    
}


- (void)upWordsCB:(DownloaderCallbackObj *)cb{
    BqsLog(@"FTSWordsTableView upWordsCB:%@",cb);
    
    return ; //up or down always be ture,not 
    
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
        BqsLog(@"upWordsCB attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
    [[FTSDataMgr sharedInstance] addRecordWords:info upType:iJokeUpDownUp];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell) {
        BqsLog(@"upWordsCB tableView did not contain cell at indexPath:%@",indexPath);
        return ;
    }
    
    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
    

}

- (void)downWordsCB:(DownloaderCallbackObj *)cb{
    
    BqsLog(@"FTSWordsTableView upWordsCB:%@",cb);
    
    return ; //up or down always be ture
    
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
        BqsLog(@"downWords attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell) {
        BqsLog(@"downWords tableView did not contain cell at indexPath:%@",indexPath);
        return ;
    }
    
    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self resaveDataArray];

    

    
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
    
    if (![cb.attached isKindOfClass:[NSIndexPath class]]) {
        
        BqsLog(@"attacth is not kind of NSIndexPath");
        
        return;
        
    }
    NSIndexPath *indexPath = (NSIndexPath *)cb.attached;
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"addFavCB attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
    [[FTSDataMgr sharedInstance] addFavoritedWords:info addType:TRUE];
    
    FTSWordsTableCell *cell = (FTSWordsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell) {
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
    
    Words *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
    [[FTSDataMgr sharedInstance] addFavoritedWords:info addType:FALSE];
    
    
    FTSWordsTableCell *cell = (FTSWordsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell) {
        BqsLog(@"addFavCB tableView did not contain cell at indexPath:%@",indexPath);
        return ;
    }
    [cell refreshRecordState];
    
//    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
//    
}




@end
