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

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSString *const MPCAppStoreId = @"588227679";

NSString *settingsBackgroundImageKey = @"backgroundImageKey";


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
							
- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *currentBackgroundImageNumber = [defaults objectForKey:settingsBackgroundImageKey];
    [defaults setObject:[NSNumber numberWithInt:[currentBackgroundImageNumber intValue] + 1] forKey:settingsBackgroundImageKey];
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

    // Open the bundled read-only SQLite database directly from the app bundle.
    NSURL *storeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DecoderData" ofType:@"sqlite"]];
    NSDictionary *readOnlyOptions = @{ NSReadOnlyPersistentStoreOption: @YES };
    NSError *error = nil;

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:readOnlyOptions error:&error]) {
        NSLog(@"Failed to open persistent store: %@, %@", error, [error userInfo]);
        _persistentStoreCoordinator = nil;
    }

    return _persistentStoreCoordinator;
}


@end
