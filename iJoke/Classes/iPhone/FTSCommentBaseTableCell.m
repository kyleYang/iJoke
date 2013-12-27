//
//  FTSCommentBaseTableCell.m
//  iJoke
//
//  Created by Kyle on 13-8-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommentBaseTableCell.h"
#import "FTSCellUserControl.h"
#import "NSString+TimeInterval.h"

#define kCommentFont [UIFont systemFontOfSize:14.0f]

#define kUserOffX 10
#define kUserOffY 6
#define kUserHeight 30

#define kUserNumberWap 20

#define kNumberWidth 40

#define kUserContentPaddY 15

#define kContenButtomPaddY 15

#define kLabelHeight 15

@interface FTSCommentBaseTableCell(){
    Comment *_comment;
}

@property (nonatomic, strong, readwrite) Comment *comment;
@property (nonatomic, strong, readwrite) UILabel *commentLabel;
@property (nonatomic, strong, readwrite) UILabel *timeLabel;
@property (nonatomic, strong, readwrite) UILabel *numberLabel;
@property (nonatomic, strong, readwrite) FTSCellUserControl *userControl;

@end 

@implementation FTSCommentBaseTableCell
@synthesize delegate = _delegate;
@synthesize comment = _comment;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.userControl = [[FTSCellUserControl alloc] initWithFrame:CGRectMake(kUserOffX, kUserOffY,CGRectGetWidth(self.frame)-2*kUserOffX- kUserNumberWap-kNumberWidth, kUserHeight)];
        self.userControl.nickName.font = [UIFont systemFontOfSize:11.0f];
        [self.userControl addTarget:self action:@selector(userInfoTouch:) forControlEvents:UIControlEventTouchUpInside];
        self.userControl.backgroundColor = [UIColor clearColor];
        [self addSubview:self.userControl];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.userControl.frame), kLabelHeight)];
        self.timeLabel.font = [UIFont systemFontOfSize:10.0f];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = HexRGB(0x9D9D9D);
        [self.userControl addSubview:self.timeLabel];
        
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-kNumberWidth-kUserOffX, CGRectGetMinY(self.userControl.frame), kNumberWidth, kLabelHeight)];
        self.numberLabel.font = [UIFont systemFontOfSize:12.0f];
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.textColor = HexRGB(0x9D9D9D);
        [self addSubview:self.numberLabel];
        
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.userControl.frame), 0, CGRectGetWidth(self.frame)-2*CGRectGetMinX(self.userControl.frame), 0)];
        //        self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.commentLabel.font = kCommentFont;
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = [UIColor clearColor];
        self.commentLabel.textColor = HexRGB(0x9D9D9D);
        [self addSubview:self.commentLabel];
        
        UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.userControl.frame), CGRectGetHeight(self.frame) - 2, CGRectGetWidth(self.frame)-2*CGRectGetMinX(self.userControl.frame), 2)];
        bgImg.image = [[Env sharedEnv] cacheImage:@"square_horizontal_separator.png"];
        bgImg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:bgImg];
        
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configCellForComment:(Comment *)comment{
    
    if (_comment == comment) {
        return;
    }
    
    _comment = comment;
   
    CGFloat height = 0;

    self.userControl.user = _comment.user;
    
//    self.numberLabel.frame =  CGRectMake(CGRectGetWidth(self.bounds)-kNumberWidth-kUserOffX, CGRectGetMinY(self.userControl.frame), kNumberWidth, kLabelHeight);
    
    
    NSString *notice = [_comment.addtime noticeTimeIntervalFromCurrent];
    
    height = CGRectGetMaxY(self.userControl.frame)+kUserContentPaddY;
    CGRect frame = self.userControl.nickName.frame;
    frame.origin.y = 0;
    frame.size.height = 14;
    self.userControl.nickName.frame = frame;
    
    frame = self.timeLabel.frame;
    frame.origin.x = CGRectGetMinX(self.userControl.nickName.frame);
    frame.origin.y = CGRectGetMaxY(self.userControl.nickName.frame)+5;
    frame.size.width = CGRectGetWidth(self.userControl.nickName.frame);
    self.timeLabel.frame = frame;
    self.timeLabel.text = notice;
    
    self.numberLabel.frame =  CGRectMake(CGRectGetWidth(self.bounds)-kNumberWidth-kUserOffX, CGRectGetMinY(self.userControl.frame), kNumberWidth, kLabelHeight);
    
    CGSize size = [_comment.comment sizeWithFont:self.commentLabel.font constrainedToSize:CGSizeMake(self.commentLabel.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    

    frame = self.commentLabel.frame;
    frame.size.height = size.height;
    frame.origin.y = height;
    self.commentLabel.frame = frame;
    self.commentLabel.text = _comment.comment;
    self.commentLabel.frame = frame;
    
    height += (kContenButtomPaddY+CGRectGetHeight(self.commentLabel.frame));
    
    frame = self.frame;
    frame.size.height = height+5;
    self.frame = frame;
    
    [self setNeedsLayout];
}


+(float)caculateHeighForComment:(Comment *)comment{
    
    CGSize size = [comment.comment sizeWithFont:kCommentFont constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height+kUserContentPaddY+kContenButtomPaddY+kUserHeight;
    
}


- (void)userInfoTouch:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(commentTableCellUserInfoAtIndexPath:)]) {
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        BqsLog(@"commentTableCellUserInfoAtIndexPath indexpath:%@",path);
        [_delegate commentTableCellUserInfoAtIndexPath:path];
    }

}

@end
