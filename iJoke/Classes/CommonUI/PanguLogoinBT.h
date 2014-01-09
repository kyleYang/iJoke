//
//  PanguLogoinBT.h
//  pangu
//
//  Created by yang zhiyun on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PanguLogoinBT : UIButton
{
    UILabel *_message;
    NSString *_userName;
    NSString *_lineName;
    UIColor *_txtColor;
    UIFont *_txtFont;
}

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *lineName;
@property (nonatomic, retain) UIColor *txtColor;
@property (nonatomic ,retain) UILabel *message;
@property (nonatomic, retain) UIFont *txtFont;

@end
