//
//  FTSImageDetailHeadView.m
//  iJoke
//
//  Created by Kyle on 13-9-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSImageDetailHeadView.h"
#import "Record.h"
#import "FTSDataMgr.h"

#define kTagBegin 100

#define kBackgroundOffY 5

#define kHeadBackgroundOffX 2
#define kHeadBackgroundOffY 1
#define kHeadBackgroundHeight 45

#define kImageOffX 5
#define kImageOffY 2

#define kUserOffY 5
#define kUserHeight 30

#define kUserContentPaddY 10

#define kContentOffX 10

#define kContentOffY 10

#define kContentImagePaddY 6
#define kImageBUttonPaddY 15

#define kImagesOffY 10

#define kButtonHeight 28
#define kButtonWidth 30
#define kButtonPaddY 20
#define kButtonsPaddY 10

#define kImageExtern 20
#define kButtomExterHeight 10

#define kAddBigDuration 0.6
#define kAddSmaDuration 0.3


#define kHeadFont [UIFont systemFontOfSize:16.0f]

@interface FTSImageDetailHeadView()<UIGestureRecognizerDelegate,ImageCellImageViewDelegate>

@property (nonatomic, strong, readwrite) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *headBackground;
@property (nonatomic, strong, readwrite) FTSCellUserControl *userControl;
@property (nonatomic, strong, readwrite) NSMutableArray *contentViews;
@property (nonatomic, strong, readwrite) NSMutableArray *imageViews;
@property (nonatomic, strong, readwrite) JKIconTextButton *upBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *downBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *shareBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *favBtn;
@property (nonatomic, strong) UILabel *addImg;

@property (nonatomic, strong, readwrite) Image *image;

@end


@implementation FTSImageDetailHeadView
@synthesize image = _image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentViews = [NSMutableArray arrayWithCapacity:5];
        self.imageViews = [NSMutableArray arrayWithCapacity:5];
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageOffX, kBackgroundOffY, CGRectGetWidth(self.bounds)-2*kImageOffX, CGRectGetHeight(self.bounds)- 4*kImageOffY)];
        //        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self.backgroundImageView setImage:[[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
        self.backgroundImageView.userInteractionEnabled = TRUE;
        [self addSubview:self.backgroundImageView];
        
        self.headBackground = [[UIView alloc] initWithFrame:CGRectMake(kHeadBackgroundOffX, kHeadBackgroundOffY,CGRectGetWidth(self.backgroundImageView.frame)-2*kHeadBackgroundOffX , kHeadBackgroundHeight)];
        self.headBackground.backgroundColor = RGBA(253, 248, 239, 1.0);
        [self.backgroundImageView addSubview:self.headBackground];
        
        self.userControl = [[FTSCellUserControl alloc] initWithFrame:CGRectMake(2, kUserOffY, CGRectGetWidth(self.bounds)-10, kUserHeight)];
        [self.userControl addTarget:self action:@selector(userInfoTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundImageView addSubview:self.userControl];
        
        self.upBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, 25, kButtonHeight)];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.upBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_ding_normal.png"];
        self.upBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_ding_select.png"];
        self.upBtn.normalColor =  HexRGB(0xA5A29B);
        self.upBtn.hilightColor =  HexRGB(0xFF5858);
        [self.upBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.upBtn addTarget:self action:@selector(upDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundImageView addSubview:self.upBtn];
        
//        self.downBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, 25, kButtonHeight)];
//              [self.downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
        self.addImg.textColor = [UIColor redColor];
        self.addImg.alpha = 0.0f;
        [self.backgroundImageView addSubview:self.addImg];
        
        
    }
    return self;
}

- (void)reloadData{
    
    int num = 0;
    for (Picture *picture in _image.imageArray){
        
        if ([self.imageViews count] <= num) {
            
            BqsLog(@"reloadData [self.imageViews count] :%d, < num", [self.imageViews count],num);
            return;
        }
        
        JKImageCellImageView *imageView = [self.imageViews objectAtIndex:num];
        imageView.imageUrl = picture.picUrl;
        
        num ++;
        
    }
    

}


- (CGFloat)configCellForImage:(Image *)image;{
    
    if (_image == image) return 0;
    _image = image;
    if (_image == nil) {
        BqsLog(@"_image = nil");
        return 0;
    }
    
    
    CGFloat height = kUserOffY;
    
    if (_image.user == nil) {
        self.headBackground.hidden = TRUE;
    }else{
        self.headBackground.hidden = FALSE;
        self.userControl.user = _image.user;
        height += CGRectGetHeight(self.userControl.frame);
    }
    
    CGRect frame;
    
    NSInteger contentNum = -1;
    NSInteger imageNum = -1;
    for (Picture *picture in _image.imageArray) {
        
        if (picture.content != nil && [picture.content length] >0) {
            contentNum++;
            
            UILabel *contentLabel = nil;
            if ([self.contentViews count] > contentNum) {
                contentLabel = [self.contentViews objectAtIndex:contentNum];
            }else{
                contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.backgroundImageView.bounds)-2*kContentOffX,0)];
                //        self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                contentLabel.font = kHeadFont;
                contentLabel.numberOfLines = 0;
                contentLabel.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);
                contentLabel.backgroundColor = [UIColor clearColor];
                [self.backgroundImageView addSubview:contentLabel];
                [self.contentViews addObject:contentLabel];
            }
            
            height += kContentOffY;
            
            CGSize size = [picture.content sizeWithFont:contentLabel.font constrainedToSize:CGSizeMake(contentLabel.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            frame = contentLabel.frame;
            frame.size.height = size.height;
            frame.origin.y = height;
            contentLabel.frame = frame;
            contentLabel.text = picture.content;
            
            
            height += size.height;
            
        }
        
        if (picture.picUrl != nil) {
            imageNum ++;
            JKImageCellImageView *webImage = nil;
            if ([self.imageViews count] > imageNum) {
                webImage = [self.imageViews objectAtIndex:imageNum];
            }else{
                
                webImage = [[JKImageCellImageView alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.backgroundImageView.frame)-2*kContentOffX,0)];
                [self.backgroundImageView addSubview:webImage];
                [self.imageViews addObject:webImage];
                
            }
            webImage.delegate = self;
            webImage.index = imageNum;
            height += kImagesOffY;
            
            frame = webImage.frame;
            frame.origin.y = height;
            if (picture.width < CGRectGetWidth(self.backgroundImageView.frame)-2*kContentOffX) {
                
                frame.origin.x = (CGRectGetWidth(self.backgroundImageView.frame)-2*kContentOffX - picture.width)/2;
                frame.size.width = picture.width;
                frame.size.height = picture.height;
            }else{
                frame.size.width = CGRectGetWidth(self.backgroundImageView.frame)-2*kContentOffX;
                frame.origin.x = kContentOffX;
                frame.size.height = (picture.height * (CGRectGetWidth(self.backgroundImageView.frame)-2*kContentOffX))/picture.width;
            }
            webImage.frame = frame;
            
            height += CGRectGetHeight(frame);
            
        
            webImage.imageUrl = picture.picUrl;
        }
        
    }
    
    while ([self.contentViews count] > contentNum+1) {
        UILabel *contentLabel = [self.contentViews lastObject];
        [contentLabel removeFromSuperview];
        [self.contentViews removeLastObject];
    }
    
    while ([self.imageViews count] > imageNum+1) {
        JKImageCellImageView *webImage = [self.imageViews lastObject];
        [webImage removeFromSuperview];
        [self.imageViews removeLastObject];
    }

    

    
    height += kImageBUttonPaddY;
    
    [self.upBtn calculateWidth:[NSString stringWithFormat:@"%d",image.up]];
    frame = self.upBtn.frame;
    frame.origin.y = height;
    frame.origin.x = kContentOffX;
    self.upBtn.frame = frame;
    
//    [self.downBtn calculateWidth:[NSString stringWithFormat:@"-%d",image.down]];
//    frame = self.downBtn.frame;
//    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
//    frame.origin.x = CGRectGetMaxX(self.upBtn.frame)+kButtonsPaddY;
//    self.downBtn.frame = frame;
    
    frame = self.shareBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    frame.origin.x = CGRectGetWidth(self.backgroundImageView.bounds) - CGRectGetWidth(self.shareBtn.frame)-20;;
    self.shareBtn.frame = frame;
    
    frame = self.favBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    frame.origin.x = CGRectGetMinX(self.shareBtn.frame)-CGRectGetWidth(self.favBtn.frame)-kButtonsPaddY;
    self.favBtn.frame = frame;
    
    [self refreshRecordState];
    
    height += CGRectGetHeight(self.upBtn.frame);
    
    
    height += kImageExtern;
    
    frame = self.backgroundImageView.frame;
    frame.size.height = height;
    frame.origin.y = kBackgroundOffY;
    self.backgroundImageView.frame = frame;
    
    frame = self.headBackground.frame;
    frame.origin.y = -6;
    self.headBackground.frame = frame;
    
    
    return  height+kButtomExterHeight;
    
}

-(void)refreshRecordState{
    
    FTSRecord *record = nil;
    if ([self.delegate respondsToSelector:@selector(imageRecordForeImageDetailHeadViewImage:)]) {
        record = [self.delegate imageRecordForeImageDetailHeadViewImage:_image];
    }
    
    if (record) {
        if (record) {
            
            if ([record.updown intValue] == iJokeUpDownUp) {
                self.upBtn.buttonSelected = YES;
//                self.downBtn.buttonSelected = FALSE;
            }else if ([record.updown intValue] == iJokeUpDownDown){
                self.upBtn.buttonSelected = FALSE;
//                self.downBtn.buttonSelected = TRUE;
            }else{
                self.upBtn.buttonSelected = FALSE;
//                self.downBtn.buttonSelected = FALSE;
            }
            
            if ([record.favorite boolValue]) {
                self.favBtn.buttonSelected = TRUE;
            }else{
                self.favBtn.buttonSelected = FALSE;
            }
            
        }else{
            
            self.upBtn.buttonSelected = FALSE;
//            self.downBtn.buttonSelected = FALSE;
            self.favBtn.buttonSelected = FALSE;
        }
    }
    
    
    
}

#pragma mark
#pragma mark UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Determine if the touch is inside the custom subview
    if ([_delegate respondsToSelector:@selector(subViewShouldReceiveTouch:)]) {
        return [_delegate subViewShouldReceiveTouch:self];
    }
    return YES;
}


#pragma mark
#pragma mark Button method


- (void)ImageCellImageView:(JKImageCellImageView *)cell didTouchIndex:(NSUInteger)index{
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageDetailHeadViewImageTouch:atIndex:)]) {
        BqsLog(@"imageDetailHeadViewImageTouch up at Index:%d",index);
        [_delegate imageDetailHeadViewImageTouch:self atIndex:index];
        
    }
    
}

- (void)userInfoTouch:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(imageDetailHeadViewUserInfo:)]) {
        BqsLog(@"wordsDetailHeadViewUserInfo");
        [_delegate imageDetailHeadViewUserInfo:self];
    }
}


- (void)upDetail:(id)sender{
    
    if (self.upBtn.buttonSelected ) {
        
        return ;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageDetailUpHeadView:)]) {
        BqsLog(@"FTSImageDetailHeadView up ");
        [_delegate imageDetailUpHeadView:self];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addImg.alpha = 0.7f;
        self.addImg.text = @"+1";
        self.addImg.frame = self.upBtn.frame;
        self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        
        _image.up ++;
        
        
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
                [self.upBtn calculateWidth:[NSString stringWithFormat:@"%d",_image.up]];
                [self refreshRecordState];
            }];
            
        }];
    });
    
    
    
    
    
}

- (void)downDetail:(id)sender{
    
    if (self.upBtn.buttonSelected || self.downBtn.buttonSelected) {
        
        return ;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageDetailDownHeadView:)]) {
        BqsLog(@"FTSImageDetailHeadView down");
        [_delegate imageDetailDownHeadView:self];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addImg.alpha = 0.7f;
        self.addImg.text = @"-1";
        self.addImg.frame = self.downBtn.frame;
        self.addImg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        
        _image.down ++;
    
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
                [self.downBtn calculateWidth:[NSString stringWithFormat:@"%d",_image.down]];
            }];
            
        }];
    });
    

    
}



- (void)favoriteDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(imageDetailFavoriteHeadView:addType:)]) {
        BOOL value = !self.favBtn.selected;
        BqsLog(@"FTSImageDetailHeadView favorite addType:%d",value);
        [_delegate imageDetailFavoriteHeadView:self addType:value];
    }
    
}


- (void)shareDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(imageDetailShareHeadView:)]) {
        BqsLog(@"FTSImageDetailHeadView share");
        [_delegate imageDetailShareHeadView:self];
    }
    
}

@end
