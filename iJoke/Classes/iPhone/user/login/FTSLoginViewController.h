//
//  FTSLoginViewController.h
//  iJoke
//
//  Created by Kyle on 13-8-22.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSUserCenterBaseViewController.h"

@protocol FTSLoginDelegate;

@interface FTSLoginViewController : FTSUserCenterBaseViewController

@property (nonatomic, assign) SEL action;
@property (nonatomic, weak_delegate) id<FTSLoginDelegate> delegate;
@property (nonatomic, strong) UIScrollView *contentView;

@end


@protocol FTSLoginDelegate <NSObject>


@optional

- (void)loginSuccess:(BOOL)value action:(SEL)action;
- (void)popBackParent;
- (void)returnToParaent;

@end

