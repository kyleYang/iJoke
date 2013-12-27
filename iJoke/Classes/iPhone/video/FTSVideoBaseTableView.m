//
//  FTSVideoBaseTableView.m
//  iJoke
//
//  Created by Kyle on 13-9-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSVideoBaseTableView.h"
#import "FTSVideoTableCell.h"
#import "FTSUIOps.h"
#import "FTSMoviePlayerViewController.h"

#define kRelationMaxNum 30

@interface FTSVideoBaseTableView()<FTSVideoTableCellDelegate,MoviePlayerViewControllerDelegate>{
    
    NSIndexPath *_playedIndexPath;
    
}


@property (nonatomic, strong)  NSIndexPath *playedIndexPath;

@end


@implementation FTSVideoBaseTableView
@synthesize playedIndexPath = _playedIndexPath;


- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
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
    FTSVideoTableCell *cell = (FTSVideoTableCell *)[aTableView dequeueReusableCellWithIdentifier:cellIden];
    if (!cell) {
        cell = [[FTSVideoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
    }
    
    cell.delegate = self;
    
    Video *info = [self.dataArray objectAtIndex:indexPath.row];
    
    [cell configCellForVideo:info];
    
    return cell;
}



-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Video *info = [self.dataArray objectAtIndex:indexPath.row];
    
    return [FTSVideoTableCell caculateHeighForVideo:info];
    
}


#pragma mark
#pragma mark WordTableCellDelegate

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
//    [ctl dismissViewControllerAnimated:YES completion:^{}];
    [self.parCtl.navigationController.revealController.flipboardNavigationController popViewController];
}



- (void)videoTableCell:(FTSVideoTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([self.dataArray count] <= indexPath.row) {
        BqsLog(@"videoTableCell selectIndexPath indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
        return;
    }
    
    BOOL isWifi = [FTSUserCenter BoolValueForKey:kDftNetTypeWifi];
    if (!isWifi) {
        self.playedIndexPath = indexPath;
        [HMPopMsgView showChaoseAlertError:nil Msg:NSLocalizedString(@"title.network.3G.play", self) delegate:self];
        return;
    }
    
    
    Video *info = [self.dataArray objectAtIndex:indexPath.row];
    
    NSMutableArray *videoArray = [NSMutableArray arrayWithArray:self.dataArray];
    BOOL hasBefore = YES;
    while ([videoArray count] > kRelationMaxNum) {
        
        Video *temp = nil;
        
        if (hasBefore) {
            temp = [videoArray objectAtIndex:0];
            if (temp == info) {
                hasBefore = FALSE;
            }else{
                [videoArray removeObjectAtIndex:0];
            }

        }else{
            [videoArray removeLastObject];
        }

    }
    
    
    FTSMoviePlayerViewController *playViewController = [[FTSMoviePlayerViewController alloc] initWithVideo:info videoArray:videoArray];
    playViewController.delegate = self;
//    [self.parCtl.navigationController.revealController.flipboardNavigationController presentViewController:playViewController animated:YES completion:^{}];
    [self.parCtl.navigationController.revealController.flipboardNavigationController pushViewController:playViewController];
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

        
        Video *info = [self.dataArray objectAtIndex:self.playedIndexPath.row];
        
        NSMutableArray *videoArray = [NSMutableArray arrayWithArray:self.dataArray];
        BOOL hasBefore = YES;
        while ([videoArray count] > kRelationMaxNum) {
            
            Video *temp = nil;
            
            if (hasBefore) {
                temp = [videoArray objectAtIndex:0];
                if (temp == info) {
                    hasBefore = FALSE;
                }else{
                    [videoArray removeObjectAtIndex:0];
                }
                
            }else{
                [videoArray removeLastObject];
            }
            
        }
        
        
        FTSMoviePlayerViewController *playViewController = [[FTSMoviePlayerViewController alloc] initWithVideo:info videoArray:videoArray];
        playViewController.delegate = self;
        //    [self.parCtl.navigationController.revealController.flipboardNavigationController presentViewController:playViewController animated:YES completion:^{}];
        [self.parCtl.navigationController.revealController.flipboardNavigationController pushViewController:playViewController];


    }
    
    
}


//- (void)wordsTableCell:(FTSWordsTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath{
//    
//    self.detailController = [[FTSWordsDetailViewController alloc] initWithDataArray:self.dataArray hasMore:self.hasMore curIndex:indexPath.row];
//    self.detailController.delegate = self;
//    self.detailController.baseDelegate = self;
//    
//    //    MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:self.detailController];
//    
//    [FTSUIOps flipNavigationController:self.parCtl.navigationController.revealController.flipboardNavigationController pushNavigationWithController:self.detailController];
//    
//}
//
//
//- (void)wordsTableCell:(FTSWordsTableCell *)cell shareIndexPath:(NSIndexPath *)indexPath{
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"share indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    _shareRow = indexPath.row;
//    
//    Words *info = [self.dataArray objectAtIndex:indexPath.row];
//    
//    
//    [UMSocialSnsService presentSnsIconSheetView:self.parCtl
//                                         appKey:nil
//                                      shareText:info.content
//                                     shareImage:nil
//                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatTimeline,UMShareToTencent,UMShareToQzone,UMShareToWechatSession,nil]
//                                       delegate:(id<UMSocialUIDelegate>)self];
//}
//
//
//- (void)wordsTableCell:(FTSWordsTableCell *)cell commitIndexPath:(NSIndexPath *)indexPath{
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"commit indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    
//    
//    
//}
//- (void)wordsTableCell:(FTSWordsTableCell *)cell upIndexPath:(NSIndexPath *)indexPath{
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"up indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    Words *info = [self.dataArray objectAtIndex:indexPath.row];
//    [FTSNetwork dingWordsDownloader:self.downloader Target:self Sel:@selector(upWordsCB:) Attached:indexPath wordId:info.wordId type:1];
//    
//    
//    //    if (!cell) {
//    //        BqsLog(@"upWordsCB tableView did not contain cell at indexPath:%@",indexPath);
//    //        return ;
//    //    }
//    //
//    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//    
//    
//}
//- (void)wordsTableCell:(FTSWordsTableCell *)cell downIndexPath:(NSIndexPath *)indexPath{
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"down indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    Words *info = [self.dataArray objectAtIndex:indexPath.row];
//    [FTSNetwork dingWordsDownloader:self.downloader Target:self Sel:@selector(downWordsCB:) Attached:indexPath wordId:info.wordId type:-1];
//    
//    //    if (!cell) {
//    //        BqsLog(@"upWordsCB tableView did not contain cell at indexPath:%@",indexPath);
//    //        return ;
//    //    }
//    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//    
//    
//}
//- (void)wordsTableCell:(FTSWordsTableCell *)cell favIndexPath:(NSIndexPath *)indexPath addType:(BOOL)value{
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"fav indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    Words *info = [self.dataArray objectAtIndex:indexPath.row];
//    
//    if (value) {
//        [FTSNetwork addFavWordsDownloader:self.downloader Target:self Sel:@selector(addFavCB:) Attached:indexPath wordId:info.wordId];
//    }else{
//        [FTSNetwork delFavWordsDownloader:self.downloader Target:self Sel:@selector(delFavCB:) Attached:indexPath wordId:info.wordId];
//    }
//    
//    
//    
//}

#pragma mark
#pragma mark UMSocialUIDelegate

//-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
//    
//    if (response.responseCode == UMSResponseCodeSuccess) {
//        
//        if ([self.dataArray count] <= _shareRow) {
//            BqsLog(@"share _shareRow:%d > [self.dataArray count]:%d",_shareRow,self.dataArray.count);
//            return;
//        }
//        Words *info = [self.dataArray objectAtIndex:_shareRow];
//        [FTSNetwork shareCountDownloader:self.downloader Target:self Sel:@selector(shareCountCB:) Attached:nil wordId:info.wordId];
//    }
//    
//}

#pragma mark
#pragma mark WordsDetailViewControllerDelegate

//- (void)FTSWordsDetailViewControllerLoadMore:(FTSWordsDetailViewController *)viewControll{
//    
//    [self loadNetworkDataMore:TRUE];
//}


#pragma mark
#pragma mark FTSCommitBaseViewControllerDelegate

//- (void)commitViewControllerPopViewController:(FTSCommitBaseViewController *)viewController offset:(NSIndexPath *)indexPath{
//    
//    
//    
//    BqsLog(@"commitViewControllerPopViewController offset:%@",indexPath);
//    
//    NSIndexPath *nIndex = nil;
//    
//    if (indexPath.row >=[self.dataArray count]) {
//        nIndex = [NSIndexPath indexPathForRow:([self.dataArray count]-1) inSection:0];
//    }else{
//        nIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
//    }
//    
//    
//    [self.tableView scrollToRowAtIndexPath:nIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    
//    [self.tableView reloadData];
//    
//    //    __weak_delegate FTSWordsBaseTableView *wself = self;
//    
//    
//    
//    [viewController.flipboardNavigationController popViewControllerWithCompletion:^(void){
//        
//    }];
//    
//    
//}
//




#pragma mark
#pragma mark DownloaderCallback
//- (void)shareCountCB:(DownloaderCallbackObj *)cb{
//    BqsLog(@"FTSWordsTableView share count:%@",cb);
//    
//    return ; //share count down always be ture,not
//    
//    
//}
//
//
//- (void)upWordsCB:(DownloaderCallbackObj *)cb{
//    BqsLog(@"FTSWordsTableView upWordsCB:%@",cb);
//    
//    return ; //up or down always be ture,not
//    
//    if(nil == cb) return;
//    
//    if(nil != cb.error || 200 != cb.httpStatus) {
//		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
//        return;
//	}
//    
//    Msg *msg = [Msg parseJsonData:cb.rspData];
//    if (!msg.code) {
//        [HMPopMsgView showPopMsg:msg.msg];
//        return;
//    }
//    
//    if (![cb.attached isKindOfClass:[NSIndexPath class]]) {
//        
//        BqsLog(@"attacth is not kind of NSIndexPath");
//        
//        return;
//        
//    }
//    NSIndexPath *indexPath = (NSIndexPath *)cb.attached;
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"upWordsCB attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    Words *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
//    [[FTSDataMgr sharedInstance] addRecordWords:info upType:iJokeUpDownUp];
//    
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    
//    if (!cell) {
//        BqsLog(@"upWordsCB tableView did not contain cell at indexPath:%@",indexPath);
//        return ;
//    }
//    
//    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//    
//}
//
//- (void)downWordsCB:(DownloaderCallbackObj *)cb{
//    
//    BqsLog(@"FTSWordsTableView upWordsCB:%@",cb);
//    
//    return ; //up or down always be ture
//    
//    if(nil == cb) return;
//    
//    if(nil != cb.error || 200 != cb.httpStatus) {
//		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
//        return;
//	}
//    
//    Msg *msg = [Msg parseJsonData:cb.rspData];
//    if (!msg.code) {
//        [HMPopMsgView showPopMsg:msg.msg];
//        return;
//    }
//    
//    if (![cb.attached isKindOfClass:[NSIndexPath class]]) {
//        
//        BqsLog(@"attacth is not kind of NSIndexPath");
//        
//        return;
//        
//    }
//    NSIndexPath *indexPath = (NSIndexPath *)cb.attached;
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"downWords attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    Words *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
//    
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    
//    if (!cell) {
//        BqsLog(@"downWords tableView did not contain cell at indexPath:%@",indexPath);
//        return ;
//    }
//    
//    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//    [self resaveDataArray];
//    
//    
//    
//    
//}
//
//- (void)addFavCB:(DownloaderCallbackObj *)cb{
//    
//    if(nil == cb) return;
//    
//    if(nil != cb.error || 200 != cb.httpStatus) {
//		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
//        return;
//	}
//    
//    Msg *msg = [Msg parseJsonData:cb.rspData];
//    [HMPopMsgView showPopMsg:msg.msg];
//    if (!msg.code) {
//        return;
//    }
//    
//    if (![cb.attached isKindOfClass:[NSIndexPath class]]) {
//        
//        BqsLog(@"attacth is not kind of NSIndexPath");
//        
//        return;
//        
//    }
//    NSIndexPath *indexPath = (NSIndexPath *)cb.attached;
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"addFavCB attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    Words *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
//    [[FTSDataMgr sharedInstance] addFavoritedWords:info addType:TRUE];
//    
//    FTSWordsTableCell *cell = (FTSWordsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//    
//    if (!cell) {
//        BqsLog(@"addFavCB tableView did not contain cell at indexPath:%@",indexPath);
//        return ;
//    }
//    [cell refreshRecordState];
//    
//    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//    
//}
//
//- (void)delFavCB:(DownloaderCallbackObj *)cb{
//    
//    
//    if(nil == cb) return;
//    
//    if(nil != cb.error || 200 != cb.httpStatus) {
//		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
//        return;
//	}
//    
//    Msg *msg = [Msg parseJsonData:cb.rspData];
//    [HMPopMsgView showPopMsg:msg.msg];
//    if (!msg.code) {
//        
//        return;
//    }
//    
//    if (![cb.attached isKindOfClass:[NSIndexPath class]]) {
//        
//        BqsLog(@"attacth is not kind of NSIndexPath");
//        
//        return;
//        
//    }
//    NSIndexPath *indexPath = (NSIndexPath *)cb.attached;
//    
//    if ([self.dataArray count] <= indexPath.row) {
//        BqsLog(@"delFavCB attatch  indexPath:%@ > [self.dataArray count]:%d",indexPath,self.dataArray.count);
//        return;
//    }
//    
//    Words *info = [self.dataArray objectAtIndex:indexPath.row]; //should set data and save data
//    [[FTSDataMgr sharedInstance] addFavoritedWords:info addType:FALSE];
//    
//    
//    FTSWordsTableCell *cell = (FTSWordsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//    
//    if (!cell) {
//        BqsLog(@"addFavCB tableView did not contain cell at indexPath:%@",indexPath);
//        return ;
//    }
//    [cell refreshRecordState];
//    
//    //    NSArray *cellArray = [NSArray arrayWithObject:indexPath];
//    //    [self.tableView reloadRowsAtIndexPaths:cellArray withRowAnimation:UITableViewRowAnimationAutomatic];
//    //    
//}


@end
