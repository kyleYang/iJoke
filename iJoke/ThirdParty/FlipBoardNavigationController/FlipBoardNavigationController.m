//
//  FlipBoardNavigationController.m
//  iamkel.net
//
//  Created by Michael henry Pantaleon on 4/30/13.
//  Copyright (c) 2013 Michael Henry Pantaleon. All rights reserved.
//

#import "FlipBoardNavigationController.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kAnimationDuration = 0.5f;
static const CGFloat kAnimationDelay = 0.0f;
static const CGFloat kMaxBlackMaskAlpha = 0.8f;

typedef enum {
    PanDirectionNone = 0,
    PanDirectionLeft = 1,
    PanDirectionRight = 2
} PanDirection;


@interface FlipBoardNavigationController ()<UIGestureRecognizerDelegate>{
    NSMutableArray *_gestures;
    UIView *_blackMask;
    CGPoint _panOrigin;
    BOOL _animationInProgress;
    CGFloat _percentageOffsetFromLeft;
}

@property(nonatomic, retain, readwrite) NSMutableArray *viewControllers;

- (void) addPanGestureToView:(UIView*)view;
- (void) rollBackViewController;

- (UIViewController *)currentViewController;
- (UIViewController *)previousViewController;

- (void) transformAtPercentage:(CGFloat)percentage ;
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction;
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset;
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation ;
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation FlipBoardNavigationController

- (id) initWithRootViewController:(UIViewController*)rootViewController {
    if (self = [super init]) {
        self.viewControllers = [NSMutableArray arrayWithObject:rootViewController];
    }
    return self;
}

- (void) dealloc {
    self.viewControllers = nil;
    _gestures  = nil;
    _blackMask = nil;
}

#pragma mark - Load View
- (void) loadView {
    [super loadView];
    CGRect viewRect = [self viewBoundsWithOrientation:self.interfaceOrientation];
   
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    [rootViewController willMoveToParentViewController:self];
    [self addChildViewController:rootViewController];
   
    UIView * rootView = rootViewController.view;
    rootView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    rootView.frame = viewRect;
    [self.view addSubview:rootView];
    
    [rootViewController didMoveToParentViewController:self];
    _blackMask = [[UIView alloc] initWithFrame:viewRect];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0;
    _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:_blackMask atIndex:0];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
}

#pragma mark - PushViewController With Completion Block
- (void) pushViewController:(UIViewController *)viewController completion:(FlipBoardNavigationControllerCompletionBlock)handler {
    _animationInProgress = YES;
    viewController.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
    viewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _blackMask.alpha = 0.0;
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view bringSubviewToFront:_blackMask];
    [self.view addSubview:viewController.view];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        [self currentViewController].view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        viewController.view.frame = self.view.bounds;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            [self.viewControllers addObject:viewController];
            [viewController didMoveToParentViewController:self];
            _animationInProgress = NO;
            _gestures = [[NSMutableArray alloc] init];
            [self addPanGestureToView:[self currentViewController].view];
            handler();
        }
    }];
}

- (void) pushViewController:(UIViewController *)viewController {
    [self pushViewController:viewController completion:^{}];
}

#pragma mark - PopViewController With Completion Block
- (void) popViewControllerWithCompletion:(FlipBoardNavigationControllerCompletionBlock)handler {
    _animationInProgress = YES;
    if (self.viewControllers.count < 2) {
        return;
    }
    
    UIViewController *currentVC = [self currentViewController];
    UIViewController *previousVC = [self previousViewController];
    [previousVC viewWillAppear:NO];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        currentVC.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        CGAffineTransform transf = CGAffineTransformIdentity;
        previousVC.view.transform = CGAffineTransformScale(transf, 1.0, 1.0);
        previousVC.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [currentVC.view removeFromSuperview];
            [currentVC willMoveToParentViewController:nil];
            [self.view bringSubviewToFront:[self previousViewController].view];
            [currentVC removeFromParentViewController];
            [currentVC didMoveToParentViewController:nil];
            [self.viewControllers removeObject:currentVC];
            _animationInProgress = NO;
            [previousVC viewDidAppear:NO];
            handler();
        }
    }];
    
}

- (void) removeViewControllerArray:(NSArray *)array{
    
    for (UIViewController *viewController in array) {
        NSUInteger index = [self.viewControllers indexOfObject:viewController];
        if (index != NSNotFound) {
            
            [viewController.view removeFromSuperview];
            [viewController willMoveToParentViewController:nil];
            
            [viewController removeFromParentViewController];
            [viewController didMoveToParentViewController:nil];
            [self.viewControllers removeObject:viewController];
            
        }

    }
    
    
   
    
}





- (void) popViewController {
    [self popViewControllerWithCompletion:^{}];
}




- (void) popToViewController:(UIViewController *)viewController{
    [self popToViewController:viewController Completion:^{}];
    
    
}
- (void) popToViewController:(UIViewController *)viewController Completion:(FlipBoardNavigationControllerCompletionBlock)handler{
    
    _animationInProgress = YES;
    if (self.viewControllers.count < 2) {
        return;
    }
    
    UIViewController *currentVC = [self currentViewController];
    
    [self removeViewControllersAfterViewController:viewController];
    
    UIViewController *previousVC = [self previousViewController];
    
    [previousVC viewWillAppear:NO];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        currentVC.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        CGAffineTransform transf = CGAffineTransformIdentity;
        previousVC.view.transform = CGAffineTransformScale(transf, 1.0, 1.0);
        previousVC.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [currentVC.view removeFromSuperview];
            [currentVC willMoveToParentViewController:nil];
            [self.view bringSubviewToFront:[self previousViewController].view];
            [currentVC removeFromParentViewController];
            [currentVC didMoveToParentViewController:nil];
            [self.viewControllers removeObject:currentVC];
            _animationInProgress = NO;
            [previousVC viewDidAppear:NO];
            handler();
        }
    }];

    
    
}

- (void) popToRootViewControllerAnimated:(BOOL)animated{
    [self popToRootViewControllerAnimatedWithCompletion:^{}];
}

- (void) popToRootViewControllerAnimatedWithCompletion:(FlipBoardNavigationControllerCompletionBlock)handler{
    
    UIViewController *rootViewController = [self rootViewController];
    [self popToViewController:rootViewController Completion:handler];
    
}


- (void) rollBackViewController {
    _animationInProgress = YES;
    
    UIViewController * vc = [self currentViewController];
    UIViewController * nvc = [self previousViewController];
    CGRect rect = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);

    [UIView animateWithDuration:0.3f delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        nvc.view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        vc.view.frame = rect;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            _animationInProgress = NO;
        }
    }];
}

- (BOOL)shouldAutorotate
{
    UIViewController * vc = [self currentViewController];
    if (vc) {
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UIViewController *temp = [(UINavigationController *)vc topViewController];
            if (temp) {
                return temp.shouldAutorotate;;
            }
            
            return NO;
        }
        
        
        return vc.shouldAutorotate;
    }
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIViewController * vc = [self currentViewController];
    if (vc) {
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UIViewController *temp = [(UINavigationController *)vc topViewController];
            if (temp) {
                return temp.supportedInterfaceOrientations;;
            }
            
            return UIInterfaceOrientationMaskPortrait;
        }

        
        return vc.supportedInterfaceOrientations;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
 
    UIViewController * vc = [self currentViewController];
    if (vc) {
        
        return [vc shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }

    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

}

#pragma mark - ChildViewController
- (UIViewController *)currentViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>0) {
        result = [self.viewControllers lastObject];
    }
    return result;
}

#pragma mark - ParentViewController
- (UIViewController *)previousViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>1) {
        result = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
    }
    return result;
}

#pragma mark - RootViewController

- (UIViewController *)rootViewController{
    UIViewController *result = nil;
    if ([self.viewControllers count]>1) {
        result = [self.viewControllers objectAtIndex:0];
    }
    return result;
}

- (void)removeViewControllersAfterViewController:(UIViewController *)viewController{
    
    if (![self.viewControllers containsObject:viewController]){
        NSLog(@"self.viewController not contains objects :%@",viewController);
        return;
    }
    
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    while ([self.viewControllers count] > index+2) {
        UIViewController *result = [self.viewControllers objectAtIndex:index+1];
        [result.view removeFromSuperview];
        [result willMoveToParentViewController:nil];
        [result removeFromParentViewController];
        [result didMoveToParentViewController:nil];
        [self.viewControllers removeObjectAtIndex:index+1];
    }
    
    
}

#pragma mark - Add Pan Gesture
- (void) addPanGestureToView:(UIView*)view
{
    NSLog(@"ADD PAN GESTURE $$### %i",[_gestures count]);
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(gestureRecognizerDidPan:)];
//    panGesture.cancelsTouchesInView = NO;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    [_gestures addObject:panGesture];
    panGesture = nil;
}

# pragma mark - Avoid Unwanted Vertical Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    return fabs(translation.x) > fabs(translation.y) ;
}


#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIViewController * vc =  [self.viewControllers lastObject];
    
    if ([vc isKindOfClass:[UINavigationController class]]  && ((UINavigationController *)vc).navigationBar.hidden == FALSE) {
        
        if (CGRectContainsPoint(((UINavigationController *) vc).navigationBar.frame,[touch locationInView:vc.view])) {
            return FALSE;
        }
    
    }
    
    _panOrigin = vc.view.frame.origin;
    gestureRecognizer.enabled = YES;
    
    
    return !_animationInProgress;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark - Handle Panning Activity
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(_animationInProgress) return;
 
    CGPoint currentPoint = [panGesture translationInView:self.view];
    CGFloat x = currentPoint.x + _panOrigin.x;
    
    PanDirection panDirection = PanDirectionNone;
    CGPoint vel = [panGesture velocityInView:self.view];

    if (vel.x > 0) {
        panDirection = PanDirectionRight;
    } else {
        panDirection = PanDirectionLeft;
    }
    
    CGFloat offset = 0;
    
    UIViewController * vc ;
    vc = [self currentViewController];
    offset = CGRectGetWidth(vc.view.frame) - x;
    
    _percentageOffsetFromLeft = offset/[self viewBoundsWithOrientation:self.interfaceOrientation].size.width;
    vc.view.frame = [self getSlidingRectWithPercentageOffset:_percentageOffsetFromLeft orientation:self.interfaceOrientation];
    [self transformAtPercentage:_percentageOffsetFromLeft];
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        // If velocity is greater than 100 the Execute the Completion base on pan direction
        if(abs(vel.x) > 100) {
            [self completeSlidingAnimationWithDirection:panDirection];
        }else { 
            [self completeSlidingAnimationWithOffset:offset];
        }
    }
}

#pragma mark - Set the required transformation based on percentage
- (void) transformAtPercentage:(CGFloat)percentage {
    CGAffineTransform transf = CGAffineTransformIdentity;
    CGFloat newTransformValue =  1 - (percentage*10)/100;
    CGFloat newAlphaValue = percentage* kMaxBlackMaskAlpha;
    [self previousViewController].view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
    _blackMask.alpha = newAlphaValue;
}

#pragma mark - This will complete the animation base on pan direction
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction {
    if(direction==PanDirectionRight){
        [self popViewController];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - This will complete the animation base on offset
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset{
   
    if(offset<[self viewBoundsWithOrientation:self.interfaceOrientation].size.width/2) {
         [self popViewController];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - Get the origin and size of the visible viewcontrollers(child)
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation {
    CGRect viewRect = [self viewBoundsWithOrientation:orientation];
    CGRect rectToReturn = CGRectZero;
    UIViewController * vc;
    vc = [self currentViewController];
    rectToReturn.size = viewRect.size;
    rectToReturn.origin = CGPointMake(MAX(0,(1-percentage)*viewRect.size.width), 0.0);
    return rectToReturn;
}

#pragma mark - Get the size of view in the main screen
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation{
	CGRect bounds = [UIScreen mainScreen].bounds;
    
    if(DeviceSystemMajorVersion() >=7){
        return bounds;
    }

    if([[UIApplication sharedApplication]isStatusBarHidden]){
        return bounds;
    } else if(UIInterfaceOrientationIsLandscape(orientation)){
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width - 20;
        return bounds;
	}else{
        bounds.size.height-=20;
        return bounds;
    }
}



@end



#pragma mark - UIViewController Category
//For Global Access of flipViewController
@implementation UIViewController (FlipBoardNavigationController)
@dynamic flipboardNavigationController;

- (FlipBoardNavigationController *)flipboardNavigationController
{
    
    if([self.parentViewController isKindOfClass:[FlipBoardNavigationController class]]){
        return (FlipBoardNavigationController*)self.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController isKindOfClass:[FlipBoardNavigationController class]]){
        return (FlipBoardNavigationController*)[self.parentViewController parentViewController];
    }
    else{
        return nil;
    }
    
}


@end