//
// TopLeftAlignedLabel.m
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

#import "TopLeftAlignedLabel.h"

@implementation TopLeftAlignedLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    _verticalAlignment = VerticalAlignmentTop;
    
    return self;
}

- (VerticalAlignment)verticalAlignment {
    return _verticalAlignment;
}

- (void)setVerticalAlignment:(VerticalAlignment)value {
    _verticalAlignment = value;
    [self setNeedsDisplay];
}

// Align text block according to vertical alignment settings
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    NSLog(@"numberOfLines: %ld", (long)numberOfLines);

    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    CGRect result;
    
    switch (_verticalAlignment) {
        case VerticalAlignmentTop:
            result = CGRectMake(bounds.origin.x, bounds.origin.y, rect.size.width, rect.size.height);
            break;
        case VerticalAlignmentMiddle:
            result = CGRectMake(bounds.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height) / 2, rect.size.width, rect.size.height);
            break;
        case VerticalAlignmentBottom:
            result = CGRectMake(bounds.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height), rect.size.width, rect.size.height);
            break;
        default:
            result = bounds;
            break;
    }
   
    return result;
}

- (void)drawTextInRect:(CGRect)rect {
    CGRect r = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:r];
}

@end
