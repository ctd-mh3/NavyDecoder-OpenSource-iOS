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
#import "Category.h"
#import "Item.h"
#import "Details.h"
#import "NavyDecoderAppDelegate.h"
#import "UIViewController+ReviewRequest.h"
#import "ViewConstants.h"

@interface DetailTableViewController ()

@property (strong, nonatomic) id codeKey;
@property (strong, nonatomic) NSString *categoryTitle;
@property (strong, nonatomic) NSString *codeKeyString;
@property (strong, nonatomic) NSString *codeValueString;
@property (strong, nonatomic) NSString *codeSourceString;

@end

@implementation DetailTableViewController

static NSString *const kiOS7AppStoreURLBaseFormat = @"itms-apps://itunes.apple.com/app/id";



- (void)setItem:(id)newItem {
    _item = newItem;
    [self configureView];    
}

/*
// The following four functions are used to reduce the size between the sections
//   Per: http://stackoverflow.com/questions/2817308/reducing-the-space-between-sections-of-the-uitableview
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kFooterHeight;
}
*/
- (void)configureView {
        
    self.codeKeyLabel.text = self.codeKeyString;
    
    Item *item = (Item *)self.item;
    self.codeKeyString = item.codeKey;
    self.title = [NSString stringWithFormat:@"Decoded %@", self.categoryTitle];
 
    Category *category = item.categorySource;
    self.categoryTitle = category.categoryTitle;
    
    Details *details = item.itemDetails;
    self.codeValueString = details.codeValue;
    self.codeValueLabel.text = self.codeValueString;

    self.codeSourceString = details.codeSource;
    self.codeSourceLabel.text = self.codeSourceString;
    
    UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        ? UIFontTextStyleTitle3 : UIFontTextStyleBody;
    UIFont *contentFont = [UIFont preferredFontForTextStyle:textStyle];
    self.codeKeyLabel.font = contentFont;
    self.codeKeyLabel.adjustsFontForContentSizeCategory = YES;
    self.codeValueLabel.font = contentFont;
    self.codeValueLabel.adjustsFontForContentSizeCategory = YES;
    self.codeSourceLabel.font = contentFont;
    self.codeSourceLabel.adjustsFontForContentSizeCategory = YES;

    NSLog(@"Meaning: %@", self.codeValueString);
}

// https://schiffr.de/2016/12/auto-growing-uitableviewcells-with-static-cells/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAt:(NSIndexPath *)indexPath {
    return 10.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    if (indexPath.section == 3) {
        UIFontTextStyle textStyle = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            ? UIFontTextStyleTitle3 : UIFontTextStyleBody;
        UIFont *font = [UIFont preferredFontForTextStyle:textStyle];
        for (UIView *subview in cell.contentView.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                label.font = font;
                label.adjustsFontForContentSizeCategory = YES;
            }
        }
    }
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    self.tableView.tableHeaderView = [self makeNoticeHeaderView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestReviewIfAppropriate];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
    NSString *urlString = [kiOS7AppStoreURLBaseFormat stringByAppendingString:MPCAppStoreId];

    if (indexPath.section == 3) {

        switch (indexPath.row) {
            case 0:
                [self shareDecodeDetailsFromCell:[tableView cellForRowAtIndexPath:indexPath]];
                break;
            case 1:
                [self openCorrectionEmail];
                break;
            case 2:
                // https://stackoverflow.com/questions/18905686/itunes-review-url-and-ios-7-ask-user-to-rate-our-app-appstore-show-a-blank-pag
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
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

        NSString *subjectString = @"iOS-Navy Decoder(v";
        subjectString = [subjectString stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        subjectString = [subjectString stringByAppendingString:@") Correction/Comment"];
        [mailer setSubject:subjectString];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"support@crashtestdummylimited.com", nil];
        [mailer setToRecipients:toRecipients];
         NSString *emailBody = @"Feedback below for ";
        emailBody = [emailBody stringByAppendingString:self.categoryTitle];
        emailBody = [emailBody stringByAppendingString:@" code ("];
        emailBody = [emailBody stringByAppendingString:self.codeKeyString];
        emailBody = [emailBody stringByAppendingString:@"):"];
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Error"
                                    message:@"Your device appears not to support email."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       //No action except to close alert
                                   }];
        
        [alert addAction:okButton];
        
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

    // iPad requires a source for the popover
    activityVC.popoverPresentationController.sourceView = cell;
    activityVC.popoverPresentationController.sourceRect = cell.bounds;

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: User cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: User saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: The email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: The email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
