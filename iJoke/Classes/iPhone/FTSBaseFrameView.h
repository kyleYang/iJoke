//
//  FTSBaseFrameView.h
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MptCotentCell.h"
#import "MobClick.h"
#import "MobclickMarco.h"
#import "HMPopMsgView.h"
#import "UMSocial.h"

@interface FTSBaseFrameView : MptCotentCell{
    
    NSInteger _curPage;
    
}

@property (nonatomic, strong, readonly) UIView *viewContent;
@property (nonatomic, strong, readonly) UIImageView *ivBg;

@end
