//
//  FTSTextField.m
//  iJoke
//
//  Created by Kyle on 13-8-22.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTextField.h"


#define kInputOrgX 10
#define kCleanButWidth 23

@interface FTSTextField()<UITextFieldDelegate>{
    
}

@property (nonatomic, strong, readwrite) UIImageView *bgImageView;
@property (nonatomic, strong, readwrite) UITextField *textField;
@property (nonatomic, strong, readwrite) UIButton *cleanButton;

@end

@implementation FTSTextField
@synthesize enable = _enable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.bgImageView.image = [[Env sharedEnv] cacheScretchableImage:@"joke_input_bg.png" X:10 Y:10];
        self.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.bgImageView];
    
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(kInputOrgX, 0, CGRectGetWidth(frame) - kCleanButWidth - 2*kInputOrgX, CGRectGetHeight(frame))] ;
        self.textField.textAlignment = UITextAlignmentLeft;
        self.textField.delegate = self;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.textField];
        
        _enable = TRUE;
        
        self.cleanButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textField.frame), (CGRectGetHeight(frame) - kCleanButWidth)/2, kCleanButWidth, kCleanButWidth)];
        self.cleanButton.backgroundColor = [UIColor clearColor];
        self.cleanButton.hidden = YES;
        [self.cleanButton setBackgroundImage:[[Env sharedEnv] cacheImage:@"joke_clean_normal.png"] forState:UIControlStateNormal];
        [self.cleanButton setBackgroundImage:[[Env sharedEnv] cacheImage:@"joke_clean_down.png"] forState:UIControlStateHighlighted];
        [self.cleanButton addTarget:self action:@selector(cleanChar:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cleanButton];

       
    }
    return self;
}


- (NSString *)getText{
    
    return _textField.text;
    
}

- (void)setText:(NSString *)text{

    _textField.text = text;
    
}

- (void)setEnable:(BOOL)enable{
    if (_enable == enable) return;
    _enable = enable;
    
    self.textField.enabled = _enable;
    if (_enable) {
        self.bgImageView.image = _background;
    }else{
        self.bgImageView.image = _disabledBackground;
    }
}


- (void)setBackground:(UIImage *)background{
    
    if (_background == background) return;
    
    _background = background;
    

    
}

- (void)setDisabledBackground:(UIImage *)disabledBackground{
    
    if (_disabledBackground == disabledBackground) return;
    
    _disabledBackground = disabledBackground;
        
}


- (void)cleanChar:(id)sender
{
    self.text = nil;
    self.cleanButton.hidden = YES;
}


- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *) sender;
    
    if (!_enable) {
        return;
    }
       
    if (!textField.text || textField.text.length == 0) {
        self.cleanButton.hidden = YES;
    }else{
        self.cleanButton.hidden = NO;
    }
    
}


// 按住下一个时候，获取下一个焦点
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [_delegate textFieldDidBeginEditing:self];
    }
    
    if (!textField.text || textField.text.length == 0) {
        return;
    }
    
    if (!_enable) {
        return;
    }
    
    self.cleanButton.hidden = NO;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    self.cleanButton.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    if([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]){
        
        return [_delegate textFieldShouldReturn:self];
        
    }
    
    return YES;
    
}





@end
