//
//  JkCategoryButton.m
//  iJoke
//
//  Created by Kyle on 13-8-16.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "JkCategoryButton.h"

#define kIconHeight 18
#define kIconWidth 17

@interface JkCategoryButton()

@property (nonatomic, strong, readwrite) UIImageView *icon;
@property (nonatomic, strong, readwrite) UILabel *title;

@end

@implementation JkCategoryButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(40, (CGRectGetHeight(self.bounds)-kIconHeight)/2, kIconWidth, kIconHeight)];
        [self addSubview:self.icon];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.icon.frame)+20, 0, CGRectGetWidth(self.bounds)-CGRectGetMaxX(self.icon.frame)-20, CGRectGetHeight(self.bounds))];
        self.title.backgroundColor = [UIColor clearColor];
        [self addSubview:self.title];
        
    }
    return self;
}



@end
