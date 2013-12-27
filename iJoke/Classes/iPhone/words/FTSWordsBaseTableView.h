//
//  FTSWordsTableView.h
//  iJoke
//
//  Created by Kyle on 13-8-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSDetailTableView.h"
#import "FTSNetwork.h"
#import "FTSWordsTableCell.h"
#import "FTSWordsDetailViewController.h"
#import "FTSDataMgr.h"
#import "FTSUserCenter.h"
#import "Words.h"
#import "Msg.h"
#import "FTSUserInfoViewController.h"

#define kWordsPageEachNum 0

@interface FTSWordsBaseTableView : FTSDetailTableView


@property (nonatomic, strong) FTSWordsDetailViewController *detailController;


- (void)resaveDataArray; //save data ,when reload data array;should be rewrite


@end
