//
//  MptCustomScrollView.m
//  iJoke
//
//  Created by Kyle on 13-8-20.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "MptCustomScrollView.h"

@implementation MptCustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
        if (velocity.x < 0 && self.contentOffset.x>= self.contentSize.width-self.frame.size.width) {
            return NO;
        }else if(velocity.x>0 && self.contentOffset.x<=0){
            return NO;
        }
        
        return YES;
    }
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    return  (touch.view == self);
//}


//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    
//    return self;
//}


@end
