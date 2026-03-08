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
#import "Category.h"
#import "Item.h"
#import "ViewConstants.h"

@interface CategoryViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
            @"codeKey CONTAINS[c] %@ OR itemDetails.codeValue CONTAINS[c] %@",
            searchString, searchString];
        [NSFetchedResultsController deleteCacheWithName:@"GlobalSearch"];
        [self.searchFetchedResultsController.fetchRequest setPredicate:predicate];
        NSError *error = nil;
        [self.searchFetchedResultsController performFetch:&error];
    }

    [self.tableView reloadData];

    BOOL hasResults = self.searchFetchedResultsController.fetchedObjects.count > 0;
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [super tableView:tableView willDisplayHeaderView:view forSection:section];
    ((UITableViewHeaderFooterView *)view).textLabel.textColor = UIColor.labelColor;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isSearchActive]) {
        return [[self.searchFetchedResultsController sections] count];
    }

    NSInteger count = [[self.fetchedResultsController sections] count];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isSearchActive]) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [self.searchFetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isSearchActive]) {
        static NSString *searchCellId = @"GlobalSearchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchCellId];
        }
        Item *item = [self.searchFetchedResultsController objectAtIndexPath:indexPath];
        UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            ? UIFontTextStyleTitle3 : UIFontTextStyleBody;
        cell.textLabel.text = item.codeKey;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:textStyle];
        cell.textLabel.adjustsFontForContentSizeCategory = YES;
        cell.detailTextLabel.text = item.categorySource.categoryTitle;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
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

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *categoryString = cell.textLabel.text;

    if ([categoryString rangeOfString:@"RFAS"].location == NSNotFound) {
        [self performSegueWithIdentifier:kSegueShowItem sender:cell];
    } else {
        [self performSegueWithIdentifier:kSegueShowRFAS sender:cell];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:kSegueShowGlobalSearchDetail]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        Item *item = [self.searchFetchedResultsController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setItem:item];

    } else if ([[segue identifier] isEqualToString:kSegueShowItem]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Category *category = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setCategory:category];

    } else if ([[segue identifier] isEqualToString:kSegueShowRFAS]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSString *categoryString = cell.textLabel.text;
        BOOL isEnlisted = ([categoryString rangeOfString:@"Enl"].location != NSNotFound);
        RfasViewController *controller = (RfasViewController *)segue.destinationViewController;
        controller.isEnlisted = isEnlisted;
    }
}

#pragma mark - Fetched Results Controllers

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryTitle" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
        initWithFetchRequest:fetchRequest
        managedObjectContext:self.managedObjectContext
          sectionNameKeyPath:nil
                   cacheName:@"Master"];
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Data Retrieval Error"
                                                                       message:@"Please try again."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }

    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController {
    if (_searchFetchedResultsController != nil) {
        return _searchFetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSArray *sortDescriptors = @[
        [[NSSortDescriptor alloc] initWithKey:@"categorySource.categoryTitle" ascending:YES],
        [[NSSortDescriptor alloc] initWithKey:@"codeKey" ascending:YES],
    ];
    [fetchRequest setSortDescriptors:sortDescriptors];

    // Return no results until the user types something
    [fetchRequest setPredicate:[NSPredicate predicateWithValue:NO]];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
        initWithFetchRequest:fetchRequest
        managedObjectContext:self.managedObjectContext
          sectionNameKeyPath:nil
                   cacheName:@"GlobalSearch"];
    self.searchFetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    [self.searchFetchedResultsController performFetch:&error];

    return _searchFetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Category *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = category.categoryTitle;

    UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        ? UIFontTextStyleTitle3 : UIFontTextStyleBody;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:textStyle];
    cell.textLabel.adjustsFontForContentSizeCategory = YES;
}

@end
