//
//  FTSTopicImageDetailCell.m
//  iJoke
//
//  Created by Kyle on 13-11-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTopicImageDetailCell.h"
#import "FTSLoadingCell.h"
#import "FTSEmptyCell.h"
#import "FTSUIOps.h"
#import "FTSUserInfoViewController.h"

#define kMtoolBarHeigh 44


@interface FTSTopicImageDetailCell()<UIGestureRecognizerDelegate,ImageTableDetailHeadDelegate>
@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) Downloader *downloader;
@property (nonatomic, strong, readwrite) FTSImageDetailHeadView *headView;


@end


@implementation FTSTopicImageDetailCell
@synthesize hasMore = _hasMore;
@synthesize image = _image;
@synthesize delegate = _delegate;

- (void)dealloc{
    [self.downloader cancelAll];
    self.downloader = nil;
}

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl
{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (nil == self) return nil;
    
    // create subview
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.bounds),  CGRectGetHeight(self.bounds))];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollsToTop = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.headView = [[FTSImageDetailHeadView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), 0)];
    [self.scrollView addSubview:self.headView];
    self.headView.delegate = self;
    _hasMore = YES;
    _curPage = 0;
    // create downloade
    self.downloader = [[Downloader alloc] init];
    self.downloader.bSearialLoad = YES;
    
    
    self.nTotalNum = -1;
    self.nTaskId = -1;
    return self;
    
    
}


#pragma
#pragma mark instance method

- (void)viewWillAppear{
    [super viewWillAppear];
    _hasMore = YES;
    _onceLoaded = NO;
    
    
    
    [self tableContentFrsh];
    //    [self performSelector:@selector(tableContentFrsh) withObject:nil afterDelay:1];
    
}



- (void)viewWillDisappear{
    
    [self.downloader cancelAll];
      self.nTotalNum = -1;
    [super viewWillDisappear];
}

- (void)tableContentFrsh{
    [self dataFresh:nil];
}


- (void)dataFresh:(id)sender{
    [self loadNetworkDataMore:NO];
}


-(void)viewDidAppear {
    [super viewDidAppear];
    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
        self.scrollView.contentInset = UIEdgeInsetsMake(64+self.videoOffset, 0, 0, 0);
    }
    
}




- (void)mainViewOnFont:(BOOL)value{
    if (value) {
        self.scrollView.scrollsToTop = YES;
       
    }else{
        self.scrollView.scrollsToTop = NO;
       
        
    }
}


- (void)viewDidDisappear{
    _image = nil;
    [self.headView configCellForImage:nil];
    [super viewDidDisappear];
}


- (void)setImage:(Image *)image{
    if (_image == image) return;
    _image = image;
    
    //    self.tableView.contentOffset = CGPointZero;
    
    CGRect frame = self.headView.frame;
    CGFloat height = [self.headView configCellForImage:_image];
    
    BqsLog(@"FTSImageDetailCell height:%.1f",height);
    if (height!=0) {
        frame.size.height = height;
        self.headView.frame = frame;
    }
    CGSize size = self.scrollView.contentSize;
    size.height = height>CGRectGetHeight(self.bounds)?height:CGRectGetHeight(self.bounds);
    self.scrollView.contentSize = size;
    CGFloat offsetY = 0;
    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
        offsetY = -64;
    }
    self.scrollView.contentOffset = CGPointMake(0, offsetY);
    
}


#pragma mark
#pragma mark Button method
- (void)imageDetailHeadViewImageTouch:(FTSImageDetailHeadView *)cell atIndex:(NSUInteger)index{
    
    if (_delegate && [_delegate respondsToSelector:@selector(topicImageDetailCell:popHeadView:atIndex:)]) {
        
        [_delegate topicImageDetailCell:self popHeadView:cell atIndex:index];
    }
    
}





#pragma mark
#pragma mark - network ops
- (BOOL)loadLocalDataNeedFresh{
    return TRUE;
}

-(void)loadNetworkDataMore:(BOOL)bLoadMore {
    
}


- (void)dataFresh{
    
}


























@end
