#include <objc/runtime.h>
#import "ICGlobal.h"
#import "ICNetworksViewController.h"
#import "ICChatViewController.h"
#import "ICSettingsViewController.h"
#import "ICLogInViewController.h"
#import "ICApplication.h"
#import "UIViewController+RotationFix.h"

@implementation ICNetworksViewController
@synthesize buffers;
-(void)loadView{
	[super loadView];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.title=__(@"IRCCLOUD");
	self.navigationItem.leftBarButtonItem=[self editButtonItem];
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAdd)];
	[self setToolbarItems:[NSArray arrayWithObjects:
		//[[UIBarButtonItem alloc]initWithTitle:__(@"SETTINGS") style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)]
		[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
		[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)],
	nil] animated:NO];
	self.navigationController.toolbarHidden=NO;
	if([ICApp cookie]==nil&&isPad)[self performSelector:@selector(showLogIn) withObject:nil afterDelay:.3];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
-(void)showLogIn{
	ICLogInViewController *logIn=[[ICLogInViewController alloc]initWithStyle:UITableViewStyleGrouped];
	UINavigationController *logInCtrl=[[UINavigationController alloc]initWithRootViewController:logIn];
	logInCtrl.modalPresentationStyle=UIModalPresentationFormSheet;
	[logInCtrl setParent:self];
	[self.navigationController presentModalViewController:logInCtrl animated:YES];
}
-(void)showAdd{
	UIAlertView *addAlert=[[UIAlertView alloc]initWithTitle:__(@"JOIN_CHANNEL") message:[NSString stringWithFormat:__(@"JOIN_CHANNEL_MESSAGE"),@"Test"] delegate:self cancelButtonTitle:__(@"CANCEL") otherButtonTitles:__(@"JOIN"),nil];
	addAlert.alertViewStyle=UIAlertViewStylePlainTextInput;
	[addAlert textFieldAtIndex:0].text=@"#";
	[addAlert textFieldAtIndex:0].placeholder=@"#channel";
	[addAlert show];
}
-(void)showSettings{
	if(isShowingSettings){
		isShowingSettings=NO;
		[settingsPopover dismissPopoverAnimated:YES];
		[settingsPopover release];
	}else{
		ICSettingsViewController *settings=[[ICSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
		if(isPad){
			isShowingSettings=YES;
			UINavigationController *settingsNavController=[[UINavigationController alloc]initWithRootViewController:settings];
			settingsPopover=[[objc_getClass("UIPopoverController") alloc]initWithContentViewController:settingsNavController];
			settingsPopover.delegate=self;
			settings.popoverController=settingsPopover;
			[settingsPopover presentPopoverFromBarButtonItem:[self.toolbarItems objectAtIndex:1] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}else [self.navigationController pushViewController:settings animated:YES];
	}
}
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)index{
	if([[alert buttonTitleAtIndex:index]isEqualToString:__(@"JOIN")])[[[UIAlertView alloc]initWithTitle:@"Channel would have been joined" message:[alert textFieldAtIndex:0].text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popover{
	isShowingSettings=NO;
	[settingsPopover release];
}
@end
