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

static NSInteger const kSearchBarHeightIPad = 50;
static NSInteger const kSearchBarHeightIPhone = 44;

#pragma mark - Initialization

- (void)setCategory:(id)newCategory {
    Category *category = (Category *)newCategory;
    self.categoryTitle = category.categoryTitle;
    self.title = self.categoryTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.detailTableViewController = (DetailTableViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Followed Sample-UISearchController example from GitHub
    // The following appeared to be needed to ensure that when the user has entered search criteria and then presses a row that it is
    //   handled as a seque and not as a case of "when the search bar becomes the first responder or when the user makes changes inside
    //   the search bar" which has been seen to cause updateSearchResultsForSearchController to be called (Observation #1)
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;

    // initWithSearchResultsController must be set to searchResultsController and not nil (or Observation #1 occurs)
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    self.searchController.searchResultsUpdater = self;

    NSInteger searchBarHeight;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        searchBarHeight = kSearchBarHeightIPad;
        
        // Update the searchBar's font size to match the table view cells
        UIFont *systemFont =  [UIFont systemFontOfSize:12.0];
        [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{
            NSFontAttributeName: [UIFont fontWithName:systemFont.fontName size:NDPTextSize],
                                                                                                     }];
    } else {
        searchBarHeight = kSearchBarHeightIPhone;
    }

    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, searchBarHeight);

    self.searchController.hidesNavigationBarDuringPresentation = false;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    self.searchController.searchBar.placeholder  = @"Search for Code";
    self.searchController.obscuresBackgroundDuringPresentation = false;
    
    self.definesPresentationContext = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];
    
    [self updateFilteredContentForEnteredSearch:searchString];
    
    // Due to change above to address Observation #1, this code is needed to update the table view shown when the user has entered search results
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
    
    // Needed for after a cancel operation to restore full list
    [self.tableView reloadData];
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
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
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
    if ([[segue identifier] isEqualToString:@"showDetails"]) {

        // Get the indexPath assuming the search table view is visible
        NSIndexPath *indexPath = [((UITableViewController *)self.searchController.searchResultsController).tableView indexPathForCell:(UITableViewCell *)sender];
       
        // if the above resulted in nil, then the full table is visible (self.tableView)
        if (indexPath == nil) {
            indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        }
        
        Item *item = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setItem:item];
    } else if ([[segue identifier] isEqualToString:@"showDetailsAccessoryButton"]) {
       
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
    [self performSegueWithIdentifier:@"showDetailsAccessoryButton" sender:indexPath];
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
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	
    if (![self.fetchedResultsController performFetch:&error]) {
	    
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Data Retrieval Error"
                                    message:@"Please try again."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       //No action except to close alert
                                   }];
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"codeKey"] description];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        [cell.textLabel setFont:[UIFont systemFontOfSize:NDPTextSize]];
    }
}

@end
