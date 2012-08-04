#import <objc/runtime.h>
#import "ICGlobal.h"
#import "ICApplication.h"
#import "ICNetworksViewController.h"
#import "ICChatViewController.h"

@implementation ICApplication
@synthesize window;
-(void)applicationDidFinishLaunching:(UIApplication *)application{
	window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
	if(isPad){
		viewController=[[objc_getClass("UISplitViewController") alloc]init];
		viewController.delegate=self;
		sidebar=[[ICNetworksViewController alloc]init];
		main=[[ICChatViewController alloc]init];
		sidebarNavController=[[[UINavigationController alloc]initWithRootViewController:sidebar]autorelease];
		mainNavController=[[[UINavigationController alloc]initWithRootViewController:main]autorelease];
		viewController.viewControllers=[NSArray arrayWithObjects:sidebarNavController,mainNavController,nil];
		[window addSubview:viewController.view];
	}else{
		sidebar=[[ICNetworksViewController alloc]init];
		sidebarNavController=[[[UINavigationController alloc]initWithRootViewController:sidebar]autorelease];
		[window addSubview:sidebarNavController.view];
	}
	[window makeKeyAndVisible];
}
-(void)splitViewController:(UISplitViewController *)split willHideViewController:(UIViewController *)ctrl withBarButtonItem:(UIBarButtonItem *)item forPopoverController:(UIPopoverController *)popover{
	main.title=item.title=__(@"CONNECTIONS");
	main.navigationItem.leftBarButtonItem=item;
}
-(void)splitViewController:(UISplitViewController *)split willShowViewController:(UIViewController *)ctrl invalidatingBarButtonItem:(UIBarButtonItem *)item{
	main.title=__(@"IRCCLOUD");
	main.navigationItem.leftBarButtonItem=nil;
}
-(void)dealloc{
	[window release];
	[sidebar release];
	[main release];
	[sidebarNavController release];
	[mainNavController release];
	[super dealloc];
}
@end
