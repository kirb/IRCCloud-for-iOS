//
//  ICMasterViewController.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICMasterViewController.h"
#import "ICBufferViewController.h"
#import "ICLogInViewController.h"
#import "ICAddViewController.h"
#import "ICAppDelegate.h"
#import "ICController.h"
#import "ICNetwork.h"
#import "ICChannel.h"
#import "ICParser.h"

@implementation ICMasterViewController

- (void)awakeFromNib
{
	loggedIn = !![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
	servers = [[NSMutableArray alloc] init];/*WithObjects:
				@[@"IRCCloud", [@[@"#alpha", @"#changelog", @"#feedback", @"#themes"] mutableCopy]],
				@[@"Saurik", [@[@"#bacon", @"#cycript", @"#cydia", @"#iphone", @"#iphonedev", @"#theos", @"#winterboard"] mutableCopy]],
				@[@"Rizon", [@[@"#jailbreak", @"#tklbot"] mutableCopy]],
				@[@"Chronic-Dev", [@[@"#greenpois0n"] mutableCopy]],
				@[@"freenode", [@[@"#GelbrackQA", @"#iphonedev", @"#iTweakStore", @"#iTweakStore-dev", @"#jailbreakqa"] mutableCopy]],
				nil];
                                             */
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [kSharedController setDelegate:self];
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	[self updateLoginStatus];
	self.detailViewController = (ICBufferViewController *)[[self.splitViewController.viewControllers objectAtIndex:1] topViewController];
	
	((ICAppDelegate *)[UIApplication sharedApplication].delegate).buffers = self;
}

- (void)viewDidAppear:(BOOL)animated {
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
    ICAddViewController *adder = [[UIStoryboard storyboardWithName:isPad ? @"Add_iPad" : @"Add_iPhone" bundle:nil] instantiateInitialViewController];
	[self.navigationController presentViewController:adder animated:YES completion:NULL];
}

- (void)showLogIn
{
	ICLogInViewController *logIn = [[UIStoryboard storyboardWithName:isPad ? @"LogIn_iPad" : @"LogIn_iPhone" bundle:nil] instantiateInitialViewController];
	[self.navigationController presentViewController:logIn animated:YES completion:NULL];
}

- (IBAction)showSettings:(id)sender
{
    
}

- (void)updateLoginStatus
{
	loggedIn = !![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
	if (loggedIn) {
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
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
	return loggedIn ? [[[servers objectAtIndex:section] channels] count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return loggedIn ? [servers[section] networkName] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (loggedIn) {
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell" forIndexPath:indexPath];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChannelCell"];
		cell.textLabel.text = [[[[servers objectAtIndex:indexPath.section] channels] objectAtIndex:indexPath.row] name];
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
        [(ICNetwork *)servers[indexPath.section] userPartedChannelWithBID:((ICChannel *)[(ICNetwork *)servers[indexPath.section] channels][indexPath.row]).bid];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isPad) {
        //elf.detailViewController.server = servers[indexPath.section];
		self.detailViewController.channelIndex = indexPath.row;
        [self.detailViewController setServerName:[[servers objectAtIndex:indexPath.section] networkName]];
        [self.detailViewController setChannelName:[[[[servers objectAtIndex:indexPath.section] channels] objectAtIndex:indexPath.row] name]];
        [self.detailViewController setChannel:[[[servers objectAtIndex:indexPath.section] channels] objectAtIndex:indexPath.row]];
        [self.detailViewController.tableView reloadData];
		[self.detailViewController configureView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showBuffer"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [segue.destinationViewController setServerName:[[servers objectAtIndex:indexPath.section] networkName]];
        [(ICBufferViewController *)segue.destinationViewController setChannelName:[[[[servers objectAtIndex:indexPath.section] channels] objectAtIndex:indexPath.row] name]];
		[segue.destinationViewController setChannelIndex:indexPath.row];
		[(ICBufferViewController *)segue.destinationViewController configureView];
        [(ICBufferViewController *)segue.destinationViewController setChannel:[[[servers objectAtIndex:indexPath.section] channels] objectAtIndex:indexPath.row]];
    }
}

#pragma mark - ICController Delegate
- (void)controllerDidAddNetwork:(ICNetwork *)network
{
    [network setDelegate:self];
    [servers addObject:network];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
    });
}

- (void)controllerDidRemoveNetwork:(ICNetwork *)network
{
    [network setDelegate:nil];
    [servers removeObject:network];
    [self.tableView reloadData];
}

#pragma mark - ICNetwork Delegate
- (void)network:(ICNetwork *)network didAddChannel:(ICChannel *)channel
{
    if ([[ICParser sharedParser] loadingOOB] == NO) {
        NSIndexPath *insertionPath = [NSIndexPath indexPathForRow:[[network channels] indexOfObject:channel] inSection:[servers indexOfObject:network]];
        [self.tableView insertRowsAtIndexPaths:@[insertionPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

static __strong NSIndexPath *removalPath = nil;
- (void)network:(ICNetwork *)network willRemoveChannel:(ICChannel *)channel
{
    removalPath = [NSIndexPath indexPathForRow:[network.channels indexOfObject:channel] inSection:[servers indexOfObject:network]];    
}

- (void)network:(ICNetwork *)network didRemoveChannel:(ICChannel *)channel
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[removalPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

@end
