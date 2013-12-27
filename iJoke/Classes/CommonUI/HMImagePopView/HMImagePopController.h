//
//  ASMediaFocusViewController.h
//  ASMediaFocusManager
//
//  Created by Philippe Converset on 21/12/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HMImagePopCell.h"
#import "ASImageScrollView.h"

@protocol ImagePopControllerDataSource;
@protocol ImagePopControllerDelegate;

@interface HMImagePopController : UIViewController{
    
    id<ImagePopControllerDataSource> __weak_delegate _dataSource;
    id<ImagePopControllerDelegate>  __weak_delegate _delegate;
    UIScrollView *_scrollView;
    NSMutableArray *_onScreenCells;
    NSMutableDictionary *_saveCells;
    
    NSUInteger _total;
    NSUInteger _currentPage;
}


@property (nonatomic, weak_delegate) id<ImagePopControllerDataSource> dataSource;
@property (nonatomic, weak_delegate) id<ImagePopControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) NSUInteger total;
@property (nonatomic, assign, readonly) NSUInteger currentPage;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *mainImageView;

@property (strong, nonatomic) UIView *accessoryView;

- (void)updateOrientationAnimated:(BOOL)animated;

- (void)installZoomView:(CGRect)rect;
- (void)uninstallZoomView;


- (HMImagePopCell *)dequeueCellWithIdentifier:(NSString *)identifier;
- (HMImagePopCell *)cellForRowAtIndex:(NSUInteger)index;
- (void)reloadData;
- (void)setCurrentItemIndex:(NSUInteger)index animation:(BOOL)animation;


@end


@protocol ImagePopControllerDataSource <NSObject>

@required
- (NSUInteger)numberOfItemForImagePopController:(HMImagePopController *)popController;
- (HMImagePopCell*)cellViewForImagePopController:(HMImagePopController *)popController frame:(CGRect)frame AtIndex:(NSUInteger)index;


@optional
- (NSUInteger)currentIndexForPopController:(HMImagePopController *)popController;
- (NSString *)summaryForImagePopController:(HMImagePopController *)popController AtIndex:(NSUInteger)index;


@end

@protocol ImagePopControllerDelegate <NSObject>

@optional
- (void)imagePopController:(HMImagePopController *)popController curOffsetPercent:(CGFloat)percent;
- (void)imagePopController:(HMImagePopController *)popController curIndex:(NSInteger)index;

- (void)imagePopControllerDidTap:(HMImagePopController *)popController currentIndex:(NSInteger)index;

@end

