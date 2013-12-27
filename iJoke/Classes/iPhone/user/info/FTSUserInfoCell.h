//
//  FTSUserInfoCell.h
//  iJoke
//
//  Created by Kyle on 13-8-26.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "FTSCircleImageView.h"
#import "FTSTextField.h"

@protocol UserInfoCellDelegate;

@interface FTSUserInfoCell : UITableViewCell{
    
    id<UserInfoCellDelegate> __weak_delegate _delegate;
}

@property (nonatomic, weak_delegate) id<UserInfoCellDelegate> delegate;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, strong, readonly) FTSCircleImageView *iconView;
@property (nonatomic, strong, readonly) FTSTextField *nameLable;
@property (nonatomic, strong, readonly) FTSTextField *signLable;

- (void)registerFirstResponder;

- (void)configCellForWords:(User *)user canEdit:(BOOL)value;
+(float)caculateHeighForWords:(User *)user;

@end


@protocol UserInfoCellDelegate <NSObject>

@optional

- (void)userInfoCellTapIconView:(FTSUserInfoCell *)cell;
- (void)userInfoCellDidBeginEditing:(FTSUserInfoCell *)cell;
- (void)userInfoCellRegisterFirstResponder:(FTSUserInfoCell *)cell;
- (BOOL)userInfoCellShouldReturn:(FTSUserInfoCell *)cell;
- (void)userInfoCellChangePassword:(FTSUserInfoCell *)cell;

@end
