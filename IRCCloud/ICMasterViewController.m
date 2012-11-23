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
#import "ICAppDelegate.h"

@implementation ICMasterViewController

- (void)awakeFromNib
{
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
	self.detailViewController = (ICBufferViewController *)[[self.splitViewController.viewControllers objectAtIndex:1] topViewController];
	
	((ICAppDelegate *)[UIApplication sharedApplication].delegate).buffers = self;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (!isPad && !loggedIn) {
		[self performSelector:@selector(showLogIn) withObject:nil afterDelay:0.3];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    ICAddViewController *adder = [[UIStoryboard storyoardWithName:@"Add" bundle:nil] instantiateInitialViewController];
	[self.navigationController presentViewController:adder animated:YES completion:NULL];
}

-(void)showLogIn {
	ICLogInViewController *logIn = [[UIStoryboard storyboardWithName:isPad ? @"LogIn_iPad" : @"LogIn_iPhone" bundle:nil] instantiateInitialViewController];
	[self.navigationController presentViewController:logIn animated:YES completion:NULL];
}

-(IBAction)showSettings:(id)sender {
}

-(void)updateLoginStatus {
	loggedIn = !![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
	if (loggedIn) {
		UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
		self.navigationItem.rightBarButtonItem = addButton;
	} else {
		self.navigationItem.leftBarButtonItem = nil;
	}
	[self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return loggedIn ? servers.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return loggedIn ? [servers[section][1] count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return loggedIn ? servers[section][0] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (loggedIn) {
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell" forIndexPath:indexPath];
		cell.textLabel.text = servers[indexPath.section][1][indexPath.row];
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavBar"]];
    	return cell;
	}
	return nil;
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
    if ([[segue identifier] isEqualToString:@"showBuffer"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [segue.destinationViewController setServer:servers[indexPath.section]];
		[segue.destinationViewController setChannelIndex:indexPath.row];
		[(ICBufferViewController *)segue.destinationViewController configureView];
    }
}

@end
