//
//  Comment.h
//  iJoke
//
//  Created by Kyle on 13-8-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "XmlWriter.h"
#import "User.h"

@interface Comment : NSObject

@property (nonatomic, strong) NSString *addtime;
@property (nonatomic, assign) NSInteger articleId;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, strong) User *user;


+(NSArray *)parseJsonData:(NSData*)data;

+(NSArray *)parseXmlData:(NSData*)data;
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj;

@end
