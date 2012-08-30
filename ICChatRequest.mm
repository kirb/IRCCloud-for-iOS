#import <objc/runtime.h>
#include <sys/utsname.h>
#import "ICGlobal.h"
#import "ICChatRequest.h"
#import "ICRequest.h"
#import "ICApplication.h"
#import "lib/WebSocket.h"

@implementation ICChatRequest
@synthesize connected,webSocket;
-(ICChatRequest *)initWithDelegate:(id)delegate1 selector:(SEL)messageSelector1 errorSelector:(SEL)errorSelector1{
	if(![ICApp cookie]||[[ICApp cookie]isEqualToString:@""])return nil;
	if((self=[super init])){
		delegate=delegate1;
		messageSelector=messageSelector1;
		errorSelector=errorSelector1;
		NSLog(@"websocket.");
		WebSocketConnectConfig *config=[WebSocketConnectConfig configWithURLString:[NSString stringWithFormat:@"wss://%@/",[ICApp userIsOnAlpha]?alphaURL:betaURL]
			origin:nil protocols:nil tlsSettings:nil headers:[NSArray arrayWithObject:[@"Cookie: session=" stringByAppendingString:[ICApp cookie]]] verifySecurityKey:YES extensions:nil];
		config.host=[ICApp userIsOnAlpha]?alphaURL:betaURL;
		config.closeTimeout=15;
		config.isSecure=YES;
		NSLog(@"here we go.");
		self.webSocket=[[WebSocket webSocketWithConfig:config delegate:self]retain];
	}
	return self;
}
-(void)startConnection{
	NSLog(@"firin' up the socket");
	[self.webSocket open];//idk why we need this to be separate, but somehow that works.
}
-(void)didOpen{
	NSLog(@"websocket connected");
	self.connected=YES;
}
-(void)didClose:(NSUInteger)status message:(NSString *)msg error:(NSError *)err{
	NSLog(@"fail :( - %@ / %@",msg,err);
	self.connected=NO;
	[delegate performSelector:errorSelector withObject:err];
}
-(void)didReceiveError:(NSError *)err{
	NSLog(@"hmm, error. %@",err);
	[delegate performSelector:errorSelector withObject:err];
}
-(void)didReceiveTextMessage:(NSString *)msg{
	NSLog(@"message! %@",msg);
	if([msg isEqualToString:@""])return;
	NSError *err=nil;
	NSDictionary *json=msg?[objc_getClass("NSJSONSerialization") JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err]:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-2] forKey:@"error"];
	if(err)[delegate performSelector:errorSelector withObject:err];
	else [delegate performSelector:messageSelector withObject:json];
}
-(void)didReceiveBinaryMessage:(NSData *)msg{
	NSLog(@"wtf, received binary from the websocket");
}
@end
