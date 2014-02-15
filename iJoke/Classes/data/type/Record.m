//
//  Updown.m
//  iJoke
//
//  Created by Kyle on 13-8-29.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "Record.h"
#import "TBXML.h"
#import "XmlWriter.h"
#import "JSONKit.h"


#define kList @"list"
#define kRecord @"record"

#define kItemId @"itemId"
#define kCollect @"collect"
#define kUpdown @"updown"
#define kTime @"time"
#define kType @"type"

@implementation Record

- (NSString *)description{
    
    return [NSString stringWithFormat:@"[Record Updown: itemid:%d, favorite:%d,type:%d time:%@]",self.itemId,self.favorite,self.type,self.time];
}


+(Record *)recordInitWithDicctionary:(NSDictionary *)subDic{
    if (!subDic) {
        
        return nil;
    }
    
    Record *record = [[Record alloc] init];
    
    if([subDic objectForKey:kItemId]!=[NSNull null]){
        record.itemId = [[subDic objectForKey:kItemId] intValue];
    }
    
    if([subDic objectForKey:kCollect]!=[NSNull null]){
        record.favorite = [[subDic objectForKey:kCollect] boolValue];
    }
    
    if([subDic objectForKey:kUpdown]!=[NSNull null]){
        record.updown = [[subDic objectForKey:kUpdown] intValue];
    }
    if([subDic objectForKey:kType]!=[NSNull null]){
        record.type = [[subDic objectForKey:kType] intValue];
    }
    if([subDic objectForKey:kTime]!=[NSNull null]){
        record.time = [subDic objectForKey:kTime];
    }


    return record;
}



+(NSMutableArray *)parseJsonData:(NSData*)data{
    if(nil == data || [data length] < 1) {
        BqsLog(@"invalid param. data: %@", data);
        
        return nil;
    }
    
    NSError *err;
    NSDictionary *resultsDictionary = [data objectFromJSONDataWithParseOptions:JKParseOptionNone error:&err];
    if (err) {
        BqsLog(@"JSONParse error:%@",err);
        return nil;
    }
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    
    NSArray *jsonArray = [resultsDictionary objectForKey:kList];
    
    if (jsonArray == NULL || ![jsonArray isKindOfClass:[NSArray class]]) {
        BqsLog(@"JSONParse has no array");
        return arr;
    }
    
    for (NSDictionary *subDic in jsonArray) {
        Record *record = [Record recordInitWithDicctionary:subDic];
        
        if (record == nil) {
            break;
        }
        [arr addObject:record];

    }
    

    return arr;
    
}




+(Record *)parseXml:(TBXMLElement*)element {
    if(NULL == element || NULL == element->name) return nil;
    if(![kRecord isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    Record *record = [[Record alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if([kItemId isEqualToString:sName]) {
                record.itemId = [text integerValue];
            }else if([kCollect isEqualToString:sName]){
                record.favorite = [text boolValue];
            }else if([kUpdown isEqualToString:sName]){
                record.type = [text integerValue];
            }else if([kTime isEqualToString:sName]){
                record.time = text;
            }else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        
        
        item = item->nextSibling;
    }
    
    return record;
    
}




+(NSMutableArray *)parseXmlData:(NSData*)data {
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
                if([kRecord isEqualToString:siName]) {
                    
                    Record *record = [Record parseXml:si];
                    
                    if(nil != record) {
                        [arr addObject:record];
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
    
    [wrt writeIntTag:kItemId Value:self.itemId];
    [wrt writeIntTag:kCollect Value:self.favorite];
    [wrt writeIntTag:kUpdown Value:self.type];
    [wrt writeStringTag:kTime Value:self.time CData:NO];
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
    
    for(Record *record in obj) {
        [wrt writeStartTag:kRecord];
        
        [record writeXmlItem:wrt];
        
        [wrt writeEndTag:kRecord];
    }
    
    [wrt writeEndTag:kList];
    [wrt writeEndTag:@"result"];
    
	BOOL bError = wrt.bError;
    
	
	return !bError;
    
}


@end
