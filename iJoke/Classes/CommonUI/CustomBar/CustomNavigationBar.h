//
//  CustomNavigationBar.h
//  CustomNavigationBar
//
//  Created by looyao teng on 12-5-29.
//  Copyright (c) 2012年 Looyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationBar : UINavigationBar


- (void)setBarTintGradientColor:(UIColor *)color;
- (void)setBarTintGradientColorArray:(NSArray *)barTintGradientColors;

@property (nonatomic, retain) UIImage *customBgImage;

@end
