//
//  PanguImgPopView.h
//  pangu
//
//  Created by yang zhiyun on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSMacro.h"
#import "HMImagePopController.h"

@protocol HMImagePopManagerDelegate;

@interface HMImagePopManager : NSObject
{
    
}

@property (nonatomic, assign) id<HMImagePopManagerDelegate> delegate;
@property (nonatomic, retain, readonly) HMImagePopController *focusViewController;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, retain) UIImage *dftImage;
// The animation duration. Defaults to 0.5.
@property (nonatomic, assign) NSTimeInterval animationDuration;
// The background color. Defaults to transparent black.
@property (nonatomic, retain) UIColor *backgroundColor;
// Returns whether the animation has an elastic effect. Defaults to YES.
@property (assign, nonatomic) BOOL elasticAnimation;
// Returns whether zoom is enabled on fullscreen image. Defaults to YES.
@property (nonatomic, assign) BOOL zoomEnabled;

@property (nonatomic, assign) CGRect imgRect;
@property (nonatomic, copy) NSString *urlString;


- (id)initWithParentConroller:(UIViewController *)controller DefaultImg:(UIImage *)popImage imageUrl:(NSString*)popImgUrl imageFrame:(CGRect)rect;

- (void)handleFocusGesture:(UIGestureRecognizer *)gesture;
- (BOOL)handleDefocusGesture:(UIGestureRecognizer *)gesture;
@end


@protocol HMImagePopManagerDelegate <NSObject>
@optional
- (void)HMImagePopManager:(HMImagePopManager *)popManag loadIndex:(NSUInteger)index;

@end
