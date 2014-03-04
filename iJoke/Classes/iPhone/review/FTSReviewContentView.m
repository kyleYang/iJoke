//
//  FTSReviewContentView.m
//  iJoke
//
//  Created by Kyle on 13-11-5.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSReviewContentView.h"
#import "FTSDataMgr.h"
#import "Record.h"
#import "JKImageCellImageView.h"

#define kBackgroundOffY 5

#define kHeadBackgroundOffX 2
#define kHeadBackgroundOffY 1
#define kHeadBackgroundHeight 45

#define kImageOffX 5
#define kImageOffY 2

#define kUserOffY 5
#define kUserHeight 30

#define kUserContentPaddY 10

#define kContentOffX 5

#define kContentOffY 10

#define kContentImagePaddY 6
#define kImageBUttonPaddY 6

#define kImagesOffY 10

#define kButtonHeight 25
#define kButtonPaddY 20
#define kButtonsPaddY 8

#define kImageExtern 20
#define kButtomExterHeight 10

#define kAddBigDuration 0.6
#define kAddSmaDuration 0.3

#define kHeadFont [UIFont systemFontOfSize:15.0f]

@interface FTSReviewContentView()<ImageCellImageViewDelegate>{
    
    Words *_words;
    Image *_image;
}

@property (nonatomic, strong, readwrite) NSMutableArray *contentViews;
@property (nonatomic, strong, readwrite) NSMutableArray *imageViews;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *headBackground;

@property (nonatomic, strong, readwrite) UIButton *touchView;
@property (nonatomic, strong, readwrite) FTSCellUserControl *userControl;
@property (nonatomic, strong, readwrite) Words *words;
@property (nonatomic, strong, readwrite) Image *image;

@end



@implementation FTSReviewContentView
@synthesize delegate = _delegate;
@synthesize image = _image;
@synthesize words = _words;


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
        //        self.headBackground.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self.backgroundImageView addSubview:self.headBackground];
        
        self.userControl = [[FTSCellUserControl alloc] initWithFrame:CGRectMake(2, kUserOffY, CGRectGetWidth(self.bounds)-10, kUserHeight)];
        [self.userControl addTarget:self action:@selector(userInfoTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundImageView addSubview:self.userControl];
        

    
    }
    return self;
}


#pragma mark
#pragma mark Button method





- (void)userInfoTouch:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(reviewContentUserInfoView:)]) {
        BqsLog(@"reviewcContent userInfo");
        [_delegate reviewContentUserInfoView:self];
    }
    
}










#pragma mark
#pragma mark config cell


- (CGFloat)configCellForImage:(Image *)image{
    
    if (_image == image) return 0;
    _image = image;
    if (_image == nil) {
        BqsLog(@"_image = nil");
        return 0;
    }
    
    
    CGFloat height = kUserOffY;
    
    if (_image.user == nil) {
        self.userControl.hidden = TRUE;
        self.headBackground.hidden = YES;
    }else{
        self.userControl.hidden = FALSE;
        self.headBackground.hidden = NO;
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
                contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.bounds)-2*kContentOffX,0)];
                //        self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                contentLabel.font = kHeadFont;
                contentLabel.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);
                contentLabel.numberOfLines = 0;
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


- (CGFloat)configCellForWords:(Words *)word{
    
    if (_words == word) return 0;
    _words = word;
    if (_words == nil) {
        BqsLog(@"_words = nil");
        return 0;
    }
    
    
    CGFloat height = kUserOffY;
    
    if (_words.user == nil) {
        self.userControl.hidden = TRUE;
        self.headBackground.hidden = TRUE;
    }else{
        self.userControl.hidden = FALSE;
        self.headBackground.hidden = FALSE;
        self.userControl.user = _words.user;
        height += CGRectGetHeight(self.userControl.frame);
    }
    
    CGRect frame;
        
    UILabel *contentLabel = nil;
    if ([self.contentViews count] != 0) {
         contentLabel = [self.contentViews objectAtIndex:0];
    }else{
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.bounds)-2*kContentOffX,0)];
        //        self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        contentLabel.font = kHeadFont;
        contentLabel.numberOfLines = 0;
        contentLabel.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);
        contentLabel.backgroundColor = [UIColor clearColor];
        [self.backgroundImageView addSubview:contentLabel];
        [self.contentViews addObject:contentLabel];

    }
    
    height += kContentOffY;
    
    CGSize size = [_words.content sizeWithFont:contentLabel.font constrainedToSize:CGSizeMake(contentLabel.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    frame = contentLabel.frame;
    frame.size.height = size.height;
    frame.origin.y = height;
    contentLabel.frame = frame;
    contentLabel.text = _words.content;
    
     height += size.height;
    
    while ([self.contentViews count] > 1) {
        UILabel *contentLabel = [self.contentViews lastObject];
        [contentLabel removeFromSuperview];
        [self.contentViews removeLastObject];
    }
    
    while ([self.imageViews count] > 0) {
        JKImageCellImageView *webImage = [self.imageViews lastObject];
        [webImage removeFromSuperview];
        [self.imageViews removeLastObject];
    }

    height += kImageBUttonPaddY;
    
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




@end
