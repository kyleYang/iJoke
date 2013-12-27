//
//  Msg.m
//  iJoke
//
//  Created by Kyle on 13-8-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import "Msg.h"


#define kCode @"code"
#define kFreshSize @"freshSize"
#define kMsg @"msg"
#define kPassport @"passport"

@implementation Msg



- (id)init{
    self = [super init];
    if (self) {
        self.code = FALSE;
    }
    return self;
}


- (NSString *)description{
    return [NSString stringWithFormat:@"[Msg: code:%d, freshSize:%d msg:%@, passport:%@]",self.code,self.freshSize,self.msg, self.passport];
}

+(Msg *)msgInitWithDicctionary:(NSDictionary *)subDic{
    if (!subDic) {
        
        return nil;
    }
    
    Msg *msg = [[Msg alloc] init];
    
    if([subDic objectForKey:kCode]!=[NSNull null]){
        msg.code = ![[subDic objectForKey:kCode] boolValue];
    }
    
    if([subDic objectForKey:kFreshSize]!=[NSNull null]){
        msg.freshSize = [[subDic objectForKey:kFreshSize] intValue];
    }
    

    if([subDic objectForKey:kMsg]!=[NSNull null]){
        msg.msg = [subDic objectForKey:kMsg];
    }
    
    
    if([subDic objectForKey:kPassport]!=[NSNull null]){
        msg.passport = [subDic objectForKey:kPassport];
    }
    
    return msg;
}



+(Msg *)parseJsonData:(NSData*)data{
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
    
    Msg *msg = [Msg msgInitWithDicctionary:resultsDictionary];
    
    return msg;
    
}


@end
