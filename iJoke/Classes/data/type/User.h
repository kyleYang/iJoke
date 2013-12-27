//
//  User.h
//  iJoke
//
//  Created by Kyle on 13-8-26.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "XmlWriter.h"
#import "JSONKit.h"

#define kUser @"user"

@interface User : NSObject

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *nikeName;
@property (nonatomic, strong) NSString *icon;

- (NSString *)stringOfUserId;

+(User *)userInfoForLogData:(NSData *)data;
+(User *)userInitWithDicctionary:(NSDictionary *)subDic;
+(User *)parseXml:(TBXMLElement*)element;
- (void)writeXmlItem:(XmlWriter*)wrt;
@end
