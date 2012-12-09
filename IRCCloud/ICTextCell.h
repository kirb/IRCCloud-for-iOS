//
//  ICTextCell.h
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICTextCell : UITableViewCell {
	UITextField *textField;
}

-(void)commonSetup;

@property (nonatomic, strong) UITextField *textField;

@end
