//
//  FTSImageTableCell.h
//  iJoke
//
//  Created by Kyle on 13-8-15.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"
#import "JKImageCellImageView.h"
#import "FTSMacro.h"
#import "FTSCellUserControl.h"
#import "JKIconTextButton.h"
#import "FTSRecord.h";

@protocol FTSImageTableCellDelegate;

@interface FTSImageTableCell : UITableViewCell{
    
}

@property (nonatomic, weak_delegate) id<FTSImageTableCellDelegate> delegate;
@property (nonatomic, strong, readonly) FTSCellUserControl *userControl;
@property (nonatomic, strong, readonly) NSMutableArray *contentViews;
@property (nonatomic, strong, readonly) NSMutableArray *imageViews;
@property (nonatomic, strong, readonly) JKIconTextButton *commitBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *upBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *downBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *shareBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *favBtn;


- (void)configCellForImage:(Image *)image;
+(float)caculateHeighForImage:(Image *)image;
- (void)refreshRecordState;


@end


@protocol FTSImageTableCellDelegate <NSObject>

- (FTSRecord *)imageRecordFroImageTableCellImage:(Image *)image;

@optional
- (void)imageTableCell:(FTSImageTableCell *)cell touchImageIndex:(NSIndexPath *)indexPath;
- (void)imageTableCell:(FTSImageTableCell *)cell userInfoIndexPath:(NSIndexPath *)indexPath;
- (void)imageTableCell:(FTSImageTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath;
- (void)imageTableCell:(FTSImageTableCell *)cell commitIndexPath:(NSIndexPath *)indexPath;
- (void)imageTableCell:(FTSImageTableCell *)cell upIndexPath:(NSIndexPath *)indexPath;
- (void)imageTableCell:(FTSImageTableCell *)cell downIndexPath:(NSIndexPath *)indexPath;
- (void)imageTableCell:(FTSImageTableCell *)cell favIndexPath:(NSIndexPath *)indexPath addType:(BOOL)value; //vale: true for add and false for del favorite
- (void)imageTableCell:(FTSImageTableCell *)cell shareIndexPath:(NSIndexPath *)indexPath;


@end