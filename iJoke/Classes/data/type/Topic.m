//
//  Topic.m
//  iJoke
//
//  Created by Kyle on 13-11-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "Topic.h"
#import "JSONKit.h"

#define kList @"list"

#define kTopic @"topic"
#define kTopicId @"id"
#define kName @"name"
#define kType @"type"


@implementation Topic


- (NSString *)description{
    
    return [NSString stringWithFormat:@"[Topic id:%d, name:%@, type:%d]",self.topicId,self.name,self.type];
}


+(Topic *)topicInitWithDicctionary:(NSDictionary *)subDic{
    if (!subDic) {
        
        return nil;
    }
    
    Topic *topic = [[Topic alloc] init];
    
    if([subDic objectForKey:kTopicId]!=[NSNull null]){
        topic.topicId = [[subDic objectForKey:kTopicId] intValue];
    }
    
    if([subDic objectForKey:kName]!=[NSNull null]){
        topic.name = [subDic objectForKey:kName];
    }
    
    if([subDic objectForKey:kType]!=[NSNull null]){
        topic.type = [[subDic objectForKey:kType] intValue];
    }
    
    return topic;
}


+(NSArray *)parseJsonData:(NSData*)data{
    
    if(nil == data || [data length] < 1) {
        BqsLog(@"invalid param. data: %@", data);
        
        return nil;
    }
    
    NSError *err;
    NSArray *jsonArray = [data objectFromJSONDataWithParseOptions:JKParseOptionNone error:&err];
    if (err) {
        BqsLog(@"JSONParse error:%@",err);
        return nil;
    }
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    

    if (jsonArray == NULL || ![jsonArray isKindOfClass:[NSArray class]]) {
        BqsLog(@"JSONParse has no array");
        return nil;
    }
    
    for (NSDictionary *subDic in jsonArray) {
        Topic *topic = [Topic topicInitWithDicctionary:subDic];
        
        if (topic == nil) {
            break;
        }
        [arr addObject:topic];
        
        
    }

    return arr;
    
}


+ (Topic *)parseXml:(TBXMLElement*)element {
    if(NULL == element || NULL == element->name) return nil;
    if(![kTopic isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    Topic *topic = [[Topic alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if([kTopicId isEqualToString:sName]) {
                topic.topicId = [text intValue];
            }else if([kName isEqualToString:sName]) {
                topic.name = text;
            }else if([kType isEqualToString:sName]){
                topic.type = [text intValue];
            }else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        
        
        item = item->nextSibling;
    }
    
    return topic;
    
}


+(NSArray *)parseXmlData:(NSData*)data{
    
    if(nil == data || [data length] < 1) {
        BqsLog(@"invalid param. data: %@", data);
        
        return nil;
    }
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    
    TBXML *tbxml = [[TBXML alloc] initWithXMLData:data];
    
    if(NULL == tbxml.rootXMLElement) {
        return nil;
    }
    
    TBXMLElement *item = tbxml.rootXMLElement->firstChild;
    
    while(NULL != item) {
        
        NSString *name = [TBXML elementName:item];
        if([kList isEqualToString:name]) {
            
            TBXMLElement *si = item->firstChild;
            while(NULL != si) {
                
                NSString *siName = [TBXML elementName:si];
                if([kTopic isEqualToString:siName]) {
                    
                    Topic *topic = [Topic parseXml:si];
                    
                    if(nil != topic) {
                        [arr addObject:topic];
                    }
                    
                } else {
                    BqsLog(@"Unknown tag: %@", siName);
                }
                
                si = si->nextSibling;
            }
            
        }
        
        item = item->nextSibling;
    }
    
    return arr;

    
}

- (void)writeXmlItem:(XmlWriter*)wrt {
    
    [wrt writeIntTag:kTopicId Value:self.topicId];
    [wrt writeStringTag:kName Value:self.name CData:YES];
    [wrt writeIntTag:kType Value:self.type];
}


+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj{
	if(nil == obj || nil == path) {
		BqsLog(@"Invalid param path: %@, obj: %@", path, obj);
		return NO;
	}
	
	XmlWriter *wrt = [[XmlWriter alloc] initWithFile:path];
	if(nil == wrt) {
		BqsLog(@"Can't write to file %@", path);
		return NO;
	}
    
    [wrt writeStartTag:@"result"];
    [wrt writeStartTag:kList];
    
    for(Topic *topic in obj) {
        [wrt writeStartTag:kTopic];
        
        [topic writeXmlItem:wrt];
        
        [wrt writeEndTag:kTopic];
    }
    
    [wrt writeEndTag:kList];
    [wrt writeEndTag:@"result"];
    
	BOOL bError = wrt.bError;
    
	
	return !bError;
    
}



@end
