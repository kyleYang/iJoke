//
//  NGVideoTableView.m
//  iJoke
//
//  Created by Kyle on 13-12-8.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "NGVideoTableView.h"


@interface NGVideoTableView()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}

@property (nonatomic, strong, readwrite) UITableView *tableView;

@end

@implementation NGVideoTableView
@synthesize delegate = _delegate;
@synthesize tableView = _tableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.scrollsToTop = YES;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.allowsSelectionDuringEditing = NO;
        self.tableView.delegate = self;
        self.tableView.allowsSelection = YES;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        
    }
    return self;
}


#pragma mark
#pragma mark UITableViewDataSource UITableViewDelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if ([_delegate respondsToSelector:@selector(numberOfSectionNGVideoTableView:)]) {
        
        return [_delegate numberOfSectionNGVideoTableView:self];
    }
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([_delegate respondsToSelector:@selector(NGVideoTableView:numberOfRowInSection:)]) {
        
        return [_delegate NGVideoTableView:self numberOfRowInSection:section];
    }
    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:11.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    NSString *title = NSLocalizedString(@"video.tableview.notitle", nil);
    
    if ([_delegate respondsToSelector:@selector(NGVideoTableView:titleInIndexPath:)]) {
        title = [_delegate NGVideoTableView:self titleInIndexPath:indexPath];
    }
    cell.textLabel.text = title;
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_delegate respondsToSelector:@selector(NGVideoTableView:didSelectIndexPath:)]) {
        
        [_delegate NGVideoTableView:self didSelectIndexPath:indexPath];
    }
    
    
}



@end
