//
//  FTSRelationTableCell.h
//  iJoke
//
//  Created by Kyle on 13-11-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"

@protocol relationTableCellDelegate;

@interface FTSRelationTableCell : UITableViewCell{
   
    id<relationTableCellDelegate> __weak_delegate _delegate;

}

@property (nonatomic, weak_delegate) id<relationTableCellDelegate> delegate;

- (void)configCellForVideo:(Video *)video;
+(float)caculateHeighForVideo:(Video *)video;

@end

@protocol relationTableCellDelegate <NSObject>

@optional
- (void)relationTable:(FTSRelationTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath;



@end