//
//  FTSCollectImageCell.m
//  iJoke
//
//  Created by Kyle on 13-12-5.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCollectImageCell.h"
#import "Record.h"
#import "FTSDataMgr.h"

#define kImageOffX 8
#define kImageOffY 2

#define kUserOffY 9
#define kUserHeight 30

#define kUserContentPaddY 10

#define kContentOffY 10
#define kContentOffX 10

#define kContentImagePaddY 6
#define kImagesOffY 10
#define kImagesPaddY 4
#define kImageBUttonPaddY 25

#define kButtonHeight 28
#define kButtonWidht 30
#define kButtonsPaddY 10

#define kTouchButtomY 5

#define kAddBigDuration 0.6
#define kAddSmaDuration 0.3


#define kContentFont [UIFont systemFontOfSize:16.0f]

@interface FTSCollectImageCell(){
    Image *_image;
}


@property (nonatomic, strong, readwrite) UIButton *touchView;
@property (nonatomic, strong) UIView *headBackground;
@property (nonatomic, strong, readwrite) FTSCellUserControl *userControl;
@property (nonatomic, strong, readwrite) NSMutableArray *contentViews;
@property (nonatomic, strong, readwrite) NSMutableArray *imageViews;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) Image *image;


@end

@implementation FTSCollectImageCell
@synthesize image = _image;
@synthesize contentViews = _contentViews;
@synthesize imageViews = _imageViews;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        self.multipleTouchEnabled = YES;
        
        self.contentViews = [NSMutableArray arrayWithCapacity:5];
        self.imageViews = [NSMutableArray arrayWithCapacity:5];
        
        self.touchView = [[UIButton alloc] initWithFrame:CGRectMake(kImageOffX, kImageOffY, CGRectGetWidth(self.bounds)-2*kImageOffX, CGRectGetHeight(self.bounds)- 4*kImageOffY)];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
        [self.touchView setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_pressed.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
        [self.touchView addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.touchView];
        
        self.headBackground = [[UIView alloc] initWithFrame:CGRectMake(2, 1,CGRectGetWidth(self.touchView.frame)-4 , 45)];
        self.headBackground.backgroundColor = RGBA(253, 248, 239, 1.0);
        [self.touchView addSubview:self.headBackground];
        
        self.userControl = [[FTSCellUserControl alloc] initWithFrame:CGRectMake(2, kUserOffY, CGRectGetWidth(self.touchView.frame)-80, kUserHeight)];
//        [self.userControl addTarget:self action:@selector(userInfoTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self.headBackground addSubview:self.userControl];
    
        
    }
    return self;
}




- (void)imageViewPan:(UIPanGestureRecognizer *)gesture{
    
    NSIndexPath *index = nil;
    if(DeviceSystemMajorVersion() >=7){
        index = [(UITableView *)self.superview.superview indexPathForCell:self];
    }else{
        index = [(UITableView *)self.superview indexPathForCell:self];
    }
    
//    if (_delegate && [_delegate respondsToSelector:@selector(imageTableCell:touchImageIndex:)]) {
//        [_delegate imageTableCell:self touchImageIndex:index];
//        BqsLog(@"imageTableCell touchImageIndex:%@",index);
//    }
    
}

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
    if (_delegate && [_delegate respondsToSelector:@selector(collectImageCell:shareIndexPath:)]) {
        
        NSIndexPath *path = nil;
        if(DeviceSystemMajorVersion() >=7){
            path = [(UITableView *)self.superview.superview indexPathForCell:self];
        }else{
            path = [(UITableView *)self.superview indexPathForCell:self];
        }
        
        BqsLog(@"FTSImageTableCell share indexpath:%@",path);
        [_delegate collectImageCell:self shareIndexPath:path];
    }
    
}



- (void)configCellForImage:(Image *)image{
    
    if (_image == image) {
        BqsLog(@"configCellForImage _image == image");
        return;
    }
    
    _image = image;
    
    CGFloat height = kUserOffY+kImageOffY;
    

    if (image.user == nil) {
        self.headBackground.hidden = TRUE;
    }else{
        self.headBackground.hidden = FALSE;
        self.userControl.user = image.user;
        self.userControl.frame = CGRectMake(2, kUserOffY-4, CGRectGetWidth(self.touchView.frame)-80, kUserHeight);
        height +=CGRectGetHeight(self.userControl.frame);
        height +=kUserContentPaddY;

    }
    
    CGRect frame;
    
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
//                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPan:)];
//                [webImage addGestureRecognizer:tap];
                [self.touchView addSubview:webImage];
                [self.imageViews addObject:webImage];
                
            }
            
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
    
    frame = self.touchView.frame;
    frame.size.height = height;
    self.touchView.frame = frame;
    
    height += kImageOffX+kTouchButtomY;
    
    frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    [self setNeedsLayout];
    
    
    
}




+(float)caculateHeighForImage:(Image *)image{
    
    CGFloat height = kUserOffY+kImageOffY;
    if (image.user == nil) {
        
    }else{
        
        height +=kUserHeight;
        height +=kUserContentPaddY;
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
    
    
    height += kImageBUttonPaddY + kImageOffX+kTouchButtomY;
    
    return height;
    
    
}

@end
