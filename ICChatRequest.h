#import "ICRequest.h"

@interface ICChatRequest:ICRequest{
	SEL messageSelector;
}
+(ICChatRequest *)requestWithDelegate:(id)delegate selector:(SEL)selector errorSelector:(SEL)errorSelector;
-(ICChatRequest *)initWithDelegate:(id)delegate selector:(SEL)selector errorSelector:(SEL)errorSelector;
@end
