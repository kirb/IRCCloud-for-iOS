//
//  ICBufferViewController.h
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICNetwork;

@interface ICBufferViewController : UITableViewController <UISplitViewControllerDelegate>
{
	UITextField *textField;
	UIToolbar *toolbar;
	int channelIndex;
}

@property (strong, nonatomic) NSString *serverName;
@property (assign) int channelIndex;

- (void)configureView;

@end
