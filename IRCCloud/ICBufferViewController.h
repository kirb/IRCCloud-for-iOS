//
//  ICBufferViewController.h
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICChannel;

@interface ICBufferViewController : UITableViewController <UISplitViewControllerDelegate>
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
