//
//  HMImagePopCell.h
//  iJoke
//
//  Created by Kyle on 13-9-2.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASImageScrollView.h"

@interface HMImagePopCell : UIView{
@private
    NSUInteger _cellTag;
    NSString *_identifier;
}

@property (nonatomic, strong, readonly) ASImageScrollView *imageView;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, assign) CGRect defaultRect;
@property (nonatomic, strong) NSString *defaultUrl;
@property (nonatomic, assign) NSUInteger cellTag;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, weak_delegate) UIViewController *parCtl;


- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl;
- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident;

//shouled be rewite
- (void)viewWillAppear;
- (void)viewDidAppear;

- (void)viewWillDisappear;
- (void)viewDidDisappear;

- (void)mainViewOnFont:(BOOL)value;



@end
