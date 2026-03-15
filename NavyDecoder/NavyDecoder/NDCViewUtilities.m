//
// NDCViewUtilities.m
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

#import "NDCViewUtilities.h"
#import "NavyDecoderAppDelegate.h"
#import "UIImage+ProportionalFill.h"

NSString *const settingsBackgroundImageKey = @"backgroundImageKey";

@interface NDCViewUtilities ()
@property (nonatomic, strong) UIImage *cachedBackgroundImage;
@property (nonatomic, assign) CGSize cachedSize;
@property (nonatomic, assign) NSInteger cachedImageNumber;
@end

@implementation NDCViewUtilities

NSInteger const kNumberOfBackgroundImages = 8;

#pragma mark Singleton Methods

+ (id)sharedInstance {
    static NDCViewUtilities *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark Main Methods

- (UIImageView *)getBackgroundImageViewForSize:(CGSize)size {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger backgroundImageNumber = [[defaults objectForKey:settingsBackgroundImageKey] integerValue] % kNumberOfBackgroundImages;

    if (!self.cachedBackgroundImage ||
        !CGSizeEqualToSize(self.cachedSize, size) ||
        self.cachedImageNumber != backgroundImageNumber) {
        NSString *imageFileName = [NSString stringWithFormat:@"%ld_2048x2048_background.png", (long)backgroundImageNumber];
        UIImage *originalBackgroundImage = [UIImage imageNamed:imageFileName];
        self.cachedBackgroundImage = [originalBackgroundImage imageCroppedToFitSize:size];
        self.cachedSize = size;
        self.cachedImageNumber = backgroundImageNumber;
    }

    return [[UIImageView alloc] initWithImage:self.cachedBackgroundImage];
}

@end
