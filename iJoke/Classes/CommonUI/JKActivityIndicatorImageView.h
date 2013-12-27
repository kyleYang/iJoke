//
//  JKActivityIndicatorImageView.h
//  iJoke
//
//  Created by Kyle on 13-9-25.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKActivityIndicatorImageView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *progressBar;


@end
