//
//  ICWebSocketDelegate.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICWebSocketDelegate.h"
#import "ICAppDelegate.h"
#import "ICNotification.h"
#include <sys/utsname.h>

@implementation ICWebSocketDelegate

-(id)init {
	self = [super init];
	if (self) {
		struct utsname info;
		uname(&info);
		NSLog(@"setting config");
		WebSocketConnectConfig *config = [WebSocketConnectConfig configWithURLString:@"wss://alpha.irccloud.com" origin:nil protocols:nil tlsSettings:nil headers:@[
										  [NSString stringWithFormat:@"User-Agent: IRCCloudiOS/%@ (%@; iOS %@)", @"0.0.1", [NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding], [[UIDevice currentDevice] systemVersion]],
										  [NSString stringWithFormat:@"Cookie: session=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"cookie"]]
										  ] verifySecurityKey:YES extensions:nil];
		config.closeTimeout = 15;
		config.keepAlive = 15;
		webSocket = [[WebSocket webSocketWithConfig:config delegate:self] retain];
	}
	return self;
}

-(void)open {
	[webSocket open];
}

-(void)close {
	[webSocket close];
}

-(void)didReceiveTextMessage:(NSString *)message {
	NSLog(@"MESSAGE! %@", message);
}

-(void)didReceiveBinaryMessage:(NSData *)message {
	NSLog(@"BINARY MESSAGE...?");
}

-(void)didOpen {
	NSLog(@"OPEN!");
}

-(void)didReceiveError:(NSError *)error {
	NSLog(@"CLOSED :( %@", error);
}

-(void)didClose:(NSUInteger)statusCode message:(NSString *)message error:(NSError *)error {
	[ICNotification notificationWithMessage:[NSString stringWithFormat:L(@"Oops, an error occurred: \"%@\""), message] type:AJNotificationTypeRed];
	NSLog(@"CLOSED :/ %u, %@, %@", statusCode, message, error);
}

@end
