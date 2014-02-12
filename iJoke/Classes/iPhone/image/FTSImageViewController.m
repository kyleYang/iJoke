//
//  FTSImageViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSImageViewController.h"
#import "FTSImageNewTableView.h"

@interface FTSImageViewController ()

@end

@implementation FTSImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = NSLocalizedString(@"joke.category.image", nil);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.navigationItem.title = NSLocalizedString(@"joke.category.image", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kUmeng_ImagePage];
}


- (void)viewWillDisappear:(BOOL)animated{
    [MobClick endLogPageView:kUmeng_ImagePage];
    [super viewWillDisappear:animated];
}



- (NSUInteger)numberOfItemFor:(MptContentScrollView *)scrollView{ // must be rewrite
//    return self.segmentedControl.numberOfSegments;
    return 1;
}

- (MptCotentCell*)cellViewForScrollView:(MptContentScrollView *)scrollView frame:(CGRect)frame AtIndex:(NSUInteger)index{
    static NSString *identifier = @"cell";
    FTSImageNewTableView *cell = (FTSImageNewTableView *)[scrollView dequeueCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FTSImageNewTableView alloc] initWithFrame:frame withIdentifier:identifier withController:self];
    }
    return cell;
    
}



@end
