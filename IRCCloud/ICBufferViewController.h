//
//  ICBufferViewController.h
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICChannel.h"

@interface ICBufferViewController : UITableViewController <UISplitViewControllerDelegate, UITextFieldDelegate, ICBufferDelegate>
{
	UITextField     *_textField;
    UITextField     *_realTextField;
    UIToolbar       *_toolbar;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *serverName;
@property (strong, nonatomic) ICChannel *channel;

- (void)configureView;

@end
