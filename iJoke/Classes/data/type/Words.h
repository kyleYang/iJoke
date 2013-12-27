//
//  Words.h
//  iJoke
//
//  Created by Kyle on 13-8-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "XmlWriter.h"
#import "JSONKit.h"
#import "User.h"


typedef NS_ENUM(NSInteger, JokeMessageType) {
    JokeMessageTypeWords = 0,
    JokeMessageTypeImage,
    JokeMessageTypeVideo,
};


@class Words;


@interface Words : NSObject

@property (nonatomic, assign) NSInteger collectCount;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) NSInteger down;
@property (nonatomic, strong) NSString *hotTime;
@property (nonatomic, assign) NSInteger wordId;
@property (nonatomic, assign) NSInteger shareCount;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger up;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *url;

- (NSString *)stringOfId;
- (NSString *)reviewStatus;

+(NSArray *)parseJsonData:(NSData*)data;
+(Words *)wordInitWithDicctionary:(NSDictionary *)subDic;
+(NSArray *)parseXmlData:(NSData*)data;
+(Words *)parseXml:(TBXMLElement*)element;
- (void)writeXmlItem:(XmlWriter*)wrt;
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj;

@end
