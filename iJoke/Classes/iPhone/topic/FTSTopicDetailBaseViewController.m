//
//  FTSTopicDetailBaseViewController.m
//  iJoke
//
//  Created by Kyle on 13-11-26.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTopicDetailBaseViewController.h"


@interface FTSTopicDetailBaseViewController ()

@property (nonatomic, strong, readwrite) Topic *topic;

@end

@implementation FTSTopicDetailBaseViewController
@synthesize dataArray = _dataArray;
@synthesize hasMore = _hasMore;
@synthesize topic = _topic;



- (id)initWithTopic:(Topic *)atopic{
    
    self = [super init];
    if (self) {
        
        _topic = atopic;
        
    }
    return self;
}


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
    
    self.managedObjectContext = ((FTSAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
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
    [self loadLocalDataNeedFresh];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [self.downloader cancelAll];
    [super viewWillDisappear:animated];
}

- (void)backSuper:(id)sender{
    
    [self.flipboardNavigationController popViewController];
    
}



#pragma mark
#pragma mark property
- (void)setDataArray:(NSArray *)dataArray{
    
    _dataArray = dataArray;
    [self reloadData];
    
}

- (void)loadLocalDataNeedFresh{
    
}

- (void)reloadData{
    
}

- (void)dataFresh:(id)sender{
    
}






@end
