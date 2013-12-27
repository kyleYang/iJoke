//
//  FTSElementView.h
//  FTSGridViewExample
//
//  Created by Kyle on 13-7-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipView.h"





@protocol FTSGirdViewCellDelegate;

@interface FTSGirdViewCell : UIView<UIGestureRecognizerDelegate>{
    
    FlipView *_flipView;
    UILabel *_titleLabel;
    
    NSUInteger _index;
    NSString   *_reuseIdentifier;
    
    id<FTSGirdViewCellDelegate> __weak _delegate;

}

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong, readonly) NSString *reuseIdentifier;
@property (strong) NSString *title;
@property (nonatomic, strong, readonly) FlipView *flipView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIImageView *iconImageView;
@property (nonatomic, weak) id<FTSGirdViewCellDelegate> delegate;


- (id)initReuseIdentifier:(NSString *)reuseIdentifier;


@end



@protocol FTSGirdViewCellDelegate <NSObject>

@optional

-(void)fTSGirdViewCellDidTap:(FTSGirdViewCell *)cell;
-(void)fTSGirdViewCellDidDoubleTap:(FTSGirdViewCell *)cell;


@end
