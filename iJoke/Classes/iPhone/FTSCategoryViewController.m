//
//  FTSCategoryViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCategoryViewController.h"

@interface FTSCategoryViewController ()

@end



@implementation FTSCategoryViewController
@synthesize segmentedControl = _segmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    "joke.content.hot" = "热门";
//    "joke.content.new" = "新鲜";
    
	// Do any additional setup after loading the view.
//    self.segmentedControl = [[SDSegmentedControl alloc] initWithItems:@[NSLocalizedString(@"joke.content.hot", nil)]];
//    self.segmentedControl.frame = CGRectMake(60, 0, 200, 44);
//    self.segmentedControl.backgroundColor = [UIColor clearColor];
//    [self.segmentedControl addTarget:self action:@selector(sectionChanged:) forControlEvents:UIControlEventValueChanged];
//    self.navigationItem.titleView = self.segmentedControl;
    
   
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    self.segmentedControl.selectedSegmentIndex = 0;
    
}


//need be rewrite
- (void)sectionChanged:(id)sender{
    
//    [self.contentView setCurrentItemIndex:self.segmentedControl.selectedSegmentIndex animation:YES];
}

- (void)scrollView:(MptContentScrollView *)scrollView curIndex:(NSInteger)index
{
//    if (index >= self.segmentedControl.numberOfSegments) {
//        BqsLog(@"index = %d > self.segmentedControl.numberOfSegments = %d",index, self.segmentedControl.numberOfSegments);
//        return;
//    }
//    self.segmentedControl.selectedSegmentIndex = index;
}


@end
