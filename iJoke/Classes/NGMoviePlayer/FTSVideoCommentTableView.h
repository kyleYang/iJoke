//
//  FTSVideoCommentTableView.h
//  iJoke
//
//  Created by Kyle on 13-11-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommitBaseCell.h"
#import "Video.h"

@interface FTSVideoCommentTableView : FTSCommitBaseCell{
    
    Video *_video;
}

@property (nonatomic, strong, readwrite) Video *video;

@end
