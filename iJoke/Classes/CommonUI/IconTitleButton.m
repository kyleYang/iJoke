//
//  IconTitleButton.m
//  iJoke
//
//  Created by Kyle on 13-11-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "IconTitleButton.h"

#define kIconWidth 24
#define kIconHeigh 24

@interface IconTitleButton()

@property (nonatomic, strong, readwrite) UIImageView *iconImageView;
@property (nonatomic, strong, readwrite) UILabel *labelTitle;

@end

@implementation IconTitleButton
@synthesize icon = _icon;
@synthesize title = _title;
@synthesize layoutType = _layoutType;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        _layoutType = IconTitleButtonTypeVertical;
        
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)-kIconWidth)/2, 5, kIconWidth, kIconHeigh)];
        self.iconImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.iconImageView];
        
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.iconImageView.frame), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)- CGRectGetMaxY(self.iconImageView.frame))];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.textColor = [UIColor whiteColor];
        self.labelTitle.font = [UIFont systemFontOfSize:15.0f];
        self.labelTitle.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.labelTitle];
        
        
        
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (_layoutType == IconTitleButtonTypeVertical) {
        
        CGRect frame = self.labelTitle.frame;
        frame.origin.y = CGRectGetMaxY(self.iconImageView.frame);
        self.labelTitle.frame = frame;
        
    }else if(_layoutType == IconTitleButtonTypeHorizontal){
        
        self.iconImageView.frame = CGRectMake(5, (CGRectGetHeight(self.bounds)-kIconHeigh)/2, kIconWidth, kIconHeigh);
        
        CGRect frame = self.labelTitle.frame;
        frame.origin.x = CGRectGetMaxX(self.iconImageView.frame) + 5;
        frame.origin.y = 0;
        frame.size.width = CGRectGetWidth(self.bounds) - frame.origin.x - 5;
        frame.size.height = CGRectGetHeight(self.frame);
        self.labelTitle.frame = frame;

    }
   
    
}


#pragma mark
#pragma mark property

- (void)setIcon:(UIImage *)icon
{
    if (_icon == icon) return;
    _icon = icon;
    self.iconImageView.image = _icon;
    
}

- (void)setTitle:(NSString *)title
{
    if (title == _title) return;
    
    _title = title;
    self.labelTitle.text = _title;
    
}

- (void)setLayoutType:(IconTitleButtonType)layoutType{
    
    if (_layoutType == layoutType) return;
    _layoutType = layoutType;
    
    [self setNeedsLayout];
    
}


@end
