//
//  MptContentScrollView.h
//  TVGontrol
//
//  Created by Kyle on 13-4-26.
//  Copyright (c) 2013年 MIPT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSMacro.h"
#import "MptCotentCell.h"
#import "MptCustomScrollView.h"

@protocol scrollDataSource;
@protocol scrollDelegate;


@interface MptContentScrollView : UIView<UIScrollViewDelegate>{
@private
    id<scrollDataSource> __weak_delegate _dataSource;
    id<scrollDelegate>  __weak_delegate _delegate;
    MptCustomScrollView *_scrollView;
    NSMutableArray *_onScreenCells;
    NSMutableDictionary *_saveCells;
    
    NSUInteger _total;
    NSUInteger _current;
}

@property (nonatomic, weak_delegate) id<scrollDataSource> dataSource;
@property (nonatomic, weak_delegate) id<scrollDelegate> delegate;

@property (nonatomic, strong, readonly) MptCustomScrollView *scrollView;
@property (nonatomic, assign, readonly) NSUInteger total;
@property (nonatomic, assign, readonly) NSUInteger current;

- (MptCotentCell *)dequeueCellWithIdentifier:(NSString *)identifier;
- (MptCotentCell *)cellForRowAtIndex:(NSUInteger)index;
- (void)reloadData;
- (void)setCurrentItemIndex:(NSUInteger)index animation:(BOOL)animation;

- (void)viewWillDisappear;
- (void)viewWillAppear;
@end



@protocol scrollDataSource <NSObject>

@required
- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView;
- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index ;


@optional
- (NSUInteger)currentPageForScrollView:(MptContentScrollView *)popController;


@end

@protocol scrollDelegate <NSObject>

@optional

- (void)scrollView:(MptContentScrollView *)scrollView curOffsetPercent:(CGFloat)percent;
- (void)scrollView:(MptContentScrollView *)scrollView curIndex:(NSInteger)index;

@end
