//
//  FTSWordsTableCell.m
//  iJoke
//
//  Created by Kyle on 13-8-7.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSWordsTableCell.h"
#import "FTSDataMgr.h"
#import "FTSDatabaseMgr.h"
#import "Record.h"

#define kImageOffX 8
#define kImageOffY 10

#define kUserOffY 9
#define kUserBackGroundHeigth 45
#define kUserHeight 35
#define kUserContentPaddY 0

#define kContentOffX 8
#define kContentButtonPaddY 12

#define kButtonWidth 30
#define kButtonHeight 28
#define kButtonPaddY 15
#define kButtonsPaddY 10

#define kTouchButtomY 0

#define kAddBigDuration 0.6
#define kAddSmaDuration 0.3

#define kContentFont [UIFont systemFontOfSize:16.0f]

@interface FTSWordsTableCell(){
    
    Words *_words;
}

@property (nonatomic, strong, readwrite) UIButton *touchView;
@property (nonatomic, strong) UIView *headBackground;
@property (nonatomic, strong, readwrite) FTSCellUserControl *userControl;
@property (nonatomic, strong, readwrite) UILabel *content;
@property (nonatomic, strong, readwrite) JKIconTextButton *commitBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *upBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *downBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *shareBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *favBtn;

@property (nonatomic, strong) UILabel *addImg;
@property (nonatomic, strong) Words *words;

@end


@implementation FTSWordsTableCell
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        self.backgroundColor = RGBA(255, 248, 240, 1.0);
        
        self.touchView = [[UIButton alloc] initWithFrame:CGRectMake(kImageOffX, kImageOffY, CGRectGetWidth(self.bounds)-2*kImageOffX, CGRectGetHeight(self.bounds)- 4*kImageOffY)];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_pressed.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
        [self.touchView addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.touchView];
        
        self.headBackground = [[UIView alloc] initWithFrame:CGRectMake(2, 1,CGRectGetWidth(self.touchView.frame)-4 , kUserBackGroundHeigth)];
        self.headBackground.backgroundColor = RGBA(253, 248, 239, 1.0);
        [self.touchView addSubview:self.headBackground];
        
        
        self.content = [[UILabel alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.touchView.frame)-2*kContentOffX,0)];
        //        self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.content.font = kContentFont;
        self.content.numberOfLines = 0;
        self.content.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);//0xA5A29B
        self.content.backgroundColor = [UIColor clearColor];
        [self.touchView addSubview:self.content];
        
        self.commitBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 4, 25, kButtonHeight)];
        [self.commitBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateHighlighted];
        [self.commitBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.commitBtn.normalImage = [[Env sharedEnv] cacheImage:@"commit_normal.png"];
        self.commitBtn.hilightImage = [[Env sharedEnv] cacheImage:@"commit_select.png"];
        [self.commitBtn addTarget:self action:@selector(commitDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:self.commitBtn];
        
        self.userControl = [[FTSCellUserControl alloc] initWithFrame:CGRectMake(2, kUserOffY, CGRectGetWidth(self.touchView.frame)-CGRectGetWidth(self.commitBtn.frame)-70, kUserHeight)];
        [self.userControl addTarget:self action:@selector(userInfoTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.headBackground addSubview:self.userControl];
        
        self.upBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, 25, kButtonHeight)];
        [self.upBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.upBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_ding_normal.png"];
        self.upBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_ding_select.png"];
        self.upBtn.normalColor =  HexRGB(0xA5A29B);
        self.upBtn.hilightColor =  HexRGB(0xFF5858);
        [self.upBtn addTarget:self action:@selector(upDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:self.upBtn];
        
//        self.downBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(40, 0, 25, kButtonHeight)];
//        [self.downBtn addTarget:self action:@selector(downDetail:) forControlEvents:UIControlEventTouchUpInside];
//        [self.downBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
//        [self.downBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
//        self.downBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_cai_normal.png"];
//        self.downBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_cai_hilight.png"];
//        self.downBtn.normalColor =  HexRGB(0xA5A29B);
//        self.downBtn.hilightColor =  HexRGB(0xFF5858);
//        [self.touchView addSubview:self.downBtn];
        
        self.favBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateHighlighted];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.favBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_collect_select.png"];
        self.favBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_collect_nomal.png"];
        [self.favBtn addTarget:self action:@selector(favoriteDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:self.favBtn];
        
        self.shareBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
        [self.shareBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.shareBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateHighlighted];
        [self.shareBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.shareBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_share_select.png"];
        self.shareBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_share_nomal.png"];
        [self.shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.shareBtn addTarget:self action:@selector(shareDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:self.shareBtn];
        
        self.addImg = [[UILabel alloc] initWithFrame:CGRectZero];
        self.addImg.backgroundColor = [UIColor clearColor];
        self.addImg.font = [UIFont systemFontOfSize:22.0f];
        self.addImg.textAlignment = UITextAlignmentCenter;
        self.addImg.alpha = 0.0f;
        [self.touchView addSubview:self.addImg];
        
        
        
    }
    return self;
}


#pragma mark
#pragma mark Button method

- (void)touchUp:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(wordsTableCell:selectIndexPath:)]) {
        
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        
        BqsLog(@"wordsTableCell select indexpath:%@",path);
        [_delegate wordsTableCell:self selectIndexPath:path];
    }
    
}


- (void)commitDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(wordsTableCell:commitIndexPath:)]) {
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        BqsLog(@"wordsTableCell commit indexpath:%@",path);
        [_delegate wordsTableCell:self commitIndexPath:path];
    }
    
}

- (void)userInfoTouch:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(wordsTableCell:userInfoIndexPath:)]) {
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        BqsLog(@"wordsTableCell userInfo indexpath:%@",path);
        [_delegate wordsTableCell:self userInfoIndexPath:path];
    }
    
}


- (void)upDetail:(id)sender{
    
    if (self.upBtn.buttonSelected) {
        
        return ;
    }

    
//    if (self.upBtn.buttonSelected || self.downBtn.buttonSelected) {
//        
//        return ;
//    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wordsTableCell:upIndexPath:)]) {
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        BqsLog(@"wordsTableCell up indexpath:%@",path);
        [_delegate wordsTableCell:self upIndexPath:path];
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
                self.addImg.alpha = 0.7f;
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

    
    if (_delegate && [_delegate respondsToSelector:@selector(wordsTableCell:downIndexPath:)]) {
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        BqsLog(@"wordsTableCell down indexpath:%@",path);
        [_delegate wordsTableCell:self downIndexPath:path];
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
                self.addImg.alpha = 0.7f;
            } completion:^(BOOL finished){
                self.addImg.alpha = 0.0f;
                [self.downBtn calculateWidth:[NSString stringWithFormat:@"-%d",_words.down]];
                [self refreshRecordState];
            }];
            
        }];
    });
    
    
    
}



- (void)favoriteDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(wordsTableCell:favIndexPath:addType:)]) {
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        BOOL value = !self.favBtn.buttonSelected;
        BqsLog(@"wordsTableCell favorite indexpath:%@ addType:%d",path,value);
        [_delegate wordsTableCell:self favIndexPath:path addType:value];
    }
    
}


- (void)shareDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(wordsTableCell:shareIndexPath:)]) {
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        BqsLog(@"wordsTableCell share indexpath:%@",path);
        [_delegate wordsTableCell:self shareIndexPath:path];
    }
    
}

#pragma mark
#pragma mark config cell


- (void)configCellForWords:(Words *)word{
    
    if (_words == word) {
       
        return;
    }
    
    
    _words = word;
    CGFloat height = kImageOffY;
    if (word.user == nil) {
        self.headBackground.hidden = YES;
//        self.userControl.hidden = TRUE;
    }else{
        self.headBackground.hidden = NO;
        self.userControl.user = word.user;
        self.userControl.frame = CGRectMake(2, kUserOffY-4, CGRectGetWidth(self.touchView.frame)-CGRectGetWidth(self.commitBtn.frame)-80, kUserHeight);
        height += CGRectGetHeight(self.headBackground.frame);
        height += kUserContentPaddY;
    }
    
    CGSize size = [word.content sizeWithFont:self.content.font constrainedToSize:CGSizeMake(self.content.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = self.content.frame;
    frame.size.height = size.height;
    frame.origin.y = height;
    self.content.frame = frame;
    self.content.text = word.content;
    
    height += CGRectGetHeight(self.content.frame)+kContentButtonPaddY;
    
    [self.upBtn calculateWidth:[NSString stringWithFormat:@"%d",word.up]];
    frame = self.upBtn.frame;
    frame.origin.y = height;
    frame.origin.x = 8;
    self.upBtn.frame = frame;
    
//    [self.downBtn calculateWidth:[NSString stringWithFormat:@"-%d",word.down]];
//    frame = self.downBtn.frame;
//    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
//    frame.origin.x = CGRectGetMaxX(self.upBtn.frame)+kButtonsPaddY;
//    self.downBtn.frame = frame;
    [self.commitBtn calculateWidth:[NSString stringWithFormat:@"%d",word.commentsCount]];
    frame = self.commitBtn.frame;
    frame.origin.x = CGRectGetMaxX(self.upBtn.frame)+kButtonsPaddY;;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    self.commitBtn.frame = frame;
    
    
    frame = self.shareBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    frame.origin.x = CGRectGetWidth(self.touchView.bounds) - CGRectGetWidth(self.shareBtn.frame)-20;;
    self.shareBtn.frame = frame;
    
    frame = self.favBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    frame.origin.x = CGRectGetMinX(self.shareBtn.frame)-CGRectGetWidth(self.favBtn.frame)-kButtonsPaddY;
    self.favBtn.frame = frame;
    
    height += (kButtonPaddY+CGRectGetHeight(self.upBtn.frame));
    
    
    frame = self.touchView.frame;
    frame.size.height = height;
    self.touchView.frame = frame;
    
    height += kImageOffX+kButtonPaddY + kTouchButtomY;
    
    frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    [self refreshRecordState];
    
    [self setNeedsLayout];
    
}


-(void)refreshRecordState{
    
    FTSRecord *record= [FTSDatabaseMgr judgeRecordWords:_words managedObjectContext:self.managedObjectContext];
    if (record) {
        
        if ([record.updown intValue] == iJokeUpDownUp) {
//            self.upBtn.enabled = FALSE;
            self.upBtn.buttonSelected = YES;
//            self.downBtn.enabled = FALSE;
//            self.downBtn.buttonSelected = FALSE;
        }else if ([record.updown intValue] == iJokeUpDownDown){
//            self.upBtn.enabled = FALSE;
            self.upBtn.buttonSelected = FALSE;
//            self.downBtn.enabled = FALSE;
//            self.downBtn.buttonSelected = TRUE;
        }else{
//            self.upBtn.enabled = TRUE;
            self.upBtn.buttonSelected = FALSE;
//            self.downBtn.enabled = TRUE;
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
//        self.upBtn.enabled = TRUE;
//        self.downBtn.enabled = TRUE;
        self.favBtn.buttonSelected = FALSE;
    }
    
    
    
}





+(float)caculateHeighForWords:(Words *)word{
    
    CGFloat height = kImageOffY;
    if (word.user != nil) {
        height += kUserContentPaddY+kUserBackGroundHeigth;
    }
    
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]) - 2*kImageOffX - 2*kContentOffX;
    CGSize size = [word.content sizeWithFont:kContentFont constrainedToSize:CGSizeMake(width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    return height+size.height+kContentButtonPaddY+kButtonHeight+2*kButtonPaddY+kTouchButtomY;
    
}


@end
