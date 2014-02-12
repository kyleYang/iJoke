//
//  FTSRightRevealViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSRightRevealViewController.h"
#import "UMFeedbackViewController.h"
#import "FTSLoginViewController.h"
#import "FTSUIOps.h"
#import "FTSUserCenter.h"
#import "FTSUserInfoViewController.h"
#import "FTSMessagePublishViewController.h"
#import "FTSCircleImageView.h"
#import "IconTitleButton.h"
#import "FTSCollectMessageViewController.h"
#import "FTSPubulishMessageViewController.h"
#import "FTSFollowUpViewController.h"
#import "FTSSettingViewController.h"
#import "iVersion.h"
#import "HumDotaHelpViewController.h"

@interface FTSRightRevealViewController ()<FTSLoginDelegate>

@property (nonatomic, strong) FTSCircleImageView *headImage;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation FTSRightRevealViewController

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
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image = [[Env sharedEnv] cacheImage:@"reveal_background.png"];
    [self.view addSubview:backgroundView];
    
    self.headImage = [[FTSCircleImageView alloc] initWithFrame:CGRectMake(15, 30, 60, 60)];
    self.headImage.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.headImage];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImage.frame) + 11, CGRectGetMinY(self.headImage.frame)+5, 135, 30)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.view addSubview:self.nameLabel];
    
    UIImageView *dicrct = [[UIImageView alloc] initWithImage:[[Env sharedEnv] cacheImage:@"user_arrow.png"]];
    CGRect rect = dicrct.frame;
    rect.origin.y = CGRectGetMinY(self.headImage.frame) + (CGRectGetHeight(self.headImage.frame) - CGRectGetHeight(rect))/2;
    rect.origin.x = CGRectGetMaxX(self.nameLabel.frame)+5;
    dicrct.frame = rect;
    [self.view addSubview:dicrct];
    
    UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.headImage.frame), CGRectGetMinY(self.headImage.frame), CGRectGetWidth(self.view.bounds)-CGRectGetMinX(self.headImage.frame)-50, CGRectGetHeight(self.headImage.frame))];
    loginBtn.backgroundColor = [UIColor clearColor];
    [loginBtn addTarget:self action:@selector(loginOption:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    
//    "joke.setting.follow" = "跟帖";
//    "joke.setting.collect" = "收藏";
//    "joke.setting.commit" = "评论";
    
    IconTitleButton *followBtn = [[IconTitleButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.headImage.frame)+45, CGRectGetMaxY(self.headImage.frame)+10, 60, 50)];
    followBtn.title = NSLocalizedString(@"joke.setting.follow", nil);
    followBtn.iconImageView.image = [[Env sharedEnv] cacheImage:@"setting_publish.png"];
    followBtn.showsTouchWhenHighlighted = YES;
    [followBtn addTarget:self action:@selector(followCheck:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:followBtn];
    
    IconTitleButton *collectBtn = [[IconTitleButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(followBtn.frame)+30, CGRectGetMinY(followBtn.frame), CGRectGetWidth(followBtn.frame), CGRectGetHeight(followBtn.frame))];
    collectBtn.title = NSLocalizedString(@"joke.setting.collect", nil);
    collectBtn.iconImageView.image = [[Env sharedEnv] cacheImage:@"setting_collect.png"];
    collectBtn.showsTouchWhenHighlighted = YES;
    [collectBtn addTarget:self action:@selector(collectCheck:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:collectBtn];

    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.headImage.frame)-10, CGRectGetMaxY(followBtn.frame)+14, CGRectGetWidth(self.view.bounds)-CGRectGetMinX(self.headImage.frame)-10, .5)];
    line.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:line];
    
    IconTitleButton *publishBtn = [[IconTitleButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(followBtn.frame)+20, CGRectGetMaxY(line.frame)+30, 120, 35)];
    publishBtn.iconImageView.frame = CGRectMake(10, 0, CGRectGetHeight(publishBtn.frame), CGRectGetHeight(publishBtn.frame));
    [publishBtn addTarget:self action:@selector(downloadTouch:) forControlEvents:UIControlEventTouchUpInside];
    publishBtn.layoutType = IconTitleButtonTypeHorizontal;
    publishBtn.title = NSLocalizedString(@"joke.setting.publish", nil);
    publishBtn.iconImageView.image = [[Env sharedEnv] cacheImage:@"setting_publish_joke.png"];
    publishBtn.labelTitle.font = [UIFont systemFontOfSize:18.0f];
    publishBtn.showsTouchWhenHighlighted = YES;
    [self.view addSubview:publishBtn];
    
    IconTitleButton *settingBtn = [[IconTitleButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(publishBtn.frame), CGRectGetMaxY(publishBtn.frame)+20, CGRectGetWidth(publishBtn.frame), CGRectGetHeight(publishBtn.frame))];
    settingBtn.iconImageView.frame = CGRectMake(10, 0, CGRectGetHeight(settingBtn.frame), CGRectGetHeight(settingBtn.frame));
    [settingBtn addTarget:self action:@selector(settingTouch:) forControlEvents:UIControlEventTouchUpInside];
    settingBtn.layoutType = IconTitleButtonTypeHorizontal;
    settingBtn.title = NSLocalizedString(@"joke.setting.setting", nil);
    settingBtn.iconImageView.image = [[Env sharedEnv] cacheImage:@"setting_setting.png"];
    settingBtn.labelTitle.font = [UIFont systemFontOfSize:18.0f];
    settingBtn.showsTouchWhenHighlighted = YES;
    [self.view addSubview:settingBtn];
    
    
    IconTitleButton *feedbackBtn = [[IconTitleButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(publishBtn.frame), CGRectGetMaxY(settingBtn.frame)+20, CGRectGetWidth(settingBtn.frame), CGRectGetHeight(settingBtn.frame))];
    feedbackBtn.iconImageView.frame = CGRectMake(10, 0, CGRectGetHeight(feedbackBtn.frame), CGRectGetHeight(feedbackBtn.frame));
    [feedbackBtn addTarget:self action:@selector(feedbackTouch:) forControlEvents:UIControlEventTouchUpInside];
    feedbackBtn.layoutType = IconTitleButtonTypeHorizontal;
    feedbackBtn.title = NSLocalizedString(@"joke.setting.feedback", nil);
    feedbackBtn.iconImageView.image = [[Env sharedEnv] cacheImage:@"setting_feedback.png"];
    feedbackBtn.labelTitle.font = [UIFont systemFontOfSize:18.0f];
    feedbackBtn.showsTouchWhenHighlighted = YES;
    [self.view addSubview:feedbackBtn];
    
    
    UIButton *versionButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.headImage.frame), CGRectGetHeight(self.view.bounds)-50, 100, 30)];
    [self.view addSubview:versionButton];
    [versionButton addTarget:self action:@selector(versionCheck:) forControlEvents:UIControlEventTouchUpInside];
    versionButton.backgroundColor = [UIColor clearColor];
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([versionString length] == 0)
    {
        versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    
    UILabel *versionTitle = [[UILabel alloc] initWithFrame:versionButton.bounds];
    versionTitle.backgroundColor = [UIColor clearColor];
    versionTitle.textColor = [UIColor whiteColor];
    [versionButton addSubview:versionTitle];
    versionTitle.text = [NSString stringWithFormat:@"V %@",versionString];
    
    
    UIButton *eulaButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-150, CGRectGetMinY(versionButton.frame), 100, 30)];
    [self.view addSubview:eulaButton];
    [eulaButton addTarget:self action:@selector(eulaClick:) forControlEvents:UIControlEventTouchUpInside];
    eulaButton.backgroundColor = [UIColor clearColor];
    UILabel *eulaTitle = [[UILabel alloc] initWithFrame:versionButton.bounds];
    eulaTitle.font = [UIFont systemFontOfSize:12.0f];
    eulaTitle.backgroundColor = [UIColor clearColor];
    eulaTitle.textColor = [UIColor whiteColor];
    [eulaButton addSubview:eulaTitle];
    eulaTitle.text = NSLocalizedString(@"joke.setting.eula", nil);
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkLoginState];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLoginState) name:kLoginStateChange object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginStateChange object:nil];
    [super viewDidDisappear:animated];
}


- (void)checkLoginState
{
    BOOL login = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (login) {
        NSString *nikeName = [FTSUserCenter objectValueForKey:kDftUserNickName];
        if (nikeName != nil) {
             self.nameLabel.text = nikeName;
        }else{
            NSString *useName = [FTSUserCenter objectValueForKey:kDftUserName];
            self.nameLabel.text = useName;
        }
        NSString *imageUrl =[FTSUserCenter objectValueForKey:kDftUserIcon];
        [self.headImage setImageString:imageUrl placholdImage:[[Env sharedEnv] cacheImage:@"user_message_icon_default.png"]];

    }else{
        self.nameLabel.text = NSLocalizedString(@"joke.setting.login.notice", nil);
        self.headImage.imageView.image = [[Env sharedEnv] cacheImage:@"user_message_icon_default.png"];
    }
}

#pragma mark
#pragma mark button method


- (void)loginOption:(id)sender{
    
    BqsLog(@"FTSRightRevealViewController loginOption");
    
    BOOL login = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (login) { //have login ,goto user info center;
        FTSUserInfoViewController *infoViewController = [[FTSUserInfoViewController alloc] initWithNibName:nil bundle:nil];
        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:infoViewController];
        return;
        
    }else{
        FTSLoginViewController *loginViewController = [[FTSLoginViewController alloc] initWithNibName:nil bundle:nil];
        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:loginViewController];
        return;
    }
    
//    BOOL login = [FTSUserCenter BoolValueForKey:kDftUserLogin];
//    if (login) { //have login ,goto user info center; other
//        
//        FTSUserInfoViewController *infoViewController = [[FTSUserInfoViewController alloc] initWithNibName:nil bundle:nil];
//        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:infoViewController];
//        return;
//        
//    }else{
//        FTSLoginViewController *loginViewController = [[FTSLoginViewController alloc] initWithNibName:nil bundle:nil];
//        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:loginViewController];
//        return;
//
//    }
    
    
   
}


- (void)followCheck:(id)sender{
    BqsLog(@"FTSRightRevealViewController followCheck");
    BOOL login = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (login) { //have login ,goto user info center;
        FTSPubulishMessageViewController *publishedViewController = [[FTSPubulishMessageViewController alloc] initWithNibName:nil bundle:nil];
        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:publishedViewController];
        return;
        
    }else{
        FTSLoginViewController *loginViewController = [[FTSLoginViewController alloc] initWithNibName:nil bundle:nil];
        loginViewController.action = @selector(followCheck:);
        loginViewController.delegate = self;
        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:loginViewController];
        return;
    }
    
    
}


- (void)collectCheck:(id)sender{
    BqsLog(@"FTSRightRevealViewController collectCheck");
    FTSCollectMessageViewController *collectController = [[FTSCollectMessageViewController alloc] initWithNibName:nil bundle:nil];
    [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:collectController];
    return;
    
}


- (void)commitCheck:(id)sender{
    BqsLog(@"FTSRightRevealViewController commitCheck");
    
    FTSMessagePublishViewController *loginViewController = [[FTSMessagePublishViewController alloc] initWithNibName:nil bundle:nil];
    [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:loginViewController];
    return;
    
    

    BOOL login = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (login) { //have login ,goto user info center;
        FTSFollowUpViewController *followController = [[FTSFollowUpViewController alloc] initWithNibName:nil bundle:nil];
        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:followController];
        return;
        
    }else{
        FTSLoginViewController *loginViewController = [[FTSLoginViewController alloc] initWithNibName:nil bundle:nil];
        loginViewController.action = @selector(commitCheck:);
        loginViewController.delegate = self;
        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:loginViewController];
        return;
    }

    
}


- (void)settingTouch:(id)sender
{
    BqsLog(@"FTSRightRevealViewController settingTouch");
    
    FTSSettingViewController *settingViewController = [[FTSSettingViewController alloc] initWithNibName:nil bundle:nil];
    [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:settingViewController];
    
    
    
}


- (void)downloadTouch:(id)sender
{
    BqsLog(@"FTSRightRevealViewController downloadTouch");
    
    FTSMessagePublishViewController *loginViewController = [[FTSMessagePublishViewController alloc] initWithNibName:nil bundle:nil];
    [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:loginViewController];
}


- (void)feedbackTouch:(id)sender{
    UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:nil bundle:nil];
    feedbackViewController.appkey = [Env sharedEnv].umengId;

    [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:feedbackViewController];

}


- (void)versionCheck:(id)sender{
    [[iVersion sharedInstance] checkForNewVersion];
}

- (void)eulaClick:(id)sender{
    HumDotaHelpViewController *about = [[HumDotaHelpViewController alloc] initWithTitle:NSLocalizedString(@"joke.setting.eula.title", nil) html:@"eula"];
    [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:about];
}

#pragma mark
#pragma mark FTSLoginDelegate
- (void)loginSuccess:(BOOL)value action:(SEL)action{
    
    if (action != nil) {
        [self performSelector:action withObject:nil afterDelay:0.0f];
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





@end
