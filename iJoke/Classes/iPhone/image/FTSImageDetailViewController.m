//
//  FTSImageDetailViewController.m
//  iJoke
//
//  Created by Kyle on 13-9-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSImageDetailViewController.h"
#import "FTSImageDetailCell.h"
#import "FTSCommitTipsCell.h"
#import "HMImagePopManager.h"

@interface FTSImageDetailViewController()<ImageDetailCellDelegate,ImagePopControllerDataSource,ImagePopControllerDelegate,HMImagePopManagerDelegate>{
    
    HMImagePopManager *_popMange;
    
}


@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) NSUInteger imagesIndex;
@property (nonatomic, strong) HMImagePopManager *popMange;

@end

@implementation FTSImageDetailViewController
@synthesize delegate = _delegate;
@synthesize popMange = _popMange;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_image_commit];
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_image_commit];
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setDataArray:(NSArray *)dataArray more:(BOOL)more{
    
    [super setDataArray:dataArray more:more];
    
    if (_popMange) {
        [_popMange.focusViewController reloadData];
    }
    
}


- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
    return [_dataArray count]+1;
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    
    FTSImageDetailCell *cell;
    FTSCommitTipsCell *tipsCelll;
    static NSString *celleIdentifier = @"nomal";
    static NSString *tipsIdentifier = @"tips";
    
    if (index < [_dataArray count] ) {
        cell = (FTSImageDetailCell *)[scrollView dequeueCellWithIdentifier:celleIdentifier];
        if (!cell) {
            cell = [[FTSImageDetailCell alloc] initWithFrame:frame withIdentifier:celleIdentifier withController:self];
            cell.managedObjectContext = self.managedObjectContext;
        }
        
        cell.image = [_dataArray objectAtIndex:index];
        cell.delegate = self;
        return cell;
    }else if(index == [_dataArray count]){
        
        tipsCelll = (FTSCommitTipsCell *)[scrollView dequeueCellWithIdentifier:tipsIdentifier];
        
        if (_more) {
            tipsCelll.tips.text = @"加载更多ing";
            if (_delegate && [_delegate respondsToSelector:@selector(FTSImageDetailViewControllerLoadMore:)]) {
                [_delegate FTSImageDetailViewControllerLoadMore:self];
                BqsLog(@"FTSWordsDetailViewControllerLoadMore");
            }
            
        }else{
            tipsCelll.tips.text = @"加载完成";
            
        }
        return tipsCelll;
    }
    
    return nil;
    
}

#pragma mark
#pragma mark ImageDetailCellDelegate

- (void)FTSImageDetailCell:(FTSImageDetailCell *)cell popHeadView:(FTSImageDetailHeadView *)head atIndex:(NSUInteger)index{
    
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
    
    Image *info = [self.dataArray objectAtIndex:cellIndex];
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
    
    return 1; //just for images big than 1 in on image joke
    
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
    
    int imageViewIndex = self.imagesIndex;
    if ([info.imageArray count] > self.imagesIndex){
        imageViewIndex = self.imagesIndex;
    }else{
        imageViewIndex = 0;
        
    }
    
    
    Picture *picture = [info.imageArray objectAtIndex:imageViewIndex];
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
    
    //    [self.contentView setCurrentItemIndex:self.currentIndex animation:FALSE];
    
}

- (void)imagePopControllerDidTap:(HMImagePopController *)popController currentIndex:(NSInteger)index{
    
    if(_popMange == nil) return;
    
    if (index >= [self.dataArray count] ) {
        BqsLog(@"self.dataArray count:%d < index:%d",[self.dataArray count],index);
        return ;
    }
    
    //    [self.contentView setCurrentItemIndex:index animation:FALSE];
    
    FTSImageDetailCell *cell = (FTSImageDetailCell *)[self.contentView cellForRowAtIndex:self.currentIndex];
    if (cell == nil) {
        BqsLog(@"cellForRowAtIndex == nil");
        return;
    }
    
    Image *info = [self.dataArray objectAtIndex:self.currentIndex];
    
    NSUInteger imageViewIndex;
    
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
    
    FTSImageDetailCell *cell = (FTSImageDetailCell *)[self.contentView cellForRowAtIndex:index];
    
    if (cell == nil) {
        BqsLog(@"FTSImageDetailCell did not contain cell at index:%d",index);
        return;
        
    }
    [cell.headView reloadData];
    
}


#pragma mark
#pragma mark report
- (void)reportMessage{
    NSInteger curIndex = [self.contentView current];
    
    if (curIndex >= [_dataArray count] ){
        BqsLog(@"report index = %d > [_dataArray count] = %d",curIndex,[_dataArray count]);
        return;
    }
    Image *image = [_dataArray objectAtIndex:curIndex];
    
#ifdef iJokeAdministratorVersion
    [FTSNetwork deleteMessageDownloader:self.downloader Target:self Sel:@selector(reportMessageCB:) Attached:nil artId:image.imageId type:ImageSectionType];
#else
    
    [FTSNetwork reportMessageDownloader:self.downloader Target:self Sel:@selector(reportMessageCB:) Attached:nil artId:image.imageId type:ImageSectionType];
#endif
    
    
}





@end