//
//  GridData.h
//  iJoke
//
//  Created by Kyle on 13-11-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridData.h"

typedef NS_ENUM(NSInteger, gridType) {
    gridWords ,
    gridImage ,
    gridVideo ,
};

@interface GridData : NSObject


@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *iconUrl;
@property (nonatomic,assign) gridType type;


@end
