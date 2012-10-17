//
//  ICBufferViewController.m
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICBufferViewController.h"

@interface ICBufferViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation ICBufferViewController
@synthesize server, channelIndex;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
	[_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)configureView
{
    // Update the user interface for the detail item. 
	if (!textField) {
		textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		textField.borderStyle = UITextBorderStyleRoundedRect;
	}
	if (server) {
		//self.title = [NSString stringWithFormat:@"%@ | %@", server[1][channelIndex], server[0]];
		UIView *titleView = [[UIView alloc] init];
		
		UILabel *serverName = [[UILabel alloc] init];
		serverName.font = [UIFont systemFontOfSize:20];
		serverName.text = [NSString stringWithFormat:@"%@: ", server[0]];
		[titleView addSubview:serverName];
		
		UILabel *channelName = [[UILabel alloc] init];
		channelName.font = [UIFont boldSystemFontOfSize:20];
		channelName.text = server[1][channelIndex];
		[titleView addSubview:channelName];
		
		serverName.backgroundColor = channelName.backgroundColor = [UIColor clearColor];
		serverName.textColor = channelName.textColor = [UIColor whiteColor];
		serverName.shadowColor = channelName.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];

		serverName.shadowOffset = channelName.shadowOffset = CGSizeMake(0, -1);
		
		CGSize serverSize = [serverName.text sizeWithFont:serverName.font];
		serverName.frame = (CGRect) {{0, 0}, serverSize};
		
		CGSize channelSize = [channelName.text sizeWithFont:channelName.font];
		channelName.frame = (CGRect) {{serverSize.width, 0}, channelSize};
		
		titleView.frame = CGRectMake(0, 0, serverSize.width + channelSize.width, channelSize.height);
		self.navigationItem.titleView = titleView;
	}
	[self.navigationController setToolbarItems:@[[[UIBarButtonItem alloc] initWithCustomView:textField]] animated:NO];
	self.navigationController.toolbarHidden = NO;
	
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification *)notification {
	/*UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height, 0);
	self.tableView.contentInset = self.tableView.scrollIndicatorInsets = inset;
	CGRect fieldFrame = textField.frame;
	fieldFrame.origin.y = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y - fieldFrame.size.height;
	textField.frame = fieldFrame;
	NSLog(@"keyboard will show; %@, %@, %@", NSStringFromUIEdgeInsets(inset), NSStringFromCGRect(fieldFrame), NSStringFromCGRect([notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue]));*/
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textField action:@selector(resignFirstResponder)] animated:YES];
}

-(void)keyboardWillHide:(NSNotification *)notification {
	/*self.tableView.contentInset = self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
	CGRect fieldFrame = textField.frame;
	fieldFrame.origin.y = self.view.frame.size.height - fieldFrame.size.height;
	textField.frame = fieldFrame;
	NSLog(@"keyboard will hide; %@, %@", NSStringFromCGRect(fieldFrame), NSStringFromCGRect([notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue]));*/
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = L(@"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
