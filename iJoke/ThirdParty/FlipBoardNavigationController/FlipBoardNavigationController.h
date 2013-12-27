//
//  FlipBoardNavigationController.h
//  iamkel.net
//
//  Created by Michael henry Pantaleon on 4/30/13.
//  Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FlipBoardNavigationControllerCompletionBlock)(void);

@interface FlipBoardNavigationController : UIViewController

@property(nonatomic, retain, readonly) NSMutableArray *viewControllers;

- (id) initWithRootViewController:(UIViewController*)rootViewController;

- (void) pushViewController:(UIViewController *)viewController;
- (void) pushViewController:(UIViewController *)viewController completion:(FlipBoardNavigationControllerCompletionBlock)handler;
- (void) popViewController;
- (void) removeViewControllerArray:(NSArray *)array;
- (void) popViewControllerWithCompletion:(FlipBoardNavigationControllerCompletionBlock)handler;
- (void) popToViewController:(UIViewController *)viewController;
- (void) popToViewController:(UIViewController *)viewController Completion:(FlipBoardNavigationControllerCompletionBlock)handler;
- (void) popToRootViewControllerAnimated:(BOOL)animated;
- (void) popToRootViewControllerAnimatedWithCompletion:(FlipBoardNavigationControllerCompletionBlock)handler;

@end

@interface UIViewController (FlipBoardNavigationController)
@property (nonatomic, retain) FlipBoardNavigationController *flipboardNavigationController;
@end




