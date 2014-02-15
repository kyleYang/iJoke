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

@property(nonatomic, retain) NSNumber* jokeId;
@property(nonatomic, retain) NSNumber* favorite;
@property(nonatomic, retain) NSNumber* jokeType;
@property(nonatomic, retain) NSNumber* updown;
@property(nonatomic, retain) NSString* jokeTime;

@end
