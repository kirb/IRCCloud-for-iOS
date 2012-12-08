//
//  ICBufferViewController.m
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICBufferViewController.h"
#import "ICMasterViewController.h"
#import "ICAppDelegate.h"

#define kLastRow [NSIndexPath indexPathForRow:self.channel.buffer.count-1 inSection:0]

@interface ICBufferViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation ICBufferViewController
@synthesize channelIndex;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)configureView
{
	((ICAppDelegate *)[UIApplication sharedApplication].delegate).currentBuffer = self;
	
    // Update the user interface for the detail item. 
	if (!textField) {
		textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		textField.borderStyle = UITextBorderStyleRoundedRect;
	}
	if (_serverName) {
		UIView *titleView = [[UIView alloc] init];
		
		UILabel *serverLabel = [[UILabel alloc] init];
		serverLabel.font = [UIFont systemFontOfSize:20];
        serverLabel.text = [_serverName stringByAppendingString:@":"];
		[titleView addSubview:serverLabel];
		
		UILabel *channelNameLabel = [[UILabel alloc] init];
		channelNameLabel.font = [UIFont boldSystemFontOfSize:20];
		channelNameLabel.text = self.channelName;
		[titleView addSubview:channelNameLabel];
		
		serverLabel.backgroundColor = channelNameLabel.backgroundColor = [UIColor clearColor];
        serverLabel.textColor = channelNameLabel.textColor = [UIColor whiteColor];
        serverLabel.shadowColor = channelNameLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];

        serverLabel.shadowOffset = channelNameLabel.shadowOffset = CGSizeMake(0, -1);
		
		CGSize serverSize = [serverLabel.text sizeWithFont:serverLabel.font];
        serverLabel.frame = (CGRect) {{0, 0}, serverSize};
		
		CGSize channelSize = [channelNameLabel.text sizeWithFont:channelNameLabel.font];
		channelNameLabel.frame = (CGRect) {{serverSize.width, 0}, channelSize};
		
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
    self.channel.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (isPad && ![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"]) {
		[(ICMasterViewController *)[self.splitViewController.viewControllers[0] topViewController] performSelector:@selector(showLogIn) withObject:nil afterDelay:0.3];
	}
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.channel.buffer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BufferCell"];
    cell.textLabel.numberOfLines = 5;
    NSString *nick = (self.channel.buffer[indexPath.row])[@"from"];
    NSString *message = [[[self.channel buffer] objectAtIndex:indexPath.row] objectForKey:@"msg"]; // just for some contrast :P
    NSString *text = [[nick stringByAppendingString:@": "] stringByAppendingString:message];
    cell.textLabel.text = text;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - ICBuffer's notifs
- (void)addedMessageToBuffer:(ICBuffer *)buffer
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.channel.buffer indexOfObject:self.channel.buffer.lastObject] inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];

    [self.tableView scrollToRowAtIndexPath:kLastRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
