//
//  ICBufferViewController.h
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICChannel.h"

@interface ICBufferViewController : UITableViewController <UISplitViewControllerDelegate, ICBufferDelegate>
{
	UITextField *textField;
	UIToolbar *toolbar;
	int channelIndex;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *serverName;
@property (strong, nonatomic) ICChannel *channel;
@property (strong, nonatomic) NSString *channelName;
@property (assign) int channelIndex;

- (void)configureView;

@end
