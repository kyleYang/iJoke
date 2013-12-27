//
//  FTSTopicViewCell.m
//  iJoke
//
//  Created by Kyle on 13-11-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "FTSTopicViewCell.h"
#import "FTSGridView.h"
#import "GridData.h"

@interface FTSTopicViewCell()<FTSGridViewDataSource,FTSGridViewDelegate,FTSGirdViewCellDelegate>
{
    FTSGridView *_ftSGridView;
}

@property (strong, nonatomic) FTSGridView *ftSGridView;
@property (strong, nonatomic) NSArray *colorsArray;

@end


@implementation FTSTopicViewCell
@synthesize section = _section;
@synthesize dataArray = _dataArray;
@synthesize ftSGridView = _ftSGridView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)ident withController:(UIViewController *)ctrl
{
    self  = [super initWithFrame:frame withIdentifier:ident withController:ctrl];
    if (self == nil) return self;
    
    self.colorsArray = @[HexRGB(0x6CC6DE),HexRGB(0x74A8D0),HexRGB(0x5E80C8),HexRGB(0xBB6596),HexRGB(0xA9B537),HexRGB(0x6F9087),HexRGB(0x848A9A),HexRGB(0x094371),HexRGB(0x8B7B70)];
    
    _ftSGridView = [[FTSGridView alloc] initWithFrame:self.bounds];
    _ftSGridView.dataSource = self;
    _ftSGridView.delegate = self;
    [self addSubview:_ftSGridView];
    
    
    return self;

}


#pragma mark
#pragma mark property

- (void)setDataArray:(NSArray *)dataArray{
    
    if (_dataArray == dataArray) return;
    
    _dataArray = dataArray;
    
    [_ftSGridView reloadData];
    
    
}


#pragma mark
#pragma mark FTSGridViewDataSource

- (NSUInteger)numberOfCellInGridView:(FTSGridView *)gridView{
    return [_dataArray count];
}


- (FTSGirdViewCell *)gridView:(FTSGridView *)gridView cellIndex:(NSUInteger)index{
    
    static NSString *identify = @"gird";
    FTSGirdViewCell *cell = (FTSGirdViewCell *)[gridView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[FTSGirdViewCell alloc] initReuseIdentifier:identify];
    }
    if (index >= [_dataArray count]) {
        
        BqsLog(@"gridView index : %d >= [_dataArray count] :%d ",index, [_dataArray count]);
        return cell;
    }
    GridData *data = [_dataArray objectAtIndex:index];
    cell.delegate = self;
    cell.titleLabel.text = data.name;
    
    int colorIndex = (arc4random()%[self.colorsArray count]);
    cell.backgroundColor = [self.colorsArray objectAtIndex:colorIndex];
    
    if (data.type == gridImage) {
        cell.iconImageView.image = [[Env sharedEnv] cacheImage:@"timeline_card_image.png"];
    }else if (data.type == gridVideo){
        cell.iconImageView.image = [[Env sharedEnv] cacheImage:@"timeline_card_play.png"];
    }else{
        cell.iconImageView.image = nil;
    }
    
    return cell;
    
}

#pragma mark FTSGirdViewCellDelegate
-(void)fTSGirdViewCellDidTap:(FTSGirdViewCell *)cell{
    
    if ([_delegate respondsToSelector:@selector(TopicViewCell:selectSection:atIndex:)]) {
        
        [_delegate TopicViewCell:self selectSection:_section atIndex:cell.index];
        BqsLog(@"fTSGirdViewCellDidTap TopicViewCell selectSection:%d, atIndex = %d",_section,cell.index);
        
    }
    
}




@end
