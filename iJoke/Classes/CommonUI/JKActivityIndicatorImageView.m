//
//  JKActivityIndicatorImageView.m
//  iJoke
//
//  Created by Kyle on 13-9-25.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "JKActivityIndicatorImageView.h"
#import "UIImageView+WebCache.h"

#define kAlphaInterval 0.3

@interface JKActivityIndicatorImageView()

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *progressBar;
@property (nonatomic, strong) UIImageView *playMaskView;


@end


@implementation JKActivityIndicatorImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self  addSubview:self.imageView];
        
        self.progressBar = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        self.progressBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth;
        self.progressBar.center = self.center;
        [self.imageView addSubview:self.progressBar];
        self.progressBar.hidden = YES;
        
        self.playMaskView = [[UIImageView alloc] initWithImage:[[Env sharedEnv] cacheImage:@"timeline_card_play.png"]];
        [self.imageView addSubview:self.playMaskView];
        self.playMaskView.center = self.center;
        
        
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.progressBar.center = self.imageView.center;
    self.playMaskView.center = self.imageView.center;
}


- (void)setImageUrl:(NSString *)imageUrl{
    if (_imageUrl == imageUrl) return;
    
    _imageUrl = imageUrl;
    self.progressBar.hidden = YES;
    
    
    
    __weak JKActivityIndicatorImageView *wself = self;
    
    //    [self.imageView setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRefreshCached];
    
    [self.imageView setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:[[Env sharedEnv] cacheResizableImage:@"picture_default.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] options:SDWebImageLowPriority progress:^(NSUInteger receiveSize, long long excepectedSize){
        if (wself.progressBar.hidden) {
            wself.progressBar.hidden = NO;
        }
        
        if (excepectedSize <= -0) {
            return ;
        }
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        
        wself.progressBar.hidden = YES;
        wself.imageView.alpha = 0.0f;
        
        
        [UIView animateWithDuration:kAlphaInterval animations:^(void){
            
            wself.imageView.alpha = 1.0f;
            
        }];
        
        
        
    }];
    
    
}

@end
