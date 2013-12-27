//
//  FTSImageEditViewController.h
//  iJoke
//
//  Created by Kyle on 13-9-22.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUIBarButtonItem.h"


typedef void(^FTSImageEditorDoneCallback)(UIImage *image, BOOL canceled);

@interface FTSImageEditViewController : UIViewController

@property(nonatomic,strong) FTSImageEditorDoneCallback doneCallback;

@property(nonatomic,copy) UIImage *sourceImage;
@property(nonatomic,copy) UIImage *previewImage;
@property(nonatomic,assign) CGSize cropSize;
@property(nonatomic,assign) CGFloat outputWidth;
@property(nonatomic,assign) CGFloat minimumScale;
@property(nonatomic,assign) CGFloat maximumScale;

@property(nonatomic,assign) BOOL checkBounds;

@property(nonatomic,strong) UIBarButtonItem *saveButton;

-(void)reset:(BOOL)animated;

@end
