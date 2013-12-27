//
//  FTSLineButton.h
//  iJoke
//
//  Created by Kyle on 13-11-18.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTSLineButton : UIButton
{
    UILabel *_message;
    NSString *_userName;
    NSString *_lineName;
    UIColor *_txtColor;
    UIFont *_txtFont;
}

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *lineName;
@property (nonatomic, strong) UIColor *txtColor;
@property (nonatomic ,strong) UILabel *message;
@property (nonatomic, strong) UIFont *txtFont;


@end
