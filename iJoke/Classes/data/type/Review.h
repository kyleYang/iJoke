//
//  Review.h
//  iJoke
//
//  Created by Kyle on 13-11-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Words.h"
#import "Image.h"
#import "Video.h"



@interface Review : NSObject


+(NSArray*)parseJsonData:(NSData*)data;
+(NSArray *)parseXmlData:(NSData*)data;
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj;


@end
