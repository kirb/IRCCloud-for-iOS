//
//  ICAppDelegate.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICAppDelegate.h"
#import "ICWebSocketDelegate.h"
#import "ICNotification.h"
#import "ICParser.h"
#import "JSONKit.h"

@implementation ICAppDelegate
@synthesize notificationView, webSocket, buffers, currentBuffer, isConnected, selectedBufferID, highlights, preferences;


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
		UINavigationController *navigationController = splitViewController.viewControllers[1];
		splitViewController.delegate = (id)navigationController.topViewController;
		
		mainView = navigationController.view;
	} else {
		mainView = self.window.rootViewController.view;
	}
	
	notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, isPad ? 44 : 64, mainView.frame.size.width, 100)];
	notificationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	notificationView.userInteractionEnabled = NO;
	[mainView addSubview:notificationView];
	
	self.webSocket = [[ICWebSocketDelegate alloc] init];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"]) {
		[webSocket open];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
    return YES;
}

-(void)applicationWillTerminate:(UIApplication *)application {
	[webSocket close];
}

- (void)receivedJSON:(NSDictionary *)data
{
	if (!data[@"type"]) {
		return;
	} else if ([data[@"type"] isEqualToString:@"header"]) {
        NSLog(@"Header received.");
    } else if ([data[@"type"] isEqualToString:@"stat_user"]) {
		if (![data[@"verified"] boolValue]) {
			[ICNotification notificationWithMessage:L(@"Reminder: You haven't verified your email address.") type:AJNotificationTypeBlue];
		}
		self.selectedBufferID = [data[@"last_selected_bid"] intValue];
		self.highlights = data[@"highlights"];
		self.preferences = [data[@"prefs"] objectFromJSONString];
	} else if ([data[@"type"] isEqualToString:@"oob_include"]) {
		[self performSelectorInBackground:@selector(getOOBLoaderWithURL:) withObject:data[@"url"]];
	} else {
        [[ICParser sharedParser] performSelectorInBackground:@selector(parse:) withObject:data];
	}
}

- (void)getOOBLoaderWithURL:(NSString *)url
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[@"https://alpha.irccloud.com" stringByAppendingString:url]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	[request addValue:[NSString stringWithFormat:@"session=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"cookie"]] forHTTPHeaderField:@"Cookie"];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	if (data == nil) {
		[ICNotification notificationWithMessage:L(@"Oops, something went wrong while connecting to the server.") type:AJNotificationTypeOrange];
	} else {
		NSArray *jsonArray = [data objectFromJSONData];
		[[ICParser sharedParser] parseOOBArray:jsonArray];
	}
}

@end
