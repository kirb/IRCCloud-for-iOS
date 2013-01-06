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

#import <QuartzCore/QuartzCore.h>

@implementation ICMasterViewController {} // pragma marks don't show without this, for some reason.

#pragma mark - ViewController Life Cycle
- (void)awakeFromNib
{
	loggedIn = !![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
	servers = [[NSMutableArray alloc] init];
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [kSharedController setDelegate:self];
    
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
	[self updateLoginStatus];
    
	self.detailViewController = (ICBufferViewController *)[(self.splitViewController.viewControllers)[1] topViewController];
	
	((ICAppDelegate *)[UIApplication sharedApplication].delegate).buffers = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"IRCCloud";
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (!isPad) {
        ICNetwork *selectedNetwork = servers[([self.tableView indexPathForSelectedRow].section)];
        self.navigationItem.title = selectedNetwork.networkName;
    }
    
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
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
	return loggedIn ? [[servers[section] channels] count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return loggedIn ? [servers[section] networkName] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // slightly taller cells look nice in the subtitle style.
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (loggedIn) {
        UITableViewCell *cell = nil;
        
        ICNetwork *currentNetwork = servers[indexPath.section];
        ICChannel *currentChannel = currentNetwork.channels[indexPath.row];
        
        if ([cell respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)]) {
             cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell" forIndexPath:indexPath];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell"];
        }
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChannelCell"];
        }
		cell.textLabel.text = [currentChannel name];
        
        if (currentChannel && currentChannel.buffer && currentChannel.buffer.count > 0) {
            NSString *lastSender = [((NSDictionary *)currentChannel.buffer.lastObject)[@"from"] stringByAppendingString:@": "];
            NSString *lastMessage = ((NSDictionary *)currentChannel.buffer.lastObject)[@"msg"];
            NSString *labelText = [lastSender stringByAppendingString:lastMessage];
            // A way to update this must be found. Notifications, maybe.
            cell.detailTextLabel.text = labelText;
        }
        else {
            cell.detailTextLabel.text = @"";
        }
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
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isPad) {
        [self.detailViewController setServerName:[servers[indexPath.section] networkName]];
        [self.detailViewController setChannel:[servers[indexPath.section] channels][indexPath.row]];
        [self.detailViewController.tableView reloadData];
		[self.detailViewController configureView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showBuffer"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [segue.destinationViewController setServerName:[servers[indexPath.section] networkName]];
		[(ICBufferViewController *)segue.destinationViewController configureView];
        [(ICBufferViewController *)segue.destinationViewController setChannel:[servers[indexPath.section] channels][indexPath.row]];
    }
}

#pragma mark - ICController Delegate

- (void)parserFinishedLoadingOOB
{
    for (ICNetwork *network in [[kSharedController networks] reverseObjectEnumerator]) {
        // reverse object enumerator needs to be used, because the controller has it all backwards :P
        [network setDelegate:self];
        [servers addObject:network];
    }
    [self.tableView reloadData];
}

- (void)controllerDidAddNetwork:(ICNetwork *)network
{
    [network setDelegate:self];
    [servers addObject:network];
    
    [self.tableView reloadData];
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
    // get the indexPath before the channel is removed.
    removalPath = [NSIndexPath indexPathForRow:[network.channels indexOfObject:channel] inSection:[servers indexOfObject:network]];    
}

- (void)network:(ICNetwork *)network didRemoveChannel:(ICChannel *)channel
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[removalPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

@end
