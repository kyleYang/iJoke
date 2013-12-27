//
//  FTSDetailBaseView.h
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSBaseFrameView.h"
#import "Downloader.h"

@interface FTSDetailBaseView : FTSBaseFrameView


@property (nonatomic, assign) UIViewController *parCtl;
@property (nonatomic, strong, readonly) Downloader *downloader;


-(BOOL)loadLocalDataNeedFresh;
-(void)loadNetworkDataMore:(BOOL)bLoadMore;

@end
