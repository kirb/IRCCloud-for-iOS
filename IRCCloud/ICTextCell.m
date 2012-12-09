//
//  ICTextCell.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICTextCell.h"

@implementation ICTextCell
@synthesize textField;

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
	self.textField = [[UITextField alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 0)];
	self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	if (self.detailTextLabel.text) {
		self.textField.placeholder = self.detailTextLabel.text;
		self.detailTextLabel.text = nil;
		self.textField.textAlignment = UITextAlignmentRight;
		
		CGRect textFrame = self.textField.frame;
		textFrame.origin.x = [self.textLabel.text sizeWithFont:self.textLabel.font].width + 20.f;
		textFrame.size.width -= textFrame.origin.x;
		self.textField.frame = textFrame;
	}
	[self.contentView addSubview:self.textField];
}

@end
