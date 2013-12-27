//
//  FTSTopicImageDetailViewController.h
//  iJoke
//
//  Created by Kyle on 13-11-26.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTopicDetailBaseViewController.h"
#import "MptContentScrollView.h"


@interface FTSTopicImageDetailViewController : FTSTopicDetailBaseViewController<scrollDataSource,scrollDelegate>{
    

   
    NSUInteger _displayIndex; // commit page display index;

    
}


@property (nonatomic, assign) NSUInteger displayIndex;

@property (nonatomic, strong) MptContentScrollView *contentView;

@end
