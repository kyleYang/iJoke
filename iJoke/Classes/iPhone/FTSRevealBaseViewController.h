//
//  FTSRevealBaseViewController.h
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MptContentScrollView.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "Downloader.h"
#import "HMPopMsgView.h"

@interface FTSRevealBaseViewController : UIViewController<scrollDataSource,scrollDelegate>{
    
}

@property (nonatomic, strong) Downloader *downloader;
@property (nonatomic, strong) MptContentScrollView *contentView;




@end
