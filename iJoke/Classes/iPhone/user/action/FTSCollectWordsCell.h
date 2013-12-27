//
//  FTSCollectMessageCell.h
//  iJoke
//
//  Created by Kyle on 13-12-5.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSMacro.h"
#import "Words.h"
#import "FTSCellUserControl.h"
#import "JKIconTextButton.h"

@protocol collectWordsCellDelegate;

@interface FTSCollectWordsCell : UITableViewCell
{
    
    id<collectWordsCellDelegate> __weak_delegate _delegate;
}

@property (nonatomic, strong, readonly) FTSCellUserControl *userControl;
@property (nonatomic, strong, readonly) UILabel *content;
@property (nonatomic, weak_delegate) id<collectWordsCellDelegate> delegate;


- (void)configCellForWords:(Words *)word;
+(float)caculateHeighForWords:(Words *)word;

@end



@protocol collectWordsCellDelegate <NSObject>

@optional
- (void)collectWordsCell:(FTSCollectWordsCell *)cell shareIndexPath:(NSIndexPath *)indexPath;
- (void)collectSelectAtIndexPath:(NSIndexPath *)indexPath;

@end


