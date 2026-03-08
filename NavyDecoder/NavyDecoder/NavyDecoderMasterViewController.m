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

@interface NavyDecoderMasterViewController () {
    NSMutableArray *_objects;
}

@end

@implementation NavyDecoderMasterViewController

static double const kMPCHeaderAlphaDark = 0.5;
static double const kMPCHeaderAlphaLight = 0.2;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setBackgroundForSize:(CGSize)size {
    NDCViewUtilities *viewUtilities = [NDCViewUtilities sharedInstance];
    UIImageView *backgroundView = [viewUtilities getBackgroundImageViewForSize:size];
    backgroundView.alpha = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        ? kMPCHeaderAlphaDark
        : kMPCHeaderAlphaLight;
    [self.tableView setBackgroundView:backgroundView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Must get background on first view of the app as viewWillTransitionToSize is not called on this point
    UIScreen *screen = self.view.window.windowScene.screen;
    CGRect screenRect = screen ? screen.bounds : self.view.bounds;
    [self setBackgroundForSize:screenRect.size];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
        [self setBackgroundForSize:self.tableView.bounds.size];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        view.tintColor = [[UIColor blackColor] colorWithAlphaComponent:kMPCHeaderAlphaDark];
    } else {
        view.tintColor = [[UIColor blackColor] colorWithAlphaComponent:kMPCHeaderAlphaLight];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self setBackgroundForSize:size];
}

@end
