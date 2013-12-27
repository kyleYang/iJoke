//
//  FTSBaseViewController.m
//  iJoke
//
//  Created by Kyle on 13-11-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSBaseViewController.h"

#define kAnimationTimeInterval .5
#define kAnimationHoldTimeInterval 1
#define kNoticeLabelHeight 50

@interface FTSBaseViewController ()


@property (nonatomic, strong) UILabel *noticeLabel;

@end

@implementation FTSBaseViewController

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
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    if (self.noticeLabel != nil){
        [self.noticeLabel removeFromSuperview];
        self.noticeLabel = nil;
    }

    
}



- (void)noticeMessageNSString:(NSString *)message{
    
    if (self.noticeLabel == nil) {
        self.noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kNoticeLabelHeight)];
        self.noticeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:.8];
        self.noticeLabel.textAlignment = UITextAlignmentCenter;
        self.noticeLabel.textColor = [UIColor whiteColor];
    }
    self.noticeLabel.text = message;
    [self.view addSubview:self.noticeLabel];
    
    CGFloat offset = 0;
    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
        offset = 64;
    }
    __block CGRect frame = self.noticeLabel.frame;
    frame.origin.y = offset - kNoticeLabelHeight;
    self.noticeLabel.frame = frame;
    
    [UIView animateWithDuration:kAnimationTimeInterval animations:^{
        frame.origin.y = offset;
        self.noticeLabel.frame = frame;
        
    }completion:^(BOOL finish){
        
        if (finish) {
            
            
            [UIView animateWithDuration:0 delay:kAnimationHoldTimeInterval options:UIViewAnimationOptionCurveLinear animations:^{
                frame.origin.y = offset+1;
                self.noticeLabel.frame = frame;
            }completion:^(BOOL finished){
                
                if (finished) {
                    
                    [UIView animateWithDuration:kAnimationTimeInterval animations:^{
                        frame.origin.y = offset - kNoticeLabelHeight;
                        self.noticeLabel.frame = frame;
                        
                    }completion:^(BOOL finishs){
                        [self.noticeLabel removeFromSuperview];
                    }];
                }
                
                
            }];
            
            
        }
        
        
    }];
    
    
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
