//
//  FTSCommentBaseTableCell.h
//  iJoke
//
//  Created by Kyle on 13-8-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@protocol CommentTableCellDelegate;

@interface FTSCommentBaseTableCell : UITableViewCell{
    
     id<CommentTableCellDelegate> __weak_delegate _delegate;
}

@property (nonatomic, strong, readonly) Comment *comment;
@property (nonatomic, strong, readonly) UILabel *commentLabel;
@property (nonatomic, strong, readonly) UILabel *numberLabel;

@property (nonatomic, weak_delegate) id<CommentTableCellDelegate> delegate;

- (void)configCellForComment:(Comment *)comment;
+(float)caculateHeighForComment:(Comment *)comment;
@end


@protocol CommentTableCellDelegate <NSObject>

@optional
- (void)commentTableCellUserInfoAtIndexPath:(NSIndexPath *)indexPath;


@end
