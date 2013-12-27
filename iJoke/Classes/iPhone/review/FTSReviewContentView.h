//
//  FTSReviewContentView.h
//  iJoke
//
//  Created by Kyle on 13-11-5.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSMacro.h"
#import "Words.h"
#import "Image.h"
#import "FTSCellUserControl.h"
#import "JKIconTextButton.h"

@protocol ReviewContentViewDelegate;

@interface FTSReviewContentView : UIView{
    id<ReviewContentViewDelegate> __weak_delegate _delegate;

}

@property (nonatomic, strong, readonly) FTSCellUserControl *userControl;
@property (nonatomic, weak_delegate) id<ReviewContentViewDelegate> delegate;

@property (nonatomic, strong, readonly) Words *words;

- (CGFloat)configCellForWords:(Words *)word;
- (CGFloat)configCellForImage:(Image *)image;


@end


@protocol ReviewContentViewDelegate <NSObject>

@optional
- (void)reviewContentUserInfoView:(FTSReviewContentView *)view;
- (void)reviewContentFavoriteView:(FTSReviewContentView *)view addType:(BOOL)value; //vale: true for add and false for del favorite
- (void)reviewContentShareView:(FTSReviewContentView *)view;


@end