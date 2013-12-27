//
//  PanguCheckButton.m
//  pangu
//
//  Created by yang zhiyun on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PanguCheckButton.h"
#import "Env.h"

#define kIconWidth 36

@implementation PanguCheckButton
@synthesize label,icon,delegate;
-( id )initWithFrame:(CGRect) frame
{
    if ( self =[super initWithFrame:frame]) {
        icon =[[UIImageView alloc] initWithFrame:CGRectMake ( 0 , 0 , CGRectGetWidth(self.bounds) , CGRectGetWidth(self.bounds) )];
        [self setStyle:CheckButtonStyleDefault ]; // 默认风格为方框（多选）样式
        [self addSubview:icon ];
        
        label =[[UILabel alloc] initWithFrame:CGRectMake (0, CGRectGetMaxY(icon.frame),frame.size.width ,frame.size.height - CGRectGetMaxY(icon.frame)-5)];
        label.backgroundColor =[ UIColor clearColor ];
        label.font =[ UIFont systemFontOfSize: 7.0f ];
        label.textColor =[ UIColor blackColor];
        label.textAlignment = UITextAlignmentCenter ;
        [self addSubview:label];
        [self addTarget:self action:@selector(clicked) forControlEvents : UIControlEventTouchUpInside ];
    }
    return self ;
}

-( CheckButtonStyle )style{
    return style ;
}

-( void )setStyle:( CheckButtonStyle )st{
    style =st;
    switch ( style ) {
        case CheckButtonStyleDefault :
        case CheckButtonStyleBox :
            checkname = @"Pangu_checked.png" ;
            uncheckname = @"Pangu_unchecked.png" ;
            break ;
        case CheckButtonStyleRadio :
            checkname = @"radio.png" ;
            uncheckname = @"unradio.png" ;
            break ;
        default :
            break ;
    }
    [ self setChecked : checked ];
}


- (NSUInteger)btIndex
{
    return btIndex;
}
-(void)setBtIndex:(NSUInteger)index
{
    btIndex = index;
}

-( BOOL )isChecked{
    return checked ;
}
-( void )setChecked:( BOOL )b{
    Env *env = [Env sharedEnv];
    if (b!= checked ){
        checked =b;
    }
    if ( checked ) {
        [ icon setImage :[env  cacheImage:checkname]];
    } else {
        [ icon setImage :[env  cacheImage:uncheckname]];
    }
}
-( void )clicked{
    [self setChecked:!checked ];
    if ( delegate != nil ) {
        if ([delegate respondsToSelector :@selector(checkStateChange:)]){
            [delegate checkStateChange:self];
        }
    }
}

-( void )dealloc{
    delegate = nil ;
}
@end