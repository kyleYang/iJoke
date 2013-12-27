//
//  FTSImageDetailCell.h
//  iJoke
//
//  Created by Kyle on 13-9-3.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSCommitBaseCell.h"
#import "FTSImageDetailHeadView.h"
#import "Image.h"
#import "FTSMacro.h"


@protocol ImageDetailCellDelegate;

@interface FTSImageDetailCell : FTSCommitBaseCell{
    
    Image *_image;
    id<ImageDetailCellDelegate> __weak_delegate _delegate;
}

@property (nonatomic, strong) Image *image;
@property (nonatomic, strong, readonly) FTSImageDetailHeadView *headView;
@property (nonatomic, weak_delegate) id<ImageDetailCellDelegate> delegate;

@end



@protocol ImageDetailCellDelegate <NSObject>

@optional
- (void)FTSImageDetailCell:(FTSImageDetailCell *)cell popHeadView:(FTSImageDetailHeadView *)head atIndex:(NSUInteger)index;

@end

