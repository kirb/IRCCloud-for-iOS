//
//  ICBufferViewController.h
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICBufferViewController : UITableViewController <UISplitViewControllerDelegate> {
	UITextField *textField;
	UIToolbar *toolbar;
	NSArray *server;
	int channelIndex;
}

@property (strong, nonatomic) NSArray *server;
@property (assign) int channelIndex;

- (void)configureView;

@end
