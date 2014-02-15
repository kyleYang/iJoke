//
//  FTSBaseModel.m
//  iJoke
//
//  Created by Kyle on 14-2-13.
//  Copyright (c) 2014年 FantsMaker. All rights reserved.
//

#import "FTSBaseModel.h"

@implementation FTSBaseModel

+ (id)insertWithManagedObjectContext:(NSManagedObjectContext *)context value:(NSDictionary *)dictionary
{
    return nil;
}

+ (NSFetchedResultsController *)fetchedResultsControllerWithManagedObjectContext:(NSManagedObjectContext *)context sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate
{
	// Create and configure a fetch request with the Certain entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:sortDescriptors];
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    //    NSError *error;
    //	if (![fetchedResultsController performFetch:&error]) {
    //		// Update to handle the error appropriately.
    //		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    //		abort();
    //	}
    
	return fetchedResultsController;
}

+ (NSMutableArray *)fetchedResultsWithManagedObjectContext:(NSManagedObjectContext *)context sortDescriptors:(NSArray *)sortDescriptors
{
    // Create and configure a fetch request with the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *fetched = [context executeFetchRequest:fetchRequest error:nil];
    if (fetched == nil) {
        return [NSMutableArray array];
    } else {
        return [NSMutableArray arrayWithArray:fetched];
    }
}

+ (NSMutableArray *)fetchedResultsWithManagedObjectContext:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate
{
    //NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:kOrder ascending:YES];
    //NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    [fetchRequest setPredicate:predicate];
    //[fetchRequest setSortDescriptors:sortDescriptors];
    NSLog(@"predicate:%@",predicate);
    
    NSError *error = nil;
    NSArray *fetched = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"fetched:%@",fetched);
    if (fetched == nil) {
        return [NSMutableArray array];
    } else {
        return [NSMutableArray arrayWithArray:fetched];
    }
}

+ (NSMutableArray *)fetchedResultsWithManagedObjectContext:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    //NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:kOrder ascending:YES];
    //NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSLog(@"predicate:%@",predicate);
    
    NSError *error = nil;
    NSArray *fetched = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"fetched:%@",fetched);
    if (fetched == nil) {
        return [NSMutableArray array];
    } else {
        return [NSMutableArray arrayWithArray:fetched];
    }
}

+ (id)fetchWithManagedObjectContext:(NSManagedObjectContext *)context keyAttributeName:(NSString *)name keyAttributeValue:(id)attribute
{
    NSString *keyString = (NSString *)attribute;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", name, keyString];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetched = [context executeFetchRequest:fetchRequest error:&error];
    if (fetched != nil && [fetched count] != 0)
    {
        return [fetched lastObject];
    }
    
    return nil;
}

+ (id)fetchWithManagedObjectContext:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetched = [context executeFetchRequest:fetchRequest error:&error];
    if (fetched != nil && [fetched count] != 0)
    {
        return [fetched lastObject];
    }
    
    return nil;
}

+(BOOL)removeAllObjectWithManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSError *error = nil;
    NSArray *fetched = [context executeFetchRequest:fetchRequest error:&error];
    if (fetched != nil && [fetched count] != 0)
    {
        
        [fetched enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            [context deleteObject:obj];
        }];
    }
    if (![context save:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        // Fail
        return NO;
    }
    return YES;
}

- (BOOL)removeObject
{
    [self.managedObjectContext deleteObject:self];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        // Fail
        return NO;
    }
    return YES;
}


@end
