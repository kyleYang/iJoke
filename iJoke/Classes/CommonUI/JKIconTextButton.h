//
//  JKIconTextButton.h
//  iJoke
//
//  Created by Kyle on 13-9-14.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKIconTextButton : UIButton

@property (nonatomic, strong, readonly) UIImageView *iconView;
@property (nonatomic, strong, readonly) UILabel *textLabel;

@property (nonatomic, assign) BOOL buttonSelected;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *hilightImage;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *hilightColor;

- (CGFloat)calculateWidth:(NSString *)string;

@end
