//
//  FTSCircleImageView.m
//  iJoke
//
//  Created by Kyle on 13-9-23.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCircleImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface FTSCircleImageView()

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@end


@implementation FTSCircleImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
        UIBezierPath *layerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, CGRectGetWidth(self.bounds)-2, CGRectGetHeight(self.bounds)-2)];
        maskLayer.path = layerPath.CGPath;
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        
        self.layer.mask = maskLayer;
        self.clipsToBounds = YES;
        
        // use another view for clipping so that when the image size changes, the masking layer does not need to be repositioned
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.imageView];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    UIBezierPath *layerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, CGRectGetWidth(self.bounds)-2, CGRectGetHeight(self.bounds)-2)];
    maskLayer.path = layerPath.CGPath;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    self.layer.mask = maskLayer;
    self.clipsToBounds = YES;
    
}



- (void)setImageUrl:(NSURL *)url placholdImage:(UIImage *)image{
    
    __weak FTSCircleImageView *wself = self;
    
    [self.imageView setImageWithURL:url placeholderImage:nil options:SDWebImageLowPriority progress:^(NSUInteger receiveSize, long long excepectedSize){
        
        if (excepectedSize <= -0) {
            return ;
        }
        
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        
        
        wself.imageView.alpha = 0.0f;
        
        
        [UIView animateWithDuration:0.1 animations:^(void){
            
            wself.imageView.alpha = 1.0f;
            
        }];
        
        
    }];

}


- (void)setImageUrl:(NSURL *)url{
    
    [self setImageUrl:url placholdImage:nil];
    
}

- (void)setImageString:(NSString *)url{
    [self setImageString:url placholdImage:nil];
}


- (void)setImageString:(NSString *)url placholdImage:(UIImage *)image{
    [self setImageUrl:[NSURL URLWithString:url] placholdImage:image];
    
}

@end
