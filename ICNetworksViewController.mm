#import "ICGlobal.h"
#import "ICNetworksViewController.h"
#import "ICChatViewController.h"
#import "ICSettingsViewController.h"
#import "ICLogInViewController.h"

@implementation ICNetworksViewController
@synthesize buffers;
-(void)loadView{
	[super loadView];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.title=__(@"IRCCLOUD");
	self.navigationItem.rightBarButtonItem=[self editButtonItem];
	self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:__(@"SETTINGS") style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
	[self performSelector:@selector(showSignIn) withObject:nil afterDelay:.5];
}
-(void)showSignIn{
	ICLogInViewController *logIn=[[ICLogInViewController alloc]initWithStyle:UITableViewStyleGrouped];
	UINavigationController *logInCtrl=[[UINavigationController alloc]initWithRootViewController:logIn];
	logInCtrl.modalPresentationStyle=UIModalPresentationFormSheet;
	[self.navigationController presentModalViewController:logInCtrl animated:YES];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
-(void)showSettings{
	ICSettingsViewController *settings=[[ICSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:settings animated:YES];
}
@end
