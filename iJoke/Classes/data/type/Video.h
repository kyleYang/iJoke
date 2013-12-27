//
//  Video.h
//  DotAer
//
//  Created by Kyle on 13-1-29.
//  Copyright (c) 2013年 KyleYang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XmlWriter.h"
#import "TBXML.h"
#import "User.h"

typedef enum
{
   
    VideoScreenNormal = 0,
    VideoScreenClear = 1, //default
    VideoScreenHD = 2,
    VideoScreenUnknow = 3
}VideoScreenStatus;

typedef VideoScreenStatus VideoScreen;




@interface Video : NSObject

@property (nonatomic, assign) NSInteger collectCount;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, copy) NSString *mp4;
@property (nonatomic, assign) NSInteger down;
@property (nonatomic, copy) NSString *flv;
@property (nonatomic, copy) NSString *hd2;
@property (nonatomic, copy) NSString *hotTime;
@property (nonatomic, assign) NSInteger videoId;
@property (nonatomic, copy) NSString *picture;
@property (nonatomic, assign) NSInteger shareCount;
@property (nonatomic, assign) BOOL showUser;
@property (nonatomic, assign) BOOL status;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *uniqueKey;
@property (nonatomic, assign) NSInteger up;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *youkuId;

- (NSString *)stringOfId;
- (NSString *)reviewStatus;

+(NSArray *)parseJsonData:(NSData*)data;
+(Video *)videoInitWithDicctionary:(NSDictionary *)subDic;
+(NSArray *)parseXmlData:(NSData*)data;
+(Video *)parseXml:(TBXMLElement*)element;
- (void)writeXmlItem:(XmlWriter*)wrt;
+(BOOL)saveToFile:(NSString*)path Arr:(NSArray*)obj;



@end
