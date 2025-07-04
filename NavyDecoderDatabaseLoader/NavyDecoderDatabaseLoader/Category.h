//
//  Category.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * categoryTitle;
@property (nonatomic, retain) NSSet *categoryItems;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addCategoryItemsObject:(Item *)value;
- (void)removeCategoryItemsObject:(Item *)value;
- (void)addCategoryItems:(NSSet *)values;
- (void)removeCategoryItems:(NSSet *)values;

@end
