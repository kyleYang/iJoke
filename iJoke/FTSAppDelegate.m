//
//  FTSAppDelegate.m
//  iJoke
//
//  Created by Kyle on 13-7-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSAppDelegate.h"
#import "iRate.h"
#import "iVersion.h"
#import "MobClick.h"
#import "UMFeedback.h"
#import "UMSocial.h"
#import "WXApi.h"
#import "FTSUserCenter.h"
#import "Video.h"
#import "HTTPServer.h"
#import "Reachability.h"
//#import "HumDotaVideoManager.h"
#import "PKRevealController.h"
#import "FTSWordsViewController.h"
#import "FTSImageViewController.h"
#import "FTSVideoViewController.h"
#import "FTSReviewViewController.h"
#import "FTSTopicViewController.h"
#import "CustomNavigationBar.h"
#import "FTSLeftRevealViewController.h"
#import "FTSRightRevealViewController.h"
#import "SDImageCache.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"


@interface FTSAppDelegate()<EnvProtocol>{
    Reachability  *_hostReach;
}
@property (nonatomic, strong) Env *theEnv;
@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, strong) RDVTabBarController *tabBarController;
@property (nonatomic, strong) PKRevealController *revealController;
@property (nonatomic, strong) FTSRightRevealViewController *rightController;
@property (nonatomic, strong) FlipBoardNavigationController *flipNavgationController;

@end

@implementation FTSAppDelegate

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UMOnlineConfigDidFinishedNotification object:nil];
    
}

- (void)umengTrack {
    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    //    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:[Env sharedEnv].umengId reportPolicy:(ReportPolicy) SEND_ON_EXIT channelId:[Env sharedEnv].market];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //      [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
}

- (void)umengFeedback{
    [UMFeedback setLogEnabled:YES];
    [UMFeedback checkWithAppkey:[Env sharedEnv].umengId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umCheck:) name:UMFBCheckFinishedNotification object:nil];

}


- (void)umengSocail{
    
    //打开调试log的开关
    [UMSocialData openLog:YES];
    
    [UMSocialData setAppKey:[Env sharedEnv].umengId];
   
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
    
    //设置友盟appkey
    
    [UMSocialConfig setWXAppId:@"wxd9a39c7122aa6516" url:nil];
    //打开Qzone的SSO开关
    [UMSocialConfig setSupportQzoneSSO:YES importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
    //设置手机QQ的AppId，url传nil，将使用友盟的网址
    [UMSocialConfig setQQAppId:@"100424468" url:nil importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
    //打开新浪微博的SSO开关
    [UMSocialConfig setSupportSinaSSO:YES];

}


- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}


+ (void)initialize
{
    
	[iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    //enable preview mode
    
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    application.statusBarHidden = NO;
    
    self.theEnv = [[Env alloc] init];
    [iRate sharedInstance].appStoreID = [[Env sharedEnv].itunesAppId intValue];
    [iVersion sharedInstance].appStoreID = [[Env sharedEnv].itunesAppId intValue];
    
    [[SDImageCache sharedImageCache] setMaxCacheAge:2592000]; //a month
    [[SDImageCache sharedImageCache] setMaxCacheSize:104857600];// 100 MB
    
//    [[SDImageCache sharedImageCache] addPackageFilePath:@"onlineimage.pak"];
    
    [FTSUserCenter setBoolVaule:TRUE forKey:kDftNetTypeWifi]; //默认wifi
    
    if (![FTSUserCenter BoolValueForKey:kFirstUseJoke]) {
        [FTSUserCenter setIntValue:VideoScreenClear forKey:kScreenPlayType];
        [FTSUserCenter setIntValue:VideoScreenClear forKey:kScreenDownType];
        [FTSUserCenter setBoolVaule:TRUE forKey:kFirstUseJoke];
    }
    
    [self umengTrack];
    [self umengFeedback];
    [self umengSocail];
    
//    self.httpServer = [[HTTPServer alloc] init]; //this version no need to download video
//	
//	// Tell the server to broadcast its presence via Bonjour.
//	// This allows browsers such as Safari to automatically discover our service.
//	[self.httpServer setType:@"_http._tcp."];
//	
//	// Normally there's no need to run our server on any specific port.
//	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
//	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
//	[self.httpServer setPort:12345];
////    [self.httpServer setDocumentRoot:[HumDotaVideoManager instance].videoPath];
//    
//    NSError *error;
//	if(![self.httpServer start:&error])
//	{
//		BqsLog(@"Error starting HTTP Server: %@", error);
//	}

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    if (!self.theEnv.bIsPad) {
        
        
        
//        FTSWordsViewController *ctl = [[FTSWordsViewController alloc] initWithNibName:nil bundle:nil];
//        
//        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:ctl];
//        
//        CustomNavigationBar *navBar = [[CustomNavigationBar alloc] init];
//        [navBar setBarTintGradientColor:[UIColor whiteColor]];
//
//        UIImage *bgImg = [[Env sharedEnv] cacheImage:@"navbar_background.png"];
//        [navBar setCustomBgImage:bgImg];
//        [navc setValue:navBar forKey:@"navigationBar"];
        
        [self setupTabBarViewControllers];
        
        
//        FTSLeftRevealViewController *leftCtl = [[FTSLeftRevealViewController alloc] initWithNibName:nil bundle:nil];
        
        
        self.rightController = [[FTSRightRevealViewController alloc] initWithNibName:nil bundle:nil];
        
        
        self.revealController = [PKRevealController revealControllerWithFrontViewController:self.tabBarController
                                                                         leftViewController:self.rightController
                                                                        rightViewController:nil
                                                                                    options:nil];
        
        self.flipNavgationController =  [[FlipBoardNavigationController alloc]initWithRootViewController:self.revealController];
        
        
//        self.viewController = self.revealController;
    }else{
        //        HumPadDotaBaseViewController *ctl = [[HumPadDotaBaseViewController alloc] initWithNibName:nil bundle:nil];
        //        ctl.managedObjectContext = self.managedObjectContext;
        //        self.viewController = ctl;
        //        [ctl release];
    }

    
    self.window.rootViewController = self.flipNavgationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    _hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [_hostReach startNotifier];
    
    [self customizeInterface];
    
    application.applicationIconBadgeNumber = 0;

    
    return YES;
}



#pragma mark - Methods

- (void)setupTabBarViewControllers {
    UIViewController *imageViewController = [[FTSImageViewController alloc] initWithNibName:nil bundle:nil];
    UIViewController *imageNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:imageViewController];
    
    UIViewController *wordsViewController = [[FTSWordsViewController alloc] init];
    UIViewController *wordsNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:wordsViewController];
    
    UIViewController *videoViewController = [[FTSVideoViewController alloc] init];
    UIViewController *videoNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:videoViewController];
    
    UIViewController *topicViewController = [[FTSTopicViewController alloc] init];
    UIViewController *topicNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:topicViewController];
    
    UIViewController *reviewViewController = [[FTSReviewViewController alloc] init];
    UIViewController *reviewNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:reviewViewController];
    
    
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[imageNavigationController, wordsNavigationController,
                                           videoNavigationController,topicNavigationController,reviewNavigationController]];
    
    
    self.tabBarController = tabBarController;
    
    [self customizeTabBarForController:tabBarController];
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"first", @"second", @"third",@"first", @"second"];
    
//  @[NSLocalizedString(@"joke.category.image", nil), NSLocalizedString(@"joke.category.text", nil), NSLocalizedString(@"joke.category.video", nil),NSLocalizedString(@"joke.category.topic", nil),NSLocalizedString(@"joke.category.verify", nil)];
    
//    "joke.category.text" = "文字";
//    "joke.category.image" = "图片";
//    "joke.category.video" = "视频";
//    "joke.category.topic" = "专题";
//    "joke.category.verify" = "审核";
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}


- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    if (DeviceSystemMajorVersion() >= 7) {
        [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"navigationbar_background_tall"]
                                      forBarMetrics:UIBarMetricsDefault];
    } else {
        [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"navigationbar_background"]
                                      forBarMetrics:UIBarMetricsDefault];
        
        NSDictionary *textAttributes = nil;
        
        if (DeviceSystemMajorVersion() >= 7) {
            textAttributes = @{
                               NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
                               NSForegroundColorAttributeName: [UIColor blackColor],
                               };
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            textAttributes = @{
                               UITextAttributeFont: [UIFont boldSystemFontOfSize:20],
                               UITextAttributeTextColor: [UIColor blackColor],
                               UITextAttributeTextShadowColor: [UIColor clearColor],
                               UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                               };
#endif
        }
        
        [navigationBarAppearance setTitleTextAttributes:textAttributes];
    }
}




- (void)umCheck:(NSNotification *)notification {
    
    if (notification.userInfo) { //check out ,have feedback replay,notice

//        NSArray *newReplies = [notification.userInfo objectForKey:@"newReplies"];
//        NSLog(@"newReplies = %@", newReplies);
//        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"relapy.have", nil), [newReplies count]];
//        NSMutableString *content = [NSMutableString string];
//        for (NSUInteger i = 0; i < [newReplies count]; i++) {
//            NSString *dateTime = [[newReplies objectAtIndex:i] objectForKey:@"datetime"];
//            NSString *_content = [[newReplies objectAtIndex:i] objectForKey:@"content"];
//            [content appendString:[NSString stringWithFormat:@"%d .......%@.......\r\n", i + 1, dateTime]];
//            [content appendString:_content];
//            [content appendString:@"\r\n\r\n"];
//        }
        
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"relapy.have", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancle", nil) otherButtonTitles:NSLocalizedString(@"button.check", nil), nil];
        ((UILabel *) [[alertView subviews] objectAtIndex:1]).textAlignment = NSTextAlignmentLeft;
        
        [alertView show];
    
        
    } 
   
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"查看feedback");
        [self.rightController feedback:nil];
    } else {
        
    }
}


/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    /*
     //如果你要处理自己的url，你可以把这个方法的实现，复制到你的代码中：
     
     if ([url.description hasPrefix:@"sina"]) {
     return (BOOL)[[UMSocialSnsService sharedInstance] performSelector:@selector(handleSinaSsoOpenURL:) withObject:url];
     }
     else if([url.description hasPrefix:@"wx"]){
     return [WXApi handleOpenURL:url delegate:(id <WXApiDelegate>)[UMSocialSnsService sharedInstance]];
     }
     */
    
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}


/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    if(![curReach isKindOfClass: [Reachability class]])
        return;
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    [FTSUserCenter setBoolVaule:TRUE forKey:kDftHaveNetWork];
    if (status == NotReachable) {
        [FTSUserCenter setBoolVaule:FALSE forKey:kDftHaveNetWork];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"title.error.nonetwork", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"button.sure", nil) otherButtonTitles:nil];
        [alert show];
        
    }else if(status == ReachableViaWiFi) {
        [FTSUserCenter setBoolVaule:TRUE forKey:kDftNetTypeWifi];
    }else {
        [FTSUserCenter setBoolVaule:FALSE forKey:kDftNetTypeWifi];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkStateChangeTo3G object:nil];
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - for env
-(Env*)getEnv {
    return self.theEnv;
}

-(UIViewController*)getRootViewController {
    return self.revealController;
}

@end
