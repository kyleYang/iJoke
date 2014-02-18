//
//  uzysRadialProgressActivityIndicator.h
//  UzysRadialProgressActivityIndicator
//
//  Created by Uzysjung on 13. 10. 22..
//  Copyright (c) 2013년 Uzysjung. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^actionHandler)(void);
typedef NS_ENUM(NSUInteger, UZYSPullToRefreshState) {
    UZYSPullToRefreshStateNone =0,
    UZYSPullToRefreshStateStopped,
    UZYSPullToRefreshStateTriggering,
    UZYSPullToRefreshStateTriggered,
    UZYSPullToRefreshStateLoading,
    
};

static NSString *const uzyspullnormal = @"uzyspullnormal";
static NSString *const uzyspullrelease = @"uzyspullrelease";
static NSString *const uzyspullloading = @"uzyspullloading";
static NSString *const uzyspulltimeformat = @"uzyspulltimeformat";

@interface UzysRadialProgressActivityIndicator : UIView

@property (nonatomic,assign) BOOL isObserving;
@property (nonatomic,assign) CGFloat originalTopInset;
@property (nonatomic,assign) UZYSPullToRefreshState state;
@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,copy) actionHandler pullToRefreshHandler;

@property (nonatomic,strong) UIImage *imageIcon;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,assign) CGFloat borderWidth;

- (void)stopIndicatorAnimation;
- (void)manuallyTriggered;
- (void)setRefreshTime:(NSDate *)date;

- (id)initWithImage:(UIImage *)image;
- (void)setSize:(CGSize) size;

@end
