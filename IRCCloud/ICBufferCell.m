//
//  ICBufferCell.m
//  IRCCloud
//
//  Created by Aditya KD on 01/01/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "ICBufferCell.h"

@implementation ICBufferCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // more initialization code.
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
