//
//  FTSRevealBaseViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSRevealBaseViewController.h"
#import "PKRevealController.h"
#import "CustomUIBarButtonItem.h"
#import "FTSAppDelegate.h"

@interface FTSRevealBaseViewController ()

@end

@implementation FTSRevealBaseViewController
@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.downloader cancelAll];
    self.downloader = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    Env *env= [Env sharedEnv];
    
    self.view.backgroundColor = RGBA(255, 248, 240, 1.0);
    
    UIImage *revealRightImagePortrait = [env cacheImage:@"joke_nav_option.png"];
//    UIImage *revealLeftImageLandscape = [env cacheImage:@"joke_nav_option_down.png"];
    
    UIImage *revealLeftImagePortrait = [env cacheImage:@"joke_nav_setting.png"];
//    UIImage *revealRightImageLandscape = [env cacheImage:@"joke_nav_setting_down.png"];
    
    if (self.navigationController.rdv_tabBarController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [CustomUIBarButtonItem initWithImage:revealLeftImagePortrait eventImg:nil title:nil target:self action:@selector(showLeftView:)];
        
    }
    
    if (self.navigationController.rdv_tabBarController.revealController.type & PKRevealControllerTypeRight)
    {
        self.navigationItem.rightBarButtonItem = [CustomUIBarButtonItem initWithImage:revealRightImagePortrait eventImg:nil title:nil target:self action:@selector(showRgihtView:)];
    }
    
    if(DeviceSystemMajorVersion() >=7){
        
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars  = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;

    }
    
    
    self.contentView = [[MptContentScrollView alloc] initWithFrame:self.view.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];

    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    _managedObjectContext = ((FTSAppDelegate*) [UIApplication sharedApplication].delegate).managedObjectContext;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appTermNtf:) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResumeNtf:) name:UIApplicationDidBecomeActiveNotification object:nil];
    

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.contentView.dataSource = self;
    self.contentView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.downloader cancelAll];
    [self.contentView viewWillDisappear];
    self.contentView.dataSource = nil;
    self.contentView.delegate = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


- (void)dataResume{
    [self.contentView viewWillAppear];
}

#pragma mark
#pragma mark - ntf handler
-(void)appTermNtf:(NSNotification*)ntf {
    BqsLog(@"appTermNtf");
    [self.downloader cancelAll];
    [self.contentView viewWillDisappear];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)appResumeNtf:(NSNotification*)ntf {
    BqsLog(@"appResumeNtf");
    [self performSelector:@selector(dataResume) withObject:nil afterDelay:1];
}




#pragma mark
#pragma mark barbutton method
- (void)showLeftView:(id)sender
{
    if (self.navigationController.rdv_tabBarController.revealController.focusedController == self.navigationController.rdv_tabBarController.revealController.leftViewController)
    {
        [self.navigationController.rdv_tabBarController.revealController showViewController:self.navigationController.rdv_tabBarController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.rdv_tabBarController.revealController showViewController:self.navigationController.rdv_tabBarController.revealController.leftViewController];
    }
}

- (void)showRgihtView:(id)sender
{
    if (self.navigationController.rdv_tabBarController.revealController.focusedController == self.navigationController.rdv_tabBarController.revealController.leftViewController)
    {
        [self.navigationController.rdv_tabBarController.revealController showViewController:self.navigationController.rdv_tabBarController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.rdv_tabBarController.revealController showViewController:self.navigationController.rdv_tabBarController.revealController.rightViewController];
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}


 /**
  *	scrollview dataSource, Must be rewrite,like tableView
  *
  *	@param	scrollView
  *
  *	@return	
  */

- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
    return 0;
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    return nil;
}



@end
