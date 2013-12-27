//
//  Draft.m
//  iJoke
//
//  Created by Kyle on 13-9-6.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "Draft.h"

#define kList @"list"
#define kWeib @"draft"
#define kTitle @"title"
#define kContent @"content"
#define kPicUrl @"picurl"
#define kUrl @"url"


@implementation Draft

@synthesize picurl,content,url,title;

-(id)init {
    self = [super init];
    if(nil == self) return nil;
    
    return self;
}

-(void)dealloc {
    
    self.picurl = nil;
    self.content = nil;
    self.title = nil;
    self.url = nil;

}

-(NSString*)description {
    return [NSString stringWithFormat:@"[Draft title:%@,content:%@,url:%@,picurl:%@]",
            self.title, self.content,self.url,self.picurl];
}

- (void)writeXmlItem:(XmlWriter*)wrt {
    
    [wrt writeStringTag:kTitle Value:self.title CData:YES];
    [wrt writeStringTag:kContent Value:self.content CData:YES];
    [wrt writeStringTag:kUrl Value:self.url CData:YES];
    [wrt writeStringTag:kPicUrl Value:self.picurl CData:YES];
    
}

+(Draft *)parseXml:(TBXMLElement*)element {
    if(NULL == element || NULL == element->name) return nil;
    if(![kWeib isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    Draft *cid = [[Draft alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if([kTitle isEqualToString:sName]){
                cid.title = text;
            } else if([kContent isEqualToString:sName]) {
                cid.content = text;
            }else if([kUrl isEqualToString:sName]) {
                cid.url = text;
            }else if([kPicUrl isEqualToString:sName]) {
                cid.picurl = text;
            } else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        
        
        item = item->nextSibling;
    }
    return cid;
    
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
                if([kWeib isEqualToString:siName]) {
                    
                    Draft *ch = [Draft parseXml:si];
                    
                    if(nil != ch) {
                        [arr addObject:ch];
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
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj {
	if(nil == obj || nil == path || path.length < 1) {
		BqsLog(@"Invalid param. path: %@, obj: %@", path, obj);
		return NO;
	}
	
	XmlWriter *wrt = [[XmlWriter alloc] initWithFile:path];
	if(nil == wrt) {
		BqsLog(@"Can't write to %@", path);
		return NO;
	}
    
    [wrt writeStartTag:@"result"];
    [wrt writeStartTag:kList];
    
    for(Draft *cat in obj) {
        [wrt writeStartTag:kWeib];
        
        [cat writeXmlItem:wrt];
        
        [wrt writeEndTag:kWeib];
    }
    
    [wrt writeEndTag:kList];
    [wrt writeEndTag:@"result"];
    
	BOOL bError = wrt.bError;
	return !bError;
    
}

@end
