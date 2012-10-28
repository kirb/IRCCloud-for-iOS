//
//  ICMasterViewController.h
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICBufferViewController;

@interface ICMasterViewController : UITableViewController {
	BOOL loggedIn;
	NSMutableArray *servers;
}

-(void)updateLoginStatus;
-(IBAction)showSettings:(id)sender;

@property (strong, nonatomic) ICBufferViewController *detailViewController;

@end
