//
//  FTSWordsTableCell.h
//  iJoke
//
//  Created by Kyle on 13-8-7.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSMacro.h"
#import "Words.h"
#import "FTSCellUserControl.h"
#import "JKIconTextButton.h"

@protocol WordTableCellDelegate;



@interface FTSWordsTableCell : UITableViewCell{
    
    id<WordTableCellDelegate> __weak_delegate _delegate;
}

@property (nonatomic, strong, readonly) FTSCellUserControl *userControl;
@property (nonatomic, strong, readonly) UILabel *content;
@property (nonatomic, strong, readonly) JKIconTextButton *commitBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *upBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *downBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *shareBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *favBtn;
@property (nonatomic, weak_delegate) id<WordTableCellDelegate> delegate;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;


- (void)configCellForWords:(Words *)word;
+(float)caculateHeighForWords:(Words *)word;
-(void)refreshRecordState;

@end



@protocol WordTableCellDelegate <NSObject>

@optional
- (void)wordsTableCell:(FTSWordsTableCell *)cell selectIndexPath:(NSIndexPath *)indexPath;
- (void)wordsTableCell:(FTSWordsTableCell *)cell userInfoIndexPath:(NSIndexPath *)indexPath;
- (void)wordsTableCell:(FTSWordsTableCell *)cell commitIndexPath:(NSIndexPath *)indexPath;
- (void)wordsTableCell:(FTSWordsTableCell *)cell upIndexPath:(NSIndexPath *)indexPath;
- (void)wordsTableCell:(FTSWordsTableCell *)cell downIndexPath:(NSIndexPath *)indexPath;
- (void)wordsTableCell:(FTSWordsTableCell *)cell favIndexPath:(NSIndexPath *)indexPath addType:(BOOL)value; //vale: true for add and false for del favorite
- (void)wordsTableCell:(FTSWordsTableCell *)cell shareIndexPath:(NSIndexPath *)indexPath;


@end