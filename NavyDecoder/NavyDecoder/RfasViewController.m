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

@interface RfasViewController ()

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@property (nonatomic) BOOL enlisted;
@property (strong, nonatomic) Rfas *rfas;

@property (strong, nonatomic) NSString *firstCharacterMeaningWithoutTitle;
@property (strong, nonatomic) NSString *secondAndThirdCharacterMeaningWithoutTitle;
@property (strong, nonatomic) NSString *fourthCharacterMeaningWithoutTitle;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation RfasViewController

@synthesize rfasPickerView = _rfasPickerView;
@synthesize firstCharacterMeaningWithoutTitle = _firstCharacterMeaningWithoutTitle;
@synthesize secondAndThirdCharacterMeaningWithoutTitle = _secondAndThirdCharacterMeaningWithoutTitle;
@synthesize fourthCharacterMeaningWithoutTitle = _fourthCharacterMeaningWithoutTitle;
@synthesize webView = _webView;
@synthesize rfas = _rfas;
@synthesize isEnlisted = _isEnlisted;

static double const kRFASHeaderAlphaDark = 0.5;
static double const kRFASHeaderAlphaLight = 0.2;

static NSString *const STYLE_TAG_OPENING = @"<STYLE TYPE=\"text/css\">";
static NSString *const STYLE_TAG_CLOSING = @"</STYLE>";
static NSString *const STYLES_TO_INCLUDE =
@"<!--"
    "body {"
        "background-color: transparent;"
        "color: #1c1c1e;"
        "font-size: 16px;"
        "line-height: 1.5;"
        "margin: 8px 16px;"
    "}"
    "@media (prefers-color-scheme: dark) {"
        "body {"
            "color: #f2f2f7;"
        "}"
    "}"
"-->";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

    // This should cause didSelectRow() to be called for default selections but it is not for
    //   some reason
    [self.rfasPickerView reloadAllComponents];

    // Manually ensure that element decode values are set for the default values
    [self doSomethingWithRow:0 inComponent:0];
    [self doSomethingWithRow:0 inComponent:1];
    [self doSomethingWithRow:0 inComponent:2];

    [[self.webView scrollView] setBounces:NO];

    [self updatewebView];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateBackgroundForSize:size];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Background

- (void)setupBackground {
    UIImageView *bg = [[UIImageView alloc] init];
    [self.view insertSubview:bg atIndex:0];
    self.backgroundImageView = bg;

    // Clear subview backgrounds so the background image shows through.
    // Do NOT change self.view.backgroundColor — leave it as systemBackgroundColor
    // so the nav controller's background does not bleed through.
    for (UIView *subview in self.view.subviews) {
        subview.backgroundColor = UIColor.clearColor;
    }
    self.webView.opaque = NO;
    self.webView.scrollView.backgroundColor = UIColor.clearColor;
}

- (void)updateBackground {
    [self updateBackgroundForSize:self.view.bounds.size];
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
    // Deactivate storyboard-generated constraints so we can build a clean layout.
    // The storyboard had conflicting webView.top constraints and no picker position constraints.
    [NSLayoutConstraint deactivateConstraints:self.view.constraints];
    [NSLayoutConstraint deactivateConstraints:self.webView.constraints];

    UIView *pickerBand  = [self makeSectionBand:@"RFAS CODE"];
    UIView *resultBand  = [self makeSectionBand:@"DECODED MEANING"];
    UIView *shareBand   = [self makeSectionBand:@"SHARE DETAILS"];
    [self.view addSubview:pickerBand];
    [self.view addSubview:resultBand];
    [self.view addSubview:shareBand];

    [self.shareButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    CGFloat margin = 16.0;

    [NSLayoutConstraint activateConstraints:@[
        // Picker band (edge-to-edge)
        [pickerBand.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [pickerBand.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [pickerBand.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        // Picker
        [self.rfasPickerView.topAnchor constraintEqualToAnchor:pickerBand.bottomAnchor constant:4],
        [self.rfasPickerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:margin],
        [self.rfasPickerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-margin],

        // Decoded meaning band (edge-to-edge)
        [resultBand.topAnchor constraintEqualToAnchor:self.rfasPickerView.bottomAnchor constant:8],
        [resultBand.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [resultBand.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        // WebView
        [self.webView.topAnchor constraintEqualToAnchor:resultBand.bottomAnchor],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.webView.heightAnchor constraintEqualToConstant:200],

        // Share band (edge-to-edge)
        [shareBand.topAnchor constraintEqualToAnchor:self.webView.bottomAnchor constant:8],
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
    band.backgroundColor = [UIColor secondarySystemBackgroundColor];

    // Top and bottom hairline separators
    UIView *topLine = [[UIView alloc] init];
    topLine.translatesAutoresizingMaskIntoConstraints = NO;
    topLine.backgroundColor = [UIColor separatorColor];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLine.backgroundColor = [UIColor separatorColor];

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = title;
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
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
    [self updatewebView];
}

#pragma mark - Web View

- (void)updatewebView {
    NSString *htmlString = @"<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></head><body>";
    htmlString = [htmlString stringByAppendingString:STYLE_TAG_OPENING];
    htmlString = [htmlString stringByAppendingString:STYLES_TO_INCLUDE];
    htmlString = [htmlString stringByAppendingString:STYLE_TAG_CLOSING];
    htmlString = [htmlString stringByAppendingString:@"<b>1st:</b> "];
    htmlString = [htmlString stringByAppendingString:self.firstCharacterMeaningWithoutTitle];
    htmlString = [htmlString stringByAppendingString:@"</br></br>"];
    htmlString = [htmlString stringByAppendingString:@"<b>2nd:</b> "];
    htmlString = [htmlString stringByAppendingString:self.secondAndThirdCharacterMeaningWithoutTitle];
    htmlString = [htmlString stringByAppendingString:@"</br></br>"];
    htmlString = [htmlString stringByAppendingString:@"<b>3rd:</b> "];
    htmlString = [htmlString stringByAppendingString:self.fourthCharacterMeaningWithoutTitle];
    htmlString = [htmlString stringByAppendingString:@"</br>"];
    htmlString = [htmlString stringByAppendingString:@"</body></html>"];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

#pragma mark - Share

- (IBAction)shareDetails:(id)sender {
    NSString *shareText = [self buildShareText];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];

    // iPad requires a source for the popover
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
