//
//  FTSRecord.h
//  iJoke
//
//  Created by Kyle on 14-2-13.
//  Copyright (c) 2014年 FantsMaker. All rights reserved.
//

#import "FTSBaseModel.h"
#import "Constants.h"


@interface FTSRecord : FTSBaseModel

@property(nonatomic, strong) NSNumber* jokeId;
@property(nonatomic, strong) NSNumber* favorite;
@property(nonatomic, strong) NSNumber* jokeType;
@property(nonatomic, strong) NSNumber* updown;
@property(nonatomic, strong) NSString* jokeTime;

@end
