//
//  ICBufferCell.m
//  IRCCloud
//
//  Created by Aditya KD on 01/01/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "ICBufferCell.h"

@implementation ICBufferCell

@synthesize attributedLabel = _attributedLabel;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect labelFrame = self.contentView.frame;
    labelFrame.origin.x   += 5;
    labelFrame.size.width -= 5;
    labelFrame.size.height = self.contentView.frame.size.height;
    self.attributedLabel.frame = labelFrame;
    
    // set again, to redraw if interface orientation changes.
    self.attributedLabel.attributedText = self.attributedLabel.attributedText;
}

- (TTTAttributedLabel *)attributedLabel
{
    // lazily load the label.
    if (!_attributedLabel) {
        _attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:self.contentView.frame];
        _attributedLabel.font = [UIFont systemFontOfSize:14];
        _attributedLabel.textColor = [UIColor blackColor];
        _attributedLabel.lineBreakMode = UILineBreakModeWordWrap;
        _attributedLabel.dataDetectorTypes = UIDataDetectorTypeAll;
        _attributedLabel.delegate = self;
        [self.contentView addSubview:_attributedLabel];
    }
    return _attributedLabel;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
