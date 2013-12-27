//
//  FTSUIOps.h
//  iJoke
//
//  Created by Kyle on 13-8-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTSUIOps : NSObject


+(void)slideShowModalViewControler:(UIViewController*)vctl ParentVCtl:(UIViewController*)pvctl;
+(void)slideShowModalViewInNavControler:(UIViewController *)vctl ParentVCtl:(UIViewController *)pvctl;
+(void)slideDismissModalViewController:(UIViewController*)vctl;

+(void)popUIViewControlInNavigationControl:(UIViewController *)control;
+(void)revealViewControl:(UIViewController *)left presentViewControlel:(UIViewController *)font;
+(void)revealLeftViewControl:(UIViewController *)left showNavigationFontViewControl:(UIViewController *)font wihtOtherViewControle:(UIViewController *)other;

+(void)revealRightViewControl:(UIViewController *)right showNavigationFontViewControl:(UIViewController *)font wihtOtherViewControle:(UIViewController *)other;
+(void)revealRightViewControl:(UIViewController *)right showNavigationFontViewControl:(UIViewController *)font;




//flipNavigationController

+(void)flipNavigationController:(FlipBoardNavigationController*)flipNav pushNavigationWithController:(UIViewController *)controler;


@end
