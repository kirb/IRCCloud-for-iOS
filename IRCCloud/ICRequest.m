//
//  ICRequest.m
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <objc/runtime.h>
#include <sys/utsname.h>
#import "ICRequest.h"

static NSMutableData *output;

@implementation ICRequest

+(ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params unauth:(BOOL)unauth delegate:(id)delegate selector:(SEL)selector {
	return [[self alloc] initWithPage:page parameters:params unauth:unauth delegate:delegate selector:selector];
}

-(ICRequest *)initWithPage:(NSString *)page parameters:(NSString *)params unauth:(BOOL)unauth delegate:(id)delegate1 selector:(SEL)selector1 {
	self = [super init];
	if (self) {
		output = [[NSMutableData alloc] init];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://alpha.irccloud.com/chat/%@", page]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:90];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
		struct utsname info;
		uname(&info);
		[request addValue:[NSString stringWithFormat:@"IRCCloudiOS/%@ (%@; iOS %@)", @"0.0.1", [NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding], [[UIDevice currentDevice] systemVersion]] forHTTPHeaderField:@"User-Agent"];
		if (!unauth && ![[[NSUserDefaults standardUserDefaults] stringForKey:@"cookie"] isEqualToString:@""]){
			NSDictionary *cookies = [NSHTTPCookie requestHeaderFieldsWithCookies:@[[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"alpha.irccloud.com", NSHTTPCookieDomain, @"/", NSHTTPCookiePath, @"session", NSHTTPCookieName, [[NSUserDefaults standardUserDefaults] stringForKey:@"cookie"], NSHTTPCookieValue, nil]]]];
			[request setAllHTTPHeaderFields:cookies];
		} else {
			request.HTTPShouldHandleCookies = NO;
		}
		[NSURLConnection connectionWithRequest:request delegate:self];
		delegate = delegate1;
		selector = selector1;
	}
	return self;
}

+(ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params delegate:(id)delegate selector:(SEL)selector {
	return [[self alloc] initWithPage:page parameters:params delegate:delegate selector:selector];
}

-(ICRequest *)initWithPage:(NSString *)page parameters:(NSString *)params delegate:(id)delegate1 selector:(SEL)selector1 {
	return [self initWithPage:page parameters:params unauth:NO delegate:delegate1 selector:selector1];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[output appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (!delegate || !selector) {
		return;
	}
	NSError *err = nil;
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:output options:0 error:&err];
	[delegate performSelector:selector withObject:err ? [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-1] forKey:@"error"] : json];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (delegate && selector) {
		[delegate performSelector:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-2], @"error", [error localizedDescription], @"errormsg", nil]];
	}
}
@end
