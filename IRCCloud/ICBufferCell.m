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

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _attributedLabel = [self attributedLabel];;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _attributedLabel = [self attributedLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
*/
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect labelFrame = self.contentView.frame;
    labelFrame.origin.x   += 5;
    labelFrame.size.width -= 5;
    labelFrame.size.height = self.contentView.frame.size.height;
    self.attributedLabel.frame = labelFrame;
    
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
