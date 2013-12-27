//
//  FTSPublishWordsCell.h
//  iJoke
//
//  Created by Kyle on 13-12-7.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSMacro.h"
#import "Words.h"
#import "FTSCellUserControl.h"
#import "JKIconTextButton.h"

@protocol PublishWordsCellDelegate;

@interface FTSPublishWordsCell : UITableViewCell
{
    
    id<PublishWordsCellDelegate> __weak_delegate _delegate;
}

@property (nonatomic, strong, readonly) FTSCellUserControl *userControl;
@property (nonatomic, strong, readonly) UILabel *content;
@property (nonatomic, weak_delegate) id<PublishWordsCellDelegate> delegate;


- (void)configCellForWords:(Words *)word;
+(float)caculateHeighForWords:(Words *)word;

@end



@protocol PublishWordsCellDelegate <NSObject>

@optional

- (void)publishSelectAtIndexPath:(NSIndexPath *)indexPath;

@end

