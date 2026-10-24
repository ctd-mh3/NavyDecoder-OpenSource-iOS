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
#import "ViewConstants.h"

@interface AppInfoViewController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation AppInfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // The storyboard view has clearColor, which would reveal the black window behind it.
    // Use systemBackgroundColor so light mode has a white base behind the background image.
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UIImageView *bg = [[UIImageView alloc] init];
    bg.isAccessibilityElement = NO;
    [self.view insertSubview:bg atIndex:0];
    self.backgroundImageView = bg;

    for (UIView *subview in self.view.subviews) {
        subview.backgroundColor = UIColor.clearColor;
    }

    [self wrapContentLabelInScrollView];
    [self updateLabelFonts];

    if (@available(iOS 17, *)) {
        [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class]
                           withTarget:self
                               action:@selector(updateBackground)];
        // The label font depends on the horizontal size class, which can change
        // when the window resizes (iPhone Duo fold/unfold, Split View, Stage Manager).
        [self registerForTraitChanges:@[UITraitHorizontalSizeClass.class]
                           withTarget:self
                               action:@selector(updateLabelFonts)];
    }
}

// Labels are either direct subviews or, once wrapped, inside the scroll view.
- (void)updateLabelFonts {
    UIFontTextStyle textStyle = (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
                                    ? UIFontTextStyleTitle3
                                    : UIFontTextStyleBody;
    NSMutableArray<UIView *> *views = [self.view.subviews mutableCopy];
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            [views addObjectsFromArray:subview.subviews];
        }
    }
    for (UIView *view in views) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.font = [UIFont preferredFontForTextStyle:textStyle];
            label.adjustsFontForContentSizeCategory = YES;
        }
    }
}

// The storyboard's content label is only pinned by leading/trailing/top —
// there's no bottom constraint or scroll view, so at large accessibility
// text sizes (or for genuinely long content like the Open Source license
// text) it just grows past the bottom of the screen with no way to read
// the rest. This is shared by both the "About/Legal" and "Open Source"
// scenes since they both use this same class.
- (void)wrapContentLabelInScrollView {
    UILabel *contentLabel = nil;
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            contentLabel = (UILabel *)subview;
            break;
        }
    }
    if (!contentLabel) {
        return;
    }

    CGFloat sideInset = contentLabel.frame.origin.x > 0 ? contentLabel.frame.origin.x : 20.0;

    [contentLabel removeFromSuperview];
    contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    contentLabel.preferredMaxLayoutWidth = 0;

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    [scrollView addSubview:contentLabel];

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [contentLabel.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor
                                               constant:sideInset],
        [contentLabel.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor
                                                   constant:sideInset],
        [contentLabel.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor
                                                    constant:-sideInset],
        [contentLabel.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor
                                                  constant:-sideInset],
        [contentLabel.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor
                                                 constant:-(sideInset * 2)],
    ]];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 17, *)) {
        return;
    }
    if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
        [self updateBackground];
    }
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
                                         ? kBackgroundAlphaDark
                                         : kBackgroundAlphaLight;
}

- (void)updateBackgroundForSize:(CGSize)size {
    NDCViewUtilities *viewUtilities = [NDCViewUtilities sharedInstance];
    UIImageView *bg = [viewUtilities getBackgroundImageViewForSize:size];
    self.backgroundImageView.image = bg.image;
    self.backgroundImageView.alpha = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
                                         ? kBackgroundAlphaDark
                                         : kBackgroundAlphaLight;
    self.backgroundImageView.frame = CGRectMake(0, 0, size.width, size.height);
}

@end
