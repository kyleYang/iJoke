//
//  Image.m
//  iJoke
//
//  Created by Kyle on 13-8-15.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "Image.h"


#define kFreshSize @"freshSize"

#define kList @"list"
#define kWords @"words"

#define kChildPictures @"childPictures"
#define kPicture @"picture"

#define kContent @"content"
#define kHeight @"height"
#define kPicUrl @"picUrl"
#define kWidth @"width"

#define kCollectCount @"collectCount"
#define kCommentsCount @"commentsCount"
#define kShareCount @"shareCount"
#define kStatus @"status"
#define kDown @"down"
#define kHotTime @"hotTime"
#define kImageId @"id"
#define kLocalUrl @"localUrl"
#define kTime @"time"
#define kTitle @"title"
#define kUp @"up"
#define kUrl @"url"


@implementation Picture

- (NSString *)description{
    return [NSString stringWithFormat:@"[Picture content:%@, height:%d, picUrl:%@, widht:%d]",self.content,self.height,self.picUrl,self.width];
}



+(NSArray *)pictureArrayInitWithArray:(NSArray *)array{
    if (array == nil || ![array isKindOfClass:[NSArray class]]) {
        
        return nil;
    }
    
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:[array count]];
    
    
    for (NSDictionary *subDic in array) {
        Picture *picture = [Picture pictureInitWithDicctionary:subDic];
    
        if (picture != nil) {
            [mArray addObject:picture];
        }
        
    }
    
    
    
    return mArray;
}


+(Picture *)pictureInitWithDicctionary:(NSDictionary *)subDic{
    
    if (subDic == nil || ![subDic isKindOfClass:[NSDictionary class]]) {
        
        return nil;
    }
    
    Picture *picture = [[Picture alloc] init];
    
    if([subDic objectForKey:kContent]!=[NSNull null]){
        picture.content = [subDic objectForKey:kContent];
    }
    
    if([subDic objectForKey:kHeight]!=[NSNull null]){
        picture.height = [[subDic objectForKey:kHeight] intValue];
    }else{
        picture.height = 300;
    }
    
    if([subDic objectForKey:kPicUrl]!=[NSNull null]){
        picture.picUrl = [subDic objectForKey:kPicUrl];
    }
    
    
    if([subDic objectForKey:kWidth]!=[NSNull null]){
        picture.width = [[subDic objectForKey:kWidth] intValue];
    }else{
        picture.width = 320;
    }
    
    return picture;
}


+(NSArray *)parseArrayXml:(TBXMLElement*)element{
    
    if(NULL == element || NULL == element->name) return nil;
    if(![kChildPictures isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    while(NULL != item) {
        
        Picture *picture = [Picture parseXml:item];
        if (picture != nil) {
            [array addObject:picture];
        }
        item = item->nextSibling;
    }
    
    return array;
    
    
    
}



+(Picture *)parseXml:(TBXMLElement*)element{
    if(NULL == element || NULL == element->name) return nil;
    if(![kPicture isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    Picture *picture = [[Picture alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if([kContent isEqualToString:sName]) {
                picture.content = text;
            }else if([kHeight isEqualToString:sName]){
                picture.height = [text intValue];
            }else if([kPicUrl isEqualToString:sName]){
                picture.picUrl = text;
            }else if([kWidth isEqualToString:sName]) {
                picture.width = [text intValue];
            }else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        item = item->nextSibling;
    }
    
    return picture;
    
}


- (void)writeXmlItem:(XmlWriter*)wrt {
    
    [wrt writeStringTag:kContent Value:self.content CData:YES];
    [wrt writeIntTag:kHeight Value:self.height];
    [wrt writeStringTag:kPicUrl Value:self.picUrl CData:NO];
    [wrt writeIntTag:kWidth Value:self.width];
}

@end



@implementation Image

- (NSString *)description{
    return [NSString stringWithFormat:@"[Image childPictures :%@, collectCount:%d, commentsCount:%d, down:%d, hotTime:%@, imageId:%d , shareCount:%d, status:%d, time:%@, title:%@, up:%d, user:%@,url:%@]",self.imageArray,self.collectCount,self.commentsCount,self.down,self.hotTime,self.imageId,self.shareCount,self.status,self.time,self.title,self.up,self.user,self.url];
}

- (NSString *)stringOfId{
    return [NSString stringWithFormat:@"%d",self.imageId];
}

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
    NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
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
        Image *imageStr = [Image imageInitWithDicctionary:subDic];
        
        if (!imageStr) {
            break;
        }
        [arr addObject:imageStr];
        
        
    }

    return arr;
    
}



+(Image *)imageInitWithDicctionary:(NSDictionary *)subDic{
    if (!subDic) {
        
        return nil;
    }
    
    Image *image = [[Image alloc] init];
    
    
    if([subDic objectForKey:kChildPictures]!=[NSNull null]){
        image.imageArray =  [Picture pictureArrayInitWithArray:[subDic objectForKey:kChildPictures]];
    }
    
    if([subDic objectForKey:kCollectCount]!=[NSNull null]){
        image.collectCount = [[subDic objectForKey:kCollectCount] intValue];
    }
    
    if([subDic objectForKey:kCommentsCount]!=[NSNull null]){
        image.commentsCount = [[subDic objectForKey:kCommentsCount] intValue];
    }
    
    
    
    if([subDic objectForKey:kDown]!=[NSNull null]){
        image.down = [[subDic objectForKey:kDown] intValue];
    }
    
    
    if([subDic objectForKey:kHotTime]!=[NSNull null]){
        image.hotTime = [subDic objectForKey:kHotTime];
    }
    
    image.imageId = [[subDic objectForKey:kImageId] intValue];
    
    
    
    
    
    if([subDic objectForKey:kShareCount]!=[NSNull null]){
        image.shareCount = [[subDic objectForKey:kShareCount] intValue];
    }
    
    if([subDic objectForKey:kStatus]!=[NSNull null]){
        image.status = [[subDic objectForKey:kStatus] intValue];
    }else{
        image.status = -1; //unknow status
    }
    
    if([subDic objectForKey:kTime]!=[NSNull null]){
        image.time = [subDic objectForKey:kTime];
    }
    
    if([subDic objectForKey:kTitle]!=[NSNull null]){
        image.title = [subDic objectForKey:kTitle];
    }
    
    if([subDic objectForKey:kUp]!=[NSNull null]){
        image.up = [[subDic objectForKey:kUp] intValue];
    }
    
    if([subDic objectForKey:kUser]!=[NSNull null]){
        image.user =  [User userInitWithDicctionary:[subDic objectForKey:kUser]];
    }
    
    if([subDic objectForKey:kUrl]!=[NSNull null]){
        image.url = [subDic objectForKey:kUrl];
    }
    
    
    
    
    return image;
}



+(Image *)parseXml:(TBXMLElement*)element {
    if(NULL == element || NULL == element->name) return nil;
//    if(![kWords isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    Image *image = [[Image alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if ([kChildPictures isEqualToString:sName]) {
                image.imageArray = [Picture parseArrayXml:item];
            }else if([kCollectCount isEqualToString:sName]) {
                image.collectCount = [text intValue];
            }else if([kCommentsCount isEqualToString:sName]) {
                image.commentsCount = [text intValue];
            }else if([kDown isEqualToString:sName]){
                image.down = [text intValue];
            }else if([kHotTime isEqualToString:sName]) {
                image.hotTime = text;
            } else if([kImageId isEqualToString:sName]) {
                image.imageId = [text intValue];
            }else if([kShareCount isEqualToString:sName]) {
                image.shareCount = [text intValue];
            }else if([kStatus isEqualToString:sName]) {
                image.status = [text intValue];
            } else if([kTime isEqualToString:sName]) {
                image.time = text;
            } else if([kTitle isEqualToString:sName]) {
                image.title = text;
            } else if([kUp isEqualToString:sName]) {
                image.up = [text intValue];
            }else if([kUser isEqualToString:sName]) {
                image.user = [User parseXml:item];
            } else if([kUrl isEqualToString:sName]) {
                image.url= text;
            }else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        
        
        item = item->nextSibling;
    }
    
    return image;
    
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
                    
                    Image *image = [Image parseXml:si];
                    
                    if(nil != image) {
                        [arr addObject:image];
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
    
    [wrt writeStartTag:kChildPictures];
    for (Picture *picture in self.imageArray) {
        [wrt writeStartTag:kPicture];
        [picture writeXmlItem:wrt];
        [wrt writeEndTag:kPicture];
    }
    [wrt writeEndTag:kChildPictures];
    [wrt writeIntTag:kCollectCount Value:self.collectCount];
    [wrt writeIntTag:kCommentsCount Value:self.commentsCount];
    [wrt writeIntTag:kDown Value:self.down];
    [wrt writeStringTag:kHotTime Value:self.hotTime CData:NO];
    [wrt writeIntTag:kImageId Value:self.imageId];
    [wrt writeIntTag:kShareCount Value:self.shareCount];
    [wrt writeIntTag:kStatus Value:self.status];
    [wrt writeStringTag:kTime Value:self.time CData:NO];
    [wrt writeStringTag:kTitle Value:self.title CData:NO];
    [wrt writeIntTag:kUp Value:self.up];
    [wrt writeStringTag:kUrl Value:self.url CData:NO];
    [wrt writeStartTag:kUser];
    [self.user writeXmlItem:wrt];
    [wrt writeEndTag:kUser];
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
    
    for(Image *image in obj) {
        [wrt writeStartTag:kWords];
        
        [image writeXmlItem:wrt];
        
        [wrt writeEndTag:kWords];
    }
    
    [wrt writeEndTag:kList];
    [wrt writeEndTag:@"result"];
    
	BOOL bError = wrt.bError;
    
	
	return !bError;
    
}




@end
