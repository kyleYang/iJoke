//
//  Topic.h
//  iJoke
//
//  Created by Kyle on 13-11-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlWriter.h"
#import "TBXML.h"

@interface Topic : NSObject

@property (nonatomic,assign) NSInteger topicId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSInteger type;

+(Topic *)topicInitWithDicctionary:(NSDictionary *)subDic;
+(NSArray *)parseJsonData:(NSData*)data;

+ (Topic *)parseXml:(TBXMLElement*)element;
+(NSArray *)parseXmlData:(NSData*)data;
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj;

@end
