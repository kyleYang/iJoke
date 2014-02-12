//
//  FTSTopicViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTopicViewController.h"
#import "FTSNetwork.h"
#import "MBProgressHUD.h"
#import "HMPopMsgView.h"
#import "Topic.h"
#import "GridData.h"
#import "FTSTopicViewCell.h"
#import "FTSDataMgr.h"
#import "FTSUserCenter.h"
#import "FTSTopicImageDetailViewController.h"
#import "FTSTopicVideoDetailViewController.h"
#import "FTSUIOps.h"

#define kEachNum 8

enum TopicType {
    TopicTypeWords = 0,
    TopicTypeImage = 1,
    TopicTypeVideo = 2,
};


@interface FTSTopicViewController ()<TopicViewCellDelegate>
{
    
    int _nTaskId;
}

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSMutableArray *netArray;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation FTSTopicViewController
@synthesize dataArray = _dataArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"joke.category.topic", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    
    _nTaskId = -1;
    
    CGFloat orgY = 10.0f;
    CGFloat orgX = 10.0f;
    if (DeviceSystemMajorVersion()>=7) {
        orgY = 10.0f+64.0f;
        
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.contentView.frame = CGRectMake(orgX, orgY, CGRectGetWidth(self.view.bounds)- 2*orgX, CGRectGetHeight(self.view.bounds)- orgY - 10.0f);
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-30, CGRectGetWidth(self.view.bounds), 20)];
    //    [self.pageControl setBackgroundColor:[UIColor blackColor]];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    //    self.pageControl.hidesForSinglePage = TRUE;
    [self.view addSubview:self.pageControl];
    
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD .mode = MBProgressHUDModeIndeterminate;
    self.progressHUD .animationType = MBProgressHUDAnimationZoom;
    self.progressHUD .screenType = MBProgressHUDSectionScreen;
    self.progressHUD .opacity = 0.5;
    self.progressHUD .labelText = NSLocalizedString(@"review.laoding.once.title", nil);
    [self.view addSubview:self.progressHUD ];
    [self.progressHUD  hide:YES];
    
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_topic_page];
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_topic_page];
    [super viewWillDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    CGFloat lastUploadTs = [FTSUserCenter floatValueForKey:kDftTopicSaveTime];
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    
    BOOL reFresh = FALSE;
    if (fNow - lastUploadTs > kRefreshTopicIntervalS) {
        reFresh =  TRUE;
    }
    
    if (!reFresh) {
        
        [self loadLocalDataNeedFresh];
        
    }else{
        
        if(_nTaskId <= 0)
        {
            _nTaskId = [FTSNetwork topicTitleFreshDownloader:self.downloader Target:self Sel:@selector(onLoadRefreshFinished:) Attached:nil];
            [self.progressHUD show:YES];
        }
    }
    
    
}


- (void)loadLocalDataNeedFresh{
    
    
    NSArray *array = [[FTSDataMgr sharedInstance] arrayOfSaveTopic];
    
    NSMutableArray *process = [NSMutableArray arrayWithCapacity:kEachNum];
    if(self.netArray == nil)
        self.netArray = [NSMutableArray arrayWithCapacity:kEachNum];
    
    int i = -1;
    NSMutableArray *tempOrg = [NSMutableArray arrayWithCapacity:kEachNum];
    NSMutableArray *tempProcess = [NSMutableArray arrayWithCapacity:kEachNum];
    
    for (Topic *top in array) {
        
        i++;
        if (i < kEachNum) {
            [tempOrg addObject:top];
            
            GridData *data = [[GridData alloc] init];
            data.name = top.name;
            data.type = top.type;
            [tempProcess addObject:data];
            
        }else{
            [self.netArray addObject:tempOrg];
            [process addObject:tempProcess];
            
            i = 0;
            tempOrg = [NSMutableArray arrayWithCapacity:kEachNum];
            tempProcess = [NSMutableArray arrayWithCapacity:kEachNum];
            
            [tempOrg addObject:top];
            
            GridData *data = [[GridData alloc] init];
            data.name = top.name;
            data.type = top.type;
            [tempProcess addObject:data];
            
            
        }
        
        
    }
    
    [self.netArray addObject:tempOrg];
    [process addObject:tempProcess];
    
    self.dataArray = process;
    
    
    
}



- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
}

#pragma mark
#pragma mark Property

- (void)setDataArray:(NSArray *)dataArray{
    
    _dataArray = dataArray;
    [self.contentView reloadData];
    self.pageControl.numberOfPages = [_dataArray count];
    [self.pageControl updateCurrentPageDisplay];
    
}




- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
    return [self.dataArray count];
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    static NSString *identifier = @"cell";
    FTSTopicViewCell *cell = (FTSTopicViewCell *)[scrollView dequeueCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[FTSTopicViewCell alloc] initWithFrame:frame withIdentifier:identifier withController:self];
    }
    cell.section = index;
    cell.delegate = self;
    
    if (index >= [self.dataArray count]) {
        BqsLog(@"index : %d >= [self.dataArray count] : %d",index,[self.dataArray count]);
        return cell;
    }
    
    cell.dataArray = [self.dataArray objectAtIndex:index];
    
    return cell;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark TopicViewCellDelegate

- (void)TopicViewCell:(FTSTopicViewCell *)cell selectSection:(NSUInteger)section atIndex:(NSUInteger)index{
    
    BqsLog(@"TopicViewCell selectSection = %d, atIndex = d",section,index);
    
    if ([self.netArray count] <= section) {
        
        BqsLog(@"TopicViewCell selectSection [self.netArray count] :%d <= section :%d",[self.netArray count],section);
        return;
    }
    
    NSArray *topicArray = [self.netArray objectAtIndex:section];
    
    if ([topicArray count] <= index) {
        
        BqsLog(@"TopicViewCell selectSection [topicArray count] :%d <= section :%d",[topicArray count],section);
        return;
    }
    
    Topic *topic = [topicArray objectAtIndex:index];
    
    switch (topic.type) {
        case TopicTypeWords:
            
            break;
        case TopicTypeImage:
        {
            FTSTopicImageDetailViewController *topicImageVC = [[FTSTopicImageDetailViewController alloc] initWithTopic:topic];
            [FTSUIOps flipNavigationController:self.navigationController.rdv_tabBarController.revealController.flipboardNavigationController pushNavigationWithController:topicImageVC];
            break;
        }
        case TopicTypeVideo:
        {
            FTSTopicVideoDetailViewController *topicVideoVC = [[FTSTopicVideoDetailViewController alloc] initWithTopic:topic];
            [FTSUIOps flipNavigationController:self.navigationController.rdv_tabBarController.revealController.flipboardNavigationController pushNavigationWithController:topicVideoVC];
            break;
        }
            
        default:
            break;
    }
    
}


#pragma mark ContentScrollViewDelegate
- (void)scrollView:(MptContentScrollView *)scrollView curIndex:(NSInteger)index
{
    self.pageControl.currentPage = index;
    
}


#pragma mark
#pragma mark DownloadCallback
- (void)onLoadRefreshFinished:(DownloaderCallbackObj *)cb
{
    [self.progressHUD hide:YES];
    
    if(nil == cb) return;
    
    if(nil != cb.error || 200 != cb.httpStatus) {
		BqsLog(@"Error: len:%d, http%d, %@", [cb.rspData length], cb.httpStatus, cb.error);
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        return;
	}
    
    NSArray *array = [Topic parseJsonData:cb.rspData];
    if ([array count] == 0) {
        
        [HMPopMsgView showPopMsgError:cb.error Msg:NSLocalizedString(@"error.networkfailed", nil) Delegate:nil];
        
        
        return;
        
    }
    
    NSMutableArray *process = [NSMutableArray arrayWithCapacity:kEachNum];
    if(self.netArray == nil)
        self.netArray = [NSMutableArray arrayWithCapacity:kEachNum];
    
    int i = -1;
    NSMutableArray *tempOrg = [NSMutableArray arrayWithCapacity:kEachNum];
    NSMutableArray *tempProcess = [NSMutableArray arrayWithCapacity:kEachNum];
    
    for (Topic *top in array) {
        
        i++;
        if (i < kEachNum) {
            [tempOrg addObject:top];
            
            GridData *data = [[GridData alloc] init];
            data.name = top.name;
            data.type = top.type;
            [tempProcess addObject:data];
            
        }else{
            [self.netArray addObject:tempOrg];
            [process addObject:tempProcess];
            
            i = 0;
            tempOrg = [NSMutableArray arrayWithCapacity:kEachNum];
            tempProcess = [NSMutableArray arrayWithCapacity:kEachNum];
            
            [tempOrg addObject:top];
            
            GridData *data = [[GridData alloc] init];
            data.name = top.name;
            data.type = top.type;
            [tempProcess addObject:data];
            
            
        }
        
        
    }
    
    [self.netArray addObject:tempOrg];
    [process addObject:tempProcess];
    
    self.dataArray = process;
    
    [[FTSDataMgr sharedInstance] saveTopicArray:array]; //save data use xml
    const float fNow = (float)[NSDate timeIntervalSinceReferenceDate];
    [FTSUserCenter setFloatVaule:fNow forKey:kDftTopicSaveTime];
    
    
}




@end
