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

@interface RfasViewController ()

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@property (nonatomic) BOOL enlisted;
@property (strong, nonatomic) Rfas *rfas;

@property (strong, nonatomic)  NSString *firstCharacterMeaningWithoutTitle;
@property (strong, nonatomic)  NSString *secondAndThirdCharacterMeaningWithoutTitle;
@property (strong, nonatomic)  NSString *fourthCharacterMeaningWithoutTitle;

@end

@implementation RfasViewController

@synthesize rfasPickerView = _rfasPickerView;
@synthesize firstCharacterMeaningWithoutTitle = _firstCharacterMeaningWithoutTitle;
@synthesize secondAndThirdCharacterMeaningWithoutTitle = _secondAndThirdCharacterMeaningWithoutTitle;
@synthesize fourthCharacterMeaningWithoutTitle = _fourthCharacterMeaningWithoutTitle;
@synthesize webView = _webView;
@synthesize emailOtherButton = _emailOtherButton;
@synthesize rfas = _rfas;
@synthesize isEnlisted = _isEnlisted;

static NSString *const STYLE_TAG_OPENING = @"<STYLE TYPE=\"text/css\">";
static NSString *const STYLE_TAG_CLOSING = @"</STYLE>";
static NSString *const STYLES_TO_INCLUDE =
@"<!--"
    "body {"
        "background-color: white;"
        "color: black;"
    "}"
    "@media (prefers-color-scheme: dark) {"
        "body {"
            "background-color: rgb(0,0,0);"
            "color: white;"
            "font-size: 300%;"
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
    
    
    NSString *titleString;
    
    if (self.isEnlisted) {
        titleString = @"RFAS-Enlisted";
    } else {
        titleString = @"RFAS-Officer";
    }
    self.title = titleString;
    
    [self.rfasPickerView reloadAllComponents];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.firstCharacterMeaningWithoutTitle = @"";
    self.secondAndThirdCharacterMeaningWithoutTitle =  @"";
    self.fourthCharacterMeaningWithoutTitle =  @"";

    // This should cause didSelectRow() to be called for default selections but it is not for
    //   some reason
    [self.rfasPickerView reloadAllComponents];

    // Manually ensure that element decode values are set for the default values
    [self doSomethingWithRow:0 inComponent:0];
    [self doSomethingWithRow:0 inComponent:1];
    [self doSomethingWithRow:0 inComponent:2];
    
    // Make not scrollable
    //   http://stackoverflow.com/questions/500761/stop-uiwebview-from-bouncing-vertically
    [[self.webView scrollView] setBounces:NO];
    
    [self updatewebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (void)updatewebView {
    NSString *htmlString = @"<html><head></head><body>";
    
    htmlString = [htmlString stringByAppendingString:STYLE_TAG_OPENING];
    htmlString = [htmlString stringByAppendingString:STYLES_TO_INCLUDE];
    htmlString = [htmlString stringByAppendingString:STYLE_TAG_CLOSING];

    // First character
    htmlString = [htmlString stringByAppendingString:@"<b>1st:</b> "];
    htmlString = [htmlString stringByAppendingString:self.firstCharacterMeaningWithoutTitle];
    htmlString = [htmlString stringByAppendingString:@"</br></br>"];
    
    // Second and Third character
    htmlString = [htmlString stringByAppendingString:@"<b>2nd:</b> "];
    htmlString = [htmlString stringByAppendingString:self.secondAndThirdCharacterMeaningWithoutTitle];
    htmlString = [htmlString stringByAppendingString:@"</br></br>"];
    
    // Fourth character
    htmlString = [htmlString stringByAppendingString:@"<b>3rd:</b> "];
    htmlString = [htmlString stringByAppendingString:self.fourthCharacterMeaningWithoutTitle];
    htmlString = [htmlString stringByAppendingString:@"</br>"];
    
    htmlString = [htmlString stringByAppendingString:@"</body></html>"];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
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
            title = [self.rfas getFirstCharacterKeyForRow:row
                                               isEnlisted:self.isEnlisted];
            break;
        case 1:
            title = [self.rfas getSecondAndThirdCharactersKeyForRow:row
                                                        isEnlisted:self.isEnlisted];
            break;
        case 2:
            title = [self.rfas getFourthCharacterKeyForRow:row
                                                isEnlisted:self.isEnlisted];
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
        {
            self.firstCharacterMeaningWithoutTitle = [self.rfas getFirstCharacterValueForRow:row
                                                                                  isEnlisted:self.isEnlisted];
            break;
        }
        case 1:
        {
            self.secondAndThirdCharacterMeaningWithoutTitle = [self.rfas getSecondAndThirdCharactersValueForRow:row
                                                                                                     isEnlisted:self.isEnlisted];
            break;
        }
        case 2:
        {
            self.fourthCharacterMeaningWithoutTitle = [self.rfas getFourthCharacterValueForRow:row
                                                                                    isEnlisted:self.isEnlisted];
            break;
        }
    }
  
    [self updatewebView];
}

- (IBAction)openOtherEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;

        NSString *subjectString = @"iOS-Navy Decoder(v";
        subjectString = [subjectString stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        subjectString = [subjectString stringByAppendingString:@") RFAS Details"];
        [mailer setSubject:subjectString];

        NSInteger row;
        NSString *firstCharacterToDecode;
        NSString *secondAndThirdCharacterToDecode;
        NSString *fourthCharacterToDecode;
        
        row = [self.rfasPickerView selectedRowInComponent:0];
        firstCharacterToDecode = [self.rfas getFirstCharacterKeyForRow:row
                                                            isEnlisted:self.isEnlisted];
        row = [self.rfasPickerView selectedRowInComponent:1];
        secondAndThirdCharacterToDecode = [self.rfas getSecondAndThirdCharactersKeyForRow:row
                                                                               isEnlisted:self.isEnlisted];
        row = [self.rfasPickerView selectedRowInComponent:2];
        fourthCharacterToDecode = [self.rfas getFourthCharacterKeyForRow:row
                                                              isEnlisted:self.isEnlisted];
        
        
        NSString *emailBody = @"Details for ";
        
        if (self.isEnlisted) {
            emailBody = [emailBody stringByAppendingString:@"Enlisted RFAS ("];
            
        } else {
            emailBody = [emailBody stringByAppendingString:@"Officer RFAS: ("];
        }
        emailBody = [emailBody stringByAppendingString:firstCharacterToDecode];
        emailBody = [emailBody stringByAppendingString:secondAndThirdCharacterToDecode];
        emailBody = [emailBody stringByAppendingString:fourthCharacterToDecode];
        emailBody = [emailBody stringByAppendingString:@"):\n"];
        
        
        
        emailBody = [emailBody stringByAppendingString:firstCharacterToDecode];
        emailBody = [emailBody stringByAppendingString:@"="];
        emailBody = [emailBody stringByAppendingString:self.firstCharacterMeaningWithoutTitle];
        emailBody = [emailBody stringByAppendingString:@"\n"];
        
        emailBody = [emailBody stringByAppendingString:secondAndThirdCharacterToDecode];
        emailBody = [emailBody stringByAppendingString:@"="];
        emailBody = [emailBody stringByAppendingString:self.secondAndThirdCharacterMeaningWithoutTitle];
        emailBody = [emailBody stringByAppendingString:@"\n"];
        
        emailBody = [emailBody stringByAppendingString:fourthCharacterToDecode];
        emailBody = [emailBody stringByAppendingString:@"="];
        emailBody = [emailBody stringByAppendingString:self.fourthCharacterMeaningWithoutTitle];
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
