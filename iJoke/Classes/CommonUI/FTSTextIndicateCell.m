//
//  FTSTextIndicateCell.m
//  iJoke
//
//  Created by Kyle on 13-8-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTextIndicateCell.h"

@interface FTSTextIndicateCell()

@property (nonatomic, strong, readwrite) UILabel *lblLeft;
@property (nonatomic, strong, readwrite) UILabel *lblRight;
@property (nonatomic, strong, readwrite) UIImageView *imgDisclosure;

@end

@implementation FTSTextIndicateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        float fontSizeLeft = 17;
        float fontSizeRight = 15;
        
        Env *env = [Env sharedEnv];
        
        // create subviews
        self.lblLeft = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblLeft.backgroundColor = [UIColor clearColor];
        self.lblLeft.font = [UIFont systemFontOfSize:fontSizeLeft];
        self.lblLeft.adjustsFontSizeToFitWidth = NO;
        self.lblLeft.textColor = [UIColor blackColor];
        //    self.lblLeft.textColor = [UIColor whiteColor];//RGBA(0x9e, 0x9e, 0x9e, 1);
        [self.contentView addSubview:self.lblLeft];
        
        self.lblRight = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblRight.backgroundColor = [UIColor clearColor];
        self.lblRight.font = [UIFont systemFontOfSize:fontSizeRight];
        self.lblRight.adjustsFontSizeToFitWidth = NO;
        self.lblRight.textColor = [UIColor blackColor];
        //    self.lblRight.textColor = RGBA(0xff, 0xcc, 0x2f, 1);
        [self.contentView addSubview:self.lblRight];
        
        self.imgDisclosure = [[UIImageView alloc] initWithImage:[env cacheImage:@"tablecell_disclosure.png"]];
        self.imgDisclosure.hidden = YES;
        [self.contentView addSubview:self.imgDisclosure];
        
        
        UIImageView *line =  [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 3, self.frame.size.width, 2)];
        line.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        line.image = [[Env sharedEnv] cacheImage:@"dota_line.png"];
        [self addSubview:line];
        
        
        // set background
//        {
//           UIView *bgV = [[UIView alloc]initWithFrame:self.contentView.bounds];
//           bgV.backgroundColor = [UIColor clearColor];
//           self.backgroundView = bgV;
//            //        self.selectedBackgroundView = bgV;
//        }

        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) layoutSubviews {
    [super layoutSubviews];
    
    const float kPaddingHori = 16 + self.paddingHori;
    const float kGapHori = 10;
    
    CGRect rc = self.contentView.bounds;
    rc = CGRectInset(rc, kPaddingHori, 0);
    
    CGSize szLeft = CGSizeMake(0, 0), szRight = CGSizeMake(0, 0), szImg = CGSizeMake(0, 0);
    if(!self.lblLeft.hidden && self.lblLeft.text.length > 0) {
        szLeft = [self.lblLeft.text sizeWithFont:self.lblLeft.font];
    }
    if(!self.lblRight.hidden && self.lblRight.text.length > 0) {
        szRight = [self.lblRight.text sizeWithFont:self.lblRight.font];
    }
    if(!self.imgDisclosure.hidden) {
        szImg = self.imgDisclosure.frame.size;
    }
    
    if(szLeft.width + szRight.width + szImg.width + 2*kGapHori > CGRectGetWidth(rc)) {
        szLeft.width = szRight.width = floor((CGRectGetWidth(rc) - 2*kGapHori - szImg.width) / 2.0);
    }
    
    self.lblLeft.frame = CGRectMake(CGRectGetMinX(rc), floor(CGRectGetMidY(rc)-szLeft.height/2.0), szLeft.width,szLeft.height);
    if(self.imgDisclosure.hidden) {
        self.lblRight.frame = CGRectMake(CGRectGetMaxX(rc)-szRight.width, floor(CGRectGetMidY(rc)-szRight.height/2.0), szRight.width,szRight.height);
    } else {
        self.imgDisclosure.center = CGPointMake(floor(CGRectGetMaxX(rc)-szImg.width/2.0), CGRectGetMidY(rc));
        self.lblRight.frame = CGRectMake(CGRectGetMaxX(rc)-szImg.width-kGapHori-szRight.width, floor(CGRectGetMidY(rc)-szRight.height/2.0), szRight.width,szRight.height);
    }
}




@end
