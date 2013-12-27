//
//  CustomNavigationBar.m
//  CustomNavigationBar
//
//  Created by looyao teng on 12-5-29.
//  Copyright (c) 2012年 Looyao. All rights reserved.
//

#import "CustomNavigationBar.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomNavigationBar()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation CustomNavigationBar

static CGFloat const kDefaultOpacity = 0.9f;
static CGFloat const kstatusBarHeight = 20.0f;


@synthesize customBgImage = _customBgImage;


- (void)setBarTintGradientColor:(UIColor *)color{
    [self setBarTintGradientColorArray:[NSArray arrayWithObject:color]];
}

- (void)setBarTintGradientColorArray:(NSArray *)barTintGradientColors
{
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
        return;
    
    if (self.gradientLayer == nil) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.opacity = self.translucent ? kDefaultOpacity : 1.0f;
        [self.layer addSublayer:self.gradientLayer];
    }
    
    NSMutableArray *barTintGradientCGColors = nil;
    if (barTintGradientColors != nil) {
        barTintGradientCGColors = [NSMutableArray arrayWithCapacity:[barTintGradientColors count]];
        for (id color in barTintGradientColors) {
            if ([color isKindOfClass:[UIColor class]]) {
                [barTintGradientCGColors addObject:(id)[color CGColor]];
            } else {
                [barTintGradientCGColors addObject:color];
            }
        }
        self.barTintColor = [UIColor clearColor];
    }
    
    self.gradientLayer.colors = barTintGradientCGColors;
}


#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 7){
        
        if (self.gradientLayer != nil) {
            self.gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            [self.layer insertSublayer:self.gradientLayer atIndex:1];
        }
        
        return;
    }
    
    if (self.gradientLayer != nil) {
        self.gradientLayer.frame = CGRectMake(0, 0 - kstatusBarHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kstatusBarHeight);
        [self.layer insertSublayer:self.gradientLayer atIndex:1];
    }
}


- (void)setCustomBgImage:(UIImage *)customBgImage
{
   
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7){
        _customBgImage = nil;
        return;
    }
    
    
    if (self.gradientLayer == nil) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.opacity = self.translucent ? kDefaultOpacity : 1.0f;
        [self.layer addSublayer:self.gradientLayer];
    }
    
    
    self.tintColor = [UIColor clearColor];
     _customBgImage = customBgImage;
    
    self.gradientLayer.contents = (__bridge id)(_customBgImage.CGImage);;
}


//- (void)drawRect:(CGRect)rect{
//    
//    if (_customBgImage != nil) {
//        [_customBgImage drawInRect:rect];
//    }
////    else {
////        [super drawRect:rect];
////    }
//    
//}


@end
