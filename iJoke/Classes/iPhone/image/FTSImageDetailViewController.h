//
//  FTSImageDetailViewController.h
//  iJoke
//
//  Created by Kyle on 13-9-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommitBaseViewController.h"


@protocol ImageDetailViewControllerDelegate;

@interface FTSImageDetailViewController : FTSCommitBaseViewController{
    
    id<ImageDetailViewControllerDelegate> __weak_delegate _delegate;
    
}

@property (nonatomic, weak_delegate) id<ImageDetailViewControllerDelegate> delegate;

@end


@protocol ImageDetailViewControllerDelegate <NSObject>

- (void)FTSImageDetailViewControllerLoadMore:(FTSImageDetailViewController *)viewControll;

@end

