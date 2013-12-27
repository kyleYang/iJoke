//
//  MptGuideLoadingFooterView.m
//  TVGuide
//
//  Created by ellison on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PgLoadingFooterView.h"
#import "Env.h"

@interface PgLoadingFooterView(){
    UIButton *_activty;
}


@end

@implementation PgLoadingFooterView
@synthesize viewAct;
@synthesize message;
@synthesize state = _state;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) return nil;
    
    self.backgroundColor = [UIColor clearColor];
    
    UIButton *activty = [[UIButton alloc] initWithFrame:self.bounds];
    activty.backgroundColor = [UIColor clearColor];
    [activty setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [activty setBackgroundImage:[[Env sharedEnv] cacheResizableImage:@"square_card_pressed.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
    activty.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [activty addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    _activty = activty;
    
    [self addSubview:activty];
    [activty release];
    
    self.viewAct = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self.viewAct stopAnimating];
    [self addSubview:self.viewAct];
    
    
    self.message = [[[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(frame)-40, 40)] autorelease];
    self.message.backgroundColor = [UIColor clearColor];
    self.message.textAlignment = UITextAlignmentCenter;
    self.message.textColor = [UIColor blackColor];
    self.message.textColor = HexRGB(0xA5A29B);//0xA5A29B
    self.message.font = [UIFont systemFontOfSize:13.0f];
    [self addSubview:self.message];
    
    _state = PgFootRefreshInit;
    
    return self;
}
-(void)dealloc {
    
    self.viewAct = nil;
    self.message = nil;
    _delegate = nil;
    [super dealloc];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.message.frame;
    frame.origin.y = 10;
    self.message.frame = frame;
    
    frame = self.viewAct.frame;
    frame.origin.y = CGRectGetMinY(self.message.frame) + 10;
    frame.origin.x = 70;
    self.viewAct.frame = frame;
    
    _activty.frame = self.message.frame;
}

- (void)loadMore:(id)sender
{
    if(_state == PgFootRefreshLoading||_state == PgFootRefreshAllDown){
        return;
    }
    
    self.state = PgFootRefreshLoading;
    
    if ([_delegate respondsToSelector:@selector(footLoadMore)]) {
        [_delegate footLoadMore];
    }
}

//- (void)setDelegate:(id<pgFootViewDelegate>)adelegate
//{
//    if (_delegate != adelegate) {
//        _delegate = adelegate;
//        if ([_delegate respondsToSelector:@selector(messageTxtForState:)]) {
//            self.message.text = [_delegate messageTxtForState:_state];
//        }
//    }
//}


- (void)setState:(PgFootRefreshState)astate
{
   
    _state = astate;
    if (_state == PgFootRefreshLoading) {
        [self.viewAct startAnimating];
    }else if(_state == PgFootRefreshNormal){
        [self.viewAct stopAnimating];
    }else if(_state == PgFootRefreshAllDown){
        [self.viewAct stopAnimating];
    }
    
    if ([_delegate respondsToSelector:@selector(messageTxtForState:)]) {
        self.message.text = [_delegate messageTxtForState:_state];
    }
}

@end
