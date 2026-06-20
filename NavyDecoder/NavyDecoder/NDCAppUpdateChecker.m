//
// NDCAppUpdateChecker.m
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

#import "NDCAppUpdateChecker.h"

static NSString *const kLastCheckKey = @"appUpdateLastCheckDate";
static NSString *const kAppStoreId = @"588227679";
static const NSTimeInterval kCooldownInterval = 86400;

@implementation NDCAppUpdateChecker

+ (void)checkForUpdateIn:(UIWindowScene *)windowScene {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastCheck = [defaults objectForKey:kLastCheckKey];

    if (lastCheck && [[NSDate date] timeIntervalSinceDate:lastCheck] < kCooldownInterval) {
        return;
    }

    // Record now so a failed/offline request also respects the cooldown.
    [defaults setObject:[NSDate date] forKey:kLastCheckKey];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", kAppStoreId]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                 if (!data) {
                                                                     return;
                                                                 }

                                                                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                 NSArray *results = json[@"results"];

                                                                 if (!results.count) {
                                                                     return;
                                                                 }

                                                                 NSString *storeVersion = results[0][@"version"];
                                                                 NSString *storeUrlString = results[0][@"trackViewUrl"];
                                                                 NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];

                                                                 if (!storeVersion || !storeUrlString || !currentVersion) {
                                                                     return;
                                                                 }

                                                                 if ([storeVersion compare:currentVersion options:NSNumericSearch] != NSOrderedDescending) {
                                                                     return;
                                                                 }

                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [NDCAppUpdateChecker presentAlertForVersion:storeVersion storeUrlString:storeUrlString in:windowScene];
                                                                 });
                                                             }];
    [task resume];
}

+ (void)presentAlertForVersion:(NSString *)storeVersion storeUrlString:(NSString *)storeUrlString in:(UIWindowScene *)windowScene {
    UIWindow *keyWindow = nil;

    for (UIWindow *window in windowScene.windows) {
        if (window.isKeyWindow) {
            keyWindow = window;
            break;
        }
    }

    UIViewController *rootVC = keyWindow.rootViewController;

    if (!rootVC) {
        return;
    }

    NSString *message = [NSString stringWithFormat:@"Version %@ is now available in the App Store.", storeVersion];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"App Update Available"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Update Now"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                NSURL *storeUrl = [NSURL URLWithString:storeUrlString];

                                                if (storeUrl) {
                                                    [[UIApplication sharedApplication] openURL:storeUrl options:@{} completionHandler:nil];
                                                }
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:nil]];
    [rootVC presentViewController:alert animated:YES completion:nil];
}

@end
