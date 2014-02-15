//
//  FTSImageDetailHeadView.h
//  iJoke
//
//  Created by Kyle on 13-9-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"
#import "FTSMacro.h"
#import "JKImageCellImageView.h"
#import "FTSCellUserControl.h"
#import "JKIconTextButton.h"
#import "FTSRecord.h"

@protocol ImageTableDetailHeadDelegate;

@interface FTSImageDetailHeadView : UIView{
    
    Image *_image;
    id<ImageTableDetailHeadDelegate> __weak_delegate _delegate;

}
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;
@property (nonatomic, strong, readonly) FTSCellUserControl *userControl;
@property (nonatomic, strong, readonly) NSMutableArray *contentViews;
@property (nonatomic, strong, readonly) NSMutableArray *imageViews;
@property (nonatomic, strong, readonly) Image *image;
@property (nonatomic, strong, readonly) JKIconTextButton *upBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *downBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *shareBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *favBtn;
@property (nonatomic, weak_delegate) id<ImageTableDetailHeadDelegate> delegate;

- (void)reloadData;
- (CGFloat)configCellForImage:(Image *)image;
- (void)refreshRecordState;


@end


@protocol ImageTableDetailHeadDelegate <NSObject>

- (FTSRecord *)imageRecordForeImageDetailHeadViewImage:(Image *)image;

@optional
- (BOOL)subViewShouldReceiveTouch:(FTSImageDetailHeadView *)cell;
- (void)imageDetailHeadViewUserInfo:(FTSImageDetailHeadView *)cell;
- (void)imageDetailHeadViewImageTouch:(FTSImageDetailHeadView *)cell atIndex:(NSUInteger)index;
- (void)imageDetailUpHeadView:(FTSImageDetailHeadView *)cell;
- (void)imageDetailDownHeadView:(FTSImageDetailHeadView *)cell;
- (void)imageDetailFavoriteHeadView:(FTSImageDetailHeadView *)cell addType:(BOOL)value; //vale: true for add and false for del favorite
- (void)imageDetailShareHeadView:(FTSImageDetailHeadView *)cell;


@end