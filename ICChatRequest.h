#import "ICRequest.h"
#import "lib/WebSocket.h"


@interface ICChatRequest:NSObject<WebSocketDelegate>{
	id delegate;
	SEL messageSelector;
	SEL errorSelector;
	BOOL connected;
	WebSocket *webSocket;
}
-(ICChatRequest *)initWithDelegate:(id)delegate selector:(SEL)selector errorSelector:(SEL)errorSelector;
@property(assign) BOOL connected;
@property(nonatomic,retain) WebSocket *webSocket;
@end
