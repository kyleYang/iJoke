//
//  JKImageCellImageView.m
//  iJoke
//
//  Created by Kyle on 13-8-17.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "JKImageCellImageView.h"

#define kProgressOrgX 20
#define kProgressOrgY 50
#define kProgressWidth 100
#define kProgressHeigh 6

#define kAlphaInterval 0.4

@interface JKImageCellImageView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) YLProgressBar *progressBar;

@end


@implementation JKImageCellImageView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPan:)];
        tap.delegate = self;
        [self.imageView addGestureRecognizer:tap];
        [self  addSubview:self.imageView];
        
        self.progressBar = [[YLProgressBar alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-kProgressWidth-kProgressOrgX, kProgressOrgY, kProgressWidth, kProgressHeigh)];
        self.progressBar.type                     = YLProgressBarTypeFlat;
        self.progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
        self.progressBar.behavior                 = YLProgressBarBehaviorIndeterminate;
        self.progressBar.stripesOrientation       = YLProgressBarStripesOrientationVertical;
        self.progressBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth;
        self.progressBar.progressTintColor = [UIColor yellowColor];
        [self addSubview:self.progressBar];
        self.progressBar.hidden = YES;
        
        
    }
    return self;
}



- (void)setImageUrl:(NSString *)imageUrl{
    if (_imageUrl == imageUrl) return;
    
    _imageUrl = imageUrl;
    self.progressBar.hidden = YES;
    
    
    
    __weak JKImageCellImageView *wself = self;
    
//    [self.imageView setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRefreshCached];
    
    [self.imageView setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:[[Env sharedEnv] cacheResizableImage:@"picture_default.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] options:SDWebImageLowPriority progress:^(NSUInteger receiveSize, long long excepectedSize){
        if (wself.progressBar.hidden) {
            wself.progressBar.hidden = NO;
            wself.progressBar.progress = 0.0f;
        }
        
        if (excepectedSize <= -0) {
            return ;
        }

        
        [wself.progressBar setProgress:(CGFloat)receiveSize/excepectedSize animated:TRUE];
     
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        
        wself.progressBar.hidden = YES;
        wself.imageView.alpha = 0.0f;
       
        
        [UIView animateWithDuration:kAlphaInterval animations:^(void){
            
            wself.imageView.alpha = 1.0f;
            
        }];
        
        
        
    }];
    
    
}


- (void)imageViewPan:(UIPanGestureRecognizer *)gesture{
    
    if (_delegate && [_delegate respondsToSelector:@selector(ImageCellImageView:didTouchIndex:)]) {
        BqsLog(@"ImageCellImageView up at Index :%d",self.index);
        [_delegate ImageCellImageView:self didTouchIndex:self.index];
        
    }
    
}

#pragma mark
#pragma mark UIGestureRecognizerDelegate



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if (_delegate && [_delegate respondsToSelector:@selector(ImageCellImageView:didTouchIndex:)]) {
        return YES;
    }
    return NO;
    
}


@end
