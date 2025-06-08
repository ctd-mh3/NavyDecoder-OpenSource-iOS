//
// NavyDecoderAppDelegate.m
// NavyDecoder-iOS
//
// This file is part of Navy Decoder-iOS.
//
// Navy Decoder-iOS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Navy Decoder-iOS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Navy Decoder-iOS.  If not, see <https://www.gnu.org/licenses/>.
//
// Copyright (c) 2014-2025 Crash Test Dummy Limited, LLC
//

#import "NavyDecoderAppDelegate.h"

#import "CategoryViewController.h"

@implementation NavyDecoderAppDelegate

NSString *const MPCAppStoreId = @"588227679";

NSString *settingsBackgroundImageKey = @"backgroundImageKey";

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    CategoryViewController *controller = (CategoryViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;

    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:1], settingsBackgroundImageKey,
                                 nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    // Set background color to clear
    [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Grab the default/saved values which be used in calculations
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSNumber *currentBackgroundImageNumber = [defaults objectForKey:settingsBackgroundImageKey];
    
    [defaults setObject:[NSNumber numberWithInt:[currentBackgroundImageNumber intValue] + 1] forKey:settingsBackgroundImageKey];
    
    [defaults synchronize];

    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NavyDecoder" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
   
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
   
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // 20140101: Updated processing to now just have the NRPersistentStoreCoordinator point to the sqlite db in the
    //           application's Bundle and not by copying that db to the app's Documents directory and then using
    //           the db in the Documents directory.
    //
    //           Reasons:
    //           1) The code provided in the tutorial does not appear to handle when the app is updated with a new
    //              database.  It would just not copy the new database to the NRPersistentStoreCoordinator
    //           2) Temp code was added to delete the database in the Documents directory if present and then copy
    //              the db from the application bundle, but there appears to be no reason to add this complexity.
    //              Since the user cannot change the database, we can just point to the application bundle's
    //              db file and read it in as reaad-only.
    
    
    
    // From http://www.raywenderlich.com/12170/core-data-tutorial-how-to-preloadimport-existing-data-updated
    // Original code provided by tutorial
    //NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DecoderData.sqlite"];

    // If there is a not a database with this name in the Documents directory
    //if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
    //    NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DecoderData" ofType:@"sqlite"]];
    //    NSError* err = nil;
    //    if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
    //        NSLog(@"Oops, could not copy preloaded data");                }
    //}
    
    // Updated temp code to delete a db found in the Documents directory and then copy the file
    //if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
    //    NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DecoderData" ofType:@"sqlite"]];
    //    NSError* err = nil;
    //    if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
    //        // If an error occurs, it's probably because a previous backup directory
    //        // already exists.  Delete the old directory and try again.
    //        if ([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&err]) {
    //            // If the operation failed again, abort for real.
    //            if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
    //                NSLog(@"Oops, could not copy preloaded data");                }
    //        }
    //    }
    //}
    
    // 20140101: Updated processing to now just have the NRPersistentStoreCoordinator point to the sqlite db in the
    //           application's Bundle and not by copying that db to the app's Documents directory and then using
    //           the db in the Documents directory.
    NSURL *refactoredStoreURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DecoderData" ofType:@"sqlite"]];

    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    // 20140101: Added to ensure the NSPersistentStoreCoordinator reads the Bundle's db file as read-only since
    //           it is not appropriate to allow the app to modify anything in the Bundle
    NSDictionary *readOnlyOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSReadOnlyPersistentStoreOption, nil];

    // 20140101: Use the URL that points to the Bundle's db file and used the ReadOnly options
    //if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:refactoredStoreURL options:readOnlyOptions error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
