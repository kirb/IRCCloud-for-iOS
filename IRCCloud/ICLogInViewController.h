//
//  ICLogInViewController.h
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICLogInViewController : UITableViewController <UITextFieldDelegate>
{
	UIBarButtonItem *cancelButton;
}

- (void)logIn;

@end
