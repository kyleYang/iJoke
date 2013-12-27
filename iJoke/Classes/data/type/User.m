//
//  User.m
//  iJoke
//
//  Created by Kyle on 13-8-26.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "User.h"

#define kUsrInfo @"userInfo"
#define kIcon @"icon"
#define kId @"id"
#define kName @"name"
#define kNickName @"nickName"

@implementation User

- (NSString *)description{
    return [NSString stringWithFormat:@"[user id:%d, name:%@, nickName:%@ icon:%@,]",self.userId,self.userName,self.nikeName,self.icon];
}

- (NSString *)stringOfUserId{
    return [NSString stringWithFormat:@"%d", self.userId];
}


+(User *)userInfoForLogData:(NSData *)data{
    
    NSError *err;
    NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
    NSDictionary *userDic = [resultsDictionary objectForKey:kUsrInfo];
    
    return [User userInitWithDicctionary:userDic];
    
}

+(User *)userInitWithDicctionary:(NSDictionary *)subDic{
    if (subDic == nil || ![subDic isKindOfClass:[NSDictionary class]]) {
        
        return nil;
    }
    
    User *user = [[User alloc] init];
    
    if([subDic objectForKey:kIcon]!=[NSNull null]){
        user.icon = [subDic objectForKey:kIcon];
    }
    
    if([subDic objectForKey:kId]!=[NSNull null]){
        user.userId = [[subDic objectForKey:kId] intValue];
    }
    
    if([subDic objectForKey:kName]!=[NSNull null]){
        user.userName = [subDic objectForKey:kName];
    }
    
    if([subDic objectForKey:kNickName]!=[NSNull null]){
        user.nikeName = [subDic objectForKey:kNickName];
    }
    
    return user;
}



+(User *)parseXml:(TBXMLElement*)element {
    if(NULL == element || NULL == element->name) return nil;
    if(![kUser isEqualToString:[TBXML elementName:element]]) return nil;
    
    TBXMLElement *item = element->firstChild;
    
    if(NULL == item) return nil;
    
    // item
    User *user = [[User alloc] init];
    
    while(NULL != item) {
        
        if(NULL != item->name) {
            NSString *sName = [TBXML elementName:item];
            NSString *text = [TBXML textForElement:item];
            
            if([kId isEqualToString:sName]) {
                user.userId = [text intValue];
            }else if([kName isEqualToString:sName]){
                user.userName = text;
            }else if([kNickName isEqualToString:sName]){
                user.nikeName = text;
            }else if([kIcon isEqualToString:sName]) {
                user.icon = text;
            }else {
                BqsLog(@"unknown tag: %@", sName);
            }
        }
        item = item->nextSibling;
    }
    
    return user;
    
}


- (void)writeXmlItem:(XmlWriter*)wrt {

    [wrt writeIntTag:kId Value:self.userId];
    [wrt writeStringTag:kName Value:self.userName CData:NO];
    [wrt writeStringTag:kNickName Value:self.nikeName CData:YES];
    [wrt writeStringTag:kIcon Value:self.icon CData:YES];
}






@end
