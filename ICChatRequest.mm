#import <objc/runtime.h>
#include <sys/utsname.h>
#import "ICGlobal.h"
#import "ICChatRequest.h"
#import "ICRequest.h"
#import "ICApplication.h"

static NSMutableString *output;

@implementation ICChatRequest
@synthesize connected;
+(ICChatRequest *)requestWithDelegate:(id)delegate selector:(SEL)selector errorSelector:(SEL)errorSelector{
	return [[self alloc]initWithDelegate:delegate selector:selector errorSelector:errorSelector];
}
-(ICChatRequest *)initWithDelegate:(id)delegate1 selector:(SEL)messageSelector1 errorSelector:(SEL)errorSelector1{
	if((self=[self initWithPage:@"stream" parameters:@"" delegate:delegate1 selector:errorSelector1])){ //requires le GO_EASY_ON_ME=1
		delegate=delegate1;
		messageSelector=messageSelector1;
		errorSelector=errorSelector1;
		output=[[NSMutableString alloc]init];
	}
	return self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)err{
	NSLog(@"fail :(");
	self.connected=NO;
	[delegate performSelector:errorSelector withObject:err];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	[self connection:connection didFailWithError:[NSError errorWithDomain:@"ICChatRequestFinishedLoadingError" code:1 userInfo:nil]];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSString *out=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"message! %@",out);
	if([out isEqualToString:@""]||[out rangeOfString:@"\n"].location==NSNotFound){
		[output appendString:out];
		return;
	}
	NSLog(@"string = %@",output);
	NSString *outcp=[output copy];
	NSArray *split=[outcp componentsSeparatedByString:@"\n"];
	for(NSString *i in split)[self parseData:i];
	output=[[NSMutableString alloc]init];
}
-(void)parseData:(NSString *)data{
	NSError *err=nil;
	NSDictionary *json=data?[objc_getClass("NSJSONSerialization") JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err]:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-2] forKey:@"error"];
	if(err)[delegate performSelector:errorSelector withObject:err];
	else [delegate performSelector:messageSelector withObject:json];
}
@end
