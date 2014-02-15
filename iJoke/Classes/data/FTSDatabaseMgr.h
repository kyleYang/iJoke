//
//  FTSDatabaseMgr.h
//  iJoke
//
//  Created by Kyle on 14-2-14.
//  Copyright (c) 2014年 FantsMaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "FTSRecord.h"
#import "Record.h"
#import "Words.h"
#import "Image.h"
#import "Video.h"

@interface FTSDatabaseMgr : NSObject

+(BOOL)jokeAddRecordWords:(Words *)words upType:(iJokeUpDownType)type managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(BOOL)jokeAddRecordWords:(Words *)words favorite:(BOOL)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(FTSRecord *)judgeRecordWords:(Words *)words managedObjectContext:(NSManagedObjectContext *)managedObjectContext;


+(BOOL)jokeAddRecordImage:(Image *)image upType:(iJokeUpDownType)type managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(BOOL)jokeAddRecordImage:(Image *)image favorite:(BOOL)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(FTSRecord *)judgeRecordImage:(Image *)image managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+(BOOL)jokeAddRecordVideo:(Video *)video upType:(iJokeUpDownType)type managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(BOOL)jokeAddRecordVideo:(Video *)video favorite:(BOOL)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(FTSRecord *)judgeRecordVideo:(Video *)video managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+(BOOL)freshRcordWithArray:(NSArray *)arrayNew managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(BOOL)removeAllRecordManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+(BOOL)removeRedundancyRecodeManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end
