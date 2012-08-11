#import "ICGlobal.h"
#import "ICRequest.h"
#import "ICChatRequestParser.h"
#import "ICApplication.h"

@implementation ICChatRequestParser
-(void)parseResponse:(NSDictionary *)json{
	//...
}
-(void)receivedResponse:(NSDictionary *)json{
	NSLog(@"got data = %@",json);
	/*if(![json objectForKey:@"type"])return;
	else if([[json objectForKey:@"type"]isEqualToString:@"oob_include"])ICRequest *oobrequest=[ICRequest requestWithPage:[[json objectForKey:@"url"]stringByReplacingOccurrencesOfString:@"/chat/" withString:@""] parameters:nil delegate:self selector:@selector(receivedOOBResponse:)];
	else [self parseResponse:i];*/
}
-(void)receivedError:(id)json{
	NSLog(@"boom");
}
-(void)receivedOOBResponse:(id)json{
	/*if([json respondsToSelector:@selector(objectAtIndex:)])for(NSDictionary *i in json)[self parseResponse:i];
		if([[i objectForKey:@"type"]isEqualToString:@"makeserver"])[ICApp addServer:i];
		else if([[i objectForKey:@"type"]isEqualToString:@"makebuffer"])[ICApp addBuffer:i];
		else if([[i objectForKey:@"type"]isEqualToString:@"channelinit"])[ICApp addChannel:i];
		else [self parseResponse:i];
	}*/
}
@end
