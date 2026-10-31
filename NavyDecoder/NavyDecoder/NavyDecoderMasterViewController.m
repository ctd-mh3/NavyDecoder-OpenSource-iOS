//
// NavyDecoderMasterViewController.m
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

#import "NavyDecoderMasterViewController.h"
#import "NDCViewUtilities.h"
#import "ViewConstants.h"

@implementation NavyDecoderMasterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kDefaultEstimatedRowHeight;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 32.0;
    [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class, UITraitHorizontalSizeClass.class]
                       withTarget:self
                           action:@selector(traitDidChange)];
}

- (void)traitDidChange {
    [self setBackgroundForSize:self.tableView.bounds.size];
    [self.tableView reloadData];
}

- (void)setBackgroundForSize:(CGSize)size {
    NDCViewUtilities *viewUtilities = [NDCViewUtilities sharedInstance];
    UIImageView *backgroundView = [viewUtilities getBackgroundImageViewForSize:size];
    backgroundView.isAccessibilityElement = NO;
    backgroundView.alpha = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
                               ? kBackgroundAlphaDark
                               : kBackgroundAlphaLight;
    [self.tableView setBackgroundView:backgroundView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Must get background on first view of the app as viewWillTransitionToSize is not called on this point
    [self setBackgroundForSize:self.tableView.bounds.size];
}


#pragma mark - Updating Table View Backgrounds (Cells and Headers)

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // https://stackoverflow.com/questions/813068/uitableview-change-section-header-color
    [cell setBackgroundColor:[UIColor clearColor]];

    cell.textLabel.adjustsFontForContentSizeCategory = YES;
    cell.detailTextLabel.adjustsFontForContentSizeCategory = YES;
}

// The stock plain-style UITableViewHeaderFooterView.textLabel doesn't scale
// reliably with Dynamic Type, and its default internal padding is far more
// generous than this app's headers need. A fully custom header view gives
// control over both: a small bold baseline scaled via UIFontMetrics (so it
// still reads as a header, not body text, at every size) and tight,
// explicit padding.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title.length == 0) {
        return nil;
    }

    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *tc) {
        CGFloat alpha = (tc.userInterfaceStyle == UIUserInterfaceStyleDark)
                            ? kBackgroundAlphaDark
                            : kBackgroundAlphaLight;
        return [[UIColor blackColor] colorWithAlphaComponent:alpha];
    }];

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = title;
    UIFont *baseFont = [UIFont boldSystemFontOfSize:14];
    label.font = [[UIFontMetrics defaultMetrics] scaledFontForFont:baseFont];
    label.adjustsFontForContentSizeCategory = YES;
    label.textColor = [UIColor labelColor];

    [headerView addSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor
                                            constant:16],
        [label.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor
                                             constant:-16],
        [label.topAnchor constraintEqualToAnchor:headerView.topAnchor
                                        constant:6],
        [label.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor
                                           constant:-6],
    ]];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title.length > 0) {
        return UITableViewAutomaticDimension;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self setBackgroundForSize:size];
}

#pragma mark - Mail Compose Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if (result == MFMailComposeResultFailed) {
                                     NSString *message = error.localizedDescription ?: @"The email could not be sent. Please try again.";
                                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Email Failed"
                                                                                                    message:message
                                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                     [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                     [self presentViewController:alert animated:YES completion:nil];
                                 }
                             }];
}

#pragma mark - Notice Header

- (UIView *)makeNoticeHeaderView {
    UIView *container = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.numberOfLines = 0;
    label.text = kOpenSourceNotice;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    label.textColor = [UIColor secondaryLabelColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = UIColor.clearColor;
    [container addSubview:label];
    NSLayoutConstraint *bottom = [label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-16];
    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:container.topAnchor
                                        constant:8],
        [label.leadingAnchor constraintEqualToAnchor:container.leadingAnchor
                                            constant:16],
        [label.trailingAnchor constraintEqualToAnchor:container.trailingAnchor
                                             constant:-16],
        bottom,
    ]];
    return container;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *header = self.tableView.tableHeaderView;
    if (!header)
        return;
    CGFloat width = self.tableView.bounds.size.width;
    if (width == 0)
        return;
    // Small headroom buffer: systemLayoutSizeFittingSize: with
    // UILayoutFittingCompressedSize can come out a hair short of what a
    // multi-line centered label actually needs at extreme accessibility
    // sizes.
    CGFloat height = ceil([header systemLayoutSizeFittingSize:CGSizeMake(width, UILayoutFittingCompressedSize.height)
                                withHorizontalFittingPriority:UILayoutPriorityRequired
                                      verticalFittingPriority:UILayoutPriorityFittingSizeLevel]
                              .height) +
                     4.0;
    if (ABS(header.frame.size.height - height) > 0.5) {
        header.frame = CGRectMake(0, 0, width, height);
        self.tableView.tableHeaderView = header;
    }
}

@end
