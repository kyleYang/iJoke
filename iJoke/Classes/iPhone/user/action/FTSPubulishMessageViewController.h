//
//  FTSPubulishMessageViewController.h
//  iJoke
//
//  Created by Kyle on 13-11-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSActionBaseViewController.h"
#import "User.h"

@interface FTSPubulishMessageViewController : FTSActionBaseViewController

- (id)initWithUser:(User *)info;

@property (nonatomic, strong,readonly) User *user;

@end
