//
//  FTSCommentWordsViewController.h
//  iJoke
//
//  Created by Kyle on 13-12-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommentBaseViewController.h"
#import "Words.h"

@interface FTSCommentWordsViewController : FTSCommentBaseViewController{
    Words *_words;
}

@property (nonatomic, strong) Words *words;


@end
