//
//  FTSUIOps.m
//  iJoke
//
//  Created by Kyle on 13-8-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSUIOps.h"
#import <QuartzCore/QuartzCore.h>
#import "PKRevealController.h"
#import "CustomNavigationController.h"
#import "CustomNavigationBar.h"


@implementation FTSUIOps

+(void)slideShowModalViewControler:(UIViewController*)vctl ParentVCtl:(UIViewController*)pvctl {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = pvctl.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    
    [pvctl presentModalViewController:vctl animated:NO];
}

+(void)slideShowModalViewInNavControler:(UIViewController *)vctl ParentVCtl:(UIViewController *)pvctl {
    if(nil == vctl || nil == pvctl) return;
    
    CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:vctl];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    CustomNavigationBar *navBar = [[CustomNavigationBar alloc] init];
    UIImage *bgImg = [[Env sharedEnv] cacheImage:@"navbar_background.png"];
    [navBar setCustomBgImage:bgImg];
    [nav setValue:navBar forKey:@"navigationBar"];
    
    [self slideShowModalViewControler:nav ParentVCtl:pvctl];
    
}

+(void)slideDismissModalViewController:(UIViewController*)vctl {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    
    // NSLog(@"%s: controller.view.window=%@", _func_, controller.view.window);
    UIView *containerView = vctl.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    
    [vctl dismissModalViewControllerAnimated:NO];
}

+(void)popUIViewControlInNavigationControl:(UIViewController *)control{
    
    UINavigationController *navCtl = control.navigationController;
    if (control == [navCtl.viewControllers objectAtIndex:0]) {
        [control dismissModalViewControllerAnimated:YES];
    }else{
        [navCtl popViewControllerAnimated:YES];
    }
    
}


+(void)revealViewControl:(UIViewController *)left presentViewControlel:(UIViewController *)font{
    FlipBoardNavigationController *navc = [[FlipBoardNavigationController alloc] initWithRootViewController:font];
//    CustomNavigationBar *navBar = [[CustomNavigationBar alloc] init];
//    UIImage *bgImg = [[Env sharedEnv] cacheImage:@"dota_frame_title_bg.png"];
//    [navBar setCustomBgImage:bgImg];
//    [navc setValue:navBar forKey:@"navigationBar"];
    
    [left.revealController presentModalViewController:navc animated:YES];;
    
}

+(void)revealLeftViewControl:(UIViewController *)left showNavigationFontViewControl:(UIViewController *)font wihtOtherViewControle:(UIViewController *)other{
//    FlipBoardNavigationController *navc = [[FlipBoardNavigationController alloc] initWithRootViewController:font];
//    CustomNavigationBar *navBar = [[CustomNavigationBar alloc] init];
//    UIImage *bgImg = [[Env sharedEnv] cacheImage:@"dota_frame_title_bg.png"];
//    [navBar setCustomBgImage:bgImg];
//    [navc setValue:navBar forKey:@"navigationBar"];
    
    left.revealController.frontViewController = font;
    left.revealController.rightViewController = other;
    [left.revealController showViewController:left.revealController.frontViewController];
    
}

+(void)revealRightViewControl:(UIViewController *)right showNavigationFontViewControl:(UIViewController *)font wihtOtherViewControle:(UIViewController *)other{
//    FlipBoardNavigationController *navc = [[FlipBoardNavigationController alloc] initWithRootViewController:font];
//    CustomNavigationBar *navBar = [[CustomNavigationBar alloc] init];
//    UIImage *bgImg = [[Env sharedEnv] cacheImage:@"dota_frame_title_bg.png"];
//    [navBar setCustomBgImage:bgImg];
//    [navc setValue:navBar forKey:@"navigationBar"];
    
    right.revealController.frontViewController = font;
    [right.revealController showViewController:right.revealController.frontViewController];
   
}

+(void)revealRightViewControl:(UIViewController *)right showNavigationFontViewControl:(UIViewController *)font{
//    FlipBoardNavigationController *navc = [[FlipBoardNavigationController alloc] initWithRootViewController:font];
//    CustomNavigationBar *navBar = [[CustomNavigationBar alloc] init];
//    UIImage *bgImg = [[Env sharedEnv] cacheImage:@"dota_frame_title_bg.png"];
//    [navBar setCustomBgImage:bgImg];
//    [navc setValue:navBar forKey:@"navigationBar"];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:font];
    
//    CustomNavigationBar *navBar = [[CustomNavigationBar alloc] init];
//    UIImage *bgImg = [[Env sharedEnv] cacheImage:@"navbar_background.png"];
//    [navBar setCustomBgImage:bgImg];
//    [navc setValue:navBar forKey:@"navigationBar"];

    
    
    right.revealController.frontViewController = navc;
    [right.revealController showViewController:right.revealController.frontViewController];
       
}


//FlipNavigation

+(void)flipNavigationController:(FlipBoardNavigationController*)flipNav pushNavigationWithController:(UIViewController *)controler{
    
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:controler];
    
//    CustomNavigationBar *navBar = [[CustomNavigationBar alloc] init];
//    [navBar setBarTintGradientColor:[UIColor whiteColor]];
//    UIImage *bgImg = [[Env sharedEnv] cacheImage:@"navbar_background.png"];
//    [navBar setCustomBgImage:bgImg];
//    [navc setValue:navBar forKey:@"navigationBar"];
    
    [flipNav pushViewController:navc];
}


+(void)flipNavigationController:(FlipBoardNavigationController*)flipNav popNavigationWithController:(UIViewController *)controler{

}
@end
