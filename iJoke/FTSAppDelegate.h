//
//  FTSAppDelegate.h
//  iJoke
//
//  Created by Kyle on 13-7-27.
//  Copyright (c) 2013年 FantsMaker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
