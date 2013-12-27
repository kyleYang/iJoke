//
//  FTSRelationTableCell.m
//  iJoke
//
//  Created by Kyle on 13-11-24.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSRelationTableCell.h"
#import "JKIconTextButton.h"
#import "NSString+TimeInterval.h"

#define kImageOffX 10
#define kImageOffY 10


#define kUserOffY 10
#define kUserHeight 35


#define kContentOffX 11
#define kContentOffY 5
#define kContentWidth 220
#define kContentHeight 18

#define kContentLabGap 5

#define kTimeLabelHeight 14

#define kButtonHeight 28
#define kButtonPaddY 15
#define kButtonsPaddY 8

#define kTouchButtomY 5

#define kAddBigDuration 0.6
#define kAddSmaDuration 0.3

#define kContentFont [UIFont systemFontOfSize:13.0f]

@interface FTSRelationTableCell()

@property (nonatomic, strong, readwrite) UIButton *touchView;
@property (nonatomic, strong, readwrite) UILabel *content;
@property (nonatomic, strong, readwrite) UILabel *timeLabel;
@property (nonatomic, strong, readwrite) JKIconTextButton *upBtn;


@end


@implementation FTSRelationTableCell
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.touchView = [[UIButton alloc] initWithFrame:CGRectMake(kImageOffX, kImageOffY, CGRectGetWidth(self.bounds)-2*kImageOffX, CGRectGetHeight(self.bounds)- 4*kImageOffY)];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_pressed.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
        [self.touchView addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.touchView];
        
        
        self.content = [[UILabel alloc] initWithFrame:CGRectMake(kContentOffX, kContentOffY, kContentWidth,kContentHeight)];
        //        self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.content.font = kContentFont;
        self.content.textColor = HexRGB(0x666666);
        self.content.backgroundColor = [UIColor clearColor];
        [self.touchView addSubview:self.content];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.content.frame), CGRectGetMaxY(self.content.frame)+kContentLabGap, CGRectGetWidth(self.content.frame), kTimeLabelHeight)];
        self.timeLabel.textColor = HexRGB(0x666666);
        self.timeLabel.font = [UIFont systemFontOfSize:11.0f];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        [self.touchView addSubview:self.timeLabel];
        
    
        self.upBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, 25, kButtonHeight)];
        //        [self.upBtn setBackgroundImage:[UIImage imageNamed:@"detail_toolbar_cai_nor@2x.png"] forState:UIControlStateNormal];
        //        [self.upBtn setBackgroundImage:[UIImage imageNamed:@"detail_toolbar_cai_highLigth@2x.png"] forState:UIControlStateHighlighted];
        [self.upBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.upBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_ding_normal.png"];
        self.upBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_ding_select.png"];
//        [self.upBtn addTarget:self action:@selector(upDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:self.upBtn];

        
    }
    return self;
}


#pragma mark
#pragma mark Button method

- (void)touchUp:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(relationTable:selectIndexPath:)]) {
        
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        
        BqsLog(@"relationTable select indexpath:%@",path);
        [_delegate relationTable:self selectIndexPath:path];
    }
    
}


#pragma mark
#pragma mark config cell


- (void)configCellForVideo:(Video *)video{
    
    [self.upBtn calculateWidth:[NSString stringWithFormat:@"%d",video.up]];
    CGRect frame = self.upBtn.frame;
    frame.origin.x = CGRectGetWidth(self.touchView.bounds) - CGRectGetWidth(frame)-5;
    frame.origin.y = kUserOffY;
    self.upBtn.frame = frame;
    
    frame = self.touchView.frame;
    frame.size.height = kContentOffY+kContentHeight+kContentLabGap+kTimeLabelHeight+kContentOffY;
    self.touchView.frame = frame;
    
    NSString *title = NSLocalizedString(@"videoldetail.tuijian.notilte", nil);
    
    if (video.title != nil && video.title.length > 0) {
        title = video.title;
    }else if(video.summary != nil && video.summary.length > 0){
        title = video.summary;
    }
    
    self.content.text = title;
    self.timeLabel.text = [video.time timeFromatToDay];
    
    frame = self.frame;
    frame.size.height = kImageOffY+kContentOffY+kContentHeight+kContentLabGap+kTimeLabelHeight+kContentOffY+3;
    self.frame = frame;
    
    [self setNeedsLayout];
    
}


+(float)caculateHeighForVideo:(Video *)video{
    
    
    return kImageOffY+kContentOffY+kContentHeight+kContentLabGap+kTimeLabelHeight+kContentOffY+3;
    
}



@end
