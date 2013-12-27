//
//  FTSLoadingCell.m
//  iJoke
//
//  Created by Kyle on 13-8-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSLoadingCell.h"

#define kLabelWidth 280
#define kLabelHeight 50

@implementation FTSLoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 280, 50)];
        imageView.image = [[Env sharedEnv] cacheResizableImage:@"square_card_bg.png" WithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [self addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.text = NSLocalizedString(@"joke.comment.loading", nil);
        label.textColor =  HexRGB(0xA5A29B);
        [imageView addSubview:label];
        
//        "joke.comment.loading" = "正在加载评论";
//        "joke.comment.empty" = "暂无评论，赶紧抢沙发";
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
