//
//  FTSCommitTips.m
//  iJoke
//
//  Created by Kyle on 13-8-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommitTipsCell.h"


@interface FTSCommitTipsCell()

@property (nonatomic, strong, readwrite) UILabel *tips;

@end


@implementation FTSCommitTipsCell

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl
{
    self = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (nil == self) return nil;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 200, 200, 80)];
    imageView.image = [[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self addSubview:imageView];
    
    self.tips = [[UILabel alloc] initWithFrame:imageView.bounds];
    self.tips.backgroundColor = [UIColor clearColor];
    self.tips.textAlignment = UITextAlignmentCenter;
    self.tips.textColor =  HexRGB(0xA5A29B);
    [imageView addSubview:self.tips];
    
    return self;
}


@end
