//
// AppInfoViewController.m
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

#import "AppInfoViewController.h"
#import "NDCViewUtilities.h"

@interface AppInfoViewController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation AppInfoViewController

static double const kAIVHeaderAlphaDark = 0.5;
static double const kAIVHeaderAlphaLight = 0.2;

- (void)viewDidLoad {
    [super viewDidLoad];

    // The storyboard view has clearColor, which would reveal the black window behind it.
    // Use systemBackgroundColor so light mode has a white base behind the background image.
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UIImageView *bg = [[UIImageView alloc] init];
    [self.view insertSubview:bg atIndex:0];
    self.backgroundImageView = bg;

    UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        ? UIFontTextStyleTitle3 : UIFontTextStyleBody;
    for (UIView *subview in self.view.subviews) {
        subview.backgroundColor = UIColor.clearColor;
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.font = [UIFont preferredFontForTextStyle:textStyle];
            label.adjustsFontForContentSizeCategory = YES;
        }
    }

    [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class]
                       withTarget:self
                           action:@selector(updateBackground)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIScreen *screen = self.view.window.windowScene.screen;
    CGRect screenRect = screen ? screen.bounds : self.view.bounds;
    [self updateBackgroundForSize:screenRect.size];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateBackgroundForSize:size];
}

- (void)updateBackground {
    // Only the alpha needs to change when the color scheme toggles; image and frame are already set.
    self.backgroundImageView.alpha = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        ? kAIVHeaderAlphaDark
        : kAIVHeaderAlphaLight;
}

- (void)updateBackgroundForSize:(CGSize)size {
    NDCViewUtilities *viewUtilities = [NDCViewUtilities sharedInstance];
    UIImageView *bg = [viewUtilities getBackgroundImageViewForSize:size];
    self.backgroundImageView.image = bg.image;
    self.backgroundImageView.alpha = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        ? kAIVHeaderAlphaDark
        : kAIVHeaderAlphaLight;
    self.backgroundImageView.frame = CGRectMake(0, 0, size.width, size.height);
}

@end
