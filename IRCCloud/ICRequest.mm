#import <objc/runtime.h>
#include <sys/utsname.h>
#import "ICGlobal.h"
#import "ICRequest.h"
#import "ICApplication.h"
#import "NSString+URL.h"

static NSMutableData *output;

@implementation ICRequest
+(ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params alpha:(BOOL)alpha delegate:(id)delegate selector:(SEL)selector{
	return [[self alloc]initWithPage:page parameters:params alpha:alpha delegate:delegate selector:selector];
}
-(ICRequest *)initWithPage:(NSString *)page parameters:(NSString *)params alpha:(BOOL)alpha delegate:(id)delegate1 selector:(SEL)selector1{
	if((self=[super init])){
		output=[[NSMutableData alloc]init];
		NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/chat/%@",alpha?alphaURL:betaURL,page]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:90];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
		struct utsname info;
		uname(&info);
		[request addValue:[NSString stringWithFormat:@"IRCCloudiOS/%@ (%@; iOS %@)",version,[NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding],[[UIDevice currentDevice]systemVersion]] forHTTPHeaderField:@"User-Agent"];
		if(![page isEqualToString:@"login"]&&![[ICApp cookie]isEqualToString:@""]){
			NSLog(@"has cookie");
			NSDictionary *cookies=[NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObject:[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
				[[ICApp userIsOnAlpha]?@"alpha.":@"" stringByAppendingString:@"irccloud.com"],NSHTTPCookieDomain,
				@"/",NSHTTPCookiePath,
				@"session",NSHTTPCookieName,
				[ICApp cookie], NSHTTPCookieValue,
				nil]]]];
			NSLog(@"mmm, cookie... uh, i mean, %@",cookies);
			[request setAllHTTPHeaderFields:cookies];
		}else request.HTTPShouldHandleCookies=NO;
		NSLog(@"lets go!");
		[NSURLConnection connectionWithRequest:request delegate:self];
		delegate=delegate1;
		selector=selector1;
	}
	return self;
}
+(ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params delegate:(id)delegate selector:(SEL)selector{
	return [[self alloc]initWithPage:page parameters:params delegate:delegate selector:selector];
}
-(ICRequest *)initWithPage:(NSString *)page parameters:(NSString *)params delegate:(id)delegate1 selector:(SEL)selector1{
	return [self initWithPage:page parameters:params alpha:[(ICApplication *)[UIApplication sharedApplication]userIsOnAlpha] delegate:delegate1 selector:selector1];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[output appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if(!delegate||!selector)return;
	NSError *err=nil;
	NSDictionary *json=objc_getClass("NSJSONSerialization")?[objc_getClass("NSJSONSerialization") JSONObjectWithData:output options:0 error:&err]:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-2] forKey:@"error"];
	[delegate performSelector:selector withObject:err?[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-1] forKey:@"error"]:json];
	[output release];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	if(delegate&&selector)[delegate performSelector:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-2],@"error",[error localizedDescription],@"errormsg",nil]];
}
@end
