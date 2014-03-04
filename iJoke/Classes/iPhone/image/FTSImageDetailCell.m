//
//  FTSImageDetailCell.m
//  iJoke
//
//  Created by Kyle on 13-9-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSImageDetailCell.h"
#import "FTSImageDetailHeadView.h"
#import "FTSNetwork.h"
#import "FTSDataMgr.h"
#import "FTSDatabaseMgr.h"
#import "Msg.h"
#import "HMPopMsgView.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "Comment.h"

@interface FTSImageDetailCell()<ImageTableDetailHeadDelegate>

@property (nonatomic, strong,readwrite) FTSImageDetailHeadView *headView;

@end



@implementation FTSImageDetailCell
@synthesize image = _image;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (self) {
        
        self.headView = [[FTSImageDetailHeadView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0)];
        self.headView.delegate = self;
        
        
        
    }
    
    return self;
}

- (void)viewDidDisappear{
    _image = nil;
    [self.headView configCellForImage:nil];
    self.tableView.tableHeaderView = nil;
    [super viewDidDisappear];
}


- (void)setImage:(Image *)image{
    if (_image == image) return;
    _image = image;
    
//    self.tableView.contentOffset = CGPointZero;
    
    CGRect frame = self.headView.frame;
    CGFloat height = [self.headView configCellForImage:_image];
    
    BqsLog(@"FTSImageDetailCell height:%.1f",height);
    if (height!=0) {
        frame.size.height = height;
        self.headView.frame = frame;
    }
    self.tableView.tableHeaderView = self.headView;
    
}


#pragma mark
#pragma mark Overloaded

- (void)sendCommentText:(NSString *)text anonymous:(BOOL)anonymous{
    
    [FTSNetwork postCommitDownloader:self.downloader Target:self Sel:@selector(commitCB:) Attached:[NSNumber numberWithBool:anonymous] artId:_image.imageId comment:text type:ImageSectionType hiddenUser:anonymous];
    
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        self.tempArray = nil;
        [MobClick endEvent:kUmeng_image_commit_fresh];
        
    }else{
        _curPage++;
        [MobClick endEvent:kUmeng_image_commit_next label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
    self.nTaskId = [FTSNetwork commitListDownloader:self.downloader Target:self Sel:@selector(onLoadCommitListFinished:) Attached:nil artId:_image.imageId page:_curPage type:ImageSectionType];
    
}




#pragma mark
#pragma mark ImageTableDetailHeadDelegate


- (FTSRecord *)imageRecordForeImageDetailHeadViewImage:(Image *)image{
    return [FTSDatabaseMgr judgeRecordImage:image managedObjectContext:self.managedObjectContext];
}

- (BOOL)subViewShouldReceiveTouch:(FTSImageDetailHeadView *)cell{
    return !_keyboardIsShow;
}


- (void)imageDetailHeadViewImageTouch:(FTSImageDetailHeadView *)cell atIndex:(NSUInteger)index{
    
    if (_delegate && [_delegate respondsToSelector:@selector(FTSImageDetailCell:popHeadView:atIndex:)]) {
    
        [_delegate FTSImageDetailCell:self popHeadView:cell atIndex:index];
    }
}

- (void)imageDetailHeadViewUserInfo:(FTSImageDetailHeadView *)cell{
    
    if (_image.user == nil) {
        BqsLog(@"wordsDetailHeadViewUserInfo word.user == nil");
        return;
    }
    
    FTSUserInfoViewController *infoViewController = [[FTSUserInfoViewController alloc] initWithUser:_image.user];
    [FTSUIOps flipNavigationController:self.parCtl.navigationController.flipboardNavigationController pushNavigationWithController:infoViewController];
    
}


- (void)imageDetailUpHeadView:(FTSImageDetailHeadView *)cell{
    
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(upWordsCB:) Attached:nil artId:_image.imageId type:ImageSectionType upDown:1];
    [FTSDatabaseMgr jokeAddRecordImage:_image upType:iJokeUpDownUp managedObjectContext:self.managedObjectContext];
    
    
    
}
- (void)imageDetailDownHeadView:(FTSImageDetailHeadView *)cell{
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(downWordsCB:) Attached:nil artId:_image.imageId type:ImageSectionType upDown:-1];
    [FTSDatabaseMgr jokeAddRecordImage:_image upType:iJokeUpDownDown managedObjectContext:self.managedObjectContext];
//    [self.headView refreshRecordState];
    
}

- (void)imageDetailFavoriteHeadView:(FTSImageDetailHeadView *)cell addType:(BOOL)value{//vale: true for add and false for del favorite
    
    BOOL login  = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (!login) { //save local
        
        if (value) {
            if([[FTSDataMgr sharedInstance] addOneJokeSave:_image]){
                [FTSDatabaseMgr jokeAddRecordImage:_image favorite:TRUE managedObjectContext:self.managedObjectContext];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.add.success", nil)];
                [cell refreshRecordState];
                return;
            }
        }else{
            
            if([[FTSDataMgr sharedInstance] removeOneJoke:_image]){
                 [FTSDatabaseMgr jokeAddRecordImage:_image favorite:FALSE managedObjectContext:self.managedObjectContext];
                [HMPopMsgView showPopMsg:NSLocalizedString(@"jole.useraction.collect.local.del.success", nil)];
                [cell refreshRecordState];
                return;
                
            }
        }
        
    }else{
        
        if (value) {
            [FTSNetwork addFavoriteDownloader:self.downloader Target:self Sel:@selector(addFavCB:) Attached:nil artId:_image.imageId type:ImageSectionType];
            
        }else{
            [FTSNetwork delFavoriteDownloader:self.downloader Target:self Sel:@selector(delFavCB:) Attached:nil artId:_image.imageId type:ImageSectionType];
        }
    }
    
    
}

- (void)imageDetailShareHeadView:(FTSImageDetailHeadView *)cell{
    
    if ([_image.imageArray count] == 0) {
        BqsLog(@"[_image.imageArray count] == 0");
        return;
    }
    
    Picture *picture = [_image.imageArray objectAtIndex:0];
    
    NSString *title = picture.content;
    
    UIImage *sharImage = nil;
    if ([cell.imageViews count] != 0) {
        
        JKImageCellImageView *cellImage = [cell.imageViews objectAtIndex:0];
        sharImage = cellImage.imageView.image;
    }
    
    
    [UMSocialSnsService presentSnsIconSheetView:self.parCtl
                                         appKey:[Env sharedEnv].umengId
                                      shareText:title
                                     shareImage:sharImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,UMShareToQzone,UMShareToSina,UMShareToQQ,UMShareToTencent,UMShareToWechatSession,nil]
                                       delegate:(id<UMSocialUIDelegate>)self];
    
    
}


#pragma mark
#pragma mark UMSocialUIDelegate

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    
    if (response.responseCode == UMSResponseCodeSuccess) {
        
        [FTSNetwork shareCountDownloader:self.downloader Target:self Sel:@selector(shareCountCB:) Attached:nil artId:_image.imageId type:ImageSectionType];
    }
    
}



#pragma mark
#pragma mark DownloaderCallback

- (void)shareCountCB:(DownloaderCallbackObj *)cb{
    BqsLog(@"FTSWordsTableView share count:%@",cb);
    
    return ; //share count down always be ture,not
    
}




#pragma mark
#pragma mark DownloaderCallback
- (void)onLoadCommitListFinished:(DownloaderCallbackObj *)cb{
    
    _onceLoaded = YES;
    [self.tableView stopRefreshAnimation];
    
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
    if (!msg.code) {
        [HMPopMsgView showPopMsg:msg.msg];
        return;
    }
    [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.useraction.collect.del.success", nil)];
    [FTSDatabaseMgr jokeAddRecordImage:_image favorite:TRUE managedObjectContext:self.managedObjectContext];
    
    
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
    if (!msg.code) {
        [HMPopMsgView showPopMsg:msg.msg];
        return;
    }
    [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.useraction.collect.del.success", nil)];
    [FTSDatabaseMgr jokeAddRecordImage:_image favorite:FALSE managedObjectContext:self.managedObjectContext];
    
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
