//
//  FTSVideoTableCell.h
//  iJoke
//
//  Created by Kyle on 13-9-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKActivityIndicatorImageView.h"
#import "JKIconTextButton.h"
#import "Video.h"

@protocol FTSVideoTableCellDelegate;

@interface FTSVideoTableCell : UITableViewCell{
    
    id<FTSVideoTableCellDelegate> __weak_delegate _delegate;
    
}

@property (nonatomic, weak_delegate) id<FTSVideoTableCellDelegate> delegate;

@property (nonatomic, strong, readonly) JKActivityIndicatorImageView *webImage;
@property (nonatomic, strong, readonly) UILabel *content;
@property (nonatomic, strong, readonly) JKIconTextButton *commitBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *upBtn;

- (void)configCellForVideo:(Video *)video;
+(float)caculateHeighForVideo:(Video *)vido;

@end


@protocol FTSVideoTableCellDelegate <NSObject>

@optional
- (void)videoTableCell:(FTSVideoTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath;

@end
