//
//  Constants.h
//  iJoke
//
//  Created by Kyle on 14-2-14.
//  Copyright (c) 2014年 FantsMaker. All rights reserved.
//

#ifndef iJoke_Constants_h
#define iJoke_Constants_h


enum UserSection {
    WordsSectionType = 0,
    ImageSectionType = 1,
    VideoSectionType = 2,
};


typedef enum {
    UnionLogoinTypeNone = 0,
    UnionLogoinTypeSina = 1,                 //sina weibo
    UnionLogoinTypeQQSpace = 2,              //QQ space
    UnionLogoinTypeTenc = 3,                 //tencent weibo
    UnionLogoinTypeMobileQQ = 4,
} UnionLogoinType;

typedef enum {
    UnionLoginUserAttach = 0,
    UnionLoginUserNew = 1,
}UnionLoginUserType;


typedef NS_ENUM(NSInteger, iJokeUpDownType)
{
    iJokeUpDownDown = -1,
    iJokeUpDownNone = 0,
    iJokeUpDownUp = 1,
};


#define kMaxRecordNumber 1000

// -------------record
#define kJokeId @"jokeId"
#define kJokeType @"jokeType"
#define kJokeTime @"jokeTime"


/*********Equipment*******/
#define kShopNumber @"shopNumber"
#define kEquipOrder @"equipOrder"
#define kEquipSN @"equipSN"
#define kMaterialSN @"materialSN"
#define kUpgradSN @"upgradSN"



#endif

