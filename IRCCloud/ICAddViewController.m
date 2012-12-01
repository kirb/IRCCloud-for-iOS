//
//  ICAddViewController.m
//  IRCCloud
//
//  Created by Adam D on 22/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICAddViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ICAddViewController ()
@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UISwitch *sslSwitch;

@end

@implementation ICAddViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].backgroundView = [[UIView alloc] init];
    self.portTextField.layer.cornerRadius = 3.5f;
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
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:(CGRect){0, 0, [UIScreen mainScreen].bounds.size.width, 50}];
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
    [self.portTextField resignFirstResponder];
}

- (void)viewDidUnload
{
    [self setPortTextField:nil];
    [self setSslSwitch:nil];
    [super viewDidUnload];
}
@end
