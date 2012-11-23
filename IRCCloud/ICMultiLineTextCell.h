//
//  ICMultiLineTextCell.h
//  IRCCloud
//
//  Created by Adam D on 22/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSTextView;

@interface ICMultiLineTextCell : UITableViewCell {
	SSTextView *textView;
}

-(void)commonSetup;

@property (nonatomic, retain) SSTextView *textView;

@end
