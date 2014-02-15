//
//  FTSImageTableCell.m
//  iJoke
//
//  Created by Kyle on 13-8-15.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSImageTableCell.h"
#import "Record.h"
#import "FTSDataMgr.h"

#define kImageOffX 8
#define kImageOffY 2

#define kHeadBackgroundHeight 45

#define kUserOffY 9
#define kUserHeight 30

#define kUserContentPaddY 2

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


#define kContentFont [UIFont systemFontOfSize:16.0f]

@interface FTSImageTableCell(){
    Image *_image;
}


@property (nonatomic, strong, readwrite) UIButton *touchView;
@property (nonatomic, strong) UIView *headBackground;
@property (nonatomic, strong, readwrite) FTSCellUserControl *userControl;
@property (nonatomic, strong, readwrite) NSMutableArray *contentViews;
@property (nonatomic, strong, readwrite) NSMutableArray *imageViews;
@property (nonatomic, strong, readwrite) JKIconTextButton *commitBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *upBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *downBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *shareBtn;
@property (nonatomic, strong, readwrite) JKIconTextButton *favBtn;

@property (nonatomic, strong) UILabel *addImg;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) Image *image;


@end

@implementation FTSImageTableCell
@synthesize image = _image;
@synthesize contentViews = _contentViews;
@synthesize imageViews = _imageViews;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentViews = [NSMutableArray arrayWithCapacity:5];
        self.imageViews = [NSMutableArray arrayWithCapacity:5];
        
        self.touchView = [[UIButton alloc] initWithFrame:CGRectMake(kImageOffX, kImageOffY, CGRectGetWidth(self.bounds)-2*kImageOffX, CGRectGetHeight(self.bounds)- 4*kImageOffY)];
        [self.touchView addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.touchView];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_pressed.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
        
        self.headBackground = [[UIView alloc] initWithFrame:CGRectMake(2, 1,CGRectGetWidth(self.touchView.frame)-4 , kHeadBackgroundHeight)];
        self.headBackground.backgroundColor = RGBA(253, 248, 239, 1.0);
        [self.touchView addSubview:self.headBackground];

        
        self.userControl = [[FTSCellUserControl alloc] initWithFrame:CGRectMake(2, kUserOffY, CGRectGetWidth(self.touchView.frame)-CGRectGetWidth(self.commitBtn.frame)-80, kUserHeight)];
        [self.userControl addTarget:self action:@selector(userInfoTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.headBackground addSubview:self.userControl];
        
        
        self.commitBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 4, 25, kButtonHeight)];
        [self.commitBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateHighlighted];
        [self.commitBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.commitBtn.normalImage = [[Env sharedEnv] cacheImage:@"commit_normal.png"];
        self.commitBtn.hilightImage = [[Env sharedEnv] cacheImage:@"commit_select.png"];
        [self.commitBtn addTarget:self action:@selector(commitDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:self.commitBtn];
        
        
        self.upBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(0, 0, 25, kButtonHeight)];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.upBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.upBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_ding_normal.png"];
        self.upBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_ding_select.png"];
        self.upBtn.normalColor =  HexRGB(0xA5A29B);
        self.upBtn.hilightColor =  HexRGB(0xFF5858);
        [self.upBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.upBtn addTarget:self action:@selector(upDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:self.upBtn];
        
//        self.downBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(40, 0, 25, kButtonHeight)];
//        [self.downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.downBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
//        [self.downBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
//        self.downBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_cai_normal.png"];
//        self.downBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_cai_hilight.png"];
//        self.downBtn.normalColor =  HexRGB(0xA5A29B);
//        self.downBtn.hilightColor =  HexRGB(0xFF5858);
//        [self.downBtn addTarget:self action:@selector(downDetail:) forControlEvents:UIControlEventTouchUpInside];
//        [self.touchView addSubview:self.downBtn];
        
        self.favBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(40, 0, kButtonWidht, kButtonHeight)];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateHighlighted];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_select_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateSelected];
        [self.favBtn setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"action_normal_background.png" WithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) ] forState:UIControlStateNormal];
        self.favBtn.hilightImage = [[Env sharedEnv] cacheImage:@"action_collect_select.png"];
        self.favBtn.normalImage = [[Env sharedEnv] cacheImage:@"action_collect_nomal.png"];
        [self.favBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.favBtn addTarget:self action:@selector(favoriteDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.touchView addSubview:self.favBtn];
        
        
        self.shareBtn = [[JKIconTextButton alloc] initWithFrame:CGRectMake(40, 0, kButtonWidht, kButtonHeight)];
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

- (void)touchUp:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:selectIndexPath:)]) {
       
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }

        
        BqsLog(@"FTSImageTableCell select indexpath:%@",path);
        [_delegate imageTableCell:self selectIndexPath:path];
    }
    
}

- (void)imageViewPan:(UIPanGestureRecognizer *)gesture{
    
    NSIndexPath *index = nil;
    if(DeviceSystemMajorVersion() >=7){
        index = [(UITableView *)self.superview.superview indexPathForCell:self];
    }else{
        index = [(UITableView *)self.superview indexPathForCell:self];
    }

    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:touchImageIndex:)]) {
        [_delegate imageTableCell:self touchImageIndex:index];
        BqsLog(@"imageTableCell touchImageIndex:%@",index);
    }
    
}

- (void)userInfoTouch:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:userInfoIndexPath:)]) {
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        BqsLog(@"wordsTableCell userInfo indexpath:%@",path);
        [_delegate imageTableCell:self userInfoIndexPath:path];
    }
    
}




- (void)commitDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:commitIndexPath:)]) {
       
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }

        BqsLog(@"FTSImageTableCell commit indexpath:%@",path);
        [_delegate imageTableCell:self commitIndexPath:path];
    }
    
}


- (void)upDetail:(id)sender{
    
    if (self.upBtn.buttonSelected ) {
        
        return ;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:upIndexPath:)]) {
       
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }

        BqsLog(@"FTSImageTableCell up indexpath:%@",path);
        [_delegate imageTableCell:self upIndexPath:path];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addImg.alpha = 0.7f;
        self.addImg.text = @"+1";
        self.addImg.textColor = [UIColor redColor];
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
                self.addImg.alpha = 0.7f;
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
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:downIndexPath:)]) {
        
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }

        BqsLog(@"FTSImageTableCell down indexpath:%@",path);
        [_delegate imageTableCell:self downIndexPath:path];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.addImg.alpha = 0.7f;
        self.addImg.text = @"-1";
        self.addImg.textColor = [UIColor blueColor];
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
                self.addImg.alpha = 0.7f;
            } completion:^(BOOL finished){
                self.addImg.alpha = 0.0f;
                
                [self.downBtn calculateWidth:[NSString stringWithFormat:@"-%d",_image.down]];
                [self refreshRecordState];
                
            }];
            
        }];
    });
    
    
    
}



- (void)favoriteDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:favIndexPath:addType:)]) {
        
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }

        BOOL value = !self.favBtn.selected;
        BqsLog(@"FTSImageTableCell favorite indexpath:%@ addType:%d",path,value);
        [_delegate imageTableCell:self favIndexPath:path addType:value];
    }
    
}


- (void)shareDetail:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:shareIndexPath:)]) {
        
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }

        BqsLog(@"FTSImageTableCell share indexpath:%@",path);
        [_delegate imageTableCell:self shareIndexPath:path];
    }
    
}



- (void)configCellForImage:(Image *)image{
    
    if (_image == image) {
        return;
    }
    
    _image = image;
    
    CGFloat height = kImageOffY;
    
    if (image.user == nil) {
        self.headBackground.hidden = YES;
        
    }else{
        self.headBackground.hidden = FALSE;
        self.userControl.user = image.user;
        self.userControl.frame = CGRectMake(2, kUserOffY-4, CGRectGetWidth(self.touchView.frame)-CGRectGetWidth(self.commitBtn.frame)-80, kUserHeight);
        height += kHeadBackgroundHeight;
        height += kUserContentPaddY;
    }
    
    CGRect frame = CGRectZero;

    
    NSInteger contentNum = -1;
    NSInteger imageNum = -1;
    for (Picture *picture in image.imageArray) {
        
        if (picture.content != nil && [picture.content length] >0) {
            contentNum++;
            
            UILabel *contentLabel = nil;
            if ([self.contentViews count] > contentNum) {
                contentLabel = [self.contentViews objectAtIndex:contentNum];
            }else{
                contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.touchView.frame)-2*kContentOffX,0)];
                //        self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                contentLabel.font = kContentFont;
                contentLabel.numberOfLines = 0;
                contentLabel.textColor = RGBA(97.0f, 97.0f, 97.0f, 1.0);
                contentLabel.backgroundColor = [UIColor clearColor];
                [self.touchView addSubview:contentLabel];
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
                
                webImage = [[JKImageCellImageView alloc] initWithFrame:CGRectMake(kContentOffX, 0, CGRectGetWidth(self.touchView.frame)-2*kContentOffX,0)];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPan:)];
                [webImage addGestureRecognizer:tap];
                [self.touchView addSubview:webImage];
                [self.imageViews addObject:webImage];
                
            }
            webImage.index = imageNum;
            height += kImagesOffY;
            
            frame = webImage.frame;
            frame.origin.y = height;
            if (picture.width < CGRectGetWidth(self.touchView.frame)-2*kContentOffX) {
                
                frame.origin.x = (CGRectGetWidth(self.touchView.frame)-2*kContentOffX - picture.width)/2;
                frame.size.width = picture.width;
                frame.size.height = picture.height;
            }else{
                frame.size.width = CGRectGetWidth(self.touchView.frame)-2*kContentOffX;
                frame.origin.x = kContentOffX;
                frame.size.height = (picture.height * (CGRectGetWidth(self.touchView.frame)-2*kContentOffX))/picture.width;
            }
            webImage.frame = frame;
            
            height += CGRectGetHeight(frame);
            
            
            _url = picture.picUrl;
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
    frame.origin.x = 10;
    self.upBtn.frame = frame;
    
    [self.commitBtn calculateWidth:[NSString stringWithFormat:@"%d",_image.commentsCount]];
    frame = self.commitBtn.frame;
    frame.origin.x = CGRectGetMaxX(self.upBtn.frame)+kButtonsPaddY;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    self.commitBtn.frame = frame;
    
//    [self.downBtn calculateWidth:[NSString stringWithFormat:@"-%d",image.down]];
//    frame = self.downBtn.frame;
//    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
//    frame.origin.x = CGRectGetMaxX(self.upBtn.frame)+kButtonsPaddY;
//    self.downBtn.frame = frame;
    
    frame = self.shareBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    frame.origin.x = CGRectGetWidth(self.touchView.bounds) - CGRectGetWidth(self.shareBtn.frame)-15;
    self.shareBtn.frame = frame;
    
    frame = self.favBtn.frame;
    frame.origin.y = CGRectGetMinY(self.upBtn.frame);
    frame.origin.x = CGRectGetMinX(self.shareBtn.frame)-CGRectGetWidth(self.favBtn.frame)-kButtonsPaddY;
    self.favBtn.frame = frame;
    
    height += CGRectGetHeight(self.upBtn.frame)+15;
    
    
    frame = self.touchView.frame;
    frame.size.height = height;
    self.touchView.frame = frame;
    
    [self refreshRecordState];
    
    frame = self.frame;
    frame.size.height = height+kImageOffX+kButtonPaddY+kTouchButtomY;
    self.frame = frame;
    [self setNeedsLayout];
    
    
    
}


- (void)refreshRecordState{
    FTSRecord *record = nil;
    if ([self.delegate respondsToSelector:@selector(imageRecordFroImageTableCellImage:)]) {
        record = [self.delegate imageRecordFroImageTableCellImage:_image];
    }else{
        return;
    }
    
    
    if (record != nil) {
        
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



+(float)caculateHeighForImage:(Image *)image{
    
    CGFloat height = kImageOffY;
    
    if (image.user != nil) {
        height += kHeadBackgroundHeight + kUserContentPaddY;
    }
    
    
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]) - 2*kImageOffX - 2*kContentOffX;
    
    for (Picture *picture in image.imageArray) {
        if (picture.content != nil && [picture.content length] >0) {
             CGSize size = [picture.content sizeWithFont:kContentFont constrainedToSize:CGSizeMake(width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            height += kContentOffY;
            height += size.height;
        }
        
        if (picture.picUrl != nil) {
            
            CGFloat imageHeih = 0.0f;
            
            if (picture.width < width) {
                imageHeih = picture.height;
            }else{
                imageHeih = (picture.height * width)/picture.width;
            }
            
            height += kImagesOffY;
            height += imageHeih;
    
        }
        
        
    }

    
    height += kImageOffY + kImageBUttonPaddY + kButtonHeight + kButtonPaddY + kTouchButtomY;
    
    return height;
    
    
}

@end
