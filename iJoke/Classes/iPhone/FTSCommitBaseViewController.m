//
//  FTSDetailBaseViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommitBaseViewController.h"
#import "CustomUIBarButtonItem.h"
#import "HMPopMsgView.h"
#import "Msg.h"

@interface FTSCommitBaseViewController ()<UIActionSheetDelegate>{
   
}


@property (nonatomic, strong, readwrite) NSArray *dataArray;
@end

@implementation FTSCommitBaseViewController
@synthesize dataArray = _dataArray;
@synthesize more = _more;
@synthesize displayIndex = _displayIndex;
@synthesize baseDelegate = _baseDelegate;

- (id)initWithDataArray:(NSArray*)array hasMore:(BOOL)value curIndex:(NSUInteger)index{
    self = [super init];
    if (self) {
        _dataArray = array;
        _more = value;
        _displayIndex = index;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    Env *env = [Env sharedEnv];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *revealLeftImagePortrait = [env cacheImage:@"content_navigationbar_back.png"];
    UIImage *revealLeftImageLandscape = [env cacheImage:@"content_navigationbar_back_highlighted.png"];
    
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_setting.png"];
    UIImage *revealRightImageLandscape = [env cacheImage:@"joke_nav_setting_down.png"];
    
    if(DeviceSystemMajorVersion() >=7){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars  = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }

    
    self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:revealLeftImageLandscape title:nil target:self action:@selector(backSuper:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"joke.navigation.report", nil) style:UIBarButtonItemStylePlain target:self action:@selector(reportClick:)];

    self.contentView = [[MptContentScrollView alloc] initWithFrame:self.view.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.contentView.dataSource = self;
    self.contentView.delegate = self;
    [self.view addSubview:self.contentView];

    
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.contentView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.downloader cancelAll];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}




#pragma mark
#pragma property

- (void)setDataArray:(NSArray *)dataArray more:(BOOL)more{
    _more = more;
    _dataArray = dataArray;
    [self.contentView reloadData];
}

- (void)setMore:(BOOL)more{
    if (_more == more) return;
    
    _more = more;
    [self.contentView reloadData];
    
}

- (void)setDisplayIndex:(NSUInteger)displayIndex{
    if (_displayIndex == displayIndex) return;
    _displayIndex = displayIndex;
    [self.contentView setCurrentItemIndex:_displayIndex animation:NO]; //scroll to displayIndex;
}


#pragma mark
#pragma mark 

- (void)backSuper:(id)sender{
    
    if (_baseDelegate && [_baseDelegate respondsToSelector:@selector(commitViewControllerPopViewController:offset:)]) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.contentView.current inSection:0];
        
        [_baseDelegate commitViewControllerPopViewController:self offset:indexPath];
        
        return;
        
    }
    
    [self.flipboardNavigationController popViewController];
    
}

- (void)reportClick:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"joke.comment.report", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"joke.navigation.report", nil), nil];
    [actionSheet showInView:self.view];

}


#pragma mark
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 ) { //click report
        
        [self reportMessage];
        
    }
    
}

- (void)reportMessage{
    
}

- (void)reportMessageCB:(DownloaderCallbackObj *)cb{
    
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
        [HMPopMsgView showPopMsg:NSLocalizedString(@"joke.comment.report.ok", nil)];
    }

    
}


#pragma mark
#pragma mark SupportedInterface

- (BOOL)shouldAutorotate{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


#pragma mark
#pragma mark MptContentScrollView dataSource

- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
    return 0;
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    return nil;
}

- (NSUInteger)currentPageForScrollView:(MptContentScrollView *)popController{
    return _displayIndex;
}



@end
