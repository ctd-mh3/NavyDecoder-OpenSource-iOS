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

static double const kMPCHeaderAlphaDark = 0.5;
static double const kMPCHeaderAlphaLight = 0.2;

@synthesize codeKey = _codeKey;
@synthesize categoryTitle = _categoryTitle;
@synthesize codeKeyString = _codeKeyString;
@synthesize codeValueString = _codeValueString;
@synthesize codeSourceString = _codeSourceString;

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
    // TODO- Get text to be top-left justified
    // http://stackoverflow.com/questions/1054558/vertically-align-text-within-a-uilabel
    // http://stackoverflow.com/questions/7192088/how-to-set-top-left-alignment-for-uilabel-for-ios-application
    
    self.codeKeyLabel.text = self.codeKeyString;
    
    Item *item = (Item *)self.item;
    self.codeKeyString = item.codeKey;
    self.title = self.codeKeyString;
 
    Category *category = item.categorySource;
    self.categoryTitle = category.categoryTitle;
    
    Details *details = item.itemDetails;
    self.codeValueString = details.codeValue;
    self.codeValueLabel.text = self.codeValueString;

    self.codeSourceString = details.codeSource;
    self.codeSourceLabel.text = self.codeSourceString;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        [self.codeKeyLabel setFont:[UIFont systemFontOfSize:NDPTextSize]];
        [self.codeValueLabel setFont:[UIFont systemFontOfSize:NDPTextSize]];
        [self.codeSourceLabel setFont:[UIFont systemFontOfSize:NDPTextSize]];
    }
    
    NSLog(@"Meaning: %@", self.codeValueString);
}

// https://schiffr.de/2016/12/auto-growing-uitableviewcells-with-static-cells/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAt:(NSIndexPath *)indexPath {
    return 10.0;
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

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
   
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                [self openOtherEmail];
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

- (IBAction)openOtherEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;

        NSString *subjectString = @"iOS-Navy Decoder(v";
        subjectString = [subjectString stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        subjectString = [subjectString stringByAppendingString:@") Item Details"];
        [mailer setSubject:subjectString];

        NSString *emailBody = @"Details for ";
        emailBody = [emailBody stringByAppendingString:self.categoryTitle];
        emailBody = [emailBody stringByAppendingString:@" code:\n"];
        
        emailBody = [emailBody stringByAppendingString:@"\tCode: "];
        emailBody = [emailBody stringByAppendingString:self.codeKeyString];
        emailBody = [emailBody stringByAppendingString:@"\n"];

        emailBody = [emailBody stringByAppendingString:@"\tMeaning: "];
        emailBody = [emailBody stringByAppendingString:self.codeValueString];
        emailBody = [emailBody stringByAppendingString:@"\n"];

        emailBody = [emailBody stringByAppendingString:@"\tSource: "];
        emailBody = [emailBody stringByAppendingString:self.codeSourceString];
        emailBody = [emailBody stringByAppendingString:@"\n"];       
        
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
