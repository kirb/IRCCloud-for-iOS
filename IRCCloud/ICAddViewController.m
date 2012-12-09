//
//  ICAddViewController.m
//  IRCCloud
//
//  Created by Adam D on 22/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICAddViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ICAddViewController ()
@property (strong, nonatomic) UISwitch *sslSwitch;
@end

@implementation ICAddViewController

- (void)viewWillAppear:(BOOL)animated
{
	mode = ICAddModeNetwork;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0 && indexPath.row == 0) {
		cell.backgroundView = [[UIView alloc] init];
	} else if (mode == ICAddModeNetwork && indexPath.section == 1 && indexPath.row == 2) {
		if (!self.sslSwitch) {
			self.sslSwitch = [[UISwitch alloc] init];
		}
		cell.accessoryView = self.sslSwitch;
	}
}

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender
{
    
}

-(IBAction)segmentDidChange:(UISegmentedControl *)sender
{
	if (sender.selectedSegmentIndex == 0) {
		mode = ICAddModeNetwork;
		[self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
		mode = ICAddModeChannel;
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    accessoryView.backgroundColor = [UIColor blackColor];
    [accessoryView setTranslucent:YES];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    accessoryView.items = @[flex, done];
    textField.inputAccessoryView = accessoryView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)viewDidUnload
{
    [self setSslSwitch:nil];
    [super viewDidUnload];
}

@end
