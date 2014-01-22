//
//  FTSWordsDetailViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSWordsDetailViewController.h"
#import "FTSWordsDetailCell.h"
#import "FTSCommitTipsCell.h"

@interface FTSWordsDetailViewController ()

@end

@implementation FTSWordsDetailViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_words_commit];
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_words_commit];
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
    return [_dataArray count]+1;
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    
    FTSWordsDetailCell *cell;
    FTSCommitTipsCell *tipsCelll;
    static NSString *celleIdentifier = @"nomal";
    static NSString *tipsIdentifier = @"tips";
    
    if (index < [_dataArray count] ) {
        cell = (FTSWordsDetailCell *)[scrollView dequeueCellWithIdentifier:celleIdentifier];
        if (!cell) {
            cell = [[FTSWordsDetailCell alloc] initWithFrame:frame withIdentifier:celleIdentifier withController:self];
        }
        
        cell.words = [_dataArray objectAtIndex:index];
        
        return cell;
    }else if(index == [_dataArray count]){
        
        tipsCelll = (FTSCommitTipsCell *)[scrollView dequeueCellWithIdentifier:tipsIdentifier];
        if (tipsCelll == nil) {
            tipsCelll = [[FTSCommitTipsCell alloc] initWithFrame:frame withIdentifier:tipsIdentifier withController:self];
        }
        
        if (_more) {
            tipsCelll.tips.text  = NSLocalizedString(@"joke.content.loading", nil);;
            if (_delegate && [_delegate respondsToSelector:@selector(FTSWordsDetailViewControllerLoadMore:)]) {
                [_delegate FTSWordsDetailViewControllerLoadMore:self];
                BqsLog(@"FTSWordsDetailViewControllerLoadMore");
            }
            
        }else{
            tipsCelll.tips.text = NSLocalizedString(@"joke.content.loadfininsh", nil);
            
        }
        return tipsCelll;
    }
    
    return nil;
   
}

#pragma mark 
#pragma mark report
- (void)reportMessage{
    NSInteger curIndex = [self.contentView current];
    
    if (curIndex >= [_dataArray count] ){
        BqsLog(@"report index = %d > [_dataArray count] = %d",curIndex,[_dataArray count]);
        return;
    }
    Words *word = [_dataArray objectAtIndex:curIndex];
    
    
#ifdef iJokeAdministratorVersion

    [FTSNetwork deleteMessageDownloader:self.downloader Target:self Sel:@selector(reportMessageCB:) Attached:nil artId:word.wordId type:WordsSectionType];
#else
    
    [FTSNetwork reportMessageDownloader:self.downloader Target:self Sel:@selector(reportMessageCB:) Attached:nil artId:word.wordId type:WordsSectionType];
#endif
    
   

    
}


@end
