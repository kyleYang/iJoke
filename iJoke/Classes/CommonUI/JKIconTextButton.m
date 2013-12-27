//
//  JKIconTextButton.m
//  iJoke
//
//  Created by Kyle on 13-9-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "JKIconTextButton.h"

#define kIconOffX 10
#define kIconOffY 2

#define kIconWidth 13

#define kPaddX 4
#define kTextOffX 5

@interface JKIconTextButton()

@property (nonatomic, strong, readwrite) UIImageView *iconView;
@property (nonatomic, strong, readwrite) UILabel *textLabel;

@end

@implementation JKIconTextButton
@synthesize buttonSelected = _buttonSelected;
@synthesize normalImage = _normalImage;
@synthesize hilightImage = _hilightImage;
@synthesize hilightColor = _hilightColor;
@synthesize normalColor = _normalColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        _buttonSelected = FALSE;
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetHeight(self.bounds)-kIconWidth)/2, (CGRectGetHeight(self.bounds)-kIconWidth)/2, kIconWidth,kIconWidth)];
        [self addSubview:self.iconView];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconView.frame)+kPaddX, CGRectGetMinY(self.bounds), 0,CGRectGetHeight(self.bounds))];
        self.textLabel.font = [UIFont systemFontOfSize:12.0f];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = HexRGB(0xA5A29B);
        [self addSubview:self.textLabel];
    
        
    }
    return self;
}


- (CGFloat)calculateWidth:(NSString *)string{
    
    CGSize size = [string sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(self.textLabel.frame.size.width, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = self.frame;
    CGFloat width  = CGRectGetWidth(self.iconView.frame)+kIconOffX+kPaddX+2*kTextOffX+size.width;
    frame.size.width = width;
    self.frame = frame;
    
    frame = self.textLabel.frame;
    frame.size.width = 2*kTextOffX+size.width;
    self.textLabel.frame = frame;
    
    self.textLabel.text = string;
    
    return width;
}


- (void)setButtonSelected:(BOOL)buttonSelected{
    
    if (_buttonSelected == buttonSelected) return;
    _buttonSelected = buttonSelected;
    self.selected = _buttonSelected;
    
    if (!_buttonSelected) {
        if (_normalImage != nil) {
            self.iconView.image = _normalImage;
        }
        if (_normalColor != nil) {
             self.textLabel.textColor = _normalColor;
        }
       

    }else{
        
        if (_hilightImage != nil) {
            self.iconView.image = _hilightImage;
        }
        
        if (_hilightColor != nil) {
            self.textLabel.textColor = _hilightColor;
        }
        
    }
    
    
}


- (void)setNormalImage:(UIImage *)normalImage{
    if(normalImage == _normalImage) return;
    
    _normalImage = normalImage;
    if (!_buttonSelected && _normalImage != nil) {
        self.iconView.image = _normalImage;
    }
    
    
}

- (void)setHilightImage:(UIImage *)hilightImage{
    
    if (hilightImage == _hilightImage) return;
    
    _hilightImage =hilightImage;
    if (_buttonSelected && _hilightImage != nil) {
        self.iconView.image = _hilightImage;
    }
    
}

- (void)setNormalColor:(UIColor *)normalColor{
    if (normalColor == _normalColor) {
        return;
    }
    
    _normalColor = normalColor;
    if (!_buttonSelected && _normalColor != nil) {
        self.textLabel.textColor = _normalColor;
    }
    
}

- (void)setHilightColor:(UIColor *)hilightColor{
    if (hilightColor == _hilightColor) {
        return;
    }
    
    _hilightColor = hilightColor;
    if (_buttonSelected && _hilightColor != nil) {
        self.textLabel.textColor = _hilightColor;
    }
    
}



@end
