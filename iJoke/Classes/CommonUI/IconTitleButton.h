//
//  IconTitleButton.h
//  iJoke
//
//  Created by Kyle on 13-11-12.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IconTitleButtonType) {
    IconTitleButtonTypeNone = 0,                         // no button type
    IconTitleButtonTypeHorizontal = 1,
    IconTitleButtonTypeVertical = 2,
};


@interface IconTitleButton : UIButton

@property (nonatomic, strong, readonly) UIImageView *iconImageView;
@property (nonatomic, strong, readonly) UILabel *labelTitle;

@property (nonatomic, assign) IconTitleButtonType layoutType;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString  *title;

@end
