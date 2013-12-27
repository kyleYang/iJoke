//
//  Draft.h
//  iJoke
//
//  Created by Kyle on 13-9-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlWriter.h"
#import "TBXML.h"

@interface Draft : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *picurl;


-(void)writeXmlItem:(XmlWriter*)wrt;

+(Draft *)parseXml:(TBXMLElement*)element;
+(NSArray *)parseXmlData:(NSData*)data;
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj;

@end
