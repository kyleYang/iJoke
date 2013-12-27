//
//  Video.m
//  DotAer
//
//  Created by Kyle on 13-1-29.
//  Copyright (c) 2013年 KyleYang. All rights reserved.
//

#import "Video.h"

#import "Env.h"
#import "BqsUtils.h"

#define kCode @"code"
#define kFreshSize @"freshSize"

#define kList @"list"
#define kVideo @"video"


#define kCollectCount @"collectCount"
#define kCommentsCount @"commentsCount"
#define kMp4 @"mp4"
#define kDown @"down"
#define kFlv @"flv"
#define kHd2 @"hd2"
#define kHotTime @"hotTime"
#define kVideoId @"id"
#define kPicture @"picture"
#define kShareCount @"shareCount"
#define kShowUser @"showUser"
#define kStatus @"status"
#define kSummary @"summary"
#define kTime @"time"
#define kTitle @"title"
#define kUniqueKey @"uniqueKey"
#define kUp @"up"
#define kUserId @"userId"
#define kYoukuId @"youkuId"



@implementation Video

- (NSString *)description{
    return [NSString stringWithFormat:@"[Video collectCount:%d, commentsCount:%d, mp4:%@, down:%d, flv:%@, hd2:%@, hotTime:%@, videoId:%d, picture:%@, shareCount:%d, showUser:%d, status:%d, summary:%@, time:%@, title:%@, uniqueKey:%@, up:%d, userId:%d,youkuId:%@]",self.collectCount,self.commentsCount,self.mp4,self.down,self.flv,self.hd2,self.hotTime,self.videoId,self.picture,self.shareCount,self.showUser,self.status,self.summary,self.time,self.title,self.uniqueKey,self.up,self.userId,self.youkuId];
}

- (NSString *)stringOfId{
    return [NSString stringWithFormat:@"%d",self.videoId];
}

- (NSString *)reviewStatus{
    
    NSString *stringstatus = NSLocalizedString(@"review.status.unkown", nil);
    if (self.status == 0) {
        stringstatus = NSLocalizedString(@"review.status.pass", nil);
    }else if(self.status == 1){
        stringstatus = NSLocalizedString(@"review.status.failed", nil);
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
        Video *video = [Video videoInitWithDicctionary:subDic];
        
        if (!video) {
            break;
        }
        [arr addObject:video];
        
        
    }
    
    return arr;
    
}



+(Video *)videoInitWithDicctionary:(NSDictionary *)subDic{
    if (!subDic) {
        
        return nil;
    }
    
    Video *video = [[Video alloc] init];
    
    if([subDic objectForKey:kCollectCount]!=[NSNull null]){
        video.collectCount = [[subDic objectForKey:kCollectCount] intValue];
    }
    
    if([subDic objectForKey:kCommentsCount]!=[NSNull null]){
        video.commentsCount = [[subDic objectForKey:kCommentsCount] intValue];
    }
    
    if([subDic objectForKey:kMp4]!=[NSNull null]){
        video.mp4 = [subDic objectForKey:kMp4];
    }
    
    if([subDic objectForKey:kDown]!=[NSNull null]){
        video.down = [[subDic objectForKey:kDown] intValue];
    }
    
    if([subDic objectForKey:kFlv]!=[NSNull null]){
        video.flv = [subDic objectForKey:kFlv];
    }
    
    if([subDic objectForKey:kHd2]!=[NSNull null]){
        video.hd2 = [subDic objectForKey:kHd2];
    }
    
    if([subDic objectForKey:kHotTime]!=[NSNull null]){
        video.hotTime = [subDic objectForKey:kHotTime];
    }
    
    
    video.videoId = [[subDic objectForKey:kVideoId] intValue];
    
    if([subDic objectForKey:kPicture]!=[NSNull null]){
        video.picture = [subDic objectForKey:kPicture];
    }
    
    
    if([subDic objectForKey:kShareCount]!=[NSNull null]){
        video.shareCount = [[subDic objectForKey:kShareCount] intValue];
    }
    
    if([subDic objectForKey:kShowUser]!=[NSNull null]){
        video.showUser = [[subDic objectForKey:kShowUser] boolValue];
    }
    
    if([subDic objectForKey:kStatus]!=[NSNull null]){
        video.status = [[subDic objectForKey:kStatus] boolValue];
    }
    
    if([subDic objectForKey:kSummary]!=[NSNull null]){
        video.summary = [subDic objectForKey:kSummary];
    }
    
    if([subDic objectForKey:kTime]!=[NSNull null]){
        video.time = [subDic objectForKey:kTime];
    }
    
    if([subDic objectForKey:kTitle]!=[NSNull null]){
        video.title = [subDic objectForKey:kTitle];
    }
    
    if([subDic objectForKey:kUniqueKey]!=[NSNull null]){
        video.uniqueKey = [subDic objectForKey:kUniqueKey];
    }
    
    
    if([subDic objectForKey:kUp]!=[NSNull null]){
        video.up = [[subDic objectForKey:kUp] intValue];
    }
    
    if([subDic objectForKey:kUserId]!=[NSNull null]){
        video.userId = [[subDic objectForKey:kUserId] intValue];
    }
    
    if([subDic objectForKey:kYoukuId]!=[NSNull null]){
        video.youkuId = [subDic objectForKey:kYoukuId];
    }
    
    
    return video;
}


+(Video *)parseXml:(TBXMLElement*)element {
    if(NULL == element || NULL == element->name) return nil;
//    if(![kVideo isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    Video *video = [[Video alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if([kCollectCount isEqualToString:sName]) {
                video.collectCount = [text intValue];
            }else if([kCommentsCount isEqualToString:sName]) {
                video.commentsCount = [text intValue];
            }else if([kMp4 isEqualToString:sName]){
                video.mp4 = text;
            }else if([kDown isEqualToString:sName]){
                video.down = [text intValue];
            }else if([kFlv isEqualToString:sName]){
                video.flv = text;
            }else if([kHd2 isEqualToString:sName]){
                video.hd2 = text;
            }else if([kHotTime isEqualToString:sName]) {
                video.hotTime = text;
            }else if([kVideoId isEqualToString:sName]) {
                video.videoId = [text intValue];
            }else if([kPicture isEqualToString:sName]) {
                video.picture = text;
            }else if([kShareCount isEqualToString:sName]) {
                video.shareCount = [text intValue];
            }else if([kShowUser isEqualToString:sName]) {
                video.showUser = [text boolValue];
            }else if([kStatus isEqualToString:sName]) {
                video.status = [text boolValue];
            }else if([kSummary isEqualToString:sName]) {
                video.summary = text;
            }else if([kTime isEqualToString:sName]) {
                video.time = text;
            }else if([kTitle isEqualToString:sName]) {
                video.title = text;
            }else if([kUniqueKey isEqualToString:sName]) {
                video.uniqueKey = text;
            }else if([kUp isEqualToString:sName]) {
                video.up = [text intValue];
            }else if([kUserId isEqualToString:sName]) {
                video.userId = [text intValue];
            }else if([kYoukuId isEqualToString:sName]) {
                video.youkuId= text;
            }else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        
        
        item = item->nextSibling;
    }
    
    return video;
    
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
                if([kVideo isEqualToString:siName]) {
                    
                    Video *video = [Video parseXml:si];
                    
                    if(nil != video) {
                        [arr addObject:video];
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
    [wrt writeStringTag:kMp4 Value:self.mp4 CData:YES];
    [wrt writeIntTag:kDown Value:self.down];
    [wrt writeStringTag:kFlv Value:self.flv CData:YES];
    [wrt writeStringTag:kHd2 Value:self.hd2 CData:YES];
    [wrt writeStringTag:kHotTime Value:self.hotTime CData:NO];
    [wrt writeIntTag:kVideoId Value:self.videoId];
    [wrt writeStringTag:kPicture Value:self.picture CData:YES];
    [wrt writeIntTag:kShareCount Value:self.shareCount];
    [wrt writeIntTag:kShowUser Value:self.showUser];
    [wrt writeIntTag:kStatus Value:self.status];
    [wrt writeStringTag:kSummary Value:self.summary CData:YES];
    [wrt writeStringTag:kTime Value:self.time CData:NO];
    [wrt writeStringTag:kTitle Value:self.title CData:YES];
    [wrt writeStringTag:kUniqueKey Value:self.uniqueKey CData:NO];
    [wrt writeIntTag:kUp Value:self.up];
    [wrt writeIntTag:kUserId Value:self.userId];
    [wrt writeStringTag:kYoukuId Value:self.youkuId CData:NO];
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
    
    for(Video *video in obj) {
        [wrt writeStartTag:kVideo];
        
        [video writeXmlItem:wrt];
        
        [wrt writeEndTag:kVideo];
    }
    
    [wrt writeEndTag:kList];
    [wrt writeEndTag:@"result"];
    
	BOOL bError = wrt.bError;
    
	
	return !bError;
    
}



@end
