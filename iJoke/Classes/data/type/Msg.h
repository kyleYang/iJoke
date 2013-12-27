//
//  Msg.h
//  iJoke
//
//  Created by Kyle on 13-8-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Msg : NSObject

@property (nonatomic, assign) BOOL code;
@property (nonatomic, assign) NSInteger freshSize;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSString *passport;



+(Msg *)msgInitWithDicctionary:(NSDictionary *)subDic;
+(Msg *)parseJsonData:(NSData*)data;

@end
