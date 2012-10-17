//
//  ICAppDelegate.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICAppDelegate.h"
#import "ICWebSocketDelegate.h"
#import "SRWebSocket.h"
#include <sys/utsname.h>

@implementation ICAppDelegate
@synthesize notificationView;

- (void)dealloc
{
	[_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar"] forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
	[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[[UIToolbar appearance] setBarStyle:UIBarStyleBlack];
	[[UIBarButtonItem appearance] setTintColor:RGBA(82, 255, 255, 1)];
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
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"]) {
		//[self openWebSocket];
	}
    return YES;
}
							
-(void)openWebSocket {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"]) {
		return;
	}
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"wss://alpha.irccloud.com"]];
	struct utsname info;
	uname(&info);
	[request addValue:[NSString stringWithFormat:@"IRCCloudiOS/%@ (%@; iOS %@)", @"0.0.1", [NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding], [[UIDevice currentDevice] systemVersion]] forHTTPHeaderField:@"User-Agent"];
	NSLog(@"ua = %@", [NSString stringWithFormat:@"IRCCloudiOS/%@ (%@; iOS %@)", @"0.0.1", [NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding], [[UIDevice currentDevice] systemVersion]]);
	[request addValue:[NSString stringWithFormat:@"session=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"cookie"]] forHTTPHeaderField:@"Cookie"];
	/*NSDictionary *cookies=[NSHTTPCookie requestHeaderFieldsWithCookies:@[[NSHTTPCookie cookieWithProperties:@{NSHTTPCookieDomain: @"alpha.irccloud.com", NSHTTPCookiePath: @"/", NSHTTPCookieName: @"session", NSHTTPCookieValue: [[NSUserDefaults standardUserDefaults] stringForKey:@"cookie"]}]]];
	[request setAllHTTPHeaderFields:cookies];*/
	webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
	webSocket.delegate = [[ICWebSocketDelegate alloc] init];
	[webSocket open];
}

-(void)applicationWillTerminate:(UIApplication *)application {
	[webSocket close];
}

@end
