//
//  FTSTextIndicateCell.h
//  iJoke
//
//  Created by Kyle on 13-8-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTSTextIndicateCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *lblLeft;
@property (nonatomic, strong, readonly) UILabel *lblRight;
@property (nonatomic, strong, readonly) UIImageView *imgDisclosure;
@property (nonatomic, assign) float paddingHori;

@end
