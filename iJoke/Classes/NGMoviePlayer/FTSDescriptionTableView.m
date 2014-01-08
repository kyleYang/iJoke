//
//  FTSDescriptionTableView.m
//  iJoke
//
//  Created by Kyle on 13-11-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSDescriptionTableView.h"
#import "JKIconTextButton.h"
#import "FTSDataMgr.h"

#define kTitleLeftMargin 15
#define kTitleTopMargin 25
#define kImageOffY 2

#define kUserOffY 9
#define kUserHeight 30

#define kUserContentPaddY 10

#define kContentOffY 10
#define kContentOffX 10

#define kContentImagePaddY 6
#define kImagesOffY 10
#define kImagesPaddY 4
#define kImageBUttonPaddY 15

#define kButtonHeight 28
#define kButtonWidht 30
#define kButtonPaddY 20
#define kButtonsPaddY 10

#define kTouchButtomY 5

#define kAddBigDuration 0.6
#define kAddSmaDuration 0.3

#define kTitleFont [UIFont systemFontOfSize:18.0f];
#define kContentFont [UIFont systemFontOfSize:15.0f]


@interface FTSDescriptionTableView()

@property (nonatomic, strong) UIScrollView *tableView;

@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) JKIconTextButton *upBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *downBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *favBtn;
@property (nonatomic, strong, readwrite) UIButton *reportButton;
@property (nonatomic, strong, readwrite) UILabel *descriptLabel;
@property (nonatomic, strong) UILabel *addImg;
@end


@implementation FTSDescriptionTableView
@synthesize video = _video;
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl
{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (self) {
       
        self.tableView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.scrollsToTop = YES;
        self.tableView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.tableView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTitleLeftMargin, kTitleTopMargin, CGRectGetWidth(self.tableView.frame)-2*kTitleLeftMargin, 0)];
        self.titleLabel.font = kTitleFont;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.tableView addSubview:self.titleLabel];

        self.upBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), 0, 25, kButtonHeight)];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.upBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_ding_normal.png"];
        self.upBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_ding_select.png"];
        self.upBtn.normalColor =  HexRGB(0xA5A29B);
        self.upBtn.hilightColor =  HexRGB(0xFF5858);
        [self.upBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.upBtn addTarget:self action:@selector(upDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:self.upBtn];
        
        
//        self.downBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.frame)/2+CGRectGetMinX(self.titleLabel.frame), 0, 25, kButtonHeight)];
//        [self.downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.downBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
//        [self.downBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
//        self.downBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_cai_normal.png"];
//        self.downBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_cai_hilight.png"];
//        self.downBtn.normalColor =  HexRGB(0xA5A29B);
//        self.downBtn.hilightColor =  HexRGB(0xFF5858);
//        [self.downBtn addTarget:self action:@selector(downDetail:) forControlEvents:UIControlEventTouchUpInside];
//        [self.tableView addSubview:self.downBtn];

        self.favBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.frame)/3+CGRectGetMinX(self.titleLabel.frame), 0, kButtonWidht, kButtonHeight)];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateHighlighted];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.favBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_collect_select.png"];
        self.favBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_collect_nomal.png"];
        [self.favBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.favBtn addTarget:self action:@selector(favoriteDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:self.favBtn];
        
        
        self.reportButton = [[UIButton alloc] initWithFrame:CGRectMake(2*CGRectGetWidth(self.tableView.frame)/3+CGRectGetMinX(self.titleLabel.frame), 0, kButtonWidht*2, kButtonHeight)];
        [self.reportButton setTitle:NSLocalizedString(@"joke.navigation.report", nil) forState:UIControlStateNormal];
        [self.reportButton setBackgroundColor:[UIColor clearColor]];
        [self.reportButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_hilight.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
        [self.reportButton setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"login_register_normal.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        [self.reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.reportButton addTarget:self action:@selector(reportClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:self.reportButton];
        
        
        self.descriptLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), kTitleTopMargin,CGRectGetWidth(self.titleLabel.frame), 0)];
        self.descriptLabel.font = kContentFont;
        self.descriptLabel.numberOfLines = 0;
        self.descriptLabel.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);
        self.descriptLabel.backgroundColor = [UIColor clearColor];
        [self.tableView addSubview:self.descriptLabel];
        
        self.addImg = [[UILabel alloc] initWithFrame:CGRectZero];
        self.addImg.backgroundColor = [UIColor clearColor];
        self.addImg.font = [UIFont systemFontOfSize:22.0f];
        self.addImg.textAlignment = UITextAlignmentCenter;
        self.addImg.alpha = 0.0f;
        [self.tableView addSubview:self.addImg];

       

        
        
    }
    return self;
}


- (void)viewWillAppear{
    [super viewWillAppear];
    
    if(DeviceSystemMajorVersion() >=7){ //use for ios7 with layout full screen
        self.tableView.contentInset = UIEdgeInsetsMake(64+self.videoOffset, 0, 0, 0);
    }

    
}


-(void)viewDidAppear {
    
    [super viewDidAppear];
    
}



-(void)viewWillDisappear {
    
    [super viewWillDisappear];
}


- (void)mainViewOnFont:(BOOL)value{
    if (value) {
        self.tableView.scrollsToTop = YES;
    }else{
        self.tableView.scrollsToTop = NO;
    }
}

- (void)setVideo:(Video *)video{
    
    if (_video == video) return;
    
    _video = video;
    
    NSString *summary = nil;
    
    CGRect frame = self.titleLabel.frame;
    
    if(_video.title != nil && [_video.title length] != 0){
        summary = _video.title;
    }else {
        summary = NSLocalizedString(@"video.notitle", nil);
    }
    if (summary != nil) {
        CGSize size = [summary sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.titleLabel.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        frame.size.height = size.height;
        self.titleLabel.text = summary;
        self.titleLabel.frame = frame;
    }
    
    CGFloat height = CGRectGetMaxY(self.titleLabel.frame) +20;
    
    [self.upBtn calculateWidth:[NSString stringWithFormat:@"%d",_video.up]];
    frame = self.upBtn.frame;
    frame.origin.y = height;
    self.upBtn.frame = frame;
    
//    [self.downBtn calculateWidth:[NSString stringWithFormat:@"%d",_video.down]];
//    frame = self.downBtn.frame;
//    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
//    self.downBtn.frame = frame;
//    
//    height += CGRectGetHeight(self.upBtn.frame);
//    height += 15;
    
    frame = self.favBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    self.favBtn.frame = frame;
    
    frame = self.reportButton.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    self.reportButton.frame = frame;
    
    height += CGRectGetHeight(self.favBtn.frame);
    height += 25;
    
    frame = self.descriptLabel.frame;
    if(_video.summary != nil && [_video.summary length] != 0){
        summary = _video.summary;
    }else {
        summary = NSLocalizedString(@"video.nosummary", nil);
    }
    if (summary != nil) {
        CGSize size = [summary sizeWithFont:self.descriptLabel.font constrainedToSize:CGSizeMake(self.descriptLabel.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        frame.origin.y = height;
        frame.size.height = size.height;
        self.descriptLabel.text = summary;
        self.descriptLabel.frame = frame;
    }
    
    height += 30;
    
    CGSize size = self.tableView.contentSize;
    if (size.height < height) {
        size.height = height;
        self.tableView.contentSize = size;
    }

    [self refreshRecordState];
}

#pragma mark
#pragma mark button method

- (void)upDetail:(id)sender{
    
    if (self.upBtn.buttonSelected ) {
        
        return ;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(descriptionTableView:upVideo:)]) {
        
    
        BqsLog(@"descriptionTableView up upVideo:%@",_video);
        [_delegate descriptionTableView:self upVideo:_video];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addImg.alpha = 0.7f;
        self.addImg.text = @"+1";
        self.addImg.textColor = [UIColor redColor];
        self.addImg.frame = self.upBtn.frame;
        self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        
        _video.up ++;
        [[FTSDataMgr sharedInstance] addRecordVideo:_video upType:iJokeUpDownUp];
        CGRect frame = self.addImg.frame;
        frame.origin.y -= 15;
        self.addImg.frame = frame;
        
        [UIView animateWithDuration:kAddBigDuration animations:^{
            self.addImg.alpha = 1.0f;
            self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kAddSmaDuration animations:^{
                self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
                self.addImg.alpha = 0.7f;
            } completion:^(BOOL finished){
                self.addImg.alpha = 0.0f;
                [self.upBtn calculateWidth:[NSString stringWithFormat:@"-%d",_video.up]];
                [self refreshRecordState];
            }];
            
        }];
    });
    
}






- (void)downDetail:(id)sender{
    
    if (self.upBtn.buttonSelected || self.downBtn.buttonSelected) {
        
        return ;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(descriptionTableView:downVideo:)]) {
        
        
        BqsLog(@"descriptionTableView downVideo :%@",_video);
        [_delegate descriptionTableView:self downVideo:_video];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addImg.alpha = 0.7f;
        self.addImg.text = @"-1";
        self.addImg.textColor = [UIColor blueColor];
        self.addImg.frame = self.downBtn.frame;
        self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        
        _video.down ++;
        [[FTSDataMgr sharedInstance] addRecordVideo:_video upType:iJokeUpDownDown];
        
        CGRect frame = self.addImg.frame;
        frame.origin.y -= 15;
        self.addImg.frame = frame;
        
        [UIView animateWithDuration:kAddBigDuration animations:^{
            self.addImg.alpha = 1.0f;
            self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kAddSmaDuration animations:^{
                self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
                self.addImg.alpha = 0.7f;
            } completion:^(BOOL finished){
                self.addImg.alpha = 0.0f;
                
                [self.downBtn calculateWidth:[NSString stringWithFormat:@"-%d",_video.down]];
                [self refreshRecordState];
                
            }];
            
        }];
    });
    
    
    
}

- (void)favoriteDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(descriptionTableView:favVideo:addType:)]) {
        
        BOOL value = !self.favBtn.selected;
        BqsLog(@"descriptionTableView favVideo:%@ addType:%d",_video,value);
        [_delegate descriptionTableView:self favVideo:_video addType:value];
    }
    
}


- (void)reportClick:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(reportMessageTableView:video:)]) {
        
        BqsLog(@"reportMessageTableView Video:%@ ",_video);
        [_delegate reportMessageTableView:self video:_video];
    }
    
}


- (void)refreshRecordState{
    Record *record= [[FTSDataMgr sharedInstance] judgeVideoUpType:_video];
    
    if (record) {
        
        if (record.type == iJokeUpDownUp) {
            self.upBtn.buttonSelected = YES;
//            self.downBtn.buttonSelected = FALSE;
        }else if (record.type == iJokeUpDownDown){
            self.upBtn.buttonSelected = FALSE;
//            self.downBtn.buttonSelected = TRUE;
        }else{
            self.upBtn.buttonSelected = FALSE;
//            self.downBtn.buttonSelected = FALSE;
        }
        
        if (record.favorite) {
            self.favBtn.buttonSelected = TRUE;
        }else{
            self.favBtn.buttonSelected = FALSE;
        }
        
    }else{
        
        self.upBtn.buttonSelected = FALSE;
//        self.downBtn.buttonSelected = FALSE;
        self.favBtn.buttonSelected = FALSE;
    }
    
    
}







@end
