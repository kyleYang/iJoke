//
//  FTSCircleImageView.h
//  iJoke
//
//  Created by Kyle on 13-9-23.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface FTSCircleImageView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;

- (void)setImageUrl:(NSURL *)url;
- (void)setImageUrl:(NSURL *)url placholdImage:(UIImage *)image;
- (void)setImageString:(NSString *)url;
- (void)setImageString:(NSString *)url placholdImage:(UIImage *)image;


@end
