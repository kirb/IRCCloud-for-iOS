//
//  ICWebSocketDelegate.m
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICWebSocketDelegate.h"
#import "ICAppDelegate.h"
#import "ICNotification.h"
#import "HandshakeHeader.h"
#import "JSONKit.h"
#include <sys/utsname.h>

@implementation ICWebSocketDelegate
@synthesize webSocket;
- (id)init
{
	self = [super init];
	if (self) {
		struct utsname info;
		uname(&info);
		WebSocketConnectConfig *config = [WebSocketConnectConfig configWithURLString:@"wss://alpha.irccloud.com"
                                                                              origin:nil
                                                                           protocols:nil
                                                                         tlsSettings:[@{
																(NSString *)kCFStreamSSLPeerName: [NSNull null],
														   (NSString *)kCFStreamSSLAllowsAnyRoot: @YES,
											   (NSString *)kCFStreamSSLValidatesCertificateChain: @NO
										  } mutableCopy] headers:[@[
											[HandshakeHeader headerWithValue:[NSString stringWithFormat:@"IRCCloudiOS/%@ (%@; iOS %@)", @"0.0.1",
                                            [NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding],
                                            [[UIDevice currentDevice] systemVersion]] forKey:@"User-Agent"],
											[HandshakeHeader headerWithValue:[NSString stringWithFormat:@"session=%@",
                                            [[NSUserDefaults standardUserDefaults] stringForKey:@"cookie"]] forKey:@"Cookie"]
										  ] mutableCopy]
                                                                   verifySecurityKey:YES
                                                                          extensions:nil];
		config.closeTimeout = 15;
		config.keepAlive = 15;
		webSocket = [WebSocket webSocketWithConfig:config delegate:self];
	}
	return self;
}

- (void)open
{
	[webSocket open];
}

- (void)close
{
	[webSocket close];
}

- (void)didReceiveTextMessage:(NSString *)message
{
	if ([message isEqualToString:@""]) {
		return;
	}
	[(ICAppDelegate *)[UIApplication sharedApplication].delegate receivedJSON:[message objectFromJSONString]];
}

- (void)didReceiveBinaryMessage:(NSData *)message {} // not needed; the stream will never send a binary message

- (void)didOpen
{
	((ICAppDelegate *)[UIApplication sharedApplication].delegate).isConnected = YES;
}

- (void)didReceiveError:(NSError *)error
{
	[ICNotification notificationWithMessage:[NSString stringWithFormat:L(@"Oops, an error occurred: \"%@\""), error.localizedDescription] type:AJNotificationTypeRed];
	((ICAppDelegate *)[UIApplication sharedApplication].delegate).isConnected = NO;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)didClose:(NSUInteger)statusCode message:(NSString *)message error:(NSError *)error
{
	[ICNotification notificationWithMessage:[NSString stringWithFormat:L(@"Oops, an error occurred: \"%@\""), message] type:AJNotificationTypeRed];
	((ICAppDelegate *)[UIApplication sharedApplication].delegate).isConnected = NO;
}


- (void)sendJSONFromDictionary:(NSDictionary *)dict
{
    NSData *data = [dict JSONData];
    [webSocket sendBinary:data];
}

@end
