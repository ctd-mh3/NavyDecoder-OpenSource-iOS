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

@implementation NDCViewUtilities

{
    // Save copies of image to possibly speed up processing
    UIImage *landscapeImage;
    UIImage *portraitImage;
}

static NSInteger const kNumberOfBackgroundImages = 8;

#pragma mark Singleton Methods

+ (id)sharedInstance {
    static NDCViewUtilities *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

# pragma mark Main Methods

- (UIImageView *)getBackgroundImageViewForSize:(CGSize)size {
    // http://beageek.biz/how-to-set-background-image-uiview/
    // http://www.raywenderlich.com/55384/ios-7-best-practices-part-1
    // https://stackoverflow.com/questions/4779221/in-iphone-app-how-to-detect-the-screen-resolution-of-the-device
    // http://johnmunsch.com/2013/03/09/easy-background-images-for-your-ios-views/
    
    NSLog(@"Is switching size");
    
    // Grab the default/saved values
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger backgroundImageNumber = [[defaults objectForKey:settingsBackgroundImageKey] integerValue] % kNumberOfBackgroundImages;
    
    // Start creating background image file name by starting with image number and "_"
    NSString *imageFileName = [@(backgroundImageNumber) stringValue];
    imageFileName = [imageFileName stringByAppendingString:@"_"];
    
    // Add common portion and file extension ending
    imageFileName = [imageFileName stringByAppendingString:@"2048x2048_background.png"];
    
    NSLog(@"Using background image: %@", imageFileName);
    
    // Create the initial image before modifying it for the screen size
    UIImage *originalBackgroundImage = [UIImage imageNamed:imageFileName];
    
    // Crop the image from the center
    UIImage *backgroundImage = [originalBackgroundImage imageCroppedToFitSize:size];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:backgroundImage];
    
    // Make the image semi-transparent
    bg.alpha = 0.2;
    
    return bg;
}

@end
