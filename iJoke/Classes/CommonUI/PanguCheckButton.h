//
//  PanguCheckButton.h
//  pangu
//
//  Created by yang zhiyun on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CheckButtonStyleDefault = 0 ,
    CheckButtonStyleBox = 1 ,
    CheckButtonStyleRadio = 2
} CheckButtonStyle;

@protocol PanguCheckDelegate;

@interface PanguCheckButton : UIControl {
    //UIControl* control;
    UILabel * label ;
    UIImageView * icon ;
    BOOL checked ;
    id <PanguCheckDelegate> __weak_delegate _delegate ;
    CheckButtonStyle style ;
    NSUInteger btIndex;
    NSString * checkname ,* uncheckname ; // 勾选／反选时的图片文件名
}
@property (nonatomic, weak_delegate) id<PanguCheckDelegate>delegate;
@property (nonatomic, strong)UILabel *label;
@property (nonatomic, strong)UIImageView *icon;
@property ( assign )CheckButtonStyle style;

-( CheckButtonStyle )style;
-(void)setStyle:( CheckButtonStyle )st;
- (NSUInteger)btIndex;
-(void)setBtIndex:(NSUInteger)index;
-(BOOL)isChecked;
-(void)setChecked:(BOOL)b;
@end

@protocol PanguCheckDelegate <NSObject>

@optional
- (void)checkStateChange:(id)sender;

@end