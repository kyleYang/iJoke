//
//  FTSWordsDetailHeadView.m
//  iJoke
//
//  Created by Kyle on 13-8-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSWordsDetailHeadView.h"
#import "FTSDatabaseMgr.h"
#import "FTSDataMgr.h"


#define kBackgroundOffY 5

#define kHeadBackgroundOffX 2
#define kHeadBackgroundOffY 1
#define kHeadBackgroundHeight 45

#define kImageOffX 5
#define kImageOffY 2

#define kUserOffY 5
#define kUserHeight 30
#define kUserContentPaddY 8

#define kContentOffX 10
#define kContentButtonPaddY 15

#define kButtonWidth 30
#define kButtonHeight 28
#define kButtonPaddY 20
#define kButtonsPaddY 10

#define kAddBigDuration 0.6
#define kAddSmaDuration 0.3


#define kHeadFont [UIFont systemFontOfSize:16.0f]

@interface FTSWordsDetailHeadView()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *headBackground;
@property (nonatomic, strong, readwrite) FTSCellUserControl *userControl;
@property (nonatomic, strong, readwrite) UILabel *content;
@property (nonatomic, strong, readwrite) JKIconTextButton *upBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *downBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *shareBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *favBtn;

@property (nonatomic, strong) UILabel *addImg;

@property (nonatomic, strong, readwrite) Words *words;

@end


@implementation FTSWordsDetailHeadView
@synthesize words = _words;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageOffX, kBackgroundOffY, CGRectGetWidth(self.bounds)-2*kImageOffX, CGRectGetHeight(self.bounds)- 4*kImageOffY)];
//        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self.backgroundImageView setImage:[[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
        self.backgroundImageView.userInteractionEnabled = TRUE;
        [self addSubview:self.backgroundImageView];
        
        self.headBackground = [[UIView alloc] initWithFrame:CGRectMake(kHeadBackgroundOffX, kHeadBackgroundOffY,CGRectGetWidth(self.backgroundImageView.frame)-2*kHeadBackgroundOffX , kHeadBackgroundHeight)];
        self.headBackground.backgroundColor = RGBA(253, 248, 239, 1.0);
//        self.headBackground.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self.backgroundImageView addSubview:self.headBackground];
        
        self.userControl = [[FTSCellUserControl alloc] initWithFrame:CGRectMake(2, kUserOffY, CGRectGetWidth(self.bounds)-10, kUserHeight)];
        [self.userControl addTarget:self action:@selector(userInfoTouch:) forControlEvents:UIControlEventTouchUpInside];
        self.userControl.backgroundColor = [UIColor clearColor];
        [self.headBackground addSubview:self.userControl];
        
        self.content = [[UILabel alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.backgroundImageView.bounds)-2*kContentOffX,0)];
        self.content.font = kHeadFont;
        self.content.numberOfLines = 0;
        self.content.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);
        self.content.backgroundColor = [UIColor clearColor];
        [self.backgroundImageView addSubview:self.content];
        
        self.upBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, 25, kButtonHeight)];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.upBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_ding_normal.png"];
        self.upBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_ding_select.png"];
        self.upBtn.normalColor =  HexRGB(0xA5A29B);
        self.upBtn.hilightColor =  HexRGB(0xFF5858);
        [self.upBtn addTarget:self action:@selector(upDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundImageView addSubview:self.upBtn];
        
//        self.downBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, 25, kButtonHeight)];
//        [self.downBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
//        [self.downBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
//        self.downBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_cai_normal.png"];
//        self.downBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_cai_hilight.png"];
//        self.downBtn.normalColor =  HexRGB(0xA5A29B);
//        self.downBtn.hilightColor =  HexRGB(0xFF5858);
//        [self.downBtn addTarget:self action:@selector(downDetail:) forControlEvents:UIControlEventTouchUpInside];
//        [self.backgroundImageView addSubview:self.downBtn];
        
        self.favBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateHighlighted];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.favBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_collect_select.png"];
        self.favBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_collect_nomal.png"];
        [self.favBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.favBtn addTarget:self action:@selector(favoriteDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundImageView addSubview:self.favBtn];
        
        self.shareBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
        [self.shareBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.shareBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateHighlighted];
        [self.shareBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.shareBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_share_select.png"];
        self.shareBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_share_nomal.png"];
        [self.shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.shareBtn addTarget:self action:@selector(shareDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundImageView addSubview:self.shareBtn];
        
        self.addImg = [[UILabel alloc] initWithFrame:CGRectZero];
        self.addImg.backgroundColor = [UIColor clearColor];
        self.addImg.font = [UIFont systemFontOfSize:22.0f];
        self.addImg.textAlignment = UITextAlignmentCenter;
        self.addImg.alpha = 0.0f;
        [self.backgroundImageView addSubview:self.addImg];
        
        
    }
    return self;
}



- (void)setWords:(Words *)words{
    if (_words == words) return;
    
    _words = words;
    
    CGSize size = [_words.content sizeWithFont:kHeadFont constrainedToSize:CGSizeMake(CGRectGetWidth(self.content.bounds), 1000) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = self.content.frame;
    frame.size = size;
    
    frame = self.bounds;
    frame.size.height = size.height+20;
    self.bounds = frame;
    
    self.content.text = _words.content;
    
}

- (CGFloat)configCellForWords:(Words *)word{
    
    if (_words == word) return 0;
    _words = word;
    if (_words == nil) {
        return 0;
    }
    
    
    CGFloat height = kHeadBackgroundOffY;
    
    if (word.user == nil) {
        self.headBackground.hidden = TRUE;
    }else{
        self.headBackground.hidden = FALSE;
        self.userControl.user = word.user;
        height += CGRectGetHeight(self.headBackground.frame);
        height += kUserContentPaddY;
    }
    
    
    
    CGSize size = [word.content sizeWithFont:self.content.font constrainedToSize:CGSizeMake(self.content.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = self.content.frame;
    frame.size.height = size.height;
    frame.origin.y = height;
    self.content.frame = frame;
    self.content.text = word.content;
    
    
    
    height += (kContentButtonPaddY+CGRectGetHeight(self.content.frame));
    
    [self.upBtn calculateWidth:[NSString stringWithFormat:@"%d",word.up]];
    frame = self.upBtn.frame;
    frame.origin.y = height;
    frame.origin.x = 15;
    self.upBtn.frame = frame;
    
//    [self.downBtn calculateWidth:[NSString stringWithFormat:@"-%d",word.down]];
//    frame = self.downBtn.frame;
//    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
//    frame.origin.x = CGRectGetMaxX(self.upBtn.frame)+10;
//    self.downBtn.frame = frame;
    
    frame = self.shareBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.shareBtn.frame)-30;
    self.shareBtn.frame = frame;
    
    
    frame = self.favBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    frame.origin.x = CGRectGetMinX(self.shareBtn.frame)-CGRectGetWidth(self.favBtn.frame)-kButtonsPaddY;
    self.favBtn.frame = frame;
    
    [self refreshRecordState];
    
    height += (kButtonPaddY+CGRectGetHeight(self.shareBtn.frame));
    
    frame = self.backgroundImageView.frame;
    frame.size.height = height;
    frame.origin.y = kBackgroundOffY;
    self.backgroundImageView.frame = frame;
    
    frame = self.headBackground.frame;
    frame.origin.y = -6;
    self.headBackground.frame = frame;
    
    return height+2*kBackgroundOffY;
    
}

-(void)refreshRecordState{
    
    FTSRecord *record;
    if ([self.delegate respondsToSelector:@selector(recordForDetailUpHeadViewWord:)]) {
        record = [self.delegate recordForDetailUpHeadViewWord:_words];
    }
    
    
    if (record) {
        
        if ([record.updown intValue] == iJokeUpDownUp) {
            self.upBtn.buttonSelected = YES;
//            self.downBtn.buttonSelected = FALSE;
        }else if ([record.updown intValue] == iJokeUpDownDown){
            self.upBtn.buttonSelected = FALSE;
//            self.downBtn.buttonSelected = TRUE;
        }else{
            self.upBtn.buttonSelected = FALSE;
//            self.downBtn.buttonSelected = FALSE;
        }
        
        if ([record.favorite boolValue]) {
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




#pragma mark
#pragma mark Button method

- (void)upDetail:(id)sender{
    if (self.upBtn.buttonSelected) {
        
        return ;
    }

    
    if (_delegate && [_delegate respondsToSelector:@selector(wordsDetailUpHeadView:)]) {
        BqsLog(@"FTSWordsDetailHeadView up ");
        [_delegate wordsDetailUpHeadView:self];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addImg.alpha = 0.7f;
        self.addImg.text = @"+1";
        self.addImg.textColor = [UIColor redColor];
        self.addImg.frame = self.upBtn.frame;
        self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        
        _words.up ++;
        
        CGRect frame = self.addImg.frame;
        frame.origin.y -= 15;
        self.addImg.frame = frame;
        
        [UIView animateWithDuration:kAddBigDuration animations:^{
            self.addImg.alpha = 1.0f;
            self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kAddSmaDuration animations:^{
                self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
                self.addImg.alpha = 0.4f;
            } completion:^(BOOL finished){
                self.addImg.alpha = 0.0f;
                
                [self.upBtn calculateWidth:[NSString stringWithFormat:@"%d",_words.up]];
                [self refreshRecordState];
                
            }];
            
        }];
    });
    
    
    
    
}

- (void)downDetail:(id)sender{
    
    if (self.upBtn.buttonSelected || self.downBtn.buttonSelected) {
        
        return ;
    }

    
    if (_delegate && [_delegate respondsToSelector:@selector(wordsDetailDownHeadView:)]) {
        BqsLog(@"FTSWordsDetailHeadView down");
        [_delegate wordsDetailDownHeadView:self];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addImg.alpha = 0.7f;
        self.addImg.text = @"-1";
        self.addImg.textColor = [UIColor redColor];
        self.addImg.frame = self.downBtn.frame;
        self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        
        _words.down ++;

        
        CGRect frame = self.addImg.frame;
        frame.origin.y -= 15;
        self.addImg.frame = frame;
        
        [UIView animateWithDuration:kAddBigDuration animations:^{
            self.addImg.alpha = 1.0f;
            self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kAddSmaDuration animations:^{
                self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
                self.addImg.alpha = 0.4f;
            } completion:^(BOOL finished){
                self.addImg.alpha = 0.0f;
                [self.downBtn calculateWidth:[NSString stringWithFormat:@"%d",_words.down]];
                [self refreshRecordState];
            }];
            
        }];
    });
    
    
    
}



- (void)favoriteDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(wordsDetailFavoriteHeadView:addType:)]) {
        BOOL value = !self.favBtn.selected;
        BqsLog(@"FTSWordsDetailHeadView favorite addType:%d",value);
        [_delegate wordsDetailFavoriteHeadView:self addType:value];
    }
    
}


- (void)shareDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(wordsDetailShareHeadView:)]) {
        BqsLog(@"wordsDetailShareHeadView share");
        [_delegate wordsDetailShareHeadView:self];
    }
    
}

- (void)userInfoTouch:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(wordsDetailHeadViewUserInfo:)]) {
        BqsLog(@"wordsDetailHeadViewUserInfo");
        [_delegate wordsDetailHeadViewUserInfo:self];
    }
}

@end
