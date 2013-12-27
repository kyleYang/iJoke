//
//  FTSPublishVideoCell.h
//  iJoke
//
//  Created by Kyle on 13-12-7.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKActivityIndicatorImageView.h"
#import "JKIconTextButton.h"
#import "Video.h"

@protocol PublishVideoCellDelegate;

@interface FTSPublishVideoCell : UITableViewCell{
    
    id<PublishVideoCellDelegate> __weak_delegate _delegate;
    
}

@property (nonatomic, weak_delegate) id<PublishVideoCellDelegate> delegate;

@property (nonatomic, strong, readonly) JKActivityIndicatorImageView *webImage;
@property (nonatomic, strong, readonly) UILabel *content;

- (void)configCellForVideo:(Video *)video;
+(float)caculateHeighForVideo:(Video *)vido;

@end


@protocol PublishVideoCellDelegate <NSObject>

@optional
- (void)publishSelectAtIndexPath:(NSIndexPath *)indexPath;

@end

