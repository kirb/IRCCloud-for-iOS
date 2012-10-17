//
//  ICMasterViewController.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICMasterViewController.h"
#import "ICBufferViewController.h"
#import "ICLogInViewController.h"

@implementation ICMasterViewController

- (void)awakeFromNib
{
	if (isPad) {
	    self.clearsSelectionOnViewWillAppear = NO;
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	}
	loggedIn = !![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
	servers = [[NSMutableArray alloc] initWithObjects:
				@[@"IRCCloud", [@[@"#alpha", @"#changelog", @"#feedback", @"#themes"] mutableCopy]],
				@[@"Saurik", [@[@"#bacon", @"#cycript", @"#cydia", @"#iphone", @"#iphonedev", @"#theos", @"#winterboard"] mutableCopy]],
				@[@"Rizon", [@[@"#jailbreak", @"#tklbot"] mutableCopy]],
				@[@"Chronic-Dev", [@[@"#greenpois0n"] mutableCopy]],
				@[@"freenode", [@[@"#GelbrackQA", @"#iphonedev", @"#iTweakStore", @"#iTweakStore-dev", @"#jailbreakqa"] mutableCopy]],
				nil];
    [super awakeFromNib];
}

- (void)dealloc
{
	[_detailViewController release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	[self updateLoginStatus];
	self.detailViewController = (ICBufferViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    [servers[0][1] addObject:[[NSDate date] description]];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[servers[0][1] count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)showLogIn {
	ICLogInViewController *logIn = [[UIStoryboard storyboardWithName:@"LogIn" bundle:nil] instantiateInitialViewController];
	[self.navigationController presentViewController:logIn animated:YES completion:NULL];
}

-(void)showSettings {}

-(void)updateLoginStatus {
	loggedIn = !![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
	if (loggedIn) {
		UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
		self.navigationItem.rightBarButtonItem = addButton;
		self.navigationController.toolbarHidden = NO;
		self.navigationController.toolbarItems = [@[
												  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
												  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettings)]
												  ] copy];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
	}
	[self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return loggedIn ? servers.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return loggedIn ? [servers[section][1] count] : 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return loggedIn ? servers[section][0] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (loggedIn) {
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell" forIndexPath:indexPath];
		cell.textLabel.text = servers[indexPath.section][1][indexPath.row];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		CGRect labelFrame = cell.textLabel.frame;
		labelFrame.origin.y = 16;
		cell.textLabel.frame = labelFrame;
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavBar"]];
		[cell.selectedBackgroundView addSubview:[cell viewWithTag:5]];
    	return cell;
	} else if (indexPath.row < 4) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WelcomeCell" forIndexPath:indexPath];
		
		switch (indexPath.row) {
			case 1:
			{
				UIImageView *icon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon~ipad"]] autorelease];
				icon.center = cell.contentView.center;
				icon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
				[cell.contentView addSubview:icon];
				break;
			}
			case 2:
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.text = L(@"Welcome to IRCCloud");
				break;
		}
		return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogInCell" forIndexPath:indexPath];
		[(UIButton *)[cell viewWithTag:5] addTarget:self action:@selector(showLogIn) forControlEvents:UIControlEventTouchUpInside];
		return cell;
	}
	return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!loggedIn) {
		switch (indexPath.row) {
			case 0:
				return 100.f;
			case 1:
				return 72.f;
		}
	} else {
		return 40.f;
	}
	return 44.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return loggedIn;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [servers[indexPath.section][1] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isPad) {
        self.detailViewController.server = servers[indexPath.section];
		self.detailViewController.channelIndex = indexPath.row;
		[self.detailViewController configureView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [segue.destinationViewController setServer:servers[indexPath.section]];
		[segue.destinationViewController setChannelIndex:indexPath.row];
		[(ICBufferViewController *)segue.destinationViewController configureView];
    }
}

@end
