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

    UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    if (indexPath.section == 3) {
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        for (UIView *subview in cell.contentView.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                label.font = font;
                label.adjustsFontForContentSizeCategory = YES;
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    self.tableView.tableHeaderView = [self makeNoticeHeaderView];
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
