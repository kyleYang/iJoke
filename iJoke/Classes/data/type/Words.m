//
//  Words.m
//  iJoke
//
//  Created by Kyle on 13-8-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "Words.h"
#import "JSONKit.h"

#define kFreshSize @"freshSize"

#define kList @"list"
#define kWords @"words"

#define kCollectCount @"collectCount"
#define kCommentsCount @"commentsCount"
#define kContent @"content"
#define kDown @"down"
#define kHotTime @"hotTime"
#define kWordId @"id"
#define kShareCount @"shareCount"
#define kStatus @"status"
#define kTime @"time"
#define kTitle @"title"
#define kUp @"up"

#define kUrl @"url"



@implementation Words

- (NSString *)description{
    return [NSString stringWithFormat:@"[Words collectCount:%d, commentsCount:%d, content:%@, down:%d, hotTime:%@, wordId:%d, shareCount:%d, status = %d, time:%@, title:%@, up:%d, user:%@,url:%@]",self.collectCount,self.commentsCount,self.content,self.down,self.hotTime,self.wordId,self.shareCount,self.status,self.time,self.title,self.up,self.user,self.url];
}

- (NSString *)stringOfId{
    return [NSString stringWithFormat:@"%d",self.wordId];
}

//"review.status.unkown" = "未知状态";
//"review.status.pass" = "审核通过";
//"review.status.review" = "审核中";
//"review.status.failed" = "审核未通过";

- (NSString *)reviewStatus{
    
    NSString *stringstatus = NSLocalizedString(@"review.status.unkown", nil);
    if (self.status == 0) {
        stringstatus = NSLocalizedString(@"review.status.pass", nil);
    }else if(self.status == 1){
        stringstatus = NSLocalizedString(@"review.status.review", nil);
    }else if(self.status == 2){
        stringstatus = NSLocalizedString(@"review.status.failed", nil);
    }
    
    return stringstatus;
}


+(NSArray *)parseJsonData:(NSData*)data{
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
        Words *word = [Words wordInitWithDicctionary:subDic];
        
        if (!word) {
            break;
        }
        [arr addObject:word];
        
        
    }
    return arr;

}


+(Words *)wordInitWithDicctionary:(NSDictionary *)subDic{
    if (subDic == nil) {
        
        return nil;
    }
    
    Words *word = [[Words alloc] init];
    
    if([subDic objectForKey:kCollectCount]!=[NSNull null]){
        word.collectCount = [[subDic objectForKey:kCollectCount] intValue];
    }
    
    if([subDic objectForKey:kCommentsCount]!=[NSNull null]){
        word.commentsCount = [[subDic objectForKey:kCommentsCount] intValue];
    }
    
    if([subDic objectForKey:kContent]!=[NSNull null]){
        word.content = [subDic objectForKey:kContent];
    }
    
    if([subDic objectForKey:kDown]!=[NSNull null]){
        word.down = [[subDic objectForKey:kDown] intValue];
    }
    
    if([subDic objectForKey:kHotTime]!=[NSNull null]){
        word.hotTime = [subDic objectForKey:kHotTime];
    }
    
    
    word.wordId = [[subDic objectForKey:kWordId] intValue];
    
    
    if([subDic objectForKey:kShareCount]!=[NSNull null]){
        word.shareCount = [[subDic objectForKey:kShareCount] intValue];
    }
    
    if([subDic objectForKey:kStatus]!=[NSNull null]){
        word.status = [[subDic objectForKey:kStatus] intValue];
    }else{
        word.status = -1; //unknow status
    }
    
    if([subDic objectForKey:kTime]!=[NSNull null]){
        word.time = [subDic objectForKey:kTime];
    }
    
    if([subDic objectForKey:kTitle]!=[NSNull null]){
        word.title = [subDic objectForKey:kTitle];
    }
    
    if([subDic objectForKey:kUp]!=[NSNull null]){
        word.up = [[subDic objectForKey:kUp] intValue];
    }
    
    if([subDic objectForKey:kUser]!=[NSNull null]){
        word.user =  [User userInitWithDicctionary:[subDic objectForKey:kUser]];
    }
    
    if([subDic objectForKey:kUrl]!=[NSNull null]){
        word.url = [subDic objectForKey:kUrl];
    }
    
    return word;
}


+(Words *)parseXml:(TBXMLElement*)element {
    if(NULL == element || NULL == element->name) return nil;
//    if(![kWords isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    Words *word = [[Words alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if([kCollectCount isEqualToString:sName]) {
                word.collectCount = [text intValue];
            }else if([kCommentsCount isEqualToString:sName]) {
                word.commentsCount = [text intValue];
            }else if([kContent isEqualToString:sName]){
                word.content = text;
            }else if([kDown isEqualToString:sName]){
                word.down = [text intValue];
            }else if([kHotTime isEqualToString:sName]) {
                word.hotTime = text;
            }else if([kWordId isEqualToString:sName]) {
                word.wordId = [text intValue];
            }else if([kShareCount isEqualToString:sName]) {
                word.shareCount = [text intValue];
            }else if([kStatus isEqualToString:sName]) {
                word.status = [text intValue];
            }else if([kTime isEqualToString:sName]) {
                word.time = text;
            } else if([kTitle isEqualToString:sName]) {
                word.title = text;
            } else if([kUp isEqualToString:sName]) {
                word.up = [text intValue];
            }else if([kUser isEqualToString:sName]) {
                word.user = [User parseXml:item];
            } else if([kUrl isEqualToString:sName]) {
                word.url= text;
            }else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        
        
        item = item->nextSibling;
    }
    
    return word;
    
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
                if([kWords isEqualToString:siName]) {
                    
                    Words *words = [Words parseXml:si];
                    
                    if(nil != words) {
                        [arr addObject:words];
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
    
    [wrt writeIntTag:kCollectCount Value:self.collectCount];
    [wrt writeIntTag:kCommentsCount Value:self.commentsCount];
    [wrt writeStringTag:kContent Value:self.content CData:YES];
    [wrt writeIntTag:kDown Value:self.down];
    [wrt writeStringTag:kHotTime Value:self.hotTime CData:NO];
    [wrt writeIntTag:kWordId Value:self.wordId];
    [wrt writeIntTag:kShareCount Value:self.shareCount];
    [wrt writeIntTag:kStatus Value:self.status];
    [wrt writeStringTag:kTime Value:self.time CData:NO];
    [wrt writeStringTag:kTitle Value:self.title CData:NO];
    [wrt writeIntTag:kUp Value:self.up];
    [wrt writeStartTag:kUser];
    [self.user writeXmlItem:wrt];
    [wrt writeEndTag:kUser];
    [wrt writeStringTag:kUrl Value:self.url CData:NO];
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
    
    for(Words *words in obj) {
        [wrt writeStartTag:kWords];
       
        [words writeXmlItem:wrt];
        
        [wrt writeEndTag:kWords];
    }
    
    [wrt writeEndTag:kList];
    [wrt writeEndTag:@"result"];
    
	BOOL bError = wrt.bError;

	
	return !bError;
    
}




@end
