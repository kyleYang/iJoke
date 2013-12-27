//
//  Comment.m
//  iJoke
//
//  Created by Kyle on 13-8-31.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "Comment.h"

#define kList @"list"
#define kAddtime @"addtime"
#define kArticleId @"articleId"
#define kComment @"comment"
#define kId @"id"
#define KUserId @"userId"
#define kUserName @"userName"
#define kUserPicUrl @"userPicUrl"

#define kCommentStuct @"commentStruct"


@implementation Comment




- (NSString *)description{
    return [NSString stringWithFormat:@"[Comment addtime%@, articleId:%d, comment:%@, id:%d, user:%@]",self.addtime,self.articleId,self.comment,self.commentId,self.user];
}



+(Comment *)wordInitWithDicctionary:(NSDictionary *)subDic{
    if (!subDic) {
        
        return nil;
    }
    
    Comment *comment = [[Comment alloc] init];
    
    if([subDic objectForKey:kAddtime]!=[NSNull null]){
        comment.addtime = [subDic objectForKey:kAddtime];
    }
    
    if([subDic objectForKey:kArticleId]!=[NSNull null]){
        comment.articleId = [[subDic objectForKey:kArticleId] integerValue];
    }
    
    if([subDic objectForKey:kComment]!=[NSNull null]){
        comment.comment = [subDic objectForKey:kComment];
    }
    
    if([subDic objectForKey:kId]!=[NSNull null]){
        comment.commentId = [[subDic objectForKey:kId] integerValue];
    }
    
    if([subDic objectForKey:kUser]!=[NSNull null]){
        comment.user =  [User userInitWithDicctionary:[subDic objectForKey:kUser]];
    }

    
    return comment;
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
        Comment *comment = [Comment wordInitWithDicctionary:subDic];
        
        if (!comment) {
            break;
        }
        [arr addObject:comment];
        
        
    }
    return arr;
    
}



+(Comment *)parseXml:(TBXMLElement*)element {
    if(NULL == element || NULL == element->name) return nil;
    if(![kCommentStuct isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    Comment *comment = [[Comment alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if([kAddtime isEqualToString:sName]) {
                comment.addtime = text;
            }else if([kArticleId isEqualToString:sName]){
                comment.articleId = [text integerValue];
            }else if([kComment isEqualToString:sName]){
                comment.comment = text;
            }else if([kId isEqualToString:sName]) {
                comment.commentId = [text integerValue];
            }else if([kUser isEqualToString:sName]) {
                comment.user = [User parseXml:item];
            } else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        
        
        item = item->nextSibling;
    }
    
    return comment;
    
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
                if([kCommentStuct isEqualToString:siName]) {
                    
                    Comment *comment= [Comment parseXml:si];
                    
                    if(nil != comment) {
                        [arr addObject:comment];
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
    
    [wrt writeStringTag:kAddtime Value:self.addtime CData:NO];
    [wrt writeIntTag:kArticleId Value:self.articleId];
    [wrt writeStringTag:kComment Value:self.comment CData:NO];
    [wrt writeIntTag:kId Value:self.commentId];
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
    
    for(Comment *comment in obj) {
        [wrt writeStartTag:kCommentStuct];
        
        [comment writeXmlItem:wrt];
        
        [wrt writeEndTag:kCommentStuct];
    }
    
    [wrt writeEndTag:kList];
    [wrt writeEndTag:@"result"];
    
	BOOL bError = wrt.bError;
    
	
	return !bError;
    
}




@end
