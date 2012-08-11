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
	[self.navigationController setToolbarItems:[NSArray arrayWithObjects:
		//[[UIBarButtonItem alloc]initWithTitle:__(@"SETTINGS") style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)]
		[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
		[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettings)], //todo: get a settings icon
	nil] animated:NO];
	self.navigationController.toolbarHidden=NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
-(void)showAdd{}
-(void)showSettings{
	ICSettingsViewController *settings=[[ICSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:settings animated:YES];
}
@end
