#import <objc/runtime.h>
#include <sys/utsname.h>
#import "ICGlobal.h"
#import "ICChatRequest.h"
#import "ICRequest.h"
#import "ICApplication.h"

static NSMutableData *output;

@implementation ICChatRequest
+(ICChatRequest *)requestWithDelegate:(id)delegate selector:(SEL)selector errorSelector:(SEL)errorSelector{
	return [[self alloc]initWithDelegate:delegate selector:selector errorSelector:errorSelector];
}
-(ICChatRequest *)initWithDelegate:(id)delegate1 selector:(SEL)selector1 errorSelector:(SEL)errorSelector1{
	self=(ICChatRequest *)[super initWithPage:@"stream" parameters:nil alpha:[(ICApplication *)[UIApplication sharedApplication]userIsOnAlpha] delegate:delegate1 selector:errorSelector1];
	messageSelector=selector1;
	return self;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSString *out=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
	if([out isEqualToString:@""])return;
	NSError *err=nil;
	NSDictionary *json=output?[objc_getClass("NSJSONSerialization") JSONObjectWithData:output options:0 error:&err]:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-2] forKey:@"error"];
	[delegate performSelector:messageSelector withObject:err?[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-1] forKey:@"error"]:json];
	[output release];
}
@end
