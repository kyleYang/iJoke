//
//  UMFeedbackViewController.h
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"
#import "FTSUserCenterBaseViewController.h"

@class ODRefreshControl;


@interface UMFeedbackViewController : FTSUserCenterBaseViewController <UMFeedbackDataDelegate> {
    UMFeedback *feedbackClient;
    BOOL _reloading;
    ODRefreshControl *_refreshHeaderView;
    CGFloat _tableViewTopMargin;
    BOOL _shouldScrollToBottom;
}

@property(nonatomic, retain) UITableView *mTableView;
@property(nonatomic, retain) UIToolbar *mToolBar;
@property(nonatomic, retain) UIView *mContactView;

@property(nonatomic, retain) UITextField *mTextField;
@property(nonatomic, retain) UIBarButtonItem *mSendItem;
@property(nonatomic, retain) NSArray *mFeedbackData;
@property(nonatomic, copy) NSString *appkey;

- (void)sendFeedback:(id)sender;
@end
