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
#import "NavyDecoderAppDelegate.h"
#import "NDCViewUtilities.h"
#import "ViewConstants.h"

@interface NavyDecoderMasterViewController () {
    NSMutableArray *_objects;
}

@end

@implementation NavyDecoderMasterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class]
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
    backgroundView.alpha = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        ? kBackgroundAlphaDark
        : kBackgroundAlphaLight;
    [self.tableView setBackgroundView:backgroundView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Must get background on first view of the app as viewWillTransitionToSize is not called on this point
    UIScreen *screen = self.view.window.windowScene.screen;
    CGRect screenRect = screen ? screen.bounds : self.view.bounds;
    [self setBackgroundForSize:screenRect.size];
}


#pragma mark - Updating Table View Backgrounds (Cells and Headers)

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // https://stackoverflow.com/questions/813068/uitableview-change-section-header-color
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Background color
    // https://stackoverflow.com/questions/11825152/set-transparency-in-image-ios
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        view.tintColor = [[UIColor blackColor] colorWithAlphaComponent:kBackgroundAlphaDark];
    } else {
        view.tintColor = [[UIColor blackColor] colorWithAlphaComponent:kBackgroundAlphaLight];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self setBackgroundForSize:size];
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
    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:container.topAnchor constant:8],
        [label.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:16],
        [label.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-16],
        [label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-8],
    ]];
    return container;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *header = self.tableView.tableHeaderView;
    if (!header) return;
    CGFloat width = self.tableView.bounds.size.width;
    if (width == 0) return;
    CGFloat height = [header systemLayoutSizeFittingSize:CGSizeMake(width, UILayoutFittingCompressedSize.height)
                          withHorizontalFittingPriority:UILayoutPriorityRequired
                                verticalFittingPriority:UILayoutPriorityFittingSizeLevel].height;
    if (ABS(header.frame.size.height - height) > 0.5) {
        header.frame = CGRectMake(0, 0, width, height);
        self.tableView.tableHeaderView = header;
    }
}

@end
