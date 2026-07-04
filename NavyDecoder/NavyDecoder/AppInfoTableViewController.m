//
// AppInfoTableViewController.m
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

#import "AppInfoTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "ViewConstants.h"

static const NSInteger kAppSupportSectionIndex = 1;

@interface AppInfoTableViewController ()
@property (nonatomic, assign) BOOL hasAppliedRowLabelFonts;
@end

@implementation AppInfoTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = [self makeNoticeHeaderView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.hasAppliedRowLabelFonts || !self.tableView.window || CGRectGetWidth(self.tableView.bounds) <= 0) {
        return;
    }
    self.hasAppliedRowLabelFonts = YES;
    [self applyRowLabelFonts];
}

// UITableViewCell.textLabel on IBUITableViewCellStyleDefault cells doesn't
// reliably pick up a storyboard-configured fontDescription/Dynamic Type
// binding — it falls back to a small fixed system font instead. Setting the
// font in code is the reliable way to make it respect Dynamic Type. This has
// to run once the table has a real width and a window (viewDidLoad is too
// early — self-sizing rows measure against whatever font is in place when
// the table first gets a valid layout, not whatever is set later), and
// forces a reloadData afterward so the row heights that get queried reflect
// the font just set.
- (void)applyRowLabelFonts {
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSInteger sections = [self numberOfSectionsInTableView:self.tableView];
    for (NSInteger section = 0; section < sections; section++) {
        NSInteger rows = [self.tableView numberOfRowsInSection:section];
        for (NSInteger row = 0; row < rows; row++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            cell.textLabel.font = font;
            cell.textLabel.adjustsFontForContentSizeCategory = YES;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - App Specific Controller Functionality

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kAppSupportSectionIndex) {
        switch (indexPath.row) {
        case 0:
            [self openEmail];
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL] options:@{} completionHandler:nil];
            break;
        default:
            break;
        }
    }
}

#pragma mark - Mail functionality

- (IBAction)openEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;

        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [mailer setSubject:[NSString stringWithFormat:@"iOS-Navy Decoder(v%@) Comment", version]];
        [mailer setToRecipients:@[kSupportEmail]];
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Error"
                             message:@"Your device appears not to support email."
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction
            actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action){
                        // No action except to close alert
                    }];

        [alert addAction:okButton];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
