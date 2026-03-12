//
// ItemViewController.m
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

#import "ItemViewController.h"

#import "DetailTableViewController.h"
#import "NDDataStore.h"
#import "NDDecoderItem.h"
#import "ViewConstants.h"

@interface ItemViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray<NDDecoderItem *> *allItems;
@property (nonatomic, strong) NSArray<NDDecoderItem *> *displayedItems;

@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"Select %@", self.categoryTitle];
    self.navigationItem.backButtonTitle = self.categoryTitle;

    self.allItems = [[NDDataStore sharedStore] itemsForCategoryTitle:self.categoryTitle];
    self.displayedItems = self.allItems;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Search for Code";
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    self.tableView.tableHeaderView = [self makeNoticeHeaderView];
    self.definesPresentationContext = YES;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;

    if (searchString.length == 0) {
        self.displayedItems = self.allItems;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                                  @"codeKey CONTAINS[c] %@ OR codeValue CONTAINS[c] %@", searchString, searchString];
        self.displayedItems = [self.allItems filteredArrayUsingPredicate:predicate];
    }

    [self.tableView reloadData];

    BOOL hasResults = self.displayedItems.count > 0;
    BOOL isSearching = searchString.length > 0;
    if (isSearching && !hasResults) {
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"No results for \"%@\"", searchString];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor secondaryLabelColor];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        label.numberOfLines = 0;
        self.tableView.backgroundView = label;
    } else if ([self.tableView.backgroundView isKindOfClass:[UILabel class]]) {
        [self setBackgroundForSize:self.tableView.bounds.size];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.displayedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemToDecodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    NDDecoderItem *item = self.displayedItems[indexPath.row];
    cell.textLabel.text = item.codeKey;

    UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                                    ? UIFontTextStyleTitle3
                                    : UIFontTextStyleBody;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:textStyle];
    cell.textLabel.adjustsFontForContentSizeCategory = YES;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Segue Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NDDecoderItem *item = nil;

    if ([[segue identifier] isEqualToString:kSegueShowDetails]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        item = self.displayedItems[indexPath.row];
    } else if ([[segue identifier] isEqualToString:kSegueShowDetailsAccessoryButton]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        item = self.displayedItems[indexPath.row];
    }

    if (item) {
        [(DetailTableViewController *)segue.destinationViewController setItem:item];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:kSegueShowDetailsAccessoryButton sender:indexPath];
}

@end
