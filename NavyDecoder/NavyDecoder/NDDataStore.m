//
// NDDataStore.m
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

#import "NDDataStore.h"
#import "NDDecoderItem.h"

@interface NDDataStore ()

@property (nonatomic, strong) NSDictionary<NSString *, NSArray<NDDecoderItem *> *> *categoryItems;
@property (nonatomic, strong) NSArray<NSString *> *sortedCategoryTitles;
@property (nonatomic, strong) NSArray<NDDecoderItem *> *allItems;

@end

@implementation NDDataStore

+ (instancetype)sharedStore {
    static NDDataStore *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NDDataStore alloc] init];
        [instance loadData];
    });
    return instance;
}

- (void)loadData {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"DecoderData" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSArray *records = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    NSMutableDictionary *grouped = [NSMutableDictionary dictionary];
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:records.count];

    for (NSDictionary *dict in records) {
        NDDecoderItem *item = [[NDDecoderItem alloc] initWithDictionary:dict];
        [all addObject:item];
        NSString *title = item.categoryTitle;
        if (!grouped[title]) {
            grouped[title] = [NSMutableArray array];
        }
        [(NSMutableArray *)grouped[title] addObject:item];
    }

    NSSortDescriptor *codeKeySort = [NSSortDescriptor sortDescriptorWithKey:@"codeKey" ascending:YES];
    NSMutableDictionary *sortedItems = [NSMutableDictionary dictionaryWithCapacity:grouped.count];
    for (NSString *title in grouped) {
        sortedItems[title] = [grouped[title] sortedArrayUsingDescriptors:@[codeKeySort]];
    }

    self.categoryItems = [sortedItems copy];
    self.allItems = [all copy];
    self.sortedCategoryTitles = [grouped.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray<NSString *> *)categoryTitles {
    return self.sortedCategoryTitles;
}

- (NSArray<NDDecoderItem *> *)itemsForCategoryTitle:(NSString *)title {
    return self.categoryItems[title] ?: @[];
}

- (NSArray<NDDecoderItem *> *)searchAllItemsForText:(NSString *)text {
    if (text.length == 0) return @[];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"codeKey CONTAINS[c] %@ OR codeValue CONTAINS[c] %@", text, text];
    return [self.allItems filteredArrayUsingPredicate:predicate];
}

@end
