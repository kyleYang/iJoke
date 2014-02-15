//
//  FTSDatabaseMgr.m
//  iJoke
//
//  Created by Kyle on 14-2-14.
//  Copyright (c) 2014年 FantsMaker. All rights reserved.
//

#import "FTSDatabaseMgr.h"

@implementation FTSDatabaseMgr


+(BOOL)jokeAddRecordWords:(Words *)words upType:(iJokeUpDownType)type managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:words.wordId],kJokeType,[NSNumber numberWithInt:WordsSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    if (record == nil) {
        record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FTSRecord class]) inManagedObjectContext:managedObjectContext];
        record.jokeId = [NSNumber numberWithInt:words.wordId];
        record.jokeType = [NSNumber numberWithInt:WordsSectionType];
        record.favorite = [NSNumber numberWithBool:FALSE];
        
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    BqsLog(@"exist time:%@",time);
    record.jokeTime = time;

    record.updown = [NSNumber numberWithInt:type];
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    return YES;
    
}

+(BOOL)jokeAddRecordWords:(Words *)words favorite:(BOOL)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:words.wordId],kJokeType,[NSNumber numberWithInt:WordsSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    if (record == nil) {
        record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FTSRecord class]) inManagedObjectContext:managedObjectContext];
        record.jokeId = [NSNumber numberWithInt:words.wordId];
        record.jokeType = [NSNumber numberWithInt:WordsSectionType];
        record.updown = [NSNumber numberWithBool:iJokeUpDownNone];
        
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    BqsLog(@"exist time:%@",time);
    record.jokeTime = time;
    
    record.favorite = [NSNumber numberWithBool:value];
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    return YES;

    
}



+(FTSRecord *)judgeRecordWords:(Words *)words managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:words.wordId],kJokeType,[NSNumber numberWithInt:WordsSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    return record;
}

+(BOOL)jokeAddRecordImage:(Image *)image upType:(iJokeUpDownType)type managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:image.imageId],kJokeType,[NSNumber numberWithInt:ImageSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    if (record == nil) {
        record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FTSRecord class]) inManagedObjectContext:managedObjectContext];
        record.jokeId = [NSNumber numberWithInt:image.imageId];
        record.jokeType = [NSNumber numberWithInt:ImageSectionType];
        record.favorite = [NSNumber numberWithBool:FALSE];
        
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    BqsLog(@"exist time:%@",time);
    record.jokeTime = time;
    
    record.updown = [NSNumber numberWithInt:type];
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    return YES;

    
}
+(BOOL)jokeAddRecordImage:(Image *)image favorite:(BOOL)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:image.imageId],kJokeType,[NSNumber numberWithInt:ImageSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    if (record == nil) {
        record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FTSRecord class]) inManagedObjectContext:managedObjectContext];
        record.jokeId = [NSNumber numberWithInt:image.imageId];
        record.jokeType = [NSNumber numberWithInt:ImageSectionType];
        record.updown = [NSNumber numberWithBool:iJokeUpDownNone];
        
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    BqsLog(@"exist time:%@",time);
    record.jokeTime = time;
    
    record.favorite = [NSNumber numberWithBool:value];
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    return YES;

    
}
+(FTSRecord *)judgeRecordImage:(Image *)image managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:image.imageId],kJokeType,[NSNumber numberWithInt:ImageSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    return record;
}


+(BOOL)jokeAddRecordVideo:(Video *)video upType:(iJokeUpDownType)type managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:video.videoId],kJokeType,[NSNumber numberWithInt:VideoSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    if (record == nil) {
        record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FTSRecord class]) inManagedObjectContext:managedObjectContext];
        record.jokeId = [NSNumber numberWithInt:video.videoId];
        record.jokeType = [NSNumber numberWithInt:VideoSectionType];
        record.favorite = [NSNumber numberWithBool:FALSE];
        
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    BqsLog(@"exist time:%@",time);
    record.jokeTime = time;
    
    record.updown = [NSNumber numberWithInt:type];
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    return YES;

}
+(BOOL)jokeAddRecordVideo:(Video *)video favorite:(BOOL)value managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:video.videoId],kJokeType,[NSNumber numberWithInt:VideoSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    if (record == nil) {
        record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FTSRecord class]) inManagedObjectContext:managedObjectContext];
        record.jokeId = [NSNumber numberWithInt:video.videoId];
        record.jokeType = [NSNumber numberWithInt:VideoSectionType];
        record.updown = [NSNumber numberWithBool:iJokeUpDownNone];
        
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    BqsLog(@"exist time:%@",time);
    record.jokeTime = time;
    
    record.favorite = [NSNumber numberWithBool:value];
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    return YES;

    
}
+(FTSRecord *)judgeRecordVideo:(Video *)video managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@) AND (%K = %@)", kJokeId, [NSNumber numberWithInt:video.videoId],kJokeType,[NSNumber numberWithInt:VideoSectionType]];
    FTSRecord *record =  (FTSRecord *)[FTSRecord fetchWithManagedObjectContext:managedObjectContext predicate:predicate];
    return record;
}



+(BOOL)freshRcordWithArray:(NSArray *)arrayNew managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
//    [FTSRecord removeAllObjectWithManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([FTSRecord class])];
    NSError *error = nil;
    NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetched != nil && [fetched count] != 0)
    {
        
        [fetched enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            [managedObjectContext deleteObject:obj];
        }];
        
        if (![managedObjectContext save:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // Fail
            return NO;
        }
    }
   
    
    [arrayNew enumerateObjectsUsingBlock:^(Record *obj, NSUInteger idx, BOOL *stop){
        
    
        FTSRecord *record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FTSRecord class]) inManagedObjectContext:managedObjectContext];
        record.jokeId = [NSNumber numberWithInt:obj.itemId];
        record.favorite = [NSNumber numberWithBool:obj.favorite];
        record.updown = [NSNumber numberWithInt:obj.updown];
        record.jokeType = [NSNumber numberWithInt:obj.type];
        record.jokeTime = obj.time;
        
        
    }];
    
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return FALSE;
    }
    return TRUE;
    
}

+(BOOL)removeAllRecordManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    return [FTSRecord removeAllObjectWithManagedObjectContext:managedObjectContext];
}

+(BOOL)removeRedundancyRecodeManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([FTSRecord class])];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:kJokeTime ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    NSError *error = nil;
    NSArray *fetched = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetched != nil && [fetched count] != 0)
    {
        if ([fetched count] > kMaxRecordNumber) {
            

            [fetched enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
            {
                if (idx >= kMaxRecordNumber) {
                    [managedObjectContext deleteObject:obj];
                }
               
            }];
            
            if (![managedObjectContext save:&error]) {
                // Update to handle the error appropriately.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                // Fail
                return NO;
            }

        }
        
    }
        return YES;

}


@end
