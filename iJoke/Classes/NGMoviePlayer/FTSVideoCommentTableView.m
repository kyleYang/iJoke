//
//  FTSVideoCommentTableView.m
//  iJoke
//
//  Created by Kyle on 13-11-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSVideoCommentTableView.h"
#import "FTSNetwork.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "Msg.h"
#import "HMPopMsgView.h"
#import "Comment.h"

@interface FTSVideoCommentTableView()

//@property (nonatomic, strong, readwrite) Video *video;

@end


@implementation FTSVideoCommentTableView
@synthesize video = _video;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark
#pragma mark property


- (void)setVideo:(Video *)video{
    
    if (_video == video) return;
    
    BOOL firstIn = FALSE;
    
    if (_video == nil) {
        firstIn = TRUE;
    }
    
    _video = video;
    
    if (firstIn) {
        
        return;
    }else{ //not the first in , reload commit
        
        [self loadNetworkDataMore:NO];
    }
    

    
    
}


#pragma mark
#pragma mark Overloaded

- (void)sendCommentText:(NSString *)text anonymous:(BOOL)anonymous{
    [FTSNetwork postCommitDownloader:self.downloader Target:self Sel:@selector(commitCB:) Attached:[NSNumber numberWithBool:anonymous] artId:_video.videoId comment:text type:VideoSectionType hiddenUser:anonymous];
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        self.tempArray = nil;
        [MobClick endEvent:kUmeng_video_commit_fresh];
        
    }else{
        _curPage++;
        [MobClick endEvent:kUmeng_video_commit_next label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
    self.nTaskId = [FTSNetwork commitListDownloader:self.downloader Target:self Sel:@selector(onLoadCommitListFinished:) Attached:nil artId:_video.videoId page:_curPage type:VideoSectionType];


}

#pragma mark
#pragma mark DownloaderCallback

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
