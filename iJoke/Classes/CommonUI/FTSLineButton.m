//
//  FTSLineButton.m
//  iJoke
//
//  Created by Kyle on 13-11-18.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSLineButton.h"

#define kLogoinColor [UIColor colorWithRed:142.0f/255.0f green:124.0f/255.0f blue:100.0f/255.0f alpha:1.0f]

@interface FTSLineButton ()
{
    UILabel *_user;
    UIImageView *_line;
    Env *_env;
}

@end

@implementation FTSLineButton
@synthesize userName = _userName;
@synthesize lineName = _lineName;
@synthesize txtColor = _txtColor;
@synthesize message = _message;
@synthesize txtFont = _txtFont;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _env = [Env sharedEnv];
        
        NSString *samp = NSLocalizedString(@"pangu.logoin.message", nil);
        CGSize size = [samp sizeWithFont:[UIFont systemFontOfSize:13.0f]];
        
        UILabel *user = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, size.height)];
        user.font = [UIFont systemFontOfSize:13.0f];
        user.backgroundColor = [UIColor clearColor];
        user.textColor = kLogoinColor;
        user.textAlignment = UITextAlignmentRight;
        _user = user;
        [self addSubview:user];

        
        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(user.frame.size.width, 0, size.width, size.height)];
        message.font = [UIFont systemFontOfSize:13.0f];
        message.backgroundColor = [UIColor clearColor];
        message.textColor = kLogoinColor;
        _message = message;
        [self addSubview:message];

        
        UIImageView *line = [[UIImageView alloc] initWithImage:[_env cacheImage:@"home_logoin_line.png"]];
        //       line.image = [env cacheScretchableImage:@"home_logo_line.png" X:1 Y:1];
        line.backgroundColor = [UIColor clearColor];
        
        _line = line;
        [self addSubview:line];

        
    }
    return self;
}

- (void)setUserName:(NSString *)user
{
    
    if(_userName == user) return;
    
    _userName = user;
    CGRect frame  = _user.frame;
    if (!_userName|| _userName.length == 0) {
        frame.size.width = 0;
        _user.frame = frame;
        _message.text = NSLocalizedString(@"pangu.logoin.message", nil);
    }else {
        _message.text = NSLocalizedString(@"pangu.logoin.welcome", nil);
        CGSize nameSize = [_message.text sizeWithFont:[_message font]];
        CGRect mFrame = _message.frame;
        mFrame.size = nameSize;
        _message.frame = mFrame;
        
        nameSize = [_userName sizeWithFont:[_user font]];
        if (nameSize.width + _message.frame.size.width > self.frame.size.width ) {
            frame.size.width = self.frame.size.width - _message.frame.size.width;
        }else {
            frame.size.width = nameSize.width;
        }
        _user.frame = frame;
        
        
    }
    _user.text = _userName;
}


- (void)setLineName:(NSString *)_aline
{
    if (_lineName == _aline) return;
    
    _lineName = _aline;
    _line.image = [_env cacheImage:_lineName];
}

- (void)setTxtFont:(UIFont *)aFont
{
    if (_txtFont == aFont) return;
    
    _txtFont = aFont;
    _user.font = _txtFont;
}



- (void)setTxtColor:(UIColor *)_aColor
{
    if (_txtColor == _aColor) return;
    
   
    _txtColor = _aColor;
    _user.textColor = _txtColor;
    
}



- (void)layoutSubviews
{
    CGRect frame = _message.frame;
    frame.origin.x=  _user.frame.size.width;
    
    NSString *samp = _message.text;
    CGSize size = [samp sizeWithFont:[UIFont systemFontOfSize:13.0f]];
    frame.size.width = size.width;
    
    _message.frame =frame;
    
    
    if (_user.frame.size.width == 0) {
        frame = _message.frame;
    }else {
        frame = _user.frame;
    }
    _line.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame)-CGRectGetHeight(_line.frame), CGRectGetWidth(frame), CGRectGetHeight(_line.frame));
}

@end