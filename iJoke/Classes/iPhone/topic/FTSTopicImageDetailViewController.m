//
//  FTSTopicImageDetailViewController.m
//  iJoke
//
//  Created by Kyle on 13-11-26.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTopicImageDetailViewController.h"
#import "Image.h"
#import "FTSCommitTipsCell.h"
#import "FTSTopicImageDetailCell.h"
#import "FTSCommentImageViewController.h"
#import "HMImagePopManager.h"
#import "MBProgressHUD.h"

@interface FTSTopicImageDetailViewController ()<TopicImageDetailCellDelegate,ImagePopControllerDataSource,ImagePopControllerDelegate,HMImagePopManagerDelegate>{
    
    BOOL _more;
    
}

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) NSUInteger imagesIndex;
@property (nonatomic, strong) HMImagePopManager *popMange;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation FTSTopicImageDetailViewController

@synthesize popMange = _popMange;




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = _topic.name;
    
    _more = FALSE;
    
    Env *env = [Env sharedEnv];
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_comment.png"];
    self.navigationItem.rightBarButtonItem = [CustomUIBarButtonItem initWithImage:revealRightImagePortrait eventImg:nil title:nil target:self action:@selector(showComment:)];
    
    
    self.contentView = [[MptContentScrollView alloc] initWithFrame:self.view.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.contentView.dataSource = self;
    self.contentView.delegate = self;
    [self.view addSubview:self.contentView];
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD .mode = MBProgressHUDModeIndeterminate;
    self.progressHUD .animationType = MBProgressHUDAnimationZoom;
    self.progressHUD .screenType = MBProgressHUDSectionScreen;
    self.progressHUD .opacity = 0.5;
    self.progressHUD .labelText = NSLocalizedString(@"joke.useraction.message.freshing", nil);
    [self.view addSubview:self.progressHUD ];
    [self.progressHUD  hide:YES];

    

    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_topic_image_detail];
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_topic_image_detail];
    [super viewWillDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)loadLocalDataNeedFresh{
    
    
    CGFloat lastUploadTs = [FTSUserCenter floatValueForKey:[NSString stringWithFormat:kDftTopicImageDetailSaveTimeId, _topic.topicId]];
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    
    BOOL reFresh = FALSE;
    if (fNow - lastUploadTs > kRefreshTopicImageDetailIntervalS) {
        reFresh =  TRUE;
    }
    
    if (reFresh) {
        
        [self loadNetworkDataMore:NO];
        
    }else{
        
        if (self.dataArray == nil) {
            
            self.dataArray = [[FTSDataMgr sharedInstance] arrayOfSaveTpoicImageDetailForId:_topic.topicId];
            self.tempArray = [NSMutableArray arrayWithArray:self.dataArray];
            self.hasMore = YES;
        }
    }
    

}

- (void)reloadData{
    [self.contentView reloadData];
}



-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (_nTaskId > 0) {
        return;
    }
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        
        NSInteger imageId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Image *image = [self.dataArray objectAtIndex:0];
            imageId = image.imageId;
        }
        
        _nTaskId = [FTSNetwork topicImageFreshDownloader:self.downloader Target:self Sel:@selector(onLoadRefreshFinished:) Attached:nil imageId:imageId topicID:_topic.topicId];
        [MobClick endEvent:kUmeng_topicimage_fresh_event];
        [self.progressHUD show:YES];
    }else{
        _curPage++;
        
        NSInteger imageId = 0;
        if (self.dataArray&& [self.dataArray count] !=0) {
            Image *image = [self.dataArray lastObject];
            imageId = image.imageId;
        }
        
        _nTaskId = [FTSNetwork topicImageNextDownloader:self.downloader Target:self Sel:@selector(onLoadNextDataFinished:) Attached:nil imageId:imageId topicID:_topic.topicId];
        [MobClick endEvent:kUmeng_topicimage_fresh_event label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showComment:(id)sender{
    
    NSInteger curIndex = [self.contentView current];
    
    if (curIndex >= [_dataArray count] ){
        BqsLog(@"");
        return;
    }
    
    FTSCommentImageViewController *imageComment = [[FTSCommentImageViewController alloc] initWithNibName:nil bundle:nil];
    imageComment.image = [_dataArray objectAtIndex:curIndex];
    [FTSUIOps flipNavigationController:self.flipboardNavigationController pushNavigationWithController:imageComment];
    
}




- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
    return [_dataArray count]+1;
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    
    FTSTopicImageDetailCell *cell;
    FTSCommitTipsCell *tipsCelll;
    static NSString *celleIdentifier = @"nomal";
    static NSString *tipsIdentifier = @"tips";
    
    if (index < [_dataArray count] ) {
        cell = (FTSTopicImageDetailCell *)[scrollView dequeueCellWithIdentifier:celleIdentifier];
        if (!cell) {
            cell = [[FTSTopicImageDetailCell alloc] initWithFrame:frame withIdentifier:celleIdentifier withController:self];
            cell.managedObjectContext = self.managedObjectContext;
        }
        
        cell.image = [_dataArray objectAtIndex:index];
        cell.delegate = self;
        return cell;
    }else if([_dataArray count] != 0 && index == [_dataArray count]){
        
        tipsCelll = (FTSCommitTipsCell *)[scrollView dequeueCellWithIdentifier:tipsIdentifier];
        if (tipsCelll == nil) {
            tipsCelll = [[FTSCommitTipsCell alloc] initWithFrame:frame withIdentifier:tipsIdentifier withController:self];
        }
        
        if (_more) {
            tipsCelll.tips.text = NSLocalizedString(@"joke.content.loading", nil);
            [self loadNetworkDataMore:YES];
            
        }else{
            tipsCelll.tips.text = NSLocalizedString(@"joke.content.loadfininsh", nil);
            
        }
        return tipsCelll;
    }else if([_dataArray count] == 0){
        tipsCelll = (FTSCommitTipsCell *)[scrollView dequeueCellWithIdentifier:tipsIdentifier];
        if (tipsCelll == nil) {
            tipsCelll = [[FTSCommitTipsCell alloc] initWithFrame:frame withIdentifier:tipsIdentifier withController:self];
        }

        tipsCelll.tips.text = NSLocalizedString(@"joke.content.loading", nil);
    
        return tipsCelll;
    }
    
    return nil;
    
}


#pragma mark
#pragma mark ImageDetailCellDelegate
- (void)topicImageDetailCell:(FTSTopicImageDetailCell *)cell popHeadView:(FTSImageDetailHeadView *)head atIndex:(NSUInteger)index{
    
    NSUInteger cellIndex = cell.cellTag;
    
    
    if ([head.imageViews count] <= index) {
        BqsLog(@"FTSImageDetailCell [head.imageViews count] = %d <= index = %d",[head.imageViews count],index);
        return;
        
    }
    
    JKImageCellImageView *imageView = [head.imageViews objectAtIndex:index];
    
    CGRect newFrame = [self.view convertRect:imageView.frame fromView:head.backgroundImageView];
    if(DeviceSystemMajorVersion() >=7){ //ios7
        
    }else{
        newFrame.origin.y += 44.0f;
    }
    
    if (cellIndex >= [self.dataArray count]) {
        BqsLog(@"FTSImageDetailCell touchImageIndex:%d > self.dataArray",cellIndex);
        return;
    }
    self.currentIndex = cellIndex;
    
    Image *info = [self.dataArray objectAtIndex:self.currentIndex];
    if ([info.imageArray count] <= index) {
        BqsLog(@"FTSImageDetailCell [info.imageArray count] = %d <= index = %d",[info.imageArray count],index);
        return;
        
    }
    
    self.imagesIndex = index;
    Picture *picture = [info.imageArray objectAtIndex:index];
    
    _popMange = [[HMImagePopManager alloc] initWithParentConroller:self.parentViewController DefaultImg:imageView.imageView.image imageUrl:picture.picUrl imageFrame:newFrame];
    _popMange.focusViewController.delegate = self;
    _popMange.focusViewController.dataSource = self;
    _popMange.index = cellIndex;
    _popMange.delegate = self;
    [_popMange handleFocusGesture:nil];
    
    
}


#pragma mark
#pragma mark ImagePopControllerDataSource ImagePopControllerDelegate
- (NSUInteger)numberOfItemForImagePopController:(HMImagePopController *)popController{
    
//    return [self.dataArray count];
    
    return 1; //
    
}

- (NSUInteger)currentIndexForPopController:(HMImagePopController *)popController{
    
    return 0;
    
}


- (NSString *)summaryForImagePopController:(HMImagePopController *)popController AtIndex:(NSUInteger)index{
    
    if (index >= [self.dataArray count]) {
        BqsLog(@"summaryForImagePopController AtIndex:%@ > self.dataArray",index);
        return nil;
    }
    
    Image *info = [self.dataArray objectAtIndex:self.currentIndex];
    
    Picture *picture = nil;
    if ([info.imageArray count] > self.imagesIndex){
        picture = [info.imageArray objectAtIndex:self.imagesIndex];
    }else{
         picture = [info.imageArray objectAtIndex:0];

    }
    
    
    return picture.content;
    
    
}

- (HMImagePopCell*)cellViewForImagePopController:(HMImagePopController *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    static NSString *indentity = @"popid";
    HMImagePopCell *cell = (HMImagePopCell *)[scrollView dequeueCellWithIdentifier:indentity];
    if (!cell) {
        cell = [[HMImagePopCell alloc] initWithFrame:frame withIdentifier:indentity withController:self];
    }
    
    if (index >= [self.dataArray count]) {
        BqsLog(@"imageTableCell touchImageIndex:%@ > self.dataArray",index);
        return cell;
    }
    
    Image *info = [self.dataArray objectAtIndex:self.currentIndex];
    CGRect newFrame = CGRectZero;
    
    Picture *picture = nil;
    if ([info.imageArray count] > self.imagesIndex){
        picture = [info.imageArray objectAtIndex:self.imagesIndex];
    }else{
        picture = [info.imageArray objectAtIndex:0];
        
    }

    if (picture.width < CGRectGetWidth(self.view.bounds)) {
        newFrame.size.width = picture.width;
        newFrame.size.height = picture.height;
    }else{
        newFrame.size.width = 320;
        newFrame.size.height = (picture.height * 320)/picture.width;
    }
    
    cell.defaultRect = newFrame;
    cell.defaultUrl = picture.picUrl;
    
    return cell;
    
}


- (void)imagePopController:(HMImagePopController *)popController curIndex:(NSInteger)index{
    
    if (index >= [self.dataArray count] ) {
        BqsLog(@"self.dataArray count:%d < index:%d",[self.dataArray count],index);
        return ;
    }
    
    [self.contentView setCurrentItemIndex:index animation:FALSE];
    
}

- (void)imagePopControllerDidTap:(HMImagePopController *)popController currentIndex:(NSInteger)index{
    
    if(_popMange == nil) return;
    
    if (index >= [self.dataArray count] ) {
        BqsLog(@"self.dataArray count:%d < index:%d",[self.dataArray count],index);
        return ;
    }
    
    [self.contentView setCurrentItemIndex:self.currentIndex animation:FALSE];
    
    FTSTopicImageDetailCell *cell = (FTSTopicImageDetailCell *)[self.contentView cellForRowAtIndex:self.currentIndex];
    if (cell == nil) {
        BqsLog(@"cellForRowAtIndex == nil");
        return;
    }
    
    Image *info = [self.dataArray objectAtIndex:self.currentIndex];
    int imageViewIndex = self.imagesIndex;
    if ([info.imageArray count] > self.imagesIndex){
        imageViewIndex = self.imagesIndex;
    }else{
        imageViewIndex = 0;
        
    }

    
    JKImageCellImageView *imageView = [cell.headView.imageViews objectAtIndex:imageViewIndex];
    
    CGRect newFrame = [self.view convertRect:imageView.frame fromView:cell.headView.backgroundImageView];
    if(DeviceSystemMajorVersion() >=7){ //ios7
        
    }else{
        newFrame.origin.y += 44.0f;
    }
    _popMange.imgRect = newFrame;
    
    BOOL finish =  [_popMange handleDefocusGesture:nil];
    if (finish) {
        _popMange = nil;
    }
    
}



#pragma mark
#pragma mark HMImagePopManagerDelegate

- (void)HMImagePopManager:(HMImagePopManager *)popManag loadIndex:(NSUInteger)index{
    
    FTSTopicImageDetailCell *cell = (FTSTopicImageDetailCell *)[self.contentView cellForRowAtIndex:index];
    
    if (cell == nil) {
        BqsLog(@"FTSImageDetailCell did not contain cell at index:%d",index);
        return;
        
    }
    [cell.headView reloadData];
    
}




-(void)onLoadRefreshFinished:(DownloaderCallbackObj*)cb {
    BqsLog(@"FTSTopicImageDetailViewController onLoadDataFinished:%@",cb);
    _more = YES;
    _nTaskId = -1;
    
    [self.progressHUD hide:YES];
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    
    self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {
        self.hasMore = YES;
        [HMPopMsgView showPopMsgError:cb.error Msg:msg.msg Delegate:nil];
        return;
    }
    
    NSArray *array = [Image parseJsonData:cb.rspData];
    
    if (!array ) {
        BqsLog(@"wordStruct or wordStruct.dataArray is Null");
        self.hasMore = YES;
        return;
    }else if([array count] == 0){
        self.hasMore = NO;
        return;
        
    }
    
    for (Image *image in array) {
        [self.tempArray addObject:image];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    
    [[FTSDataMgr sharedInstance] saveTpoicImageDetailArray:self.dataArray froId:_topic.topicId]; //save data use xml
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    [FTSUserCenter setFloatVaule:fNow forKey:[NSString stringWithFormat:kDftTopicImageDetailSaveTimeId,_topic.topicId]];
    
    if (msg.freshSize == 0) {
        
        [self noticeMessageNSString:NSLocalizedString(@"joke.content.nofresh", nil)];
        
    }else{
        [self noticeMessageNSString:[NSString stringWithFormat:NSLocalizedString(@"joke.content.freshnumber", nil),msg.freshSize]];
        
    }
}



-(void)onLoadNextDataFinished:(DownloaderCallbackObj*)cb {
    BqsLog(@"FTSWordsTableView onLoadDataFinished:%@",cb);
    _nTaskId = -1;
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    if (!self.tempArray) {
        self.tempArray = [[NSMutableArray alloc] initWithCapacity:15];
    }
    
    Msg *msg = [Msg parseJsonData:cb.rspData];
    if (!msg.code) {
        self.hasMore = YES;
        [HMPopMsgView showPopMsgError:cb.error Msg:msg.msg Delegate:nil];
        return;
    }
    
    NSArray *array = [Image parseJsonData:cb.rspData];
    
    if (!array) {
        BqsLog(@"array is Null");
        self.hasMore = YES;
        _more = YES;
        return;
    }else if(array.count == 0){
        BqsLog(@"array count = 0");
        self.hasMore = NO;
        _more = NO;
        return;
    }

    for (Image *image in array) {
        [self.tempArray addObject:image];
    }
    self.dataArray = self.tempArray;
    self.hasMore = YES;
    _more = YES;
    

    [[FTSDataMgr sharedInstance] saveTpoicImageDetailArray:self.dataArray froId:_topic.topicId]; //save data use xml
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    [FTSUserCenter setFloatVaule:fNow forKey:[NSString stringWithFormat:kDftTopicImageDetailSaveTimeId,_topic.topicId]];
    
    
}




@end
