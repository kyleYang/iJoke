//
//  NGVideoTableView.h
//  iJoke
//
//  Created by Kyle on 13-12-8.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGWeak.h"

@protocol NGVideoTableViewDelegate;

@interface NGVideoTableView : UIView{
    id<NGVideoTableViewDelegate> __ng_weak _delegate;
}
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, ng_weak) id<NGVideoTableViewDelegate> delegate;

@end


@protocol NGVideoTableViewDelegate <NSObject>

@optional

- (NSUInteger)numberOfSectionNGVideoTableView:(NGVideoTableView *)tableView;
- (NSUInteger)NGVideoTableView:(NGVideoTableView *)tableView numberOfRowInSection:(NSUInteger)section;
- (NSString *)NGVideoTableView:(NGVideoTableView *)tableView titleInIndexPath:(NSIndexPath *)indexPath;

- (void)NGVideoTableView:(NGVideoTableView *)tableView didSelectIndexPath:(NSIndexPath *)indexPath;

@end