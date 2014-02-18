//
//  uzysRadialProgressActivityIndicator.m
//  UzysRadialProgressActivityIndicator
//
//  Created by Uzysjung on 13. 10. 22..
//  Copyright (c) 2013년 Uzysjung. All rights reserved.
//

#import "UzysRadialProgressActivityIndicator.h"
#import "UIScrollView+UzysCircularProgressPullToRefresh.h"
#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

#define PulltoRefreshThreshold 100.0
#define kImageLabelPaddX 5
#define kImageLabelPaddY 0

@interface UzysRadialProgressActivityIndicatorBackgroundLayer : CALayer

@property (nonatomic,assign) CGFloat outlineWidth;
- (id)initWithBorderWidth:(CGFloat)width;

@end
@implementation UzysRadialProgressActivityIndicatorBackgroundLayer
- (id)init
{
    self = [super init];
    if(self) {
        self.outlineWidth=2.0f;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}
- (id)initWithBorderWidth:(CGFloat)width
{
    self = [super init];
    if(self) {
        self.outlineWidth=width;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}
- (void)drawInContext:(CGContextRef)ctx
{
    //Draw white circle
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor colorWithWhite:1.0 alpha:0.8].CGColor));
    CGContextFillEllipseInRect(ctx,CGRectInset(self.bounds, self.outlineWidth, self.outlineWidth));
    
    //Draw circle outline
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.4 alpha:0.9].CGColor);
    CGContextSetLineWidth(ctx, self.outlineWidth);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, self.outlineWidth , self.outlineWidth ));
}
- (void)setOutlineWidth:(CGFloat)outlineWidth
{
    _outlineWidth = outlineWidth;
    [self setNeedsDisplay];
}
@end

/*-----------------------------------------------------------------*/
@interface UzysRadialProgressActivityIndicator()
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;  //Loading Indicator
@property (nonatomic, strong) UzysRadialProgressActivityIndicatorBackgroundLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, strong) CATextLayer *indicatorLayer;
@property (nonatomic, strong) CATextLayer *timeLayer;
@property (nonatomic, assign) double progress;

@end
@implementation UzysRadialProgressActivityIndicator

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, -PulltoRefreshThreshold, 25, 25)];
    if(self) {
        [self _commonInit];
    }
    return self;
}
- (id)initWithImage:(UIImage *)image
{
    self = [super initWithFrame:CGRectMake(0, -PulltoRefreshThreshold, 25, 25)];
    if(self) {
        [self _commonInit];
        self.imageIcon =image;
    }
    return self;
}

- (void)_commonInit
{
    self.borderColor = [UIColor colorWithRed:203/255.0 green:32/255.0 blue:39/255.0 alpha:1];
    self.borderWidth = 2.0f;
    self.contentMode = UIViewContentModeRedraw;
    self.state = UZYSPullToRefreshStateNone;
    self.backgroundColor = [UIColor clearColor];
    //init actitvity indicator
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.hidesWhenStopped = YES;
    _activityIndicatorView.frame = self.bounds;
    [self addSubview:_activityIndicatorView];
    
    _indicatorLayer = [[CATextLayer alloc] init];
    _indicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    _indicatorLayer.foregroundColor = [UIColor blackColor].CGColor;
    _indicatorLayer.contentsScale = [UIScreen mainScreen].scale;
    _indicatorLayer.fontSize = 15.0f;
    _indicatorLayer.alignmentMode = kCAAlignmentLeft;
    [self.layer addSublayer:_indicatorLayer];
    
    NSString *indicatorString = [self localizedStringForKey:uzyspullnormal withDefault:@"下拉刷新"];
    _indicatorLayer.frame = CGRectMake(0, 0, 120, 20);
    _indicatorLayer.string = indicatorString;
    
    
    _timeLayer = [[CATextLayer alloc] init];
    _timeLayer.backgroundColor = [UIColor clearColor].CGColor;
    _timeLayer.foregroundColor = [UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:151.0f/255.0f alpha:151.0f/255.0f].CGColor;
    _timeLayer.alignmentMode = kCAAlignmentLeft;
    _timeLayer.contentsScale = [UIScreen mainScreen].scale;
    _timeLayer.fontSize = 13.0f;
    [self.layer addSublayer:_timeLayer];
    _timeLayer.frame = CGRectMake(0, 0, 0, 15);
    
    //init background layer
    UzysRadialProgressActivityIndicatorBackgroundLayer *backgroundLayer = [[UzysRadialProgressActivityIndicatorBackgroundLayer alloc] initWithBorderWidth:self.borderWidth];
    backgroundLayer.frame = self.bounds;
    [self.layer addSublayer:backgroundLayer];
    self.backgroundLayer = backgroundLayer;
    
    if(!self.imageIcon)
        self.imageIcon = [UIImage imageNamed:@"centerIcon"];
    
    //init icon layer
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);
    imageLayer.contents = (id)self.imageIcon.CGImage;
    [self.layer addSublayer:imageLayer];
    self.imageLayer = imageLayer;
    self.imageLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180),0,0,1);
    
    //init arc draw layer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = self.borderColor.CGColor;
    shapeLayer.strokeEnd = 0;
    shapeLayer.shadowColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    shapeLayer.shadowOpacity = 0.7;
    shapeLayer.shadowRadius = 20;
    shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    shapeLayer.lineWidth = self.borderWidth;
    shapeLayer.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.shapeLayer.frame = CGRectMake(0, 0, _imageIcon.size.width, _imageIcon.size.height);
    [self updatePath];
    
}
- (void)updatePath {
    CGPoint center = CGPointMake(_imageIcon.size.width/2, _imageIcon.size.height/2);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:(_imageIcon.size.width/2 - self.borderWidth)  startAngle:M_PI - DEGREES_TO_RADIANS(-90) endAngle:M_PI -DEGREES_TO_RADIANS(360-90) clockwise:NO];
    
    self.shapeLayer.path = bezierPath.CGPath;
}

#pragma mark - ScrollViewInset
- (void)setupScrollViewContentInsetForLoadingIndicator:(actionHandler)handler
{
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height + 20.0);
    [self setScrollViewContentInset:currentInsets handler:handler];
}
- (void)resetScrollViewContentInset:(actionHandler)handler
{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets handler:handler];
}
- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset handler:(actionHandler)handler
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished) {
                         if(handler)
                             handler();
                     }];
}
#pragma mark - property
- (void)setProgress:(double)progress
{
    static double prevProgress;
    
    if(progress > 1.0)
    {
        progress = 1.0;
    }
    
    self.alpha = 1.0 * progress;
    
    if (progress >= 0 && progress <=1.0) {
        //rotation Animation
        CABasicAnimation *animationImage = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animationImage.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*prevProgress)];
        animationImage.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180-180*progress)];
        animationImage.duration = 0.15;
        animationImage.removedOnCompletion = NO;
        animationImage.fillMode = kCAFillModeForwards;
        [self.imageLayer addAnimation:animationImage forKey:@"animation"];
        
        //strokeAnimation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = [NSNumber numberWithFloat:((CAShapeLayer *)self.shapeLayer.presentationLayer).strokeEnd];
        animation.toValue = [NSNumber numberWithFloat:progress];
        animation.duration = 0.35 + 0.25*(fabs([animation.fromValue doubleValue] - [animation.toValue doubleValue]));
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        //        [self.shapeLayer removeAllAnimations];
        [self.shapeLayer addAnimation:animation forKey:@"animation"];
        
    }
    _progress = progress;
    prevProgress = progress;
}
-(void)setLayerOpacity:(CGFloat)opacity
{
//    self.imageLayer.opacity = opacity;
//    self.backgroundLayer.opacity = opacity;
//    self.shapeLayer.opacity = opacity;
}
-(void)setLayerHidden:(BOOL)hidden
{
    self.imageLayer.hidden = hidden;
    self.shapeLayer.hidden = hidden;
    self.backgroundLayer.hidden = hidden;
}
-(void)setCenter:(CGPoint)center
{
    [super setCenter:center];
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}
- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
    static double prevProgress;
    CGFloat yOffset = contentOffset.y;
    self.progress = ((yOffset+ self.originalTopInset)/-PulltoRefreshThreshold);
    
    self.center = CGPointMake(self.center.x, (contentOffset.y+ self.originalTopInset)/2);
    switch (_state) {
        case UZYSPullToRefreshStateStopped: //finish
            //            NSLog(@"Stoped");
            self.indicatorLayer.string = [self localizedStringForKey:uzyspullnormal withDefault:@"下拉刷新"];
            break;
        case UZYSPullToRefreshStateNone: //detect action
        {
            //            NSLog(@"None");
            if(self.scrollView.isDragging && yOffset <0 )
            {
                self.state = UZYSPullToRefreshStateTriggering;
                self.indicatorLayer.string = [self localizedStringForKey:uzyspullnormal withDefault:@"下拉刷新"];
            }
        }
        case UZYSPullToRefreshStateTriggering: //progress
        {
            //            NSLog(@"trigering");
            if(self.progress >= 1.0){
                self.state = UZYSPullToRefreshStateTriggered;
                self.indicatorLayer.string = [self localizedStringForKey:uzyspullrelease withDefault:@"松开刷新"];
            }
            
        }
            break;
        case UZYSPullToRefreshStateTriggered: //fire actionhandler
            //            NSLog(@"trigered");
            if(self.scrollView.dragging == NO && prevProgress > 0.99)
            {
                [self actionTriggeredState];
                self.indicatorLayer.string = [self localizedStringForKey:uzyspullrelease withDefault:@"松开刷新"];
            }
            break;
        case UZYSPullToRefreshStateLoading: //wait until stopIndicatorAnimation
            //            NSLog(@"loading");
             self.indicatorLayer.string = [self localizedStringForKey:uzyspullloading withDefault:@"正在刷新"];
            break;
        default:
            self.indicatorLayer.string = [self localizedStringForKey:uzyspullnormal withDefault:@"下拉刷新"];
            break;
    }
    //because of iOS6 KVO performance
    prevProgress = self.progress;
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showPullToRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}


-(void)actionStopState
{
    self.state = UZYSPullToRefreshStateNone;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        self.activityIndicatorView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        self.activityIndicatorView.transform = CGAffineTransformIdentity;
        [self.activityIndicatorView stopAnimating];
        [self resetScrollViewContentInset:^{
            [self setLayerHidden:NO];
            [self setLayerOpacity:1.0];
        }];
        
    }];
}
-(void)actionTriggeredState
{
    self.state = UZYSPullToRefreshStateLoading;
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setLayerOpacity:0.0];
    } completion:^(BOOL finished) {
        [self setLayerHidden:YES];
    }];
    
    [self.activityIndicatorView startAnimating];
    [self setupScrollViewContentInsetForLoadingIndicator:nil];
    if(self.pullToRefreshHandler)
        self.pullToRefreshHandler();
}

#pragma mark - public method

- (void)setRefreshTime:(NSDate *)date{
    
    NSString *dateStr =[self timeFormatFrmDate:date];
    _timeLayer.string = [NSString stringWithFormat:[self localizedStringForKey:uzyspulltimeformat withDefault:@"刷新:%@"],dateStr];
}

- (void)stopIndicatorAnimation
{
    [self actionStopState];
}
- (void)manuallyTriggered
{
    [self setLayerOpacity:0.0];
    
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset + self.bounds.size.height + 20.0;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -currentInsets.top);
    } completion:^(BOOL finished) {
        [self actionTriggeredState];
    }];
}
- (void)setSize:(CGSize) size
{
   
    
    CGSize pSize = CGSizeMake(size.width + kImageLabelPaddX+CGRectGetWidth(_indicatorLayer.frame), MAX(size.height,CGRectGetHeight(_indicatorLayer.frame)+kImageLabelPaddY+CGRectGetHeight(_timeLayer.frame)));
    CGRect rect = CGRectMake((self.scrollView.bounds.size.width - pSize.width)/2,
                             -pSize.height, pSize.width, pSize.height);
    
    self.frame=rect;
    
    self.indicatorLayer.frame = CGRectMake(size.width + kImageLabelPaddX, 0, CGRectGetWidth(_indicatorLayer.frame), CGRectGetHeight(_indicatorLayer.frame));
    self.timeLayer.frame = CGRectMake(size.width + kImageLabelPaddX, CGRectGetHeight(_indicatorLayer.frame)+kImageLabelPaddY,CGRectGetWidth(_indicatorLayer.frame), CGRectGetHeight(_timeLayer.frame));
    
    self.imageLayer.frame = CGRectInset(CGRectMake(0, 0, size.width, size.height), self.borderWidth, self.borderWidth);
    
    self.shapeLayer.frame = CGRectMake(0, 0, size.width, size.height);
    self.activityIndicatorView.frame = CGRectMake(0, 0, size.width, size.height);
    
    
    self.backgroundLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [self.backgroundLayer setNeedsDisplay];
}
- (void)setImageIcon:(UIImage *)imageIcon
{
    _imageIcon = imageIcon;
    _imageLayer.contents = (id)_imageIcon.CGImage;
   
    [self setSize:_imageIcon.size];
}
- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    _backgroundLayer.outlineWidth = _borderWidth;
    [_backgroundLayer setNeedsDisplay];
    
    _shapeLayer.lineWidth = _borderWidth;
    _imageLayer.frame = CGRectInset(CGRectMake(0, 0, _imageIcon.size.width, _imageIcon.size.height), self.borderWidth, self.borderWidth);
    
}
- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    _shapeLayer.strokeColor = _borderColor.CGColor;
}

#pragma mark
#pragma mark source
- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"uzys" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
        
        //manually select the desired lproj folder
        for (NSString *language in [NSLocale preferredLanguages])
        {
            if ([[bundle localizations] containsObject:language])
            {
                bundlePath = [bundle pathForResource:language ofType:@"lproj"];
                bundle = [NSBundle bundleWithPath:bundlePath];
                break;
            }
        }
        
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}



-(NSString*)timeFormatFrmDate:(NSDate *)date{
    
    //    "joke.commit.current" = "刚刚";
    //    "joke.commit.minutes" = "%d 分钟前";
    //    "joke.commit.hours" = "%d 小时前";
    //    "joke.commit.days" = "%d 天前";
    
    if (date == nil) {
        return [self localizedStringForKey:@"uzyspulltimenone" withDefault:@"从未更新"];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeInterval timerInterval = [[NSDate date] timeIntervalSinceDate:date];
    
    NSInteger minutes = timerInterval / 60;
    NSInteger hours = minutes / 60;
    NSInteger days = hours/24;
    NSInteger month = days/30;
    
    minutes = ((NSInteger)minutes) % 60;
    
    if (month > 0) {
        return [NSString stringWithFormat:[self localizedStringForKey:@"uzyspulltimemonth" withDefault:@"%d 月前"],month];
    }else if (days >= 3) {
        return [NSString stringWithFormat:[self localizedStringForKey:@"uzyspulltimedaysago" withDefault:@"%d 天前"],days];
    }else if(days >0){
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        return [dateFormatter stringFromDate:date];
    }else if(hours > 3){
        [dateFormatter setDateFormat:@"HH:mm"];
        return [dateFormatter stringFromDate:date];
    }else if(hours >0){
         return [NSString stringWithFormat:[self localizedStringForKey:@"uzyspulltimehoursago" withDefault:@"%d 小时前"],hours];
    }else if (minutes > 10) {
        return [NSString stringWithFormat:[self localizedStringForKey:@"uzyspulltimeminutsago" withDefault:@"%d 分钟前"],minutes];;
    }else{
        return [self localizedStringForKey:@"uzyspulltimecurrent" withDefault:@"刚刚"];
    }
    
}



@end