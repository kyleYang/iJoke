//
//  FTSPublishImageCell.h
//  iJoke
//
//  Created by Kyle on 13-12-7.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"
#import "JKImageCellImageView.h"
#import "FTSMacro.h"
#import "FTSCellUserControl.h"
#import "JKIconTextButton.h"

@protocol PublishImageCellDelegate;

@interface FTSPublishImageCell : UITableViewCell{
    
}

@property (nonatomic, weak_delegate) id<PublishImageCellDelegate> delegate;
@property (nonatomic, strong, readonly) FTSCellUserControl *userControl;
@property (nonatomic, strong, readonly) NSMutableArray *contentViews;
@property (nonatomic, strong, readonly) NSMutableArray *imageViews;


- (void)configCellForImage:(Image *)image;
+(float)caculateHeighForImage:(Image *)image;



@end


@protocol PublishImageCellDelegate <NSObject>

@optional


- (void)publishSelectAtIndexPath:(NSIndexPath *)indexPath;

@end