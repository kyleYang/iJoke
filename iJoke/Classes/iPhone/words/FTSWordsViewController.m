//
//  FTSWordsViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSWordsViewController.h"
#import "FTSWordsNewTableView.h"

@interface FTSWordsViewController ()

@end

@implementation FTSWordsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"joke.category.text", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_WordsPage];
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_WordsPage];
    [super viewWillDisappear:animated];
}



- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
//    return self.segmentedControl.numberOfSegments;
    return 1;
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    static NSString *identifier = @"cell";
    FTSWordsNewTableView *cell = (FTSWordsNewTableView *)[scrollView dequeueCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FTSWordsNewTableView alloc] initWithFrame:frame withIdentifier:identifier withController:self];
        cell.managedObjectContext = self.managedObjectContext;
    }
    return cell;
    
}



@end
