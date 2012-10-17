//
//  ICAppDelegate.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICAppDelegate.h"
#import "ICWebSocketDelegate.h"

@implementation ICAppDelegate
@synthesize notificationView, webSocket;

- (void)dealloc
{
	[_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar"] forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
	[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[[UIToolbar appearance] setBarStyle:UIBarStyleBlack];
	[[UIBarButtonItem appearance] setTintColor:RGBA(82, 125, 255, 1)];
	//[[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"NavButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	//[[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"NavButtonSelected"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	UIView *mainView;
	if (isPad) {
	    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
	    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
	    splitViewController.delegate = (id)navigationController.topViewController;
		mainView = navigationController.view;
	} else {
		mainView = self.window.rootViewController.view;
	}
	
	notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, isPad ? 44 : 64, mainView.frame.size.width, 100)];
	notificationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[mainView addSubview:notificationView];
	
	self.webSocket = [[ICWebSocketDelegate alloc] init];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"]) {
		[webSocket open];
	}
    return YES;
}

-(void)applicationWillTerminate:(UIApplication *)application {
	[webSocket close];
}

@end
