//
//  FTSCategoryViewController.h
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSRevealBaseViewController.h"
#import "SDSegmentedControl.h"

@interface FTSCategoryViewController : FTSRevealBaseViewController{
    
    SDSegmentedControl *_segmentedControl;
}

@property (strong, nonatomic) SDSegmentedControl *segmentedControl;

- (void)sectionChanged:(id)sender;


@end
