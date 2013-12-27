//
//  Review.m
//  iJoke
//
//  Created by Kyle on 13-11-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "Review.h"
#import "JSONKit.h"


#define kList @"list"
#define kStruct @"struct"
#define kType @"type"
#define kJoke @"joke"

@implementation Review


+(NSArray*)parseJsonData:(NSData*)data{
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
        return nil;
    }
    
    for (NSDictionary *subDic in jsonArray) {
        
        NSInteger type = 0;
        if([subDic objectForKey:kType]!=[NSNull null]){
            type= [[subDic objectForKey:kType] integerValue];
        }
        
        NSDictionary *jokeDic = nil;
        
        if([subDic objectForKey:kJoke]!=[NSNull null]){
            jokeDic= [subDic objectForKey:kJoke];
        }
        
        
        if (jokeDic == nil) {
            BqsLog(@"jokeDic == nil");
            
            break;
        }
        
        
        switch (type) {
            case JokeMessageTypeWords:
            {
                Words *word = [Words wordInitWithDicctionary:jokeDic];
                if ( word == nil) {
                    break;
                }
                [arr addObject:word];
            }
                
                break;
            case JokeMessageTypeImage:
            {
                Image *image = [Image imageInitWithDicctionary:jokeDic];
                if ( image == nil) {
                    break;
                }
                [arr addObject:image];
                
            }
                
                break;
            case JokeMessageTypeVideo:
            {
                Video *video = [Video videoInitWithDicctionary:jokeDic];
                if ( video == nil) {
                    break;
                }
                [arr addObject:video];
                
            }
                
                break;
                
            default:
                break;
        }
    }
    
    return arr;
    
}



+(NSArray *)parseXmlData:(NSData*)data {
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
                
                if ([siName isEqualToString:kStruct]) {
                    TBXMLElement *son = si->firstChild;
                    
                    while(NULL != son){
                        NSString *sonName = [TBXML elementName:son];
                        NSString *sonValue = [TBXML textForElement:son];
                        
                        if ([sonName isEqualToString:kType]) {
                            
                            JokeMessageType type = [sonValue intValue];
                            son = son ->nextSibling;
                            sonName = [TBXML elementName:son];
                            sonValue = [TBXML textForElement:son];
                            if ([sonName isEqualToString:kJoke]) {
                                if (type == JokeMessageTypeWords) {
                                    Words *words = [Words parseXml:son];
                                    if (words != nil) {
                                        [arr addObject:words];
                                    }
                                }else if (type == JokeMessageTypeImage) {
                                    Image *image = [Image parseXml:son];
                                    if (image != nil) {
                                        [arr addObject:image];
                                    }
                                }else if (type == JokeMessageTypeVideo) {
                                    Video *video = [Video parseXml:son];
                                    if (video != nil) {
                                        [arr addObject:video];
                                    }
                                }else{
                                    BqsLog(@"unknow type = %@",type);
                                }
                                
                                
                            }else{
                                BqsLog(@"unknow tag = %@",sonName);

                            }
                        }else {
                            BqsLog(@"unknow tag = %@",sonName);
                        }
                        son = son ->nextSibling;
                        
                    }
                    
                    
                }
                
                
                si = si->nextSibling;
            }
            
        }
        
        item = item->nextSibling;
    }
    
    return arr;
    
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
    
    for(id joke in obj) {
        [wrt writeStartTag:kStruct];
        if ([joke isKindOfClass:[Words class]]) {
            [wrt writeIntTag:kType Value:JokeMessageTypeWords];
            [wrt writeStartTag:kJoke];
            [(Words *)joke writeXmlItem:wrt];
            [wrt writeEndTag:kJoke];
        }else if([joke isKindOfClass:[Image class]]){
            [wrt writeIntTag:kType Value:JokeMessageTypeImage];
            [wrt writeStartTag:kJoke];
            [(Image *)joke writeXmlItem:wrt];
            [wrt writeEndTag:kJoke];
        }else if([joke isKindOfClass:[Video class]]){
            [wrt writeIntTag:kType Value:JokeMessageTypeVideo];
            [wrt writeStartTag:kJoke];
            [(Video *)joke writeXmlItem:wrt];
            [wrt writeEndTag:kJoke];
        }
        [wrt writeEndTag:kStruct];
    }
    
    [wrt writeEndTag:kList];
    [wrt writeEndTag:@"result"];
    
	BOOL bError = wrt.bError;
    
	
	return !bError;
    
}




@end
