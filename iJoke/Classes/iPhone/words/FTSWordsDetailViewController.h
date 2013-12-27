//
//  FTSWordsDetailViewController.h
//  iJoke
//
//  Created by Kyle on 13-8-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommitBaseViewController.h"
#import "FTSMacro.h"


@protocol WordsDetailViewControllerDelegate;

@interface FTSWordsDetailViewController : FTSCommitBaseViewController{
    id<WordsDetailViewControllerDelegate> __weak_delegate _delegate;
    
}


@property (nonatomic, weak_delegate) id<WordsDetailViewControllerDelegate> delegate;

@end


@protocol WordsDetailViewControllerDelegate <NSObject>

- (void)FTSWordsDetailViewControllerLoadMore:(FTSWordsDetailViewController *)viewControll;

@end
