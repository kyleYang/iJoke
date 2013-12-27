//
//  FTSCellUserControl.h
//  iJoke
//
//  Created by Kyle on 13-9-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "FTSCircleImageView.h"

@interface FTSCellUserControl : UIControl{
    User *_user;
}

@property (nonatomic, strong, readonly) FTSCircleImageView *iconView;
@property (nonatomic, strong, readonly) UILabel *nickName;

@property (nonatomic,strong) User *user;

@end
