//
//  FTSCollectMessageCell.m
//  iJoke
//
//  Created by Kyle on 13-12-5.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCollectWordsCell.h"
#import "FTSDataMgr.h"
#import "Record.h"

#define kImageOffX 8
#define kImageOffY 5

#define kUserOffY 9
#define kUserHeight 35
#define kUserContentPaddY 10

#define kContentOffX 8
#define kContentButtonPaddY 15

#define kButtonWidth 30
#define kButtonHeight 28
#define kButtonPaddY 0
#define kButtonsPaddY 10

#define kTouchButtomY 5

#define kAddBigDuration 0.6
#define kAddSmaDuration 0.3

#define kContentFont [UIFont systemFontOfSize:16.0f]

@interface FTSCollectWordsCell(){
    
    Words *_words;
}

@property (nonatomic, strong, readwrite) UIButton *touchView;
@property (nonatomic, strong) UIView *headBackground;
@property (nonatomic, strong, readwrite) FTSCellUserControl *userControl;
@property (nonatomic, strong, readwrite) UILabel *content;
@property (nonatomic, strong) UILabel *addImg;
@property (nonatomic, strong) Words *words;

@end


@implementation FTSCollectWordsCell
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
        
        self.headBackground = [[UIView alloc] initWithFrame:CGRectMake(2, 1,CGRectGetWidth(self.touchView.frame)-4 , 45)];
        self.headBackground.backgroundColor = RGBA(253, 248, 239, 1.0);
        [self.touchView addSubview:self.headBackground];
        
        
        self.content = [[UILabel alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.touchView.frame)-2*kContentOffX,0)];
        //        self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.content.font = kContentFont;
        self.content.numberOfLines = 0;
        self.content.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);//0xA5A29B
        self.content.backgroundColor = [UIColor clearColor];
        [self.touchView addSubview:self.content];
        
        self.userControl = [[FTSCellUserControl alloc] initWithFrame:CGRectMake(2, kUserOffY, CGRectGetWidth(self.touchView.frame)-80, kUserHeight)];
//        [self.userControl addTarget:self action:@selector(userInfoTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.headBackground addSubview:self.userControl];
        
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
    if (_delegate && [_delegate respondsToSelector:@selector(collectSelectAtIndexPath:)]) {
        
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        
        BqsLog(@"collectSelectAtIndexPath:%@",path);
        [_delegate collectSelectAtIndexPath:path];
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
        [_delegate collectWordsCell:self shareIndexPath:path];
    }
    
}

#pragma mark
#pragma mark config cell


- (void)configCellForWords:(Words *)word{
    
    if (_words == word) {
        return;
    }
    _words = word;
    
    CGFloat height = kUserOffY+kImageOffY;
    
    if (word.user == nil) {
        self.headBackground.hidden = TRUE;
    }else{
        self.headBackground.hidden = FALSE;
        self.userControl.user = word.user;
        self.userControl.frame = CGRectMake(2, kUserOffY-4, CGRectGetWidth(self.touchView.frame)-80, kUserHeight);
        height +=CGRectGetHeight(self.userControl.frame);
        height +=kUserContentPaddY;
    }
    

    CGSize size = [word.content sizeWithFont:self.content.font constrainedToSize:CGSizeMake(self.content.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = self.content.frame;
    frame.size.height = size.height;
    frame.origin.y = height;
    self.content.frame = frame;
    self.content.text = word.content;
    
    height += CGRectGetHeight(self.content.frame);
    

    
//    frame = self.shareBtn.frame;
//    frame.origin.y = height+kContentButtonPaddY;
//    frame.origin.x = 20;;
//    self.shareBtn.frame = frame;
    
   
    height +=kContentButtonPaddY;
    
    frame = self.touchView.frame;
    frame.size.height = height;
    self.touchView.frame = frame;
    
    height += kImageOffX+kButtonPaddY + kTouchButtomY;
    
    frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
        
    [self setNeedsLayout];
    
}




+(float)caculateHeighForWords:(Words *)word{
    
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]) - 2*kImageOffX - 2*kContentOffX;
    CGSize size = [word.content sizeWithFont:kContentFont constrainedToSize:CGSizeMake(width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height = kUserOffY+kImageOffY;
    if (word.user == nil) {
       
    }else{
        
        height +=kUserHeight;
        height +=kUserContentPaddY;
    }
    height += size.height+kContentButtonPaddY+kImageOffX+kButtonPaddY + kTouchButtomY;
    
    return height;
    
}
@end