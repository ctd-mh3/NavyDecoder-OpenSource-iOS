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
#import <StoreKit/StoreKit.h>

@interface NavyDecoderMasterViewController () {
    NSMutableArray *_objects;
}

@end

@implementation NavyDecoderMasterViewController

static double const kMPCHeaderAlphaDark = 0.5;
static double const kMPCHeaderAlphaLight = 0.2;

static NSString *settingsReviewCountKey         = @"reviewCount";
static NSString *settingsReviewBundleVersionKey = @"bundleVersion";

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self DisplayReviewController];
}

- (void)setBackgroundForSize:(CGSize)size {
    NDCViewUtilities *viewUtilities = [NDCViewUtilities sharedInstance];
    
    [self.tableView setBackgroundView:[viewUtilities getBackgroundImageViewForSize:size]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Must get background on first view of the app as viewWillTransitionToSize is not called on this point
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [self setBackgroundForSize:screenRect.size];
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

- (void)DisplayReviewController {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Get the count of controller views, increment, and store new value
    NSNumber *count = [defaults objectForKey:settingsReviewCountKey];
    [defaults setObject:[NSNumber numberWithInt:[count intValue] + 1] forKey:settingsReviewCountKey];
    [defaults synchronize];
    
    // Get the current bundle version for the app
    NSString *currentBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *lastVersionPromptedForReview = [defaults objectForKey:settingsReviewBundleVersionKey];

    // Has the controller been viewd 4 times and the user has not already been prompted for this version?
    if ([count intValue] >= 4 && currentBuildVersion != lastVersionPromptedForReview) {
        
        if (@available(iOS 14.0, *)) {
            [SKStoreReviewController requestReviewInScene:self.view.window.windowScene];
        } else if (@available(iOS 10.3, *)) {
            [SKStoreReviewController requestReview];
        }

        [defaults setObject:currentBuildVersion forKey:settingsReviewBundleVersionKey];
        [defaults synchronize];
    }
}

@end
