//
//  Updown.h
//  iJoke
//
//  Created by Kyle on 13-8-29.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Record : NSObject

@property (nonatomic, assign) NSInteger itemId;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger updown; //for up and down, type:1 --up type:-1--down
@property (nonatomic, strong) NSString *time;

+(NSMutableArray *)parseJsonData:(NSData*)data;
+(NSMutableArray *)parseXmlData:(NSData*)data;
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj;



@end
