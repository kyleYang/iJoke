//
//  FTSBaseFrameView.m
//  iJoke
//
//  Created by Kyle on 13-8-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSBaseFrameView.h"

@interface FTSBaseFrameView()


@property (nonatomic, strong, readwrite) UIView *viewContent;
@property (nonatomic, strong, readwrite) UIImageView *ivBg;


@end

@implementation FTSBaseFrameView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = RGBA(255, 248, 240, 1.0);
        
//        self.viewContent = [[UIView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
//        self.viewContent.backgroundColor = [UIColor clearColor];
//        self.viewContent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [self addSubview:self.viewContent];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
