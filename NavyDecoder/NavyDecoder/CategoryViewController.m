//
// CategoryViewController.m
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

#import "CategoryViewController.h"

#import "ItemViewController.h"
#import "RfasViewController.h"
#import "DetailTableViewController.h"
#import "NDDataStore.h"
#import "NDDecoderItem.h"
#import "ViewConstants.h"

@interface CategoryViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray<NDDecoderItem *> *searchResults;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    self.navigationItem.backButtonTitle = @"Categories";
    self.navigationItem.rightBarButtonItem.image = [UIImage systemImageNamed:@"info.circle.fill"];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Search All Categories";
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = YES;
    self.definesPresentationContext = YES;

    self.searchResults = @[];
    self.tableView.tableHeaderView = [self makeNoticeHeaderView];
}

#pragma mark - Search State

- (BOOL)isSearchActive {
    return self.searchController.isActive && self.searchController.searchBar.text.length > 0;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;

    if (searchString.length > 0) {
        self.searchResults = [[NDDataStore sharedStore] searchAllItemsForText:searchString];
    } else {
        self.searchResults = @[];
    }

    [self.tableView reloadData];

    BOOL hasResults = self.searchResults.count > 0;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self isSearchActive] ? nil : @"Select a Category";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self isSearchActive] ? 0 : 36;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [super tableView:tableView willDisplayHeaderView:view forSection:section];
    ((UITableViewHeaderFooterView *)view).textLabel.textColor = UIColor.labelColor;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSearchActive]) {
        return (NSInteger)self.searchResults.count;
    }

    NSInteger count = (NSInteger)[[NDDataStore sharedStore] categoryTitles].count;
    if (count == 0) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"No categories available.";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor secondaryLabelColor];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.tableView.backgroundView = label;
    } else if ([self.tableView.backgroundView isKindOfClass:[UILabel class]]) {
        self.tableView.backgroundView = nil;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                                    ? UIFontTextStyleTitle3
                                    : UIFontTextStyleBody;

    if ([self isSearchActive]) {
        static NSString *searchCellId = @"GlobalSearchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchCellId];
        }
        NDDecoderItem *item = self.searchResults[indexPath.row];
        cell.textLabel.text = item.codeKey;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:textStyle];
        cell.textLabel.adjustsFontForContentSizeCategory = YES;
        cell.detailTextLabel.text = item.categoryTitle;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    NSString *title = [[NDDataStore sharedStore] categoryTitles][indexPath.row];
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:textStyle];
    cell.textLabel.adjustsFontForContentSizeCategory = YES;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isSearchActive]) {
        [self performSegueWithIdentifier:kSegueShowGlobalSearchDetail
                                  sender:[tableView cellForRowAtIndexPath:indexPath]];
        return;
    }

    NSString *title = [[NDDataStore sharedStore] categoryTitles][indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([title rangeOfString:@"RFAS"].location == NSNotFound) {
        [self performSegueWithIdentifier:kSegueShowItem sender:cell];
    } else {
        [self performSegueWithIdentifier:kSegueShowRFAS sender:cell];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:kSegueShowGlobalSearchDetail]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        NDDecoderItem *item = self.searchResults[indexPath.row];
        [(DetailTableViewController *)segue.destinationViewController setItem:item];

    } else if ([[segue identifier] isEqualToString:kSegueShowItem]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *title = [[NDDataStore sharedStore] categoryTitles][indexPath.row];
        [[segue destinationViewController] setCategoryTitle:title];

    } else if ([[segue identifier] isEqualToString:kSegueShowRFAS]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSString *categoryString = cell.textLabel.text;
        BOOL isEnlisted = ([categoryString rangeOfString:@"Enl"].location != NSNotFound);
        RfasViewController *controller = (RfasViewController *)segue.destinationViewController;
        controller.isEnlisted = isEnlisted;
    }
}

@end
