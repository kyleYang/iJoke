//
//  FTSCellUserControl.m
//  iJoke
//
//  Created by Kyle on 13-9-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCellUserControl.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

#define kOffX 5
#define kOffY 4

@interface FTSCellUserControl()

@property (nonatomic, strong, readwrite) FTSCircleImageView *iconView;
@property (nonatomic, strong, readwrite) UILabel *nickName;

@end

@implementation FTSCellUserControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        self.iconView = [[FTSCircleImageView alloc] initWithFrame:CGRectMake( kOffX, kOffY, CGRectGetHeight(self.bounds)-2*kOffY, CGRectGetHeight(self.bounds)-2*kOffY)];
        [self addSubview:self.iconView];
        
        self.nickName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconView.frame)+6, CGRectGetMinY(self.iconView.frame)+2, CGRectGetWidth(self.bounds)-6-CGRectGetMaxX(self.iconView.frame),CGRectGetHeight(self.bounds)-15)];
        self.nickName.font = [UIFont systemFontOfSize:14.0f];
        self.nickName.backgroundColor = [UIColor clearColor];
        self.nickName.textColor = RGBA(104, 125, 200, 1);
        [self addSubview:self.nickName];
        
        
    }
    return self;
}

- (void)setUser:(User *)user{
    
    _user = user;
    
    if (_user == nil) {
        
        self.iconView.imageView.image = [[Env sharedEnv] cacheImage:@"user_defaulthead.png"];
        self.nickName.text = NSLocalizedString(@"joke.commit.anonymous", nil);
        return;
    }
    
    __weak FTSCellUserControl *wself = self;
    
 
    [self.iconView.imageView setImageWithURL:[NSURL URLWithString:_user.icon] placeholderImage:[[Env sharedEnv] cacheImage:@"user_defaulthead.png"] options:SDWebImageLowPriority progress:^(NSUInteger receiveSize, long long excepectedSize){
        
        if (excepectedSize <= -0) {
            return ;
        }
    
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        
       
        wself.iconView.imageView.alpha = 0.0f;
        
        
        [UIView animateWithDuration:0.25 animations:^(void){
            
            wself.iconView.imageView.alpha = 1.0f;
            
        }];
    
        
    }];
    
    self.nickName.text = _user.nikeName;

    
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake( kOffX, kOffY, CGRectGetHeight(self.bounds)-2*kOffY, CGRectGetHeight(self.bounds)-2*kOffY);
    
    self.nickName.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame)+6, CGRectGetMinY(self.iconView.frame)+2, CGRectGetWidth(self.bounds)-6-CGRectGetMaxX(self.iconView.frame),CGRectGetHeight(self.bounds)-15);
}



@end
