//
//  BqsNoDrawToolbar.m
//  iMobeeBook
//
//  Created by ellison on 11-7-11.
//  Copyright 2011年 borqs. All rights reserved.
//

#import "BqsNoDrawToolbar.h"
#import "BqsUtils.h"

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif


@implementation BqsNoDrawToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) return nil;
    
    // Initialization code
//    self.clearsContextBeforeDrawing = NO;
    self.barStyle = UIBarStyleDefault;
    [self setBackgroundColor:[UIColor clearColor]];

    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    BqsLog(@"drawRect");
//    // Drawing code
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
//    CGContextFillRect(ctx, rect);
}


- (void)dealloc
{
    [super dealloc];
}

@end
