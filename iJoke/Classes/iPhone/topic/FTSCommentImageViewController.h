//
//  FTSCommentImageViewController.h
//  iJoke
//
//  Created by Kyle on 13-11-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommentBaseViewController.h"
#import "Image.h"


@interface FTSCommentImageViewController : FTSCommentBaseViewController{
    Image *_image;
}

@property (nonatomic, strong) Image *image;

@end
