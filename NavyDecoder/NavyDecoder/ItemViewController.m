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
#import "Item.h"
#import "Category.h"
#import "ViewConstants.h"

@interface ItemViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ItemViewController

#pragma mark - Initialization

- (void)setCategory:(id)newCategory {
    Category *category = (Category *)newCategory;
    self.categoryTitle = category.categoryTitle;
    self.title = [NSString stringWithFormat:@"Select %@", self.categoryTitle];
    self.navigationItem.backButtonTitle = self.categoryTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // nil results controller: search results appear inline in self.tableView (no overlay).
    // The nav-bar placement of the search bar means tapping a cell does not affect the
    // search bar's responder state, so the original "Observation #1" issue does not apply.
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Search for Code";
    self.searchController.obscuresBackgroundDuringPresentation = NO;

    // Attach to nav item (iOS 11+) so the search bar stays visible in the nav bar
    // and the searchResultsController overlay does not cover the tableHeaderView.
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    self.tableView.tableHeaderView = [self makeNoticeHeaderView];
    self.definesPresentationContext = YES;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];

    [self updateFilteredContentForEnteredSearch:searchString];
    [self.tableView reloadData];

    // Show empty state when a search yields no results
    BOOL hasResults = [[self.fetchedResultsController fetchedObjects] count] > 0;
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

#pragma mark - Content Filtering

- (void)updateFilteredContentForEnteredSearch:(NSString *)searchString {
    // Update the filtered data based on the search text
    if ((searchString == nil) || [searchString length] == 0) {
        // Show all entries
        [self restoreDefaultListItems];
    } else {
        // http://appworks.radeeccles.com/programming/convert-sql-nspredicate-core-data/
        NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:2];
        // 20140101: Updated to search for entered text in the key and value (similiar to how Android app works)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"codeKey CONTAINS[c] %@ OR itemDetails.codeValue CONTAINS[c] %@", searchString, searchString];
        [predicates addObject:predicate];
        predicate = [NSPredicate predicateWithFormat:@"categorySource.categoryTitle == %@", self.categoryTitle];
        
        [predicates addObject:predicate];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        
        [NSFetchedResultsController deleteCacheWithName:self.categoryTitle];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Fetch failure is non-fatal for a read-only store; list will show empty.
    }
}

- (void)restoreDefaultListItems {
    // Reset search predicate to contain all of the items for the designated category
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categorySource.categoryTitle == %@", self.categoryTitle];
    [NSFetchedResultsController deleteCacheWithName:self.categoryTitle];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
   
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Link explains why this change was needed
    //      http://stackoverflow.com/questions/12737860/assertion-failure-in-dequeuereusablecellwithidentifierforindexpath

    static NSString *cellIdentifier = @"ItemToDecodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
   
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Seque transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:kSegueShowDetails]) {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        Item *item = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setItem:item];
    } else if ([[segue identifier] isEqualToString:kSegueShowDetailsAccessoryButton]) {
       
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        Item *item = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setItem:item];
    }
}

// http://www.raywenderlich.com/forums/viewtopic.php?t=2052&p=13440
// http://stackoverflow.com/questions/8087389/detail-disclosure-button-and-segues
// http://stackoverflow.com/questions/9339302/indexpath-for-segue-from-accessorybutton
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:kSegueShowDetailsAccessoryButton sender:indexPath];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    // Below link explains why this is needed
    //       http://stackoverflow.com/questions/7800857/how-do-i-refresh-reload-to-update-changes-to-my-predicate-thus-fetch-request
    [NSFetchedResultsController deleteCacheWithName:self.categoryTitle];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"codeKey" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    NSPredicate *pred =
       [NSPredicate predicateWithFormat:@"categorySource.categoryTitle == %@", self.categoryTitle];
    [fetchRequest setPredicate:pred];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc]
        initWithFetchRequest:fetchRequest
        managedObjectContext:self.managedObjectContext
          sectionNameKeyPath:nil
                   cacheName:self.categoryTitle];
    
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = item.codeKey;

    UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        ? UIFontTextStyleTitle3 : UIFontTextStyleBody;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:textStyle];
    cell.textLabel.adjustsFontForContentSizeCategory = YES;
}

@end
