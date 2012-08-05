#import <objc/runtime.h>
#include <sys/utsname.h>
#import "ICGlobal.h"
#import "ICRequest.h"
#import "ICApplication.h"

static NSMutableData *output;

@implementation ICRequest
+(ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params alpha:(BOOL)alpha delegate:(id)delegate selector:(SEL)selector{
	return [[self alloc]initWithPage:page parameters:params alpha:alpha delegate:delegate selector:selector];
}
-(ICRequest *)initWithPage:(NSString *)page parameters:(NSString *)params alpha:(BOOL)alpha delegate:(id)delegate1 selector:(SEL)selector1{
	if((self=[super init])){
		output=[[NSMutableData alloc]init];
		NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@irccloud.com/chat/%@",alpha?@"alpha.":@"",page]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:90];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
		struct utsname info;
		uname(&info);
		[request addValue:[NSString stringWithFormat:@"IRCCloudiOS/%@ (%@; iOS %@)",version,[NSString stringWithCString:info.machine encoding:NSUTF8StringEncoding],[[UIDevice currentDevice]systemVersion]] forHTTPHeaderField:@"User-Agent"];
		request.HTTPShouldHandleCookies=NO;
		[NSURLConnection connectionWithRequest:request delegate:self];
		delegate=delegate1;
		selector=selector1;
	}
	return self;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[output appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSError *err=nil;
	NSDictionary *json=output?[objc_getClass("NSJSONSerialization") JSONObjectWithData:output options:0 error:&err]:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-2] forKey:@"error"];
	[delegate performSelector:selector withObject:err?[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-1] forKey:@"error"]:json];
	[output release];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[delegate performSelector:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-2],@"error",[error localizedDescription],@"errormsg",nil]];
}
@end
