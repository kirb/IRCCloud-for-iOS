//
//  ICMultiLineTextCell.m
//  IRCCloud
//
//  Created by Adam D on 22/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICMultiLineTextCell.h"
#import "SSTextView.h"

@implementation ICMultiLineTextCell
@synthesize textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self commonSetup];
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	[self commonSetup];
	return self;
}

-(void)commonSetup {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.textView = [[SSTextView alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 0)];
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.textView.customPlaceholder = self.detailTextLabel.text;
	self.detailTextLabel.text = @"";
	[self.contentView addSubview:self.textView];
}

@end