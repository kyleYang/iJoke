//
//  FTSTextField.h
//  iJoke
//
//  Created by Kyle on 13-8-22.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FTSTextFieldDelegate;

@interface FTSTextField : UIView

@property (nonatomic, weak_delegate) id<FTSTextFieldDelegate> delegate;
@property (nonatomic, strong, getter = getText) NSString *text;
@property (nonatomic, strong) UIImage *background;           // default is nil. draw in border rect. image should be stretchable
@property (nonatomic, strong) UIImage *disabledBackground;   // default is nil. ignored if background not set. image should be
@property (nonatomic, strong, readonly) UIImageView *bgImageView;
@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, strong, readonly) UIButton *cleanButton;

@property (nonatomic, assign) BOOL enable;

@end



@protocol FTSTextFieldDelegate <NSObject>

@optional

-(BOOL)textFieldShouldReturn:(FTSTextField *)textField;
-(void)textFieldDidBeginEditing:(FTSTextField *)textField;



@end
