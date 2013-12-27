//
//  FTSCollectVideoCell.h
//  iJoke
//
//  Created by Kyle on 13-12-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKActivityIndicatorImageView.h"
#import "JKIconTextButton.h"
#import "Video.h"

@protocol FTSCollectVideoCellDelegate;

@interface FTSCollectVideoCell : UITableViewCell{
    
    id<FTSCollectVideoCellDelegate> __weak_delegate _delegate;
    
}

@property (nonatomic, weak_delegate) id<FTSCollectVideoCellDelegate> delegate;

@property (nonatomic, strong, readonly) JKActivityIndicatorImageView *webImage;
@property (nonatomic, strong, readonly) UILabel *content;

- (void)configCellForVideo:(Video *)video;
+(float)caculateHeighForVideo:(Video *)vido;

@end


@protocol FTSCollectVideoCellDelegate <NSObject>

@optional
- (void)collectSelectAtIndexPath:(NSIndexPath *)indexPath;

@end
