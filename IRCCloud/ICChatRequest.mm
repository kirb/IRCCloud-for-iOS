#import <objc/runtime.h>
#include <sys/utsname.h>
#import "ICGlobal.h"
#import "ICChatRequest.h"
#import "ICApplication.h"
#import "SocketRocket/SRWebSocket.h"

@implementation ICChatRequest
@synthesize connected,webSocket;
-(ICChatRequest *)initWithDelegate:(id)delegate1 selector:(SEL)messageSelector1 errorSelector:(SEL)errorSelector1{
	if(![ICApp cookie]||[[ICApp cookie]isEqualToString:@""])return nil;
	if((self=[super init])){
		delegate=delegate1;
		messageSelector=messageSelector1;
		errorSelector=errorSelector1;
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"wss://%@/",[ICApp userIsOnAlpha]?alphaURL:betaURL]]];
        struct utsname info;
		uname(&info);
		[request addValue:[NSString stringWithFormat:@"IRCCloudiOS/%@ (%@; iOS %@)",version,[NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding],[[UIDevice currentDevice]systemVersion]] forHTTPHeaderField:@"User-Agent"];
        NSDictionary *cookies=[NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObject:[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
            [[ICApp userIsOnAlpha]?@"alpha.":@"" stringByAppendingString:@"irccloud.com"],NSHTTPCookieDomain,
            @"/",NSHTTPCookiePath,
            @"session",NSHTTPCookieName,
            [ICApp cookie], NSHTTPCookieValue,
            nil]]]];
		NSLog(@"mmm, cookie... uh, i mean, %@",cookies);
		[request setAllHTTPHeaderFields:cookies];
		NSLog(@"websocket.");
        self.webSocket=[[SRWebSocket alloc]initWithRequest:request];
		NSLog(@"here we go.");
		self.webSocket.delegate=self;
        [self.webSocket open];
	}
	return self;
}
-(void)webSocketDidOpen:(SRWebSocket *)socket{
	NSLog(@"websocket connected");
	self.connected=YES;
}
-(void)webSocket:(SRWebSocket *)socket didCloseWithCode:(NSInteger)code reason:(NSString *)msg{
	NSLog(@"fail :( - %i / %@",code,msg);
	self.connected=NO;
	[delegate performSelector:errorSelector withObject:[NSError errorWithDomain:@"ICWebSocketClosed" code:code userInfo:
        [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]]];
}
-(void)webSocket:(SRWebSocket *)socket didFailWithError:(NSError *)err{
	NSLog(@"hmm, error. %@",err);
	[delegate performSelector:errorSelector withObject:err];
}
-(void)webSocket:(SRWebSocket *)socket didReceiveMessage:(NSString *)msg{
	NSLog(@"message! %@",msg);
	if([msg isEqualToString:@""])return;
	NSError *err=nil;
	NSDictionary *json=msg?[objc_getClass("NSJSONSerialization") JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err]:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-2] forKey:@"error"];
	if(err)[delegate performSelector:errorSelector withObject:err];
	else [delegate performSelector:messageSelector withObject:json];
}
@end
