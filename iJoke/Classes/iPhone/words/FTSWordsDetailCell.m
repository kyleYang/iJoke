//
//  FTSWordsDetailCell.m
//  iJoke
//
//  Created by Kyle on 13-8-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSWordsDetailCell.h"
#import "FTSWordsDetailHeadView.h"
#import "FTSNetwork.h"
#import "FTSDataMgr.h"
#import "Msg.h"
#import "HMPopMsgView.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "Comment.h"


@interface FTSWordsDetailCell()<WordTableDetailHeadDelegate>

@property (nonatomic, strong) FTSWordsDetailHeadView *headView;

@end



@implementation FTSWordsDetailCell
@synthesize words = _words;

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (self) {
        
        self.headView = [[FTSWordsDetailHeadView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0)];
        self.headView.delegate = self;
        
        
        
    }
    
    return self;
}

- (void)viewDidDisappear{
    _words = nil;
    
    [self.headView configCellForWords:_words];
    self.tableView.tableHeaderView = nil;
    [super viewDidDisappear];
}


- (void)setWords:(Words *)words{
    if (_words == words) return;
    _words = words;
    
    //    self.tableView.contentOffset = CGPointZero;
    CGRect frame = self.headView.frame;
    CGFloat height = [self.headView configCellForWords:_words];
    
    if (height!=0) {
        frame.size.height = height;
        self.headView.frame = frame;
    }
    
    self.tableView.tableHeaderView = self.headView;
    
}


#pragma mark
#pragma mark Overloaded

- (void)sendCommentText:(NSString *)text anonymous:(BOOL)anonymous{
    
    [FTSNetwork postCommitDownloader:self.downloader Target:self Sel:@selector(commitCB:) Attached:[NSNumber numberWithBool:anonymous] artId:_words.wordId comment:text type:WordsSectionType hiddenUser:anonymous];
    
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        self.tempArray = nil;
        [MobClick endEvent:kUmeng_words_commit_fresh];
        
    }else{
        _curPage++;
        [MobClick endEvent:kUmeng_words_commit_fresh label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
    self.nTaskId = [FTSNetwork commitListDownloader:self.downloader Target:self Sel:@selector(onLoadCommitListFinished:)  Attached:nil artId:_words.wordId page:_curPage type:WordsSectionType];
    
}




#pragma mark
#pragma mark WordTableDetailHeadDelegate


- (void)wordsDetailHeadViewUserInfo:(FTSWordsDetailHeadView *)cell{
    
    if (_words.user == nil) {
        BqsLog(@"wordsDetailHeadViewUserInfo word.user == nil");
        return;
    }
    
    FTSUserInfoViewController *infoViewController = [[FTSUserInfoViewController alloc] initWithUser:_words.user];
    [FTSUIOps flipNavigationController:self.parCtl.navigationController.flipboardNavigationController pushNavigationWithController:infoViewController];
    
}

- (void)wordsDetailUpHeadView:(FTSWordsDetailHeadView *)cell{
    
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(upWordsCB:) Attached:nil artId:_words.wordId type:WordsSectionType upDown:1];
    
    //    [self.headView refreshRecordState];
    
    
    
}
- (void)wordsDetailDownHeadView:(FTSWordsDetailHeadView *)cell{
    
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(downWordsCB:) Attached:nil artId:_words.wordId type:WordsSectionType upDown:-1];
    
    //    [self.headView refreshRecordState];
    
}
- (void)wordsDetailFavoriteHeadView:(FTSWordsDetailHeadView *)cell addType:(BOOL)value{//vale: true for add and false for del favorite
    BOOL login  = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (!login) { //save local
        
        if (value) {
            if([[FTSDataMgr sharedInstance] addOneJokeSave:_words]){
                [[FTSDataMgr sharedInstance] addFavoritedWords:_words addType:TRUE];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.add.success", nil)];
                [cell refreshRecordState];
                return;
            }
        }else{
            
            if([[FTSDataMgr sharedInstance] removeOneJoke:_words]){
                [[FTSDataMgr sharedInstance] addFavoritedWords:_words addType:FALSE];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.del.success", nil)];
                [cell refreshRecordState];
                return;
                
            }
        }
        
    }else{
        
        if (value) {
            [FTSNetwork addFavoriteDownloader:self.downloader  Target:self Sel:@selector(addFavCB:) Attached:nil artId:_words.wordId type:WordsSectionType];
        }else{
            [FTSNetwork delFavoriteDownloader:self.downloader  Target:self Sel:@selector(addFavCB:) Attached:nil artId:_words.wordId type:WordsSectionType];
        }
    }
    
    
}

- (void)wordsDetailShareHeadView:(FTSWordsDetailHeadView *)cell{
    
    
    [UMSocialSnsService presentSnsIconSheetView:self.parCtl
                                         appKey:nil
                                      shareText:_words.content
                                     shareImage:nil
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatTimeline,UMShareToQzone,UMShareToTencent,UMShareToWechatSession,UMShareToQQ,nil]
                                       delegate:(id<UMSocialUIDelegate>)self];
    
    
}

#pragma mark
#pragma mark UMSocialUIDelegate

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    
    if (response.responseCode == UMSResponseCodeSuccess) {
        
        [FTSNetwork shareCountDownloader:self.downloader Target:self Sel:@selector(shareCountCB:) Attached:nil artId:_words.wordId type:WordsSectionType];
    }
    
}



#pragma mark
#pragma mark DownloaderCallback

- (void)shareCountCB:(DownloaderCallbackObj *)cb{
    BqsLog(@"FTSWordsTableView share count:%@",cb);
    
    return ; //share count down always be ture,not
    
}



- (void)onLoadCommitListFinished:(DownloaderCallbackObj *)cb{
    
    [self.pullView endRefreshing];
    _onceLoaded = YES;
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopError:cb.error];
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
    
    
    
    
    
}

- (void)addFavCB:(DownloaderCallbackObj *)cb{
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopError:cb.error];
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    [HMPopMsgView showPopMsg:msg.msg];
    if (!msg.code) {
        return;
    }
    
    
    
    [[FTSDataMgr sharedInstance] addFavoritedWords:_words addType:TRUE];
    
    [self.headView refreshRecordState];
    
    
}

- (void)delFavCB:(DownloaderCallbackObj *)cb{
    
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopError:cb.error];
        return;
	}
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    [HMPopMsgView showPopMsg:msg.msg];
    if (!msg.code) {
        
        return;
    }
    
    [[FTSDataMgr sharedInstance] addFavoritedWords:_words addType:FALSE];
    
    [self.headView refreshRecordState];
    
    
}


- (void)commitCB:(DownloaderCallbackObj *)cb{
    
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






@end
