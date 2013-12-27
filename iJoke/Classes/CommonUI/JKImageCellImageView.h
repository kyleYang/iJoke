//
//  JKImageCellImageView.h
//  iJoke
//
//  Created by Kyle on 13-8-17.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "YLProgressBar.h"

@protocol ImageCellImageViewDelegate;

@interface JKImageCellImageView : UIView{
    
    id<ImageCellImageViewDelegate> __weak_delegate _delegate;
}


@property (nonatomic, weak_delegate) id<ImageCellImageViewDelegate> delegate;

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong, readonly) YLProgressBar *progressBar;

@end


@protocol ImageCellImageViewDelegate <NSObject>

- (void)ImageCellImageView:(JKImageCellImageView *)cell didTouchIndex:(NSUInteger)index;

@end

