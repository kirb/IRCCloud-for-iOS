//
//  ICTextCell.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
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
	[self.contentView addSubview:self.textField];
}

@end
