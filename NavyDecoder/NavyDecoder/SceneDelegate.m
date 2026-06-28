//
// SceneDelegate.m
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

#import "SceneDelegate.h"

#import "NDCAppUpdateChecker.h"
#import "NDCViewUtilities.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions {
    // The storyboard and scene configuration handle window + root VC creation automatically.
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }

    UIWindowScene *windowScene = (UIWindowScene *)scene;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NDCAppUpdateChecker checkForUpdateIn:windowScene];
    });
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *current = [defaults objectForKey:kSettingsBackgroundImageKey];
    [defaults setObject:@(([current integerValue] + 1) % kNumberOfBackgroundImages) forKey:kSettingsBackgroundImageKey];
}

@end
