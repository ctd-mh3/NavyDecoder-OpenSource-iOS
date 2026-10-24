//
// DetailTableViewController.m
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

#import "DetailTableViewController.h"
#import "UIViewController+ReviewRequest.h"
#import "ViewConstants.h"

@interface DetailTableViewController ()

@property (strong, nonatomic) NSString *categoryTitle;
@property (strong, nonatomic) NSString *codeKeyString;
@property (strong, nonatomic) NSString *codeValueString;
@property (strong, nonatomic) NSString *codeSourceString;
@property (nonatomic, assign) BOOL hasAppliedShareSectionFonts;

@end

@implementation DetailTableViewController

- (void)setItem:(NDDecoderItem *)newItem {
    _item = newItem;
    [self configureView];
}

- (void)configureView {
    NDDecoderItem *item = self.item;
    if (!item)
        return;

    self.codeKeyString = item.codeKey;
    self.categoryTitle = item.categoryTitle;
    self.codeValueString = item.codeValue;
    self.codeSourceString = item.codeSource;

    self.title = [NSString stringWithFormat:@"Decoded %@", self.categoryTitle];
    self.codeKeyLabel.text = self.codeKeyString;
    self.codeValueLabel.text = self.codeValueString;
    self.codeSourceLabel.text = self.codeSourceString;

    UIFontTextStyle textStyle = (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
                                    ? UIFontTextStyleTitle3
                                    : UIFontTextStyleBody;
    UIFont *contentFont = [UIFont preferredFontForTextStyle:textStyle];
    self.codeKeyLabel.font = contentFont;
    self.codeKeyLabel.adjustsFontForContentSizeCategory = YES;
    self.codeValueLabel.font = contentFont;
    self.codeValueLabel.adjustsFontForContentSizeCategory = YES;
    self.codeSourceLabel.font = contentFont;
    self.codeSourceLabel.adjustsFontForContentSizeCategory = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAt:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    self.tableView.tableHeaderView = [self makeNoticeHeaderView];
    // The content font depends on the horizontal size class, which can change
    // when the window resizes (iPhone Duo fold/unfold, Split View, Stage Manager).
    if (@available(iOS 17, *)) {
        [self registerForTraitChanges:@[UITraitHorizontalSizeClass.class]
                           withTarget:self
                               action:@selector(configureView)];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 17, *)) {
        return;
    }
    if (self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass) {
        [self configureView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.hasAppliedShareSectionFonts || !self.tableView.window || CGRectGetWidth(self.tableView.bounds) <= 0) {
        return;
    }
    self.hasAppliedShareSectionFonts = YES;
    [self applyShareSectionFonts];
}

// The SHARE/FEEDBACK row labels are plain custom UILabels (not outlet-bound),
// and — like AppInfoTableViewController's row labels — their storyboard
// fontDescription/adjustsFontForContentSizeCategory attributes don't reliably
// take effect on their own within a static table view cell. Setting the font
// in code is the reliable way, and it has to happen once the table has a
// real width/window (self-sizing rows measure against whatever font is in
// place at that point) with a deferred reloadData afterward so the row
// heights that get queried reflect the font just set.
- (void)applyShareSectionFonts {
    NSInteger shareSection = 3;
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSInteger rows = [self.tableView numberOfRowsInSection:shareSection];
    for (NSInteger row = 0; row < rows; row++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:shareSection]];
        for (UIView *subview in cell.contentView.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                label.font = font;
                label.adjustsFontForContentSizeCategory = YES;
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestReviewIfAppropriate];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlString = kAppStoreURL;

    if (indexPath.section == 3) {
        switch (indexPath.row) {
        case 0:
            [self shareDecodeDetailsFromCell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        case 1:
            [self openCorrectionEmail];
            break;
        case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            break;
        default:
            break;
        }
    }
}

#pragma mark - Mail functionality

- (IBAction)openCorrectionEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;

        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [mailer setSubject:[NSString stringWithFormat:@"iOS-Navy Decoder(v%@) Correction/Comment", version]];
        [mailer setToRecipients:@[kSupportEmail]];
        [mailer setMessageBody:[NSString stringWithFormat:@"Feedback below for %@ code (%@):", self.categoryTitle, self.codeKeyString] isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Error"
                             message:@"Your device appears not to support email."
                      preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)shareDecodeDetailsFromCell:(UITableViewCell *)cell {
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"Details for %@ code:\n", self.categoryTitle];
    [text appendFormat:@"\tCode: %@\n", self.codeKeyString];
    [text appendFormat:@"\tMeaning: %@\n", self.codeValueString];
    [text appendFormat:@"\tSource: %@\n", self.codeSourceString];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    activityVC.popoverPresentationController.sourceView = cell;
    activityVC.popoverPresentationController.sourceRect = cell.bounds;
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
