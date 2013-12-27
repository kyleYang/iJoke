//
//  FTSCommentWordsViewController.m
//  iJoke
//
//  Created by Kyle on 13-12-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommentWordsViewController.h"
#import "FTSNetwork.h"

@interface FTSCommentWordsViewController ()

@end

@implementation FTSCommentWordsViewController
@synthesize words = _words;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
}





#pragma mark
#pragma mark Overloaded

- (void)sendCommentText:(NSString *)text anonymous:(BOOL)anonymous{
    
    if (_nTaskId > 0) {
        
        return;
    }
    
    _nTaskId = [FTSNetwork postCommitDownloader:self.downloader Target:self Sel:@selector(commitCB:) Attached:[NSNumber numberWithBool:anonymous] artId:_words.wordId comment:text type:WordsSectionType hiddenUser:anonymous];
    
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
    if (!bLoadMore) {
        self.hasMore = YES;
        _curPage = 0;
        self.tempArray = nil;
        [MobClick endEvent:kUmeng_topic_image_commit_fresh];
        
    }else{
        _curPage++;
        [MobClick endEvent:kUmeng_topic_image_commit_next label:[NSString stringWithFormat:@"%d",_curPage]];
    }
    
    [FTSNetwork commitListDownloader:self.downloader Target:self Sel:@selector(onLoadCommitListFinished:) Attached:nil artId:_words.wordId page:_curPage type:WordsSectionType];
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end