//
//  HoriIconButton.m
//  iJoke
//
//  Created by Kyle on 13-11-13.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "HoriIconButton.h"'


@interface HoriIconButton()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *labelTitle;

@end

@implementation HoriIconButton
@synthesize icon = _icon;
@synthesize title = _title;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
