//
// RfasViewController.m
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

#import "RfasViewController.h"
#import "Rfas.h"
#import "NDCViewUtilities.h"
#import "ViewConstants.h"

@interface RfasViewController ()

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@property (nonatomic) BOOL enlisted;
@property (strong, nonatomic) Rfas *rfas;

@property (strong, nonatomic) NSString *firstCharacterMeaningWithoutTitle;
@property (strong, nonatomic) NSString *secondAndThirdCharacterMeaningWithoutTitle;
@property (strong, nonatomic) NSString *fourthCharacterMeaningWithoutTitle;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *prefix1Label;
@property (nonatomic, strong) UILabel *prefix2Label;
@property (nonatomic, strong) UILabel *prefix3Label;
@property (nonatomic, strong) UILabel *meaning1Label;
@property (nonatomic, strong) UILabel *meaning2Label;
@property (nonatomic, strong) UILabel *meaning3Label;

@end

@implementation RfasViewController

@synthesize rfasPickerView = _rfasPickerView;
@synthesize firstCharacterMeaningWithoutTitle = _firstCharacterMeaningWithoutTitle;
@synthesize secondAndThirdCharacterMeaningWithoutTitle = _secondAndThirdCharacterMeaningWithoutTitle;
@synthesize fourthCharacterMeaningWithoutTitle = _fourthCharacterMeaningWithoutTitle;
@synthesize rfas = _rfas;
@synthesize isEnlisted = _isEnlisted;

static double const kRFASHeaderAlphaDark = 0.5;
static double const kRFASHeaderAlphaLight = 0.2;

- (void)viewDidLoad {
    self.rfas = [[Rfas alloc] init];
    self.title = self.isEnlisted ? @"RFAS-Enlisted" : @"RFAS-Officer";
    [self.rfasPickerView reloadAllComponents];
    [super viewDidLoad];

    [self setupBackground];
    [self setupLayout];

    [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class]
                       withTarget:self
                           action:@selector(updateBackground)];
    [self registerForTraitChanges:@[UITraitPreferredContentSizeCategory.class]
                       withTarget:self
                           action:@selector(updateResultLabels)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIScreen *screen = self.view.window.windowScene.screen;
    CGRect screenRect = screen ? screen.bounds : self.view.bounds;
    [self updateBackgroundForSize:screenRect.size];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.firstCharacterMeaningWithoutTitle = @"";
    self.secondAndThirdCharacterMeaningWithoutTitle = @"";
    self.fourthCharacterMeaningWithoutTitle = @"";

    [self.rfasPickerView reloadAllComponents];

    [self doSomethingWithRow:0 inComponent:0];
    [self doSomethingWithRow:0 inComponent:1];
    [self doSomethingWithRow:0 inComponent:2];

    [self updateResultLabels];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateBackgroundForSize:size];
}

#pragma mark - Background

- (void)setupBackground {
    UIImageView *bg = [[UIImageView alloc] init];
    [self.view insertSubview:bg atIndex:0];
    self.backgroundImageView = bg;

    for (UIView *subview in self.view.subviews) {
        subview.backgroundColor = UIColor.clearColor;
    }
}

- (void)updateBackground {
    self.backgroundImageView.alpha = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        ? kRFASHeaderAlphaDark
        : kRFASHeaderAlphaLight;
}

- (void)updateBackgroundForSize:(CGSize)size {
    NDCViewUtilities *viewUtilities = [NDCViewUtilities sharedInstance];
    UIImageView *bg = [viewUtilities getBackgroundImageViewForSize:size];
    self.backgroundImageView.image = bg.image;
    self.backgroundImageView.alpha = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        ? kRFASHeaderAlphaDark
        : kRFASHeaderAlphaLight;
    self.backgroundImageView.frame = CGRectMake(0, 0, size.width, size.height);
}

#pragma mark - Layout

- (void)setupLayout {
    [NSLayoutConstraint deactivateConstraints:self.view.constraints];

    UILabel *noticeLabel = [[UILabel alloc] init];
    noticeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    noticeLabel.numberOfLines = 0;
    noticeLabel.text = kOpenSourceNotice;
    noticeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    noticeLabel.textColor = [UIColor secondaryLabelColor];
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.backgroundColor = UIColor.clearColor;
    [self.view addSubview:noticeLabel];

    UIView *pickerBand = [self makeSectionBand:@"RFAS CODE"];
    UIView *resultBand = [self makeSectionBand:@"DECODED MEANING"];
    UIView *shareBand  = [self makeSectionBand:@"SHARE DETAILS"];
    [self.view addSubview:pickerBand];
    [self.view addSubview:resultBand];
    [self.view addSubview:shareBand];

    self.prefix1Label = [self makePrefixLabel:@"1st Element:"];
    self.prefix2Label = [self makePrefixLabel:@"2nd Element:"];
    self.prefix3Label = [self makePrefixLabel:@"3rd Element:"];
    self.meaning1Label = [self makeResultLabel];
    self.meaning2Label = [self makeResultLabel];
    self.meaning3Label = [self makeResultLabel];

    UIStackView *resultStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self makeResultRow:self.prefix1Label meaning:self.meaning1Label],
        [self makeResultRow:self.prefix2Label meaning:self.meaning2Label],
        [self makeResultRow:self.prefix3Label meaning:self.meaning3Label],
    ]];
    resultStack.axis = UILayoutConstraintAxisVertical;
    resultStack.spacing = 8;
    resultStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:resultStack];

    // Prefix column: fixed 40% of the stack width, equal across all rows
    [self.prefix1Label.widthAnchor constraintEqualToAnchor:resultStack.widthAnchor multiplier:0.30].active = YES;
    [self.prefix2Label.widthAnchor constraintEqualToAnchor:self.prefix1Label.widthAnchor].active = YES;
    [self.prefix3Label.widthAnchor constraintEqualToAnchor:self.prefix1Label.widthAnchor].active = YES;

    self.rfasPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shareButton.translatesAutoresizingMaskIntoConstraints = NO;

    // Share button: left-align text
    if (@available(iOS 15, *)) {
        UIButtonConfiguration *config = self.shareButton.configuration;
        if (config) {
            config.titleAlignment = UIButtonConfigurationTitleAlignmentLeading;
            config.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, 0);
            self.shareButton.configuration = config;
        }
    }
    [self.shareButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

    // Share button: match body font size used elsewhere
    UIFontTextStyle shareTextStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        ? UIFontTextStyleTitle3 : UIFontTextStyleBody;
    self.shareButton.titleLabel.font = [UIFont preferredFontForTextStyle:shareTextStyle];
    self.shareButton.titleLabel.adjustsFontForContentSizeCategory = YES;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    UILayoutGuide *readable = self.view.readableContentGuide;
    CGFloat margin = 16.0;

    [NSLayoutConstraint activateConstraints:@[
        // Notice label
        [noticeLabel.topAnchor constraintEqualToAnchor:safe.topAnchor constant:8],
        [noticeLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [noticeLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],

        // Picker band
        [pickerBand.topAnchor constraintEqualToAnchor:noticeLabel.bottomAnchor constant:8],
        [pickerBand.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [pickerBand.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        // Picker — centered via readable content guide
        [self.rfasPickerView.topAnchor constraintEqualToAnchor:pickerBand.bottomAnchor constant:4],
        [self.rfasPickerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.rfasPickerView.leadingAnchor constraintGreaterThanOrEqualToAnchor:readable.leadingAnchor],
        [self.rfasPickerView.trailingAnchor constraintLessThanOrEqualToAnchor:readable.trailingAnchor],

        // Decoded meaning band
        [resultBand.topAnchor constraintEqualToAnchor:self.rfasPickerView.bottomAnchor constant:8],
        [resultBand.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [resultBand.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        // Result labels stack view
        [resultStack.topAnchor constraintEqualToAnchor:resultBand.bottomAnchor constant:12],
        [resultStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:margin],
        [resultStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margin],

        // Share band
        [shareBand.topAnchor constraintEqualToAnchor:resultStack.bottomAnchor constant:12],
        [shareBand.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [shareBand.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        // Share button
        [self.shareButton.topAnchor constraintEqualToAnchor:shareBand.bottomAnchor constant:12],
        [self.shareButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:margin],
        [self.shareButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margin],
    ]];
}

- (UIView *)makeSectionBand:(NSString *)title {
    UIView *band = [[UIView alloc] init];
    band.translatesAutoresizingMaskIntoConstraints = NO;
    band.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *tc) {
        CGFloat alpha = (tc.userInterfaceStyle == UIUserInterfaceStyleDark)
            ? kRFASHeaderAlphaDark : kRFASHeaderAlphaLight;
        return [[UIColor blackColor] colorWithAlphaComponent:alpha];
    }];

    UIView *topLine = [[UIView alloc] init];
    topLine.translatesAutoresizingMaskIntoConstraints = NO;
    topLine.backgroundColor = [UIColor separatorColor];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLine.backgroundColor = [UIColor separatorColor];

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = title;
    UIFont *baseFont = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    label.font = [[UIFontMetrics defaultMetrics] scaledFontForFont:baseFont];
    label.adjustsFontForContentSizeCategory = YES;
    label.textColor = [UIColor secondaryLabelColor];

    [band addSubview:topLine];
    [band addSubview:label];
    [band addSubview:bottomLine];

    [NSLayoutConstraint activateConstraints:@[
        [topLine.topAnchor constraintEqualToAnchor:band.topAnchor],
        [topLine.leadingAnchor constraintEqualToAnchor:band.leadingAnchor],
        [topLine.trailingAnchor constraintEqualToAnchor:band.trailingAnchor],
        [topLine.heightAnchor constraintEqualToConstant:0.5],

        [label.topAnchor constraintEqualToAnchor:topLine.bottomAnchor constant:6],
        [label.leadingAnchor constraintEqualToAnchor:band.leadingAnchor constant:16],
        [label.trailingAnchor constraintEqualToAnchor:band.trailingAnchor constant:-16],
        [label.bottomAnchor constraintEqualToAnchor:bottomLine.topAnchor constant:-6],

        [bottomLine.leadingAnchor constraintEqualToAnchor:band.leadingAnchor],
        [bottomLine.trailingAnchor constraintEqualToAnchor:band.trailingAnchor],
        [bottomLine.bottomAnchor constraintEqualToAnchor:band.bottomAnchor],
        [bottomLine.heightAnchor constraintEqualToConstant:0.5],
    ]];

    return band;
}

- (UILabel *)makePrefixLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = text;
    label.numberOfLines = 0;
    label.backgroundColor = UIColor.clearColor;
    return label;
}

- (UIStackView *)makeResultRow:(UILabel *)prefix meaning:(UILabel *)meaning {
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[prefix, meaning]];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.spacing = 8;
    row.alignment = UIStackViewAlignmentTop;
    return row;
}

- (UILabel *)makeResultLabel {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.numberOfLines = 0;
    label.backgroundColor = UIColor.clearColor;
    return label;
}

#pragma mark - Result Labels

- (void)updateResultLabels {
    UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        ? UIFontTextStyleTitle3 : UIFontTextStyleBody;
    UIFont *bodyFont = [UIFont preferredFontForTextStyle:textStyle];

    for (UILabel *label in @[self.prefix1Label, self.prefix2Label, self.prefix3Label,
                              self.meaning1Label, self.meaning2Label, self.meaning3Label]) {
        label.font = bodyFont;
        label.adjustsFontForContentSizeCategory = YES;
    }

    self.meaning1Label.text = self.firstCharacterMeaningWithoutTitle ?: @"";
    self.meaning2Label.text = self.secondAndThirdCharacterMeaningWithoutTitle ?: @"";
    self.meaning3Label.text = self.fourthCharacterMeaningWithoutTitle ?: @"";
}

#pragma mark - Picker View Data Source / Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger count = 0;
    switch (component) {
        case 0:
            count = [[self.rfas getFirstCharacterKeys:self.isEnlisted] count];
            break;
        case 1:
            count = [[self.rfas getSecondAndThirdCharactersKeys:self.isEnlisted] count];
            break;
        case 2:
            count = [[self.rfas getFourthCharacterKeys:self.isEnlisted] count];
            break;
    }
    return count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    NSString *title;
    switch (component) {
        case 0:
            title = [self.rfas getFirstCharacterKeyForRow:row isEnlisted:self.isEnlisted];
            break;
        case 1:
            title = [self.rfas getSecondAndThirdCharactersKeyForRow:row isEnlisted:self.isEnlisted];
            break;
        case 2:
            title = [self.rfas getFourthCharacterKeyForRow:row isEnlisted:self.isEnlisted];
            break;
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self doSomethingWithRow:row inComponent:component];
}

- (void)doSomethingWithRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
            self.firstCharacterMeaningWithoutTitle = [self.rfas getFirstCharacterValueForRow:row
                                                                                  isEnlisted:self.isEnlisted];
            break;
        case 1:
            self.secondAndThirdCharacterMeaningWithoutTitle = [self.rfas getSecondAndThirdCharactersValueForRow:row
                                                                                                     isEnlisted:self.isEnlisted];
            break;
        case 2:
            self.fourthCharacterMeaningWithoutTitle = [self.rfas getFourthCharacterValueForRow:row
                                                                                    isEnlisted:self.isEnlisted];
            break;
    }
    [self updateResultLabels];
}

#pragma mark - Share

- (IBAction)shareDetails:(id)sender {
    NSString *shareText = [self buildShareText];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];

    activityVC.popoverPresentationController.sourceView = sender;
    activityVC.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (NSString *)buildShareText {
    NSInteger row;
    NSString *firstCharacterToDecode;
    NSString *secondAndThirdCharacterToDecode;
    NSString *fourthCharacterToDecode;

    row = [self.rfasPickerView selectedRowInComponent:0];
    firstCharacterToDecode = [self.rfas getFirstCharacterKeyForRow:row isEnlisted:self.isEnlisted];
    row = [self.rfasPickerView selectedRowInComponent:1];
    secondAndThirdCharacterToDecode = [self.rfas getSecondAndThirdCharactersKeyForRow:row isEnlisted:self.isEnlisted];
    row = [self.rfasPickerView selectedRowInComponent:2];
    fourthCharacterToDecode = [self.rfas getFourthCharacterKeyForRow:row isEnlisted:self.isEnlisted];

    NSMutableString *text = [NSMutableString string];
    [text appendString:self.isEnlisted ? @"Enlisted RFAS (" : @"Officer RFAS ("];
    [text appendString:firstCharacterToDecode];
    [text appendString:secondAndThirdCharacterToDecode];
    [text appendString:fourthCharacterToDecode];
    [text appendString:@"):\n"];
    [text appendFormat:@"%@ = %@\n", firstCharacterToDecode, self.firstCharacterMeaningWithoutTitle];
    [text appendFormat:@"%@ = %@\n", secondAndThirdCharacterToDecode, self.secondAndThirdCharacterMeaningWithoutTitle];
    [text appendFormat:@"%@ = %@\n", fourthCharacterToDecode, self.fourthCharacterMeaningWithoutTitle];
    return text;
}

@end
