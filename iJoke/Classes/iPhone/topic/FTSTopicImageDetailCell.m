//
//  FTSTopicImageDetailCell.m
//  iJoke
//
//  Created by Kyle on 13-11-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTopicImageDetailCell.h"
#import "FTSLoadingCell.h"
#import "FTSEmptyCell.h"
#import "FTSUIOps.h"
#import "FTSUserInfoViewController.h"
#import "FTSNetwork.h"
#import "FTSDatabaseMgr.h"
#import "FTSUserCenter.h"
#import "FTSDataMgr.h"
#import "HMPopMsgView.h"
#import "Msg.h"
#import "UMSocial.h"

#define kMtoolBarHeigh 44


@interface FTSTopicImageDetailCell()<UIGestureRecognizerDelegate,ImageTableDetailHeadDelegate>
@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) Downloader *downloader;
@property (nonatomic, strong, readwrite) FTSImageDetailHeadView *headView;


@end


@implementation FTSTopicImageDetailCell
@synthesize hasMore = _hasMore;
@synthesize image = _image;
@synthesize delegate = _delegate;

- (void)dealloc{
    [self.downloader cancelAll];
    self.downloader = nil;
}

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl
{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (nil == self) return nil;
    
    // create subview
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.bounds),  CGRectGetHeight(self.bounds))];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollsToTop = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.headView = [[FTSImageDetailHeadView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), 0)];
    [self.scrollView addSubview:self.headView];
    self.headView.delegate = self;
    _hasMore = YES;
    _curPage = 0;
    // create downloade
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    
    self.nTotalNum = -1;
    self.nTaskId = -1;
    return self;
    
    
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
    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
        self.scrollView.contentInset = UIEdgeInsetsMake(64+self.videoOffset, 0, 0, 0);
    }
    
}




- (void)mainViewOnFont:(BOOL)value{
    if (value) {
        self.scrollView.scrollsToTop = YES;
       
    }else{
        self.scrollView.scrollsToTop = NO;
       
        
    }
}


- (void)viewDidDisappear{
    _image = nil;
    [self.headView configCellForImage:nil];
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
    CGSize size = self.scrollView.contentSize;
    size.height = height>CGRectGetHeight(self.bounds)?height:CGRectGetHeight(self.bounds);
    self.scrollView.contentSize = size;
    CGFloat offsetY = 0;
    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
        offsetY = -64;
    }
    self.scrollView.contentOffset = CGPointMake(0, offsetY);
    
}


#pragma mark
#pragma mark Button method

- (FTSRecord *)imageRecordForeImageDetailHeadViewImage:(Image *)image{
    return [FTSDatabaseMgr judgeRecordImage:image managedObjectContext:self.managedObjectContext];
}

- (void)imageDetailHeadViewImageTouch:(FTSImageDetailHeadView *)cell atIndex:(NSUInteger)index
{
    
    if (_delegate && [_delegate respondsToSelector:@selector(topicImageDetailCell:popHeadView:atIndex:)])
    {
        
        [_delegate topicImageDetailCell:self popHeadView:cell atIndex:index];
    }
    
}

- (void)imageDetailHeadViewUserInfo:(FTSImageDetailHeadView *)cell{
    
    if (_image.user == nil) {
        BqsLog(@"wordsDetailHeadViewUserInfo word.user == nil");
        return;
    }
    
    FTSUserInfoViewController *infoViewController = [[FTSUserInfoViewController alloc] initWithUser:_image.user];
    [FTSUIOps flipNavigationController:self.parCtl.flipboardNavigationController pushNavigationWithController:infoViewController];
    
}



- (void)imageDetailUpHeadView:(FTSImageDetailHeadView *)cell
{
    [FTSNetwork dingCaiWordsDownloader:self.downloader Target:self Sel:@selector(upWordsCB:) Attached:nil artId:_image.imageId type:ImageSectionType upDown:1];
    [FTSDatabaseMgr jokeAddRecordImage:_image upType:iJokeUpDownUp managedObjectContext:self.managedObjectContext];
    
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
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.title = title;
    [UMSocialSnsService presentSnsIconSheetView:self.parCtl
                                         appKey:nil
                                      shareText:title
                                     shareImage:sharImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatTimeline,UMShareToTencent,UMShareToQzone,UMShareToWechatSession,nil]
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
#pragma mark - network ops
- (BOOL)loadLocalDataNeedFresh{
    return TRUE;
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
}


- (void)dataFresh{
    
}


#pragma mark
#pragma mark networking callback

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



























@end
