//
//  ICLogInViewController.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICLogInViewController.h"
#import "ICTextCell.h"
#import "../MBProgressHUD/MBProgressHUD.h"
#import "ICRequest.h"
#import "ICAppDelegate.h"
#import "ICMasterViewController.h"
#import "ICWebSocketDelegate.h"

@interface ICLogInViewController ()

@end

@implementation ICLogInViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[((ICTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
}

-(void)logIn {
	NSString *email = ((ICTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField.text;
	NSString *pass = ((ICTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text;
	if (email == nil || [email isEqualToString:@""]) {
		[[[UIAlertView alloc] initWithTitle:L(@"Oops, you forgot to enter your email address.") message:nil delegate:nil cancelButtonTitle:L(@"Dismiss") otherButtonTitles:nil] show];
		[((ICTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField becomeFirstResponder];
		return;
	}
	if (pass == nil || [pass isEqualToString:@""]) {
		[[[UIAlertView alloc] initWithTitle:L(@"Oops, you forgot to enter your password.") message:nil delegate:nil cancelButtonTitle:L(@"Dismiss") otherButtonTitles:nil] show];
		[((ICTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField becomeFirstResponder];
		return;
	}
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
	self.view.userInteractionEnabled = NO;
	cancelButton = self.navigationItem.leftBarButtonItem;
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[ICRequest requestWithPage:@"login" parameters:[NSString stringWithFormat:@"email=%@&password=%@", [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [pass stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] unauth:YES delegate:self selector:@selector(_gotSessionCookie:)];
}
-(void)_gotSessionCookie:(NSDictionary *)json{
	NSString *logInError = @"";
	if ([json objectForKey:@"success"] && [[json objectForKey:@"success"] boolValue] && [json objectForKey:@"session"]) {
		[[NSUserDefaults standardUserDefaults] setValue:[json objectForKey:@"session"] forKey:@"cookie"];
		[((ICAppDelegate *)[UIApplication sharedApplication].delegate).webSocket open];
		[((ICAppDelegate *)[UIApplication sharedApplication].delegate).buffers updateLoginStatus];
		[self dismissViewControllerAnimated:YES completion:NULL];
		return;
	} else if ([json objectForKey:@"message"]) {
		if ([[json objectForKey:@"message"] isEqualToString:@"auth"]) {
			logInError = L(@"Your email address or password was incorrect.");
		} else if ([[json objectForKey:@"message"] isEqualToString:@"legacy_account"]) {
			logInError = L(@"Your account hasn't been migrated to IRCCloud Alpha.");
		} else {
			logInError = [NSString stringWithFormat:L(@"Unknown error. (\"%@\")"), [json objectForKey:@"message"]];
		}
	} else {
		logInError = L(@"Unknown error.");
	}
	if (![logInError isEqualToString:@""]) {
		[MBProgressHUD hideHUDForView:self.view animated:YES];
		[[[UIAlertView alloc] initWithTitle:L(@"Oops, an error occurred.") message:logInError delegate:nil cancelButtonTitle:L(@"Dismiss") otherButtonTitles:nil] show];
	}
	self.view.userInteractionEnabled = YES;
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0 || indexPath.row == 1) {
		ICTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
		cell.textField.placeholder = L(indexPath.row == 0 ? @"Email" : @"Password");
		cell.textField.secureTextEntry = indexPath.row == 1;
		cell.textField.keyboardType = indexPath.row == 0 ? UIKeyboardTypeEmailAddress : UIKeyboardTypeDefault;
		cell.textField.returnKeyType = indexPath.row == 0 ? UIReturnKeyNext : UIReturnKeyGo;
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
		cell.textField.tag = 5 + indexPath.row;
		cell.textField.delegate = self;
		return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogInCell"];
		cell.textLabel.text = L(@"Log In");
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		return cell;
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return L(@"Please note that your account must be migrated to IRCCloud Alpha.");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == 0 || indexPath.row == 1) {
		[[tableView cellForRowAtIndexPath:indexPath].contentView becomeFirstResponder];
	} else {
		[self logIn];
	}
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField.tag == 5) {
		[((ICTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField becomeFirstResponder];
	} else if (textField.tag == 6) {
		[self logIn];
	}
	return YES;
}

@end
