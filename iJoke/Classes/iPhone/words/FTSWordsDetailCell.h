//
//  FTSWordsDetailCell.h
//  iJoke
//
//  Created by Kyle on 13-8-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommitBaseCell.h"
#import "Words.h"

@interface FTSWordsDetailCell : FTSCommitBaseCell{
    
    Words *_words;
}


@property (nonatomic, strong) Words *words;

@end
