#import "ICRequest.h"

@interface ICChatRequest:ICRequest{
	SEL messageSelector;
	SEL errorSelector;
	BOOL connected;
}
+(ICChatRequest *)requestWithDelegate:(id)delegate selector:(SEL)selector errorSelector:(SEL)errorSelector;
-(ICChatRequest *)initWithDelegate:(id)delegate selector:(SEL)selector errorSelector:(SEL)errorSelector;
-(void)parseData:(NSString *)data;
@property(assign) BOOL connected;
@end
