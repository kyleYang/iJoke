//
//  FTSLeftRevealViewController.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSLeftRevealViewController.h"
#import "PKRevealController.h"
#import "JkCategoryButton.h"
#import "FTSUIOps.h"
#import "FTSWordsViewController.h"
#import "FTSImageViewController.h"
#import "FTSVideoViewController.h"
#import "FTSReviewViewController.h"
#import "FTSTopicViewController.h"
#import "FTSUserCenter.h"
#import "FTSLoginViewController.h"

#define kButtonWidth 180
#define kButtonHeith 60

@interface FTSLeftRevealViewController ()<FTSLoginDelegate>{
    
    UIImageView *_background;
    JkCategoryButton *_verifyBtn;
}


@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) FTSWordsViewController *wordsCtl;
@property (nonatomic, strong) FTSImageViewController *imageCtl;
@property (nonatomic, strong) FTSVideoViewController *videoCtl;
@property (nonatomic, strong) FTSTopicViewController *topicCtl;
@property (nonatomic, strong) FTSReviewViewController *reviewCtl;

@end

@implementation FTSLeftRevealViewController

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
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image = [[Env sharedEnv] cacheImage:@"reveal_background.png"];
    [self.view addSubview:backgroundView];
    
    
    self.buttonArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    [self.revealController setMinimumWidth:180.0f maximumWidth:324.0f forViewController:self];
    self.revealController.animationDuration = 0.25f;
    self.revealController.animationCurve = UIViewAnimationCurveEaseInOut;
    
    CGFloat offset = 0.0f;
    if (DeviceSystemMajorVersion()>=7) {
        offset = 20.0f;
    }
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[[Env sharedEnv] cacheResizableImage:@"channel_sidebar_button_red_selected.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    background.alpha = 0.4;
    [self.view addSubview:background];
    _background = background;
    
    JkCategoryButton *textBtn = [[JkCategoryButton alloc] initWithFrame:CGRectMake(0, offset, kButtonWidth, kButtonHeith)];
    textBtn.title.text = NSLocalizedString(@"joke.category.text", nil);
    textBtn.title.textColor = RGBA(82, 176, 255, 1.0);
    textBtn.icon.image = [[Env sharedEnv] cacheImage:@"cate_text.png"];
    [textBtn addTarget:self action:@selector(textSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textBtn];
//    UIImage *image = [[Env sharedEnv] cacheResizableImage:@"channel_sidebar_button_red_selected.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
//    [textBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"channel_sidebar_button_red_selected.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
//    [textBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"channel_sidebar_button_red_selected.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateSelected];
    textBtn.selected = YES;
    [self.buttonArray addObject:textBtn];
    background.frame = textBtn.frame;
    
    JkCategoryButton *imageBtn = [[JkCategoryButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(textBtn.frame), CGRectGetMaxY(textBtn.frame), CGRectGetWidth(textBtn.frame), CGRectGetHeight(textBtn.frame))];
    imageBtn.title.text = NSLocalizedString(@"joke.category.image", nil);
    imageBtn.icon.image = [[Env sharedEnv] cacheImage:@"cate_image.png"];
    imageBtn.title.textColor = RGBA(170, 222, 156, 1.0);
    [imageBtn addTarget:self action:@selector(imageSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageBtn];
    imageBtn.selected = NO;
    [self.buttonArray addObject:imageBtn];
    
    JkCategoryButton *videoBtn = [[JkCategoryButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageBtn.frame), CGRectGetMaxY(imageBtn.frame), CGRectGetWidth(imageBtn.frame), CGRectGetHeight(imageBtn.frame))];
    videoBtn.title.text = NSLocalizedString(@"joke.category.video", nil);
    videoBtn.icon.image = [[Env sharedEnv] cacheImage:@"cate_video.png"];
    videoBtn.title.textColor = RGBA(229, 191, 59, 1.0);
    [videoBtn addTarget:self action:@selector(videoSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoBtn];
    videoBtn.selected = NO;
    [self.buttonArray addObject:videoBtn];
    
    
    JkCategoryButton *topicBtn = [[JkCategoryButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(videoBtn.frame), CGRectGetMaxY(videoBtn.frame), CGRectGetWidth(videoBtn.frame), CGRectGetHeight(videoBtn.frame))];
    topicBtn.title.text = NSLocalizedString(@"joke.category.topic", nil);
    topicBtn.icon.image = [[Env sharedEnv] cacheImage:@"cate_topic.png"];
    topicBtn.title.textColor = RGBA(219, 50, 131, 1.0);
    [topicBtn addTarget:self action:@selector(topicSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topicBtn];
    topicBtn.selected = NO;
    [self.buttonArray addObject:topicBtn];
    
    JkCategoryButton *verifyBtn = [[JkCategoryButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(topicBtn.frame), CGRectGetMaxY(topicBtn.frame), CGRectGetWidth(topicBtn.frame), CGRectGetHeight(topicBtn.frame))];
    verifyBtn.title.text = NSLocalizedString(@"joke.category.verify", nil);
    verifyBtn.icon.image = [[Env sharedEnv] cacheImage:@"cate_verify.png"];
    verifyBtn.title.textColor = RGBA(109, 0, 270, 1.0);
    [verifyBtn addTarget:self action:@selector(verifySelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:verifyBtn];
    verifyBtn.selected = NO;
    [self.buttonArray addObject:verifyBtn];
    _verifyBtn = verifyBtn;

    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *	rest Select state 
 *
 *	@param	button	select button
 *
 *	@return	FALSE : current select not equal before
 *          TRUE  : current select equal before
 */
- (BOOL)restSelectState:(JkCategoryButton *)button{
    
    for (JkCategoryButton *temp in self.buttonArray) {
        
        if (temp == button) {
            if (temp.selected) {
                return FALSE;
            }
            temp.selected = YES;
            _background.frame = temp.frame;
        }else{
            temp.selected = NO;
        }
        
    }
    
    return TRUE;
    
    
}



#pragma mark
#pragma mark button method

- (void)textSelect:(id)sender{
    
   BOOL needSet =  [self restSelectState:(JkCategoryButton *)sender];
    
    if (needSet) {
        if (!self.wordsCtl) {
           self.wordsCtl = [[FTSWordsViewController alloc] initWithNibName:nil bundle:nil];
        }
        
         [FTSUIOps revealRightViewControl:self showNavigationFontViewControl:self.wordsCtl];
        
    }else{
        [self.revealController showViewController:self.revealController.frontViewController];
    }
    
   
    
    
    
}


- (void)imageSelect:(id)sender{
    
    BOOL needSet =  [self restSelectState:(JkCategoryButton *)sender];
    
    if (needSet) {
        
        if (!self.imageCtl) {
            self.imageCtl = [[FTSImageViewController alloc] initWithNibName:nil bundle:nil];
        }

        [FTSUIOps revealRightViewControl:self showNavigationFontViewControl:self.imageCtl];
        
    }else{
        [self.revealController showViewController:self.revealController.frontViewController];
    }
    

    
    
}

- (void)videoSelect:(id)sender{
    
    BOOL needSet =  [self restSelectState:(JkCategoryButton *)sender];
    
    if (needSet) {
        
        if (!self.videoCtl) {
            self.videoCtl = [[FTSVideoViewController alloc] initWithNibName:nil bundle:nil];
        }
        
        [FTSUIOps revealRightViewControl:self showNavigationFontViewControl:self.videoCtl];
        
    }else{
        [self.revealController showViewController:self.revealController.frontViewController];
    }

    
}

- (void)topicSelect:(id)sender{
    
    BOOL needSet =  [self restSelectState:(JkCategoryButton *)sender];
    if (needSet) {
        
        if (self.topicCtl == nil) {
            self.topicCtl = [[FTSTopicViewController alloc] initWithNibName:nil bundle:nil];
        }
        [FTSUIOps revealRightViewControl:self showNavigationFontViewControl:self.topicCtl];
        
    }else{
        [self.revealController showViewController:self.revealController.frontViewController];
    }

    
}

- (void)verifySelect:(id)sender{
    
   
    
    BOOL login = [FTSUserCenter BoolValueForKey:kDftUserLogin];
    if (login) { //have login ,goto user info center;
       [self restSelectState:(JkCategoryButton *)sender];
        
            
        if (self.reviewCtl == nil) {
            self.reviewCtl = [[FTSReviewViewController alloc] initWithNibName:nil bundle:nil];
        }
           
        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:self.reviewCtl];
            
       

        
        return;
        
    }else{
        FTSLoginViewController *loginViewController = [[FTSLoginViewController alloc] initWithNibName:nil bundle:nil];
        [FTSUIOps flipNavigationController:self.revealController.flipboardNavigationController pushNavigationWithController:loginViewController];
        loginViewController.action = @selector(verifySelect:);
        loginViewController.delegate = self;

        return;
    }

    
  
    
}
#pragma mark
#pragma mark FTSLoginDelegate
- (void)loginSuccess:(BOOL)value action:(SEL)action{
    
    if (action != nil) {
        [self performSelector:action withObject:_verifyBtn afterDelay:0.0f];
    }
    
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



@end
