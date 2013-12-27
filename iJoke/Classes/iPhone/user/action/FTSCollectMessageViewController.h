//
//  FTSCollectMessageViewController.h
//  iJoke
//
//  Created by Kyle on 13-11-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSActionBaseViewController.h"

@interface FTSCollectMessageViewController : FTSActionBaseViewController


@property (nonatomic, strong, readonly) User *user;

- (id)initWithUser:(User *)info;
@end
