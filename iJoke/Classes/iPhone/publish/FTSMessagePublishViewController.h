//
//  FTSMessagePublishViewController.h
//  iJoke
//
//  Created by Kyle on 13-9-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSUserCenterBaseViewController.h"

@interface FTSMessagePublishViewController : FTSUserCenterBaseViewController
{
    UIImage *_weiboImage;
    UILabel *wordNum;
    BOOL _edited;
    
}


@property (nonatomic, strong) NSString *contentStr;
@property (nonatomic, strong) UITextView *contentView;
@property (nonatomic, strong) UILabel *wordNum;

@end
