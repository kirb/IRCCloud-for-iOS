#import "ICGlobal.h"
#import "ICNetworksViewController.h"
#import "ICChatViewController.h"
#import "ICSettingsViewController.h"
#import "ICLogInViewController.h"

@implementation ICNetworksViewController
@synthesize buffers,hasCookie;
-(void)loadView{
	[super loadView];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.title=__(@"IRCCLOUD");
	self.navigationItem.leftBarButtonItem=[self editButtonItem];
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAdd)];
	self.navigationController.toolbarHidden=NO;
	[self.navigationController setToolbarItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc]initWithTitle:__(@"SETTINGS") style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)]] animated:NO];
	if(!self.hasCookie)[self performSelector:@selector(showSignIn) withObject:nil afterDelay:.3];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
-(void)showAdd{}
-(void)showSignIn{
	ICLogInViewController *logIn=[[ICLogInViewController alloc]initWithStyle:UITableViewStyleGrouped];
	UINavigationController *logInCtrl=[[UINavigationController alloc]initWithRootViewController:logIn];
	logInCtrl.modalPresentationStyle=UIModalPresentationFormSheet;
	[self.navigationController presentModalViewController:logInCtrl animated:YES];
}
-(void)showSettings{
	ICSettingsViewController *settings=[[ICSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:settings animated:YES];
}
@end
