//
//  FTSWordsDetailHeadView.h
//  iJoke
//
//  Created by Kyle on 13-8-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Words.h"
#import "FTSMacro.h"
#import "FTSRecord.h"
#import "FTSCellUserControl.h"
#import "JKIconTextButton.h"

@protocol WordTableDetailHeadDelegate;

@interface FTSWordsDetailHeadView : UIView{
    
    Words *_words;
    id<WordTableDetailHeadDelegate> __weak_delegate _delegate;
}


@property (nonatomic, strong, readonly) FTSCellUserControl *userControl;
@property (nonatomic, strong, readonly) Words *words;
@property (nonatomic, strong, readonly) UILabel *content;
@property (nonatomic, strong, readonly) JKIconTextButton *upBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *downBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *shareBtn;
@property (nonatomic, strong, readonly) JKIconTextButton *favBtn;
@property (nonatomic, weak_delegate) id<WordTableDetailHeadDelegate> delegate;

- (CGFloat)configCellForWords:(Words *)word;
- (void)refreshRecordState;

@end



@protocol WordTableDetailHeadDelegate <NSObject>

- (FTSRecord *)recordForDetailUpHeadViewWord:(Words *)words;

@optional
- (void)wordsDetailUpHeadView:(FTSWordsDetailHeadView *)cell;
- (void)wordsDetailDownHeadView:(FTSWordsDetailHeadView *)cell;
- (void)wordsDetailFavoriteHeadView:(FTSWordsDetailHeadView *)cell addType:(BOOL)value; //vale: true for add and false for del favorite
- (void)wordsDetailShareHeadView:(FTSWordsDetailHeadView *)cell;
- (void)wordsDetailHeadViewUserInfo:(FTSWordsDetailHeadView *)cell;

@end