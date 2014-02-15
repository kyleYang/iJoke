//
//  FTSRecord.m
//  iJoke
//
//  Created by Kyle on 14-2-13.
//  Copyright (c) 2014年 FantsMaker. All rights reserved.
//

#import "FTSRecord.h"

@implementation FTSRecord

@dynamic jokeId;
@dynamic favorite;
@dynamic jokeType;
@dynamic updown;
@dynamic jokeTime;


- (NSString *)description{
    return [NSString stringWithFormat:@"[Joke jokeId:%@,jokeType:%@,favorite:%@,updown:%@,jokeTime:%@]",
            self.jokeId, self.favorite,self.jokeType,self.updown,self.jokeTime];
}


@end
