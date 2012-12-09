//
//  ICAddViewController.h
//  IRCCloud
//
//  Created by Adam D on 22/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	ICAddModeNetwork,
	ICAddModeChannel
} ICAddMode;

@interface ICAddViewController : UITableViewController <UITextFieldDelegate> {
	ICAddMode mode;
}
-(IBAction)segmentDidChange:(UISegmentedControl *)sender;
@end
