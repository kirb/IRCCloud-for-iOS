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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.sslSwitch = [[UISwitch alloc] init];
	}
	return self;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0 && indexPath.row == 0) {
		cell.backgroundView = [[UIView alloc] init];
	} else if (indexPath.section == 1 && indexPath.row == 2) {
		NSLog(@"ssl = %@", self.sslSwitch);
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
