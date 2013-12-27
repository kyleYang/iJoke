//
//  Image.h
//  iJoke
//
//  Created by Kyle on 13-8-15.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "XmlWriter.h"
#import "User.h"

@interface Picture : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) NSUInteger height;
@property (nonatomic, strong) NSString *picUrl;
@property (nonatomic, assign) NSUInteger width;

+(NSArray *)pictureArrayInitWithArray:(NSArray *)array;
+(Picture *)pictureInitWithDicctionary:(NSDictionary *)subDic;
+(NSArray *)parseArrayXml:(TBXMLElement*)element;
+(Picture *)parseXml:(TBXMLElement*)element;
- (void)writeXmlItem:(XmlWriter*)wrt;

@end

@interface Image : NSObject

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, assign) NSInteger collectCount;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, assign) NSInteger down;
@property (nonatomic, strong) NSString *hotTime;
@property (nonatomic, assign) NSInteger imageId;
@property (nonatomic, assign) NSInteger shareCount;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger up;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *url;

- (NSString *)stringOfId;
- (NSString *)reviewStatus;

+(NSArray *)parseJsonData:(NSData*)data;
+(Image *)imageInitWithDicctionary:(NSDictionary *)subDic;
+(NSArray *)parseXmlData:(NSData*)data;
+(Image *)parseXml:(TBXMLElement*)element;
- (void)writeXmlItem:(XmlWriter*)wrt;
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj;



@end
