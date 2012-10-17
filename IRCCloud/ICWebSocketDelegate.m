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

@implementation ICWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
	NSLog(@"MESSAGE! %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
	NSLog(@"OPEN!");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
	NSLog(@"CLOSED :( %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
	[ICNotification notificationWithMessage:[NSString stringWithFormat:L(@"Oops, an error occurred: \"%@\""), reason] type:AJNotificationTypeRed];
	NSLog(@"CLOSED :/ %i, %@, %@", code, reason, wasClean ? @"Y" : @"N");
}

@end
