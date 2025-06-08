//
// CustomTableViewCell.m
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

#import "CustomTableViewCell.h"

// http://code-and-coffee.blogspot.com/2012/07/how-to-use-custom-uitableviewcell.html
@implementation CustomTableViewCell

@synthesize emailButton = _emailButton;

- (UIButton *)emailButton {
    if (_emailButton) {
        _emailButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    
    return _emailButton;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [[self contentView] addSubview:self.emailButton];
    
    [self.emailButton setTitle:@"Email Correction" forState:UIControlStateNormal];
    self.emailButton.frame = CGRectMake(0, 0, 280, 100);

}

// http://stackoverflow.com/questions/9883107/ios-static-table-with-custom-cell-only-draws-a-random-cell
- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self.emailButton setTitle:@"Email Correction" forState:UIControlStateNormal];
        self.emailButton.frame = CGRectMake(0, 0, 280, 100);
    }
    
    return self;
}

@end
