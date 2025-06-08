//
//  main.m
//  NavyDecoderDatabaseLoader
//
// This file is part of Navy Decoder Databaase Loader app.
//
// Navy Decoder Databaase Loader app is free software: you can redistribute it
// and/or modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// Navy Decoder Databaase Loader app is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Navy Decoder Databaase Loader app.
// If not, see <https://www.gnu.org/licenses/>.
//
// Copyright (c) 2014-2025 Crash Test Dummy Limited, LLC
//


/***************************************************************************************************

http://www.raywenderlich.com/12170/core-data-tutorial-how-to-preloadimport-existing-data-updated

***************************************************************************************************/

#import "Category.h"
#import "Item.h"
#import "Details.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
//    NSString *path = @"NavyDecoderDatabaseLoader";
//    path = [path stringByDeletingPathExtension];
    NSString *path = @"DatabaseModel";
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        // Updated options from nil to @{NSSQLitePragmasOption:@{ @"journal_mode" : @"DELETE" }} per:
        // https://developer.apple.com/library/ios/releasenotes/DataManagement/WhatsNew_CoreData_iOS/#//apple_ref/doc/uid/TP40013394-CH1-SW1
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:@{NSSQLitePragmasOption:@{ @"journal_mode" : @"DELETE" }} error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        NSError* err = nil;
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"DecoderData" ofType:@"json"];
        NSArray* DecoderData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
        NSLog(@"Imported Decoder Data: %@", DecoderData);
        
 
        
        __block NSString* categoryTitleLast;
        __block Category* category;
        __block NSMutableSet* setOfItems;
        
        [DecoderData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSString *categoryTitleNew = [obj objectForKey:@"categoryTitle"];
            
            if (![categoryTitleNew isEqualToString:categoryTitleLast]){
                category = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Category"
                                      inManagedObjectContext:context];
                category.categoryTitle = [obj objectForKey:@"categoryTitle"];
//                [category setValue:categoryTitleNew forKey:@"categoryTitle"];
                setOfItems = [category mutableSetValueForKey:@"categoryItems"];
                categoryTitleLast = categoryTitleNew;
            }
           
            Item *item = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Item"
                          inManagedObjectContext:context];
            item.codeKey = [obj objectForKey:@"codeKey"];
            [setOfItems addObject:item];

            Details *details = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Details"
                                inManagedObjectContext:context];
            details.codeValue = [obj objectForKey:@"codeValue"];
            details.codeSource = [obj objectForKey:@"codeSource"];
            [details setValue:item forKey:@"itemKey"];
            [item setValue:details forKey:@"itemDetails"];
            [item setValue:category forKey:@"categorySource"];
           
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }];
/*
        // Test listing all FailedBankInfos from the store
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FailedBankInfo"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (FailedBankInfo *info in fetchedObjects) {
            NSLog(@"Name: %@", info.name);
            FailedBankDetails *details = info.details;
            NSLog(@"Zip: %@", details.zip);
        }
*/
 }
    return 0;
}

