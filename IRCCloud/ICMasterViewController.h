//
//  ICMasterViewController.h
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICController.h"
#import "ICNetwork.h"

@class ICBufferViewController;

@interface ICMasterViewController : UITableViewController <IControllerDelegate, ICNetworkDelegate>
{
	BOOL loggedIn;
	NSMutableArray *servers;
}

-(void)updateLoginStatus;
-(IBAction)showSettings:(id)sender;

@property (strong, nonatomic) ICBufferViewController *detailViewController;

@end
