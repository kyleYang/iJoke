//
//  FTSUserCenter.h
//  iJoke
//
//  Created by Kyle on 13-7-30.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>


//net
#define kDftHaveNetWork @"iJoke.network.have"
#define kDftNetTypeWifi @"iJoke.network.type"//net type

#define kFirstUseJoke @"dota.first.use"
#define kScreenPlayType @"screenplaytype"
#define kScreenDownType @"screendowntype"

//words
#define kDftNewWordsSaveTime @"ijoke.new.words.date"
#define kDftHotWordsSaveTime @"iJoke.hot.words.date"
#define kRefreshNewWordIntervalS (60*60*0.5)
#define kRefreshHotWordIntervalS (60*60*0.5)

//image
#define kDftNewImageSaveTime @"ijoke.new.image.date"
#define kDftHotImageSaveTime @"iJoke.hot.image.date"
#define kRefreshNewImageIntervalS (60*60*0.5)
#define kRefreshHotImageIntervalS (60*60*0.5)

//video
#define kDftNewVideoSaveTime @"ijoke.new.video.date"
#define kDftHotVideoSaveTime @"iJoke.hot.video.date"
#define kRefreshNewVideoIntervalS (60*60*0.5)
#define kRefreshHotVideoIntervalS (60*60*0.5)


//topic
#define kDftTopicSaveTime @"ijoke.topic"
#define kRefreshTopicIntervalS (60*60*2)

#define kDftTopicImageDetailSaveTimeId @"ijoke.topic.image.detail.%d"
#define kRefreshTopicImageDetailIntervalS (60*60*6)

#define kDftTopicVideoDetailSaveTimeId @"ijoke.topic.Video.detail.%d"
#define kRefreshTopicVideoDetailIntervalS (60*60*6)

#define kDftCollectMessageSaveTimeId @"ijoke.collect.message.date"
#define kRefreshCollectMessageIntervalS (60*60*24)

#define kDftPublishMessageSaveTimeId @"ijoke.collect.publish"
#define kRefreshPublishMessageIntervalS (60*60*24)

//user (important)

#define kDftMessageSynchroniz @"ijoke.message.synchroniz"

#define kDftUserId @"ijoke.user.id" //self register is e-mail
#define kDftUserName @"ijoke.user.name" //self register is e-mail
#define kDftUserNickName @"ijoke.user.nickname"
#define kDftUserIcon @"ijoke.user.icon"
#define kDftUserPassword @"ijoke.user.password"
#define kDftUserPassport @"ijoke.user.passport"
#define kDftUserLogin @"ijoke.user.login"

//union
#define kDftUserUnionSuccess @"ijoke.user.union.success"
#define kDftUserUnionWay @"ijoke.user.union.way"
#define kDftUserUnionType @"ijoke.user.union.type"
#define kDftUserUnionName @"ijoke.user.union.name"

@interface FTSUserCenter : NSObject


+(int)intValueForKey:(NSString *)key;
+(void)setIntValue:(int)value forKey:(NSString *)key;

+(CGFloat)floatValueForKey:(NSString *)key;
+(void)setFloatVaule:(CGFloat)value forKey:(NSString *)key;

+(BOOL)BoolValueForKey:(NSString *)key;
+(void)setBoolVaule:(BOOL)value forKey:(NSString *)key;

+(id)objectValueForKey:(NSString *)key;
+(void)setObjectValue:(id)value forKey:(NSString *)key;


@end
